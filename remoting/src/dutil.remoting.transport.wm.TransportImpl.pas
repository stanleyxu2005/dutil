(**
 * $Id: dutil.remoting.transport.wm.TransportImpl.pas 813 2014-05-08 15:08:01Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.transport.wm.TransportImpl;

interface

uses
  Winapi.Messages,
  Winapi.Windows,
  dutil.sys.win32.MessageWindowThread,
  dutil.remoting.transport.AbstractTransportImpl,
  dutil.remoting.transport.Pdu,
  dutil.remoting.util.ThreadedConsumer;

type
  /// <summary>The class implements a transport resource via Windows messaging.</summary>
  TTransportImpl = class(TAbstractTransportImpl)
  private
    FReceiverThread: TMessageWindowThread;
    FSenderThread: TThreadedConsumer<TPdu>;
    procedure CheckWMCopyData(var Message_: TMessage);
    function MessageTaken(const Message_: TWMCopyData): Boolean;
    function LocalWindow: HWND;
  public
    function WriteEnsured(const Pdu: TPdu): Boolean; override;
    function GetUri: string; override;
  private
    procedure SendMessage(const Pdu: TPdu);
    class function SendMessageAwait(const Pdu: TPdu): Boolean; static;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

uses
{$IFDEF LOGGING}
  Log4D,
{$ENDIF}
  System.SysUtils,
  dutil.remoting.transport.Uri;

type
  TWMUri = record
  private
    FMessageWindow: HWND;
    FId: Cardinal;
  public
    property MessageWindow: HWND read FMessageWindow;
    property Id: Cardinal read FId;
  public
    constructor Create(MessageWindow: HWND; Id: Cardinal);
    function ToString: string;
    class function FromUri(const S: string): TWMUri; static;
  end;

constructor TWMUri.Create(MessageWindow: HWND; Id: Cardinal);
begin
  FMessageWindow := MessageWindow;
  FId := Id;
end;

function TWMUri.ToString: string;
begin
  Result := TUri.Create(Format('%d', [FMessageWindow]), FId).ToString;
end;

class function TWMUri.FromUri(const S: string): TWMUri;
var
  Uri: TUri;
begin
  Uri := TUri.FromString(S);
  Result := TWMUri.Create(StrToInt(Uri.Domain), Uri.Id);
end;

constructor TTransportImpl.Create;
begin
  inherited;

  FSenderThread := TThreadedConsumer<TPdu>.Create(FOutboundQueue, SendMessage);
  FSenderThread.NameThreadForDebugging('dco.system.sender <wm>', FSenderThread.ThreadID);
  FReceiverThread := TMessageWindowThread.Create;
  FReceiverThread.NameThreadForDebugging('dco.system.receiver <wm>', FReceiverThread.ThreadID);
  FReceiverThread.OnMessage := CheckWMCopyData;

  FSenderThread.Start;
  FReceiverThread.Start;
end;

destructor TTransportImpl.Destroy;
begin
  FReceiverThread.Free;
  FSenderThread.Free;

  inherited;
end;

procedure TTransportImpl.CheckWMCopyData(var Message_: TMessage);
begin
  if Message_.Msg = WM_COPYDATA then
  begin
    if MessageTaken(TWMCopyData(Message_)) then
      Message_.Result := Integer({Handled=}True);
  end;
end;

function TTransportImpl.MessageTaken(const Message_: TWMCopyData): Boolean;
var
  Id: Cardinal;
  Pdu: TPdu;
begin
  Id := Message_.CopyDataStruct.dwData;
  try
    Pdu := TPdu.Create(
      TWMUri.Create(LocalWindow, Id).ToString,
      TWMUri.Create(Message_.From, Id).ToString,
      PChar(Message_.CopyDataStruct.lpData) // Copies data onto heap
    );
  except
    Exit(False); // Unexpected message
  end;

  FInboundQueue.Put(Pdu);
  Result := True;

{$IFDEF LOGGING}
  TLogLogger.GetLogger(ClassName).Trace(Format('<-%s: %s', [Pdu.Sender, Pdu.Message_]));
{$ENDIF}
end;

function TTransportImpl.LocalWindow: HWND;
begin
  Result := FReceiverThread.WindowHandle;
end;

function TTransportImpl.WriteEnsured(const Pdu: TPdu): Boolean;
begin
  // This message is expected to be sent immediately with ensurance, so we call the static method directly!
  Result := SendMessageAwait(Pdu);
end;

function TTransportImpl.GetUri: string;
begin
  Result := IntToStr(LocalWindow);
end;

procedure TTransportImpl.SendMessage(const Pdu: TPdu);
begin
  SendMessageAwait(Pdu);
end;

class function TTransportImpl.SendMessageAwait(const Pdu: TPdu): Boolean;
var
  Recipient: TWMUri;
  Sender: TWMUri;
  CopyData: CopyDataStruct;
begin
  try
    Recipient := TWMUri.FromUri(Pdu.Recipient);
    Sender := TWMUri.FromUri(Pdu.Sender);
  except
    on E: Exception do
    begin
      {$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Error(E.ToString);
      {$ENDIF}
      Exit(False);
    end;
  end;
  if Recipient.Id <> Sender.Id then
  begin
    {$IFDEF LOGGING}
    TLogLogger.GetLogger(ClassName).Error(
      Format('Untrusted message header detected: Recipient=%s, Sender=%s, Message=%s',
        [Pdu.Recipient, Pdu.Sender, Pdu.Message_]));
    {$ENDIF}
    Exit(False);
  end;

  if not IsWindow(Recipient.MessageWindow) then
    Exit(False);

  CopyData.dwData := Recipient.Id;
  CopyData.lpData := PChar(Pdu.Message_);
  CopyData.cbData := (Length(Pdu.Message_) + 1) * StringElementSize(Pdu.Message_);
  Winapi.Windows.SendMessage(Recipient.MessageWindow, WM_COPYDATA, WPARAM(Sender.MessageWindow), LPARAM(@CopyData));
  Result := True;

{$IFDEF LOGGING}
  TLogLogger.GetLogger(ClassName).Trace(Format('->%s: %s', [Pdu.Recipient, Pdu.Message_]));
{$ENDIF}
end;

end.