(**
 * $Id: dutil.remoting.transport.Pdu.pas 778 2014-04-26 10:11:29Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.transport.Pdu;

interface

type
  /// <summary>The immutable value object represents a PDU (protocol data unit) for the remoting framework.</summary>
  TPdu = record
  private
    FRecipient: string;
    FSender: string;
    FMessage: string;
  public
    property Recipient: string read FRecipient;
    property Sender: string read FSender;
    property Message_: string read FMessage;
  public
    constructor Create(const Recipient, Sender, Message_: string);
    function ToString: string;
    function Equals(const Other: TPdu): Boolean;
  end;

const
  POISON_PILL: TPdu = (FRecipient: ''; FSender: ''; FMessage: '');

implementation

uses
  System.SysUtils;

constructor TPdu.Create(const Recipient, Sender, Message_: string);
begin
  assert(Recipient <> '');
  assert(Sender <> '');

  FRecipient := Recipient;
  FSender := Sender;
  FMessage := Message_;
end;

function TPdu.ToString: string;
begin
  Result := Format('<TPdu>: Recipient=''%s'', Sender=''%s'', Message=''%s''', [FRecipient, FSender, FMessage]);
end;

function TPdu.Equals(const Other: TPdu): Boolean;
begin
  Result := (FRecipient = Other.FRecipient) and
            (FSender = Other.FSender) and
            (FMessage = Other.FMessage);
end;

end.