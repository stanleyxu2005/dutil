(**
 * $Id: dutil.remoting.transport.impl.ConnectionImpl.pas 790 2014-04-27 18:01:48Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.transport.impl.ConnectionImpl;

interface

uses
  dutil.remoting.transport.Connection,
  dutil.remoting.transport.Pdu,
  dutil.remoting.transport.Transport;

type
  /// <summary>This class implements a tranport connection.</summary>
  TConnectionImpl = class(TInterfacedObject, IConnection)
  private
    FTransport: ITransport;
    FLocalUri: string;
    FRemoteUri: string;
    function CreatePdu(const Message_: string): TPdu;
  public
    constructor Create(const Transport: ITransport; const LocalUri: string; const RemoteUri: string);
    destructor Destroy; override;
    /// <summary>Returns the uri of the connection.</summary>
    function GetId: string;
    /// <summary>Sends an outbound message and waits for it is actually sent out.</summary>
    function WriteEnsured(const Message_: string): Boolean;
    /// <summary>Sends an outbound message and waits for it is actually sent out.</summary>
    procedure Write(const Message_: string);
    ///
    procedure HandleRead(const Message_: string);
  end;

implementation

constructor TConnectionImpl.Create(const Transport: ITransport; const LocalUri: string; const RemoteUri: string);
begin
  assert(Transport <> nil);
  assert(LocalUri <> '');
  assert(RemoteUri <> '');
  assert(RemoteUri <> LocalUri);
  inherited Create;

  FTransport := Transport;
  FLocalUri := LocalUri;
  FRemoteUri := RemoteUri;
end;

destructor TConnectionImpl.Destroy;
begin
  FTransport := nil;

  inherited;
end;

function TConnectionImpl.CreatePdu(const Message_: string): TPdu;
begin
  Result := TPdu.Create(FRemoteUri, FLocalUri, Message_);
end;

function TConnectionImpl.GetId: string;
begin
  Result := FLocalUri;
end;

function TConnectionImpl.WriteEnsured(const Message_: string): Boolean;
var
  Pdu: TPdu;
begin
  Pdu := CreatePdu(Message_);
  Result := FTransport.WriteEnsured(Pdu);
end;

procedure TConnectionImpl.Write(const Message_: string);
var
  Pdu: TPdu;
begin
  Pdu := CreatePdu(Message_);
  FTransport.Write(Pdu);
end;

procedure TConnectionImpl.HandleRead(const Message_: string);
begin
  // TODO: 
end;

end.
