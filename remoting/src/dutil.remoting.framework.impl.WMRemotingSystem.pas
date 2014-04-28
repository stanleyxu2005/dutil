(**
 * $Id: dutil.remoting.framework.impl.WMRemotingSystem.pas 795 2014-04-28 16:30:49Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.framework.impl.WMRemotingSystem;

interface

uses
  System.Generics.Collections,
  System.SyncObjs,
  dutil.remoting.transport.Pdu,
  dutil.remoting.transport.Transport,
  dutil.remoting.transport.impl.WMTransportImpl,
  dutil.remoting.framework.RemotingSystem,
  dutil.remoting.framework.impl.RPCObjectImpl;

type
  /// <summary>This class provides a way to create data which can be shared between different processes.</summary>
  TWMRemotingSystem = class(TRemotingSystem)
  private
    FTransport: TWMTransportImpl;
  protected
    function GetTransport: ITransport; override;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>Creates an instance of RPC object (implments IExecutor and IHandler)</summary>
    function CreateAndAdd(const LocalUri: string; const RemoteUri: string): TRPCObjectImpl;

  // Windows messaging requires message window handle of both peer. However when create a remote object, it might still
  // do not know the window handle of remote. We setup an interception to wait for an incoming handshake to obtain the
  // sender uri.
  private
    FLock: TCriticalSection;
    FFilteredLookup: TDictionary<string, string>;
  protected
    function Filtered(const Pdu: TPdu): Boolean; override;
  public
    /// <summary>Returns the instance of RPC object, if there is a match.</summary>
    function Handshaked(const LocalUri: string): TRPCObjectImpl;
    /// <summary>Filters inbound messages to the particular uri. Use toghether with Handshaked()</summary>
    procedure ExpectHandshake(const LocalUri: string);
    /// <summary>Returns the next free resource uri.</summary>
    /// <exception cref="EOutOfResources">No more resource available.</exception>
    function NextFreeResourceUri(Secret: Word): string;
  end;

implementation

uses
  System.Classes,
  dutil.remoting.transport.impl.ConnectionImpl,
  dutil.remoting.transport.impl.WMUri;

constructor TWMRemotingSystem.Create;
begin
  inherited Create;

  FLock := TCriticalSection.Create;
  FTransport := TWMTransportImpl.Create;
  FFilteredLookup := TDictionary<string, string>.Create;
end;

destructor TWMRemotingSystem.Destroy;
begin
  FTransport.ShutDown;

  FLock.Acquire;
  try
    FFilteredLookup.Free;
  finally
    FLock.Release;
  end;
  FLock.Free;

  inherited;

  // As it might still be used by the super class, we free it at the end.
  FTransport := nil;
end;

function TWMRemotingSystem.GetTransport: ITransport;
begin
  Result := FTransport;
end;

function TWMRemotingSystem.Filtered(const Pdu: TPdu): Boolean;
begin
  Result := False;
  FLock.Acquire;
  try
    if FFilteredLookup.ContainsKey(Pdu.Recipient) then
    begin
      FFilteredLookup.Items[Pdu.Recipient] := Pdu.Sender;
      Result := True;
    end;
  finally
    FLock.Release;
  end;
end;

function TWMRemotingSystem.Handshaked(const LocalUri: string): TRPCObjectImpl;
var
  RemoteUri: string;
begin
  Result := nil;
  FLock.Acquire;
  try
    if FFilteredLookup.ContainsKey(LocalUri) then
    begin
      RemoteUri := FFilteredLookup.Items[LocalUri];
      if RemoteUri <> '' then
      begin
        FFilteredLookup.Remove(LocalUri);
        Result := CreateAndAdd(LocalUri, RemoteUri);
      end;
    end;
  finally
    FLock.Release;
  end;
end;

procedure TWMRemotingSystem.ExpectHandshake(const LocalUri: string);
begin
  FLock.Acquire;
  try
    FFilteredLookup.Add(LocalUri, '');
  finally
    FLock.Release;
  end;
end;

function TWMRemotingSystem.NextFreeResourceUri(Secret: Word): string;
var
  I: Word;
begin
  for I := 1 to High(Word) do
  begin
    Result := TWMUri.CreateFromRootUri(FTransport.GetUri, I, Secret).ToString;
    if not Exists(Result) then
      Exit;
  end;

  raise EOutOfResources.Create('No more free resource id available');
end;

function TWMRemotingSystem.CreateAndAdd(const LocalUri: string; const RemoteUri: string): TRPCObjectImpl;
var
  Connection: TConnectionImpl;
begin
  Connection := TConnectionImpl.Create(GetTransport, LocalUri, RemoteUri);
  assert(TConnectionImpl.InheritsFrom(TInterfacedObject));

  Result := TRPCObjectImpl.Create(Connection, Serializer);
  Add(Result);
end;

end.
