(**
 * $Id: dutil.remoting.framework.RemotingSystem.pas 813 2014-05-08 15:08:01Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.framework.RemotingSystem;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.SyncObjs,
  dutil.remoting.transport.Transport,
  dutil.remoting.transport.Pdu,
  dutil.remoting.rpc.Serializer,
  dutil.remoting.framework.Handler,
  dutil.remoting.framework.RPCObjectImpl;

type
  /// <summary>This remoting system provides a way to create data, which can be shared between different processes. The
  /// system takes PDUs (protocol data units) from a transport resource continuously. PDU will be dispatched to 
  /// corresponding RPC object (if there is any) and will be handled sequentially in another thread. Handled responses 
  /// will be written back to the transport resource.</summary>
  TRemotingSystem = class(TThread)
  private
    FSerializer: ISerializer;
    FTransport: ITransport;
    FLock: TCriticalSection;
    FHandlerLookup: TDictionary<string, IHandler>;
    FReservationLookup: TDictionary<string, string>;
  protected
    procedure Execute; override;
  public
    constructor Create(const Transport: ITransport); reintroduce; overload;
    constructor Create(const Transport: ITransport; const Serializer: ISerializer); reintroduce; overload;
    destructor Destroy; override;
    /// <summary>Returns the communication entry point of the remoting sytem</summary>
    function GetUri: string;
    /// <summary>Adds a handler.</summary>
    /// <exception cref="EDuplicateElementException">Specified handler exists already.</exception>
    procedure Add(const Handler: IHandler);
    /// <summary>Ensures a specified handler is removed.</summary>
    procedure Remove(const Id: string);
    /// <summary>Indicates whether a specified handler exists.</summary>
    function Exists(const Id: string): Boolean;
    /// <summary>Returns a specified handler interface.</summary>
    function Get(const Id: string): IHandler;

  // In case of that the system does not know the uri of a remote peer, we aquire a reserved local uri and wait for a 
  // handshake for the remote peer.
  private
    function Filtered(const Pdu: TPdu): Boolean;
    /// <exception cref="EOutOfResources">No more resource available.</exception>
    function AquireFreeUri: string;
    /// <exception cref="EOutOfResources">No more resource available.</exception>
    function CreateAndAdd(const LocalUri: string; const RemoteUri: string): TRPCObjectImpl; overload;
  public
    /// <summary>Returns an uri that remote should communicate with.</summary>
    /// <exception cref="EOutOfResources">No more resource available.</exception>
    function ExpectHandshake: string;
    /// <summary>Returns the instance of RPC object or nil.</summary>
    function Handshaked(const LocalUri: string): TRPCObjectImpl;
    /// <summary>Creates an instance of RPC object (implments IExecutor and IHandler)</summary>
    /// <exception cref="EOutOfResources">No more resource available.</exception>
    function CreateAndAdd(const RemoteUri: string): TRPCObjectImpl; overload;
  end;

implementation

uses
{$IFDEF LOGGING}
  Log4D,
{$ENDIF}
  System.SysUtils,
  dutil.core.Exception,
  dutil.remoting.rpc.jsonrpc.SerializerImpl,
  dutil.remoting.transport.ConnectionImpl,
  dutil.remoting.transport.Uri;

constructor TRemotingSystem.Create(const Transport: ITransport);
begin
  assert(TSerializerImpl.InheritsFrom(TInterfacedObject));
  Create(Transport, TSerializerImpl.Create);
end;

constructor TRemotingSystem.Create(const Transport: ITransport; const Serializer: ISerializer);
begin
  assert(Transport <> nil);
  assert(Serializer <> nil);

  inherited Create({CreateSuspended=}True);
  NameThreadForDebugging(ClassName, ThreadID);

  FSerializer := Serializer;
  FTransport := Transport;
  FLock := TCriticalSection.Create;
  FHandlerLookup := TDictionary<string, IHandler>.Create;
  FReservationLookup := TDictionary<string, string>.Create;
end;

destructor TRemotingSystem.Destroy;
begin
  FLock.Acquire;
  try
    FReservationLookup.Free;
    FHandlerLookup.Free;
  finally
    FLock.Release;
  end;
  FLock.Free;

  FTransport.ForceRead(POISON_PILL);
  WaitFor; // Makes sure the transport is stopped
  FTransport := nil;

  FSerializer := nil;

  inherited;
end;

procedure TRemotingSystem.Execute;
var
  Pdu: TPdu;
  RPCObject: IHandler;
{$IFDEF LOGGING}
  LOG: TLogLogger;
{$ENDIF}
begin
  NameThreadForDebugging(Format('dco.system <%s>', [GetUri]));

  {$IFDEF LOGGING}
  LOG := TLogLogger.GetLogger(ClassName);
  LOG.Info(Format('''%s'' starts to receive messages and to send responses, until a poison pill is eaten', [GetUri]));
  {$ENDIF}

  Pdu := FTransport.Read;
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
    Pdu := FTransport.Read;
  end;

  {$IFDEF LOGGING}
  LOG.Info(Format('''%s'' shut down', [GetUri]));
  {$ENDIF}
end;

function TRemotingSystem.GetUri: string;
begin
  Result := FTransport.GetUri;
end;

procedure TRemotingSystem.Add(const Handler: IHandler);
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

procedure TRemotingSystem.Remove(const Id: string);
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

function TRemotingSystem.Exists(const Id: string): Boolean;
begin
  FLock.Acquire;
  try
    Result := FHandlerLookup.ContainsKey(Id);
  finally
    FLock.Release;
  end;
end;

function TRemotingSystem.Get(const Id: string): IHandler;
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

function TRemotingSystem.Filtered(const Pdu: TPdu): Boolean;
begin
  Result := False;
  FLock.Acquire;
  try
    if FReservationLookup.ContainsKey(Pdu.Recipient) then
    begin
      FReservationLookup.Items[Pdu.Recipient] := Pdu.Sender;
      // As long as it is not removed from reservation list, messages will be filtered.
      Result := True;
    end;
  finally
    FLock.Release;
  end;
end;

function TRemotingSystem.ExpectHandshake: string;
begin
  FLock.Acquire;
  try
    Result := AquireFreeUri;
    FReservationLookup.Add(Result, '');
  finally
    FLock.Release;
  end;
end;

function TRemotingSystem.AquireFreeUri: string;
var
  I: Cardinal;
begin
  FLock.Acquire;
  try
    for I := 1 to High(Cardinal) do
    begin
      Result := TUri.Create(GetUri, I).ToString;
      if not Exists(Result) and not FReservationLookup.ContainsKey(Result) then
        Exit;
    end;
  finally
    FLock.Release;
  end;

  raise EOutOfResources.Create('No more free resource id available');
end;

function TRemotingSystem.Handshaked(const LocalUri: string): TRPCObjectImpl;
var
  RemoteUri: string;
begin
  assert(LocalUri <> '');

  Result := nil;
  FLock.Acquire;
  try
    if FReservationLookup.ContainsKey(LocalUri) then
    begin
      RemoteUri := FReservationLookup.Items[LocalUri];
      if RemoteUri <> '' then
      begin
        FReservationLookup.Remove(LocalUri);
        Result := CreateAndAdd(LocalUri, RemoteUri);
      end;
    end;
  finally
    FLock.Release;
  end;
end;

function TRemotingSystem.CreateAndAdd(const LocalUri: string; const RemoteUri: string): TRPCObjectImpl;
var
  Connection: TConnectionImpl;
begin
  assert(TConnectionImpl.InheritsFrom(TInterfacedObject));
  Connection := TConnectionImpl.Create(FTransport, LocalUri, RemoteUri);

  Result := TRPCObjectImpl.Create(Connection, FSerializer);
  Add(Result);
end;

function TRemotingSystem.CreateAndAdd(const RemoteUri: string): TRPCObjectImpl;
var
  LocalUri: string;
begin
  FLock.Acquire;
  try
    LocalUri := AquireFreeUri;
    Result := CreateAndAdd(LocalUri, RemoteUri);
  finally
    FLock.Release;
  end;
end;

end.
