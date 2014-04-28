(**
 * $Id: dutil.remoting.transport.Transport.pas 788 2014-04-27 17:12:50Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.transport.Transport;

interface

uses
  dutil.remoting.transport.Pdu;

type
  /// <summary>The interface defines the basic behaviors of a transport resource.</summary>
  ITransport = interface
    /// <summary>Informs the recipient to shut down.</summary>
    procedure ShutDown;
    /// <summary>Sends an outbound message and returns immediately.</summary>
    procedure Write(const Pdu: TPdu);
    /// <summary>Sends an outbound message and waits for it is actually sent out.</summary>
    function WriteEnsured(const Pdu: TPdu): Boolean;
    /// <summary>Blocks until an inbound message is retrieved.</summary>
    function Read: TPdu;
    /// <summary>Returns the identifier of the transport resource.</summary>
    function GetUri: string;
  end;

implementation

end.