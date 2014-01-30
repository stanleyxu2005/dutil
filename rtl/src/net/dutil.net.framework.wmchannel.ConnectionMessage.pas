(**
 * $Id: dutil.net.framework.wmchannel.ConnectionMessage.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.framework.wmchannel.ConnectionMessage;

interface

uses
  dutil.net.framework.wmchannel.Address,
  dutil.util.concurrent.BlockingQueue;

type
  /// <summary>This immutable record represents a message of a message channel connection.</summary>
  TConnectionMessage = record
  private
    FAddress: TAddress;
    FPdu: string;
  public
    property Address: TAddress read FAddress;
    property Pdu: string read FPdu;
    class function Assign(const Address: TAddress; const Pdu: string): TConnectionMessage; static;
  end;

implementation

class function TConnectionMessage.Assign(const Address: TAddress; const Pdu: string): TConnectionMessage;
begin
  Result.FAddress := Address;
  Result.FPdu := Pdu;
end;

end.
