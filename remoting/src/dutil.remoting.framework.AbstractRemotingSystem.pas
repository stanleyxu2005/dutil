(**
 * $Id: dutil.remoting.framework.AbstractRemotingSystem.pas 804 2014-04-30 15:33:25Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.framework.AbstractRemotingSystem;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  dutil.remoting.transport.Transport,
  dutil.remoting.transport.Pdu,
  dutil.remoting.rpc.Serializer,
  dutil.remoting.framework.Handler;

type
  /// <summary>This remoting system provides a way to create data, which can be shared between different processes. The
  /// system serves as a thread, which reads PDU (protocol data units) from a transport resource continuously. A PDU
  /// will be dispatched to corresponding RPC object (if there is any) and will be handled in another thread, so that 
  /// the reading will not be blocked. Handles responses will be written back to the transport resource.</summary>
  TAbstractRemotingSystem = class(TThread)
  private
    FLock: TCriticalSection;
    FSerializer: ISerializer;
    FHandlerLookup: TDictionary<string, IHandler>;
  protected
    property Serializer: ISerializer read FSerializer;
    procedure Execute; override;
    function Filtered(const Pdu: TPdu): Boolean; virtual;
    function GetTransport: ITransport; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
  public
    /// <summary>Returns the communication entry point of the remoting sytem</summary>
    function GetUri: string;
    /// <summary>Adds a handler.</summary>
    /// <exception cref="EDuplicateElementException">Specified handler exists already.</exception>
    procedure Add(const Handler: IHandler);
    /// <summary>Ensures a specified handler is removed.</summary>
    procedure Remove(const Id: string);
  protected
    /// <summary>Indicates whether a specified handler exists.</summary>
    function Exists(const Id: string): Boolean;
    /// <summary>Returns a specified handler interface.</summary>
    function Get(const Id: string): IHandler;
  end;

implementation

uses
{$IFDEF LOGGING}
  Log4D,
{$ENDIF}
  System.SysUtils,
  dutil.core.Exception,
  dutil.remoting.rpc.jsonrpc.SerializerImpl;

constructor TAbstractRemotingSystem.Create;
begin
  inherited Create({CreateSuspended=}True);
  NameThreadForDebugging(ClassName, ThreadID);

  FSerializer := TSerializerImpl.Create; // This is currently the only one data serializer
  assert(TSerializerImpl.InheritsFrom(TInterfacedObject));
  FLock := TCriticalSection.Create;
  FHandlerLookup := TDictionary<string, IHandler>.Create;
end;

destructor TAbstractRemotingSystem.Destroy;
begin
  FLock.Acquire;
  try
    FHandlerLookup.Free;
  finally
    FLock.Release;
  end;
  FLock.Free;
  FSerializer := nil;

  inherited;
end;

procedure TAbstractRemotingSystem.Execute;
var
  Pdu: TPdu;
  RPCObject: IHandler;
{$IFDEF LOGGING}
  LOG: TLogLogger;
{$ENDIF}
begin
  NameThreadForDebugging(Format('dco.system <%s>', [GetTransport.GetUri]));

  {$IFDEF LOGGING}
  LOG := TLogLogger.GetLogger(ClassName);
  LOG.Info(Format('''%s'' starts to receive messages and to send responses, until a poison pill is eaten',
      [GetTransport.GetUri]));
  {$ENDIF}

  try
    Pdu := GetTransport.Read;
    while not POISON_PILL.Equals(Pdu) do
    begin
      if not Filtered(Pdu) then
      begin
        RPCObject := Get(Pdu.Recipient);
        if RPCObject <> nil then
          RPCObject.Write(Pdu.Message_)
        {$IFDEF LOGGING}
        else
          LOG.Warn(Format('Unknown recipient: ''%s''', [Pdu.Recipient]));
        {$ENDIF}
      end;
      Pdu := GetTransport.Read;
    end;
  finally
    {$IFDEF LOGGING}
    LOG.Info(Format('''%s'' shut down', [GetTransport.GetUri]));
    {$ENDIF}
  end;
end;

function TAbstractRemotingSystem.Filtered(const Pdu: TPdu): Boolean;
begin
  Result := False;
end;

function TAbstractRemotingSystem.GetUri: string;
begin
  Result := GetTransport.GetUri;
end;

procedure TAbstractRemotingSystem.Add(const Handler: IHandler);
begin
  assert(Handler <> nil);

  if Exists(Handler.GetId) then
    raise EDuplicateElementException.Create(Format('Duplicated handler ''%s''', [Handler.GetId]));

  FLock.Acquire;
  try
    FHandlerLookup.Add(Handler.GetId, Handler);
  finally
    FLock.Release;
  end;
end;

procedure TAbstractRemotingSystem.Remove(const Id: string);
begin
  if not Exists(Id) then
    Exit;

  FLock.Acquire;
  try
    FHandlerLookup.Remove(Id);
  finally
    FLock.Release;
  end;
end;

function TAbstractRemotingSystem.Exists(const Id: string): Boolean;
begin
  FLock.Acquire;
  try
    Result := FHandlerLookup.ContainsKey(Id);
  finally
    FLock.Release;
  end;
end;

function TAbstractRemotingSystem.Get(const Id: string): IHandler;
begin
  if not Exists(Id) then
    Exit(nil);

  FLock.Acquire;
  try
    Result := FHandlerLookup.Items[Id];
  finally
    FLock.Release;
  end;
end;

end.
