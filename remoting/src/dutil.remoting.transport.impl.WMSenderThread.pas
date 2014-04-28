(**
 * $Id: dutil.remoting.transport.impl.WMSenderThread.pas 798 2014-04-28 17:29:33Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.transport.impl.WMSenderThread;

interface

uses
  System.Classes,
  dutil.util.container.Queue,
  dutil.remoting.transport.Pdu;

type
  /// <summary>The class implements an infinitive Windows message sending thread.</summary>
  TWMSenderThread = class(TThread)
  private
    FOutputQueue: IQueue<TPdu>;
  protected
    procedure Execute; override;
  public
    constructor Create(const OutputQueue: IQueue<TPdu>);
    destructor Destroy; override;
    class function SendMessage(const Pdu: TPdu): Boolean; static;
  end;

implementation

uses
{$IFDEF LOGGING}
  Log4D,
{$ENDIF}
  System.SysUtils,
  Winapi.Messages,
  Winapi.Windows,
  dutil.remoting.transport.impl.WMUri;

constructor TWMSenderThread.Create(const OutputQueue: IQueue<TPdu>);
begin
  assert(OutputQueue <> nil);
  inherited Create({CreateSuspended=}True);

  FOutputQueue := OutputQueue;
end;

destructor TWMSenderThread.Destroy;
begin
  // To wake up the thread context by putting a poison pill
  FOutputQueue.Put(POISON_PILL);
  WaitFor;

  FOutputQueue := nil;

  inherited;
end;

procedure TWMSenderThread.Execute;
var
  Pdu: TPdu;
begin
  Pdu := FOutputQueue.Take;
  while not POISON_PILL.Equals(Pdu) do
  begin
    // Note that the sender does not (but the TransportImpl does) have the responsibility of handling undelivered
    // messages here.
    SendMessage(Pdu);
    Pdu := FOutputQueue.Take;
  end;
end;

class function TWMSenderThread.SendMessage(const Pdu: TPdu): Boolean;
var
  Recipient: TWMUri;
  Sender: TWMUri;
  CopyData: CopyDataStruct;
begin
  try
    Recipient := TWMUri.FromString(Pdu.Recipient);
    Sender := TWMUri.FromString(Pdu.Sender);
  except
    on E: Exception do
    begin
      {$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Error(E.ToString);
      {$ENDIF}
      Exit(False);
    end;
  end;
  if (Recipient.Id <> Sender.Id) or (Recipient.Secret <> Sender.Secret) then
  begin
    {$IFDEF LOGGING}
    TLogLogger.GetLogger(ClassName).Error(
      Format('Untrusted message header detected: Recipient=%s, Sender=%s, Message=%s',
        [Pdu.Recipient, Pdu.Sender, Pdu.Message_]));
    {$ENDIF}
    Exit(False);
  end;

  if not IsWindow(Recipient.Window) then
    Exit(False);

  CopyData.dwData := MakeLong({LoWord=}Recipient.Id, {HiWord=}Recipient.Secret);
  CopyData.lpData := PChar(Pdu.Message_);
  CopyData.cbData := (Length(Pdu.Message_) + 1) * StringElementSize(Pdu.Message_);
  Winapi.Windows.SendMessage(Recipient.Window, WM_COPYDATA, WPARAM(Sender.Window), LPARAM(@CopyData));
  Result := True;

{$IFDEF LOGGING}
  TLogLogger.GetLogger(ClassName).Trace(Format('->%s: %s', [Pdu.Recipient, Pdu.Message_]));
{$ENDIF}
end;

end.