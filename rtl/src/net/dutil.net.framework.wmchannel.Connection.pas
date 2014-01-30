(**
 * $Id: dutil.net.framework.wmchannel.Connection.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.framework.wmchannel.Connection;

interface

uses
  dutil.net.framework.wmchannel.Address,
  dutil.net.framework.wmchannel.ConnectionMessage,
  dutil.net.framework.wmchannel.ConnectionOutputQueue,
  dutil.util.concurrent.BlockingQueue;

type
  /// <summary>This class reprensents a connection for IPC based on exchanging windows messages.</summary>
  /// <remarks>A TConnection instance is expected to be created by using TMessageProxy.AddConnection()</remarks>
  TConnection = class
  private
    FAddress: TAddress;
    FInput: TBlockingQueue<string>;
    FOutput: TConnectionOutputQueue;
  public
    property Address: TAddress read FAddress;
    property Input: TBlockingQueue<string>read FInput;
    property Output: TConnectionOutputQueue read FOutput;
  public
    constructor Create(const Address: TAddress; Input: TBlockingQueue<string>;
      ConnectionMessageQueue: TBlockingQueue<TConnectionMessage>);
    destructor Destroy; override;
  end;

implementation

constructor TConnection.Create(const Address: TAddress; Input: TBlockingQueue<string>;
  ConnectionMessageQueue: TBlockingQueue<TConnectionMessage>);
begin
  assert(Input <> nil);
  assert(ConnectionMessageQueue <> nil);
  inherited Create;

  FAddress := Address;
  FInput := Input;
  FOutput := TConnectionOutputQueue.Create(FAddress, ConnectionMessageQueue);
end;

destructor TConnection.Destroy;
begin
  FOutput.Free;
  FOutput := nil;
  FInput := nil;

  inherited;
end;

end.
