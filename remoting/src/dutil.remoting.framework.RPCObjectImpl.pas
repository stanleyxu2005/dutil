(**
 * $Id: dutil.remoting.framework.RPCObjectImpl.pas 800 2014-04-30 07:18:42Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.framework.RPCObjectImpl;

interface

uses
  System.Generics.Collections,
  System.SyncObjs,
  System.TimeSpan,
  superobject { An universal object serialization framework with Json support },
  dutil.util.concurrent.BlockingQueue,
  dutil.remoting.rpc.ErrorObject,
  dutil.remoting.rpc.Identifier,
  dutil.remoting.rpc.RPCHandler,
  dutil.remoting.rpc.Serializer,
  dutil.remoting.transport.Connection,
  dutil.remoting.framework.Backlog,
  dutil.remoting.framework.Command,
  dutil.remoting.framework.Executor,
  dutil.remoting.framework.Handler,
  dutil.remoting.util.ThreadedConsumer;

type
  /// <summary>This class implements a remote object.</summary>
  TRPCObjectImpl = class(TInterfacedObject, IExecutor, IHandler, IRPCHandler)
  private
    FConnection: IConnection;
    FSerializer: ISerializer;
    FBacklog: TBacklog;
  public
    constructor Create(const Connection: IConnection; const Serializer: ISerializer);
    destructor Destroy; override;

  // Handler related
  private
    FLock: TCriticalSection;
    FHandlingThread: TThreadedConsumer<string>;
    FHandlingQueue: TBlockingQueue<string>;
    FNotificationHandlerLookup: TDictionary<string, THandleNotificationMethod>;
    FRequestHandlerLookup: TDictionary<string, THandleRequestMethod>;
    procedure HandleRequest(const Method: string; const Params: ISuperObject; const Id: TIdentifier);
    procedure HandleNotification(const Method: string; const Params: ISuperObject);
    procedure HandleResponse(const Result: ISuperObject; const Id: TIdentifier); overload;
    procedure HandleResponse(const Error: TErrorObject; const Id: TIdentifier); overload;
    procedure Handle(const Message_: string);
  public
    /// <summary>Returns the identifier of the object.</summary>
    function GetId: string;
    /// <summary>Pushs a protocol specific message to handling queue.</summary>
    procedure Write(const Message_: string);
    /// <summary>Registers a notification handler.</summary>
    procedure AddNotificationHandler(Command: TCommand.TClassReference; Method: THandleNotificationMethod);
    /// <summary>Registers a request handler.</summary>
    procedure AddRequestHandler(Command: TCommand.TClassReference; Method: THandleRequestMethod);

  // Executor releated
  public
    /// <summary>Exeuctes a command. The current thread is blocked until response is available.</summary>
    /// <exception cref="ERPCException">RPC error (typically network issue)</exception>
    function ExecuteAwait(Command: TCommand): ISuperObject; overload;
    /// <summary>Exeuctes a command. The current thread is blocked until response is available or timed out.</summary>
    /// <exception cref="ERPCException">RPC error (typically network issue)</exception>
    function ExecuteAwait(Command: TCommand; const Timeout: TTimeSpan): ISuperObject; overload;
    /// <summary>Sends a notification and then returns immediately without any delivery garantee.</summary>
    procedure Notify(Command: TCommand);
  end;

implementation

uses
{$IFDEF LOGGING}
  Log4D,
  dutil.text.json.Json,
{$ENDIF}
  System.DateUtils,
  System.SysUtils,
  Winapi.Windows,
  Vcl.Forms,
  dutil.core.Exception,
  dutil.util.concurrent.Result,
  dutil.remoting.rpc.RPCException;

constructor TRPCObjectImpl.Create(const Connection: IConnection; const Serializer: ISerializer);
begin
  assert(Connection <> nil);
  assert(Serializer <> nil);
  inherited Create;

  FConnection := Connection;
  FSerializer := Serializer;
  FBacklog := TBacklog.Create;

  FLock := TCriticalSection.Create;
  FNotificationHandlerLookup := TDictionary<string, THandleNotificationMethod>.Create;
  FRequestHandlerLookup := TDictionary<string, THandleRequestMethod>.Create;

  FHandlingQueue := TBlockingQueue<string>.Create;
  FHandlingThread := TThreadedConsumer<string>.Create(FHandlingQueue, Handle);
  FHandlingThread.NameThreadForDebugging(Format('dco.rpcobj.handler <%s>', [GetId]), FHandlingThread.ThreadID);
  FHandlingThread.Start;
end;

destructor TRPCObjectImpl.Destroy;
begin
  FHandlingThread.Free;
  // Accept no more request or notifications

  FLock.Acquire;
  try
    FRequestHandlerLookup.Free;
    FNotificationHandlerLookup.Free;
  finally
    FLock.Release;
  end;
  FLock.Free;

  FBacklog.Close;
  FBacklog.Free;

  FSerializer := nil;
  FConnection := nil;
  FHandlingQueue.Free;

  inherited;
end;

procedure TRPCObjectImpl.Write(const Message_: string);
begin
  // We have a background thread (per RPC object) to handle pushed messages. In order to ensure the execution order,
  // messages will be handled sequentially.
  FHandlingQueue.Put(Message_);
end;

procedure TRPCObjectImpl.Handle(const Message_: string);
begin
  assert(GetCurrentThreadId = FHandlingThread.ThreadID);

  try
    FSerializer.Decode(Message_, {Handler=}Self); // @throws ERPCException: In case of decoding specific error
  except
    on E: Exception do
    begin
      if E is ERPCException then
      begin
        if ERPCException(E).Id.Valid then
          // This will be the last response message
          FConnection.Write(FSerializer.EncodeResponse(ERPCException(E).Error, ERPCException(E).Id));
      end;
      // In case of any error, the connection will be terminated.
      {$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Error(Format('%s Stop receiving further messages: %s', [GetId, E.ToString]));
      {$ENDIF}
      FConnection.Write(''); // poison pill
    end;
  end;
end;

procedure TRPCObjectImpl.HandleRequest(const Method: string; const Params: ISuperObject; const Id: TIdentifier);
var
  Result: ISuperObject;
  Message_: string;
  Error: TErrorObject;
begin
  assert((Params = nil) or (Params.DataType in [TSuperType.stArray, TSuperType.stObject]));
  assert(Id.Valid);

  FLock.Acquire;
  try
    if not FRequestHandlerLookup.ContainsKey(Method) then
    begin
      {$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Error(Format('%s Rejected unhandled request (method="%s", params=%s, id="%s")',
          [GetId, Method, TJson.Print(Params), Id.ToString]));
      {$ENDIF}
      Message_ := FSerializer.EncodeResponse(TErrorObject.CreateMethodNotFound('No handler available'), Id);
    end
    else
    try
      FRequestHandlerLookup[Method](Params, Result); // @throws ERPCException
      Message_ := FSerializer.EncodeResponse(Result, Id);
    except
      on E: Exception do
      begin
        if E is EJsonException then
          Error := TErrorObject.CreateInvalidParams(E.ToString)
        else
          // Unexpected exception during invoking the method
          Error := TErrorObject.CreateInternalError(E.ToString);
        {$IFDEF LOGGING}
        TLogLogger.GetLogger(ClassName).Error(Format('Unhandled exception while handling request: %s\n%s',
            [Method, E.ToString]));
        {$ENDIF}
        Message_ := FSerializer.EncodeResponse(Error, Id);
      end;
    end;
  finally
    FLock.Release;
  end;

  FConnection.Write(Message_);
end;

procedure TRPCObjectImpl.HandleNotification(const Method: string; const Params: ISuperObject);
begin
  assert((Params = nil) or (Params.DataType in [TSuperType.stArray, TSuperType.stObject]));

  FLock.Acquire;
  try
    if not FNotificationHandlerLookup.ContainsKey(Method) then
    begin
      {$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Warn(Format('%s Ignored unhandled notification (method="%s", params=%s)',
          [GetId, Method, TJson.Print(Params)]));
      {$ENDIF}
    end
    else
    try
      FNotificationHandlerLookup[Method](Params);
    except
      {$IFDEF LOGGING}
      on E: Exception do
        TLogLogger.GetLogger(ClassName).Error(Format('Unhandled exception while handling notification: %s\n%s',
            [Method, E.ToString]));
      {$ENDIF}
    end;
  finally
    FLock.Release;
  end;
end;

procedure TRPCObjectImpl.HandleResponse(const Result: ISuperObject; const Id: TIdentifier);
var
  ResultContainer: TResult<ISuperObject>;
begin
  assert(Id.Valid);

  try
    ResultContainer := FBacklog.Take(Id); // @throws EJsonException
    if ResultContainer = nil then
    begin
    {$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Warn(Format('%s Ignored unexpected response (result="%s", id="%s")',
          [GetId, TJson.Print(Result), Id.ToString]));
    {$ENDIF}
      Exit;
    end;

    ResultContainer.Put(Result);
  except
    on EJsonException do
    begin
    {$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Warn(Format('%s Ignored response with unsupported id (result="%s", id="%s")',
          [GetId, TJson.Print(Result), Id.ToString]));
    {$ENDIF}
    end;
  end;
end;

procedure TRPCObjectImpl.HandleResponse(const Error: TErrorObject; const Id: TIdentifier);
var
  ResultContainer: TResult<ISuperObject>;
begin
  assert(Id.Valid);

  try
    ResultContainer := FBacklog.Take(Id); // @throws EJsonException
    if ResultContainer = nil then
    begin
    {$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Warn(Format('%s Ignored unexpected response (id="%s"): %s',
        [GetId, Id.ToString, Error.ToString]));
    {$ENDIF}
      Exit;
    end;

    ResultContainer.PutException(ERPCException.Create(Error, Id));
  except
    on EJsonException do
    begin
    {$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Warn(Format('%s Ignored response with unsupported id (id="%s"): %s',
        [GetId, Id.ToString, Error.ToString]));
    {$ENDIF}
    end;
  end;
end;

procedure TRPCObjectImpl.AddNotificationHandler(Command: TCommand.TClassReference; Method: THandleNotificationMethod);
begin
  assert(Command.Type_ = TCommand.TType.Notification);
  assert(Assigned(Method));

  FLock.Acquire;
  try
    if FNotificationHandlerLookup.ContainsKey(Command.Method_) then
      raise EDuplicateElementException.Create(
        Format('Notification handler has been registered already: %s', [Command.Method_]));

    FNotificationHandlerLookup.Add(Command.Method_, Method);
  finally
    FLock.Release;
  end;
end;

procedure TRPCObjectImpl.AddRequestHandler(Command: TCommand.TClassReference; Method: THandleRequestMethod);
begin
  assert(Command.Type_ = TCommand.TType.Request);
  assert(Assigned(Method));

  FLock.Acquire;
  try
    if FRequestHandlerLookup.ContainsKey(Command.Method_) then
      raise EDuplicateElementException.Create(
        Format('Request handler has been registered already: %s', [Command.Method_]));

    FRequestHandlerLookup.Add(Command.Method_, Method);
  finally
    FLock.Release;
  end;
end;

function TRPCObjectImpl.GetId: string;
begin
  Result := FConnection.GetId;
end;

function TRPCObjectImpl.ExecuteAwait(Command: TCommand): ISuperObject;
begin
  Result := ExecuteAwait(Command, TTimeSpan.FromSeconds(30));
end;

function TRPCObjectImpl.ExecuteAwait(Command: TCommand; const Timeout: TTimeSpan): ISuperObject;
var
  ResultContainer: TResult<ISuperObject>;
  Id: TIdentifier;
  Message_: string;
  Expiration: TDateTime;
begin
  assert(Command <> nil);
  assert(Command.Type_ = TCommand.TType.REQUEST);
  assert((Command.Params_ = nil) or (Command.Params_.DataType in [TSuperType.stArray, TSuperType.stObject]));

  ResultContainer := TResult<ISuperObject>.Create;
  try
    Id := FBacklog.Put(ResultContainer);
    Message_ := FSerializer.EncodeRequest(Command.Method_, Command.Params_, Id);

    if not FConnection.WriteEnsured(Message_) then
    begin
      FBacklog.TakeAndFailResult(Id);
      assert(ResultContainer.Available);
      // The result container has an exception now
    end
    else
    begin
      Expiration := IncMilliSecond(Now, Round(Timeout.TotalMilliseconds));
      while not ResultContainer.Available do
      begin
        if Expiration < Now then
        begin
          FBacklog.TakeAndFailResult(Id);
          assert(ResultContainer.Available);
          // The result container has an exception now
          Break;
        end;

        // CAUTION: Waiting for a result in the main thread is *EXTREMELY EXPENSIVE*. If the current execution context is 
        // in the main thread, we will call an idle callback periodically.
        if GetCurrentThreadId = System.MainThreadId then
        begin
          Application.ProcessMessages;
        end;
      end;
    end;

    Result := ResultContainer.Take;
  finally
    ResultContainer.Free;
  end;
end;

procedure TRPCObjectImpl.Notify(Command: TCommand);
var
  Message_: string;
begin
  assert(Command <> nil);
  assert(Command.Type_ = TCommand.TType.NOTIFICATION);
  assert((Command.Params_ = nil) or (Command.Params_.DataType in [TSuperType.stArray, TSuperType.stObject]));

  Message_ := FSerializer.EncodeNotification(Command.Method_, Command.Params_);
  FConnection.Write(Message_);
end;

end.
