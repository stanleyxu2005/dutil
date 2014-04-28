(**
 * $Id: dutil.remoting.transport.impl.TransportImpl.pas 798 2014-04-28 17:29:33Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.transport.impl.TransportImpl;

interface

uses
  dutil.util.concurrent.BlockingQueue,
  dutil.remoting.transport.Pdu,
  dutil.remoting.transport.Transport;

type
  /// <summary>The abstract class implements the basic behaviors of a transport resource. To maximize the throughput,
  /// it holds two threads for transmitting inbound and outbound messages. The messages will be stored in thread-safe
  /// blocking queues.</summary>
  TTransportImpl = class abstract(TInterfacedObject, ITransport)
  protected
    // Initially I plan to keep them private and expose IQueue in protected scope. However I cannot use `property` to
    // case a generic class to a generic interface. But if I use functions to expose them, I have to do extra locking
    // for the thread safety.
    FInboundMessageQueue: TBlockingQueue<TPdu>;
    FOutboundMessageQueue: TBlockingQueue<TPdu>;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>Informs the recipient to shut down.</summary>
    procedure ShutDown;
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


constructor TTransportImpl.Create;
begin
  inherited Create;

  FInboundMessageQueue := TBlockingQueue<TPdu>.Create;
  FOutboundMessageQueue := TBlockingQueue<TPdu>.Create;
end;

destructor TTransportImpl.Destroy;
begin
  ShutDown; // TODO: How to make sure all messages have been handled?

  FOutboundMessageQueue.Free;
  FInboundMessageQueue.Free;

  inherited;
end;

procedure TTransportImpl.ShutDown;
begin
  // Shut down gracefully by sending a poison pill to corresponding handler.
  FInboundMessageQueue.Put(POISON_PILL);
end;

procedure TTransportImpl.Write(const Pdu: TPdu);
begin
  FOutboundMessageQueue.Put(Pdu);
end;

function TTransportImpl.Read: TPdu;
begin
  Result := FInboundMessageQueue.Take;
end;

end.