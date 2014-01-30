(**
 * $Id: dutil.net.framework.wmchannel.ConnectionOutputQueue.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.framework.wmchannel.ConnectionOutputQueue;

interface

uses
  dutil.net.framework.wmchannel.Address,
  dutil.net.framework.wmchannel.ConnectionMessage,
  dutil.util.concurrent.BlockingQueue;

type
  /// <summary>This container class arranges to pack a message and its delivery address as an output message payload
  /// and put it into a blocking queue.</summary>
  TConnectionOutputQueue = class(TBlockingQueue<string>)
  private
    FMessageOutputQueue: TBlockingQueue<TConnectionMessage>;
    FAddress: TAddress;
  public
    constructor Create(const Address: TAddress; MessageOutputQueue: TBlockingQueue<TConnectionMessage>);
    destructor Destroy; override;
    procedure Put(const Pdu: string); override;
  protected
    function Take: string; reintroduce;
  end;

implementation

uses
  SysUtils;

constructor TConnectionOutputQueue.Create(const Address: TAddress; 
  MessageOutputQueue: TBlockingQueue<TConnectionMessage>);
begin
  assert(MessageOutputQueue <> nil);
  inherited Create;

  FAddress := Address;
  FMessageOutputQueue := MessageOutputQueue;
end;

destructor TConnectionOutputQueue.Destroy;
begin
  FMessageOutputQueue := nil;

  inherited;
end;

procedure TConnectionOutputQueue.Put(const Pdu: string);
var
  ConnectionMessage: TConnectionMessage;
begin
  ConnectionMessage := TConnectionMessage.Assign(FAddress, Pdu);
  FMessageOutputQueue.Put(ConnectionMessage);
end;

function TConnectionOutputQueue.Take: string;
begin
  raise EProgrammerNotFound.Create('forbidden');
end;

end.
