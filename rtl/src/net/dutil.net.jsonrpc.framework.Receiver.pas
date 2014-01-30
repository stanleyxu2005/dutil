(**
 * $Id: dutil.net.jsonrpc.framework.Receiver.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.jsonrpc.framework.Receiver;

interface

uses
  SyncObjs,
  TimeSpan,
  superobject { An universal object serialization framework with Json support },
  dutil.core.NonRefCountedInterfacedObject,
  dutil.net.jsonrpc.framework.Backlog,
  dutil.net.jsonrpc.framework.NotificationHandler,
  dutil.net.jsonrpc.framework.RequestHandler,
  dutil.net.jsonrpc.message.Error,
  dutil.net.jsonrpc.message.Handler,
  dutil.net.jsonrpc.message.Identifier,
  dutil.util.concurrent.BlockingQueue;

type
  /// <summary>The responsibility of this boundary class is to take inbound messages from the specified input queue
  /// and to process requests and notifications using the corresponding handlers or to put responses into containers
  /// retrieved from the specified backlog.</summary>
  TReceiver = class(TNonRefCountedInterfacedObject, IHandler)
  private
    FLock: TCriticalSection;
    FPeer: string;
    FInput: TBlockingQueue<string>;
    FOutput: TBlockingQueue<string>;
    FBacklog: TBacklog;
    FRequestHandler: IRequestHandler;
    FNotificationHandler: INotificationHandler;
    FConnected: Boolean;
    FTimeToHandleTimeout: TDateTime;
  public
    constructor Create(const Peer: string; Input: TBlockingQueue<string>; Output: TBlockingQueue<string>;
      Backlog: TBacklog; RequestHandler: IRequestHandler; NotificationHandler: INotificationHandler);
    destructor Destroy; override;
    procedure Run;
    procedure HandleRequest(const Method: string; const Params: ISuperObject; const Id: TIdentifier);
    procedure HandleNotification(const Method: string; const Params: ISuperObject);
    procedure HandleResponse(const Result: ISuperObject; const Id: TIdentifier); overload;
    procedure HandleResponse(Error: EError; const Id: TIdentifier); overload;
  private
    procedure Handle(const Message_: string);
    procedure HandleDisconnect;
    procedure Send(const Message_: string);
  private
    FKeepAlivePeriod: TTimeSpan;
    procedure ResetTimeout;
    procedure RemoveTimeout;
    procedure HandleTimeout;
  public
    procedure Monitor(const KeepAlivePeriod: TTimeSpan);
  end;

implementation

uses
{$IFDEF LOGGING}
  Log4D,
  SysUtils,
  dutil.text.json.Json,
{$ENDIF}
  dutil.core.Exception,
  dutil.net.jsonrpc.message.Decoder,
  dutil.net.jsonrpc.message.Encoder,
  dutil.net.jsonrpc.message.JsonRpcException,
  dutil.util.concurrent.Result,
  dutil.util.concurrent.Timer;

constructor TReceiver.Create(const Peer: string; Input: TBlockingQueue<string>; Output: TBlockingQueue<string>;
  Backlog: TBacklog; RequestHandler: IRequestHandler; NotificationHandler: INotificationHandler);
begin
  assert(Input <> nil);
  assert(Output <> nil);
  assert(Backlog <> nil);
  inherited Create;

  FLock := TCriticalSection.Create;
  FPeer := Peer;
  FInput := Input;
  FOutput := Output;
  FBacklog := Backlog;
  FRequestHandler := RequestHandler;
  FNotificationHandler := NotificationHandler;
  FConnected := True;
  FKeepAlivePeriod := TTimeSpan.Zero;
end;

destructor TReceiver.Destroy;
begin
  assert(not FConnected);

  FNotificationHandler := nil;
  FRequestHandler := nil;
  FBacklog := nil;
  FOutput := nil;
  FInput := nil;
  FLock.Free;
  FLock := nil;

  inherited;
end;

procedure TReceiver.Run;
var
  Message_: string;
begin
{$IFDEF LOGGING}
  TLogLogger.GetLogger(ClassName).Info(Format('Connected to %s', [FPeer]));
{$ENDIF}
  try
    Message_ := FInput.Take;

    while Message_ <> '' do
    begin
      Handle(Message_);
      Message_ := FInput.Take;
    end;
  finally
    HandleDisconnect;
{$IFDEF LOGGING}
    TLogLogger.GetLogger(ClassName).Info(Format('Disconnected from %s', [FPeer]));
{$ENDIF}
  end;
end;

procedure TReceiver.Handle(const Message_: string);
begin
  ResetTimeout;

{$IFDEF LOGGING}
  TLogLogger.GetLogger(ClassName).Trace(Format('<-%s: %s', [FPeer, Message_]));
{$ENDIF}
  try
    TDecoder.Decode(Message_, {Handler=}Self);
  except
    on E: EJsonRpcException do
    begin
{$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Error(Format('%s Stop receiving further messages', [FPeer]), E);
{$ENDIF}
      if E.Id.Valid then
        Send(TEncoder.EncodeResponse(E.Error, E.Id));
      FOutput.Put(''); // poison pill
    end;
  end;
end;

procedure TReceiver.HandleRequest(const Method: string; const Params: ISuperObject; const Id: TIdentifier);
var
  Result: ISuperObject;
begin
  assert((Params = nil) or (Params.DataType in [TSuperType.stArray, TSuperType.stObject]));
  assert(Id.Valid);

  if FRequestHandler = nil then
  begin
{$IFDEF LOGGING}
    TLogLogger.GetLogger(ClassName).Error(Format('%s Rejected unhandled request (method="%s", params=%s, id="%s")',
        [FPeer, Method, TJson.Print(Params), Id.ToString]));
{$ENDIF}
    Send(TEncoder.EncodeResponse(EError.CreateMethodNotFound('No handler available'), Id));
    Exit;
  end;

  try
    Result := FRequestHandler.HandleRequest(Method, Params); // throws EError
    Send(TEncoder.EncodeResponse(Result, Id));
  except
    on E: EError do
    begin
      Send(TEncoder.EncodeResponse(E, Id));
    end;
  end;
end;

procedure TReceiver.HandleNotification(const Method: string; const Params: ISuperObject);
begin
  assert((Params = nil) or (Params.DataType in [TSuperType.stArray, TSuperType.stObject]));

  if FNotificationHandler = nil then
  begin
{$IFDEF LOGGING}
    TLogLogger.GetLogger(ClassName).Warn(Format('%s Ignored unhandled notification (method="%s", params=%s)',
        [FPeer, Method, TJson.Print(Params)]));
{$ENDIF}
    Exit;
  end;

  FNotificationHandler.HandleNotification(Method, Params)
end;

procedure TReceiver.HandleResponse(const Result: ISuperObject; const Id: TIdentifier);
var
  ResultContainer: TResult<ISuperObject>;
begin
  assert(Id.Valid);

  try
    ResultContainer := FBacklog.Take(Id); // throws EJsonException
    if ResultContainer = nil then
    begin
{$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Warn(Format('%s Ignored unexpected response (result="%s", id="%s")',
          [FPeer, TJson.Print(Result), Id.ToString]));
{$ENDIF}
      Exit;
    end;

    ResultContainer.Put(Result);
  except
    on EJsonException do
    begin
{$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Warn(Format('%s Ignored response with unsupported id (result="%s", id="%s")',
          [FPeer, TJson.Print(Result), Id.ToString]));
{$ENDIF}
    end;
  end;
end;

procedure TReceiver.HandleResponse(Error: EError; const Id: TIdentifier);
var
  ResultContainer: TResult<ISuperObject>;
begin
  assert(Error <> nil);
  assert(Id.Valid);

  try
    ResultContainer := FBacklog.Take(Id);
    if ResultContainer = nil then
    begin
{$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Warn(Format('%s Ignored unexpected response (id="%s")', [FPeer, Id.ToString]), Error);
{$ENDIF}
      Exit;
    end;

    ResultContainer.PutException(EJsonRpcException.Create(Error, Id));
  except
    on EJsonException do
    begin
{$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Warn(Format('%s Ignored response with unsupported id (id="%s")',
          [FPeer, Id.ToString]), Error);
{$ENDIF}
    end;
  end;
end;

procedure TReceiver.HandleDisconnect;
begin
  FLock.Acquire;
  try
    FConnected := False;
    ResetTimeout;
  finally
    FLock.Release;
  end;
  FBacklog.Close;
end;

procedure TReceiver.Send(const Message_: string);
begin
{$IFDEF LOGGING}
  TLogLogger.GetLogger(ClassName).Trace(Format('->%s: %s', [FPeer, Message_]));
{$ENDIF}
  FOutput.Put(Message_);
end;

procedure TReceiver.Monitor(const KeepAlivePeriod: TTimeSpan);
begin
  FLock.Acquire;
  try
    FKeepAlivePeriod := KeepAlivePeriod;
    ResetTimeout;
  finally
    FLock.Release;
  end;
end;

procedure TReceiver.ResetTimeout;
var
  GracePeriod: TTimeSpan;
begin
  FLock.Acquire;
  try
    RemoveTimeout;
    if FConnected and (FKeepAlivePeriod > TTimeSpan.Zero) then
    begin
      GracePeriod := TTimeSpan.Create(FKeepAlivePeriod.Ticks div 10);
      FTimeToHandleTimeout := TTimer.Schedule(FKeepAlivePeriod + GracePeriod, HandleTimeout);
    end;
  finally
    FLock.Release;
  end;
end;

procedure TReceiver.RemoveTimeout;
const
  NO_TIMER_SCHEDULED = 0;
begin
  FLock.Acquire;
  try
    if FTimeToHandleTimeout <> NO_TIMER_SCHEDULED then
    begin
      TTimer.Remove(FTimeToHandleTimeout);
      FTimeToHandleTimeout := NO_TIMER_SCHEDULED;
    end;
  finally
    FLock.Release;
  end;
end;

procedure TReceiver.HandleTimeout;
begin
{$IFDEF LOGGING}
  TLogLogger.GetLogger(ClassName).Error(Format('Peer %s is assumed to be dead', [FPeer]));
{$ENDIF}
  FOutput.Put(''); // poison pill
end;

end.
