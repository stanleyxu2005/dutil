(**
 * $Id: dutil.remoting.transport.AbstractTransportImpl.pas 805 2014-05-01 04:23:28Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.transport.AbstractTransportImpl;

interface

uses
  dutil.util.concurrent.BlockingQueue,
  dutil.remoting.transport.Pdu,
  dutil.remoting.transport.Transport;

type
  /// <summary>The abstract class implements the basic behaviors of a transport resource. To maximize the throughput,
  /// it holds two threads for transmitting inbound and outbound messages. The messages will be stored in thread-safe
  /// blocking queues.</summary>
  TAbstractTransportImpl = class abstract(TInterfacedObject, ITransport)
  protected
    // Initially I plan to keep them private and expose IQueue in protected scope. However I cannot use `property` to
    // case a generic class to a generic interface. But if I use functions to expose them, I have to do extra locking
    // for the thread safety.
    FInboundQueue: TBlockingQueue<TPdu>;
    FOutboundQueue: TBlockingQueue<TPdu>;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>Informs the recipient to shut down.</summary>
    procedure Shutdown;
    /// <summary>Sends an outbound message and returns immediately.</summary>
    procedure Write(const Pdu: TPdu);
    /// <summary>Sends an outbound message and waits for it is actually sent out.</summary>
    function WriteEnsured(const Pdu: TPdu): Boolean; virtual; abstract;
    /// <summary>Blocks until an inbound message is retrieved.</summary>
    function Read: TPdu;
    /// <summary>Returns the identifier of the transport resource.</summary>
    function GetUri: string; virtual; abstract;
  end;

implementation


constructor TAbstractTransportImpl.Create;
begin
  inherited Create;

  FInboundQueue := TBlockingQueue<TPdu>.Create;
  FOutboundQueue := TBlockingQueue<TPdu>.Create;
end;

destructor TAbstractTransportImpl.Destroy;
begin
  Shutdown; // TODO: How to make sure all messages have been handled?

  FOutboundQueue.Free;
  FInboundQueue.Free;

  inherited;
end;

procedure TAbstractTransportImpl.Shutdown;
begin
  // Shut down gracefully by sending a poison pill to corresponding handler.
  FInboundQueue.Put(POISON_PILL);
end;

procedure TAbstractTransportImpl.Write(const Pdu: TPdu);
begin
  FOutboundQueue.Put(Pdu);
end;

function TAbstractTransportImpl.Read: TPdu;
begin
  Result := FInboundQueue.Take;
end;

end.