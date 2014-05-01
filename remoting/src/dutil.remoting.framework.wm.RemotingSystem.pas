(**
 * $Id: dutil.remoting.framework.wm.RemotingSystem.pas 806 2014-05-01 04:57:21Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.framework.wm.RemotingSystem;

interface

uses
  System.Generics.Collections,
  System.SyncObjs,
  dutil.remoting.transport.Pdu,
  dutil.remoting.transport.Transport,
  dutil.remoting.transport.wm.TransportImpl,
  dutil.remoting.framework.AbstractRemotingSystem,
  dutil.remoting.framework.RPCObjectImpl;

type
  /// <summary>This class provides a way to create data which can be shared between different processes by using
  /// Windows messaging (WM_COPYDATA).</summary>
  TRemotingSystem = class(TAbstractRemotingSystem)
  private
    FTransport: TTransportImpl;
    /// <exception cref="EOutOfResources">No more resource available.</exception>
    function AquireFreeUri(Secret: Word): string;
    /// <exception cref="EOutOfResources">No more resource available.</exception>
    function CreateAndAdd(const LocalUri: string; const RemoteUri: string): TRPCObjectImpl; overload;
  protected
    function GetTransport: ITransport; override;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>Creates an instance of RPC object (implments IExecutor and IHandler)</summary>
    /// <exception cref="EOutOfResources">No more resource available.</exception>
    function CreateAndAdd(Secret: Word; const RemoteUri: string): TRPCObjectImpl; overload;

  // For Windows messaging the uri of a RPC object requires the window handle of transport resource. When the remote
  // system is still not setup, the window handle of the remote transport is still unknown. In order to establish the
  // connection, we aquire a reserved local uri and wait for a handshake for the remote peer.
  private
    FLock: TCriticalSection;
    FReservationLookup: TDictionary<string, string>;
  protected
    function Filtered(const Pdu: TPdu): Boolean; override;
  public
    /// <summary>Returns the instance of RPC object or nil.</summary>
    function Handshaked(const LocalUri: string): TRPCObjectImpl;
    /// <summary>Returns an uri that remote should communicate with.</summary>
    /// <exception cref="EOutOfResources">No more resource available.</exception>
    function ExpectHandshake(Secret: Word): string;
  end;

implementation

uses
  System.Classes,
  dutil.remoting.transport.ConnectionImpl,
  dutil.remoting.transport.wm.WMUri;

constructor TRemotingSystem.Create;
begin
  inherited Create;

  FTransport := TTransportImpl.Create;
  FLock := TCriticalSection.Create;
  FReservationLookup := TDictionary<string, string>.Create;
end;

destructor TRemotingSystem.Destroy;
begin
  FTransport.Shutdown;

  FLock.Acquire;
  try
    FReservationLookup.Free;
  finally
    FLock.Release;
  end;
  FLock.Free;

  inherited;

  // As it might still be used by the super class, we free it at the end.
  FTransport := nil;
end;

function TRemotingSystem.GetTransport: ITransport;
begin
  Result := FTransport;
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

function TRemotingSystem.ExpectHandshake(Secret: Word): string;
begin
  FLock.Acquire;
  try
    Result := AquireFreeUri(Secret);
    FReservationLookup.Add(Result, '');
  finally
    FLock.Release;
  end;
end;

function TRemotingSystem.AquireFreeUri(Secret: Word): string;
var
  I: Word;
begin
  FLock.Acquire;
  try
  for I := 1 to High(Word) do
  begin
    Result := TWMUri.Encode(FTransport.GetUri, I, Secret).ToString;
    if not Exists(Result) and not FReservationLookup.ContainsKey(Result) then
      Exit;
  end;
  finally
    FLock.Release;
  end;

  raise EOutOfResources.Create('No more free resource id available');
end;

function TRemotingSystem.CreateAndAdd(const LocalUri: string; const RemoteUri: string): TRPCObjectImpl;
var
  Connection: TConnectionImpl;
begin
  Connection := TConnectionImpl.Create(GetTransport, LocalUri, RemoteUri);
  assert(TConnectionImpl.InheritsFrom(TInterfacedObject));

  Result := TRPCObjectImpl.Create(Connection, Serializer);
  Add(Result);
end;

function TRemotingSystem.CreateAndAdd(Secret: Word; const RemoteUri: string): TRPCObjectImpl;
var
  LocalUri: string;
begin
  FLock.Acquire;
  try
    LocalUri := AquireFreeUri(Secret);
    Result := CreateAndAdd(LocalUri, RemoteUri);
  finally
    FLock.Release;
  end;
end;

end.
