(**
 * $Id: dutil.remoting.transport.impl.WMTransportImpl.pas 794 2014-04-28 16:00:24Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.transport.impl.WMTransportImpl;

interface

uses
  Winapi.Messages,
  Winapi.Windows,
  dutil.sys.win32.MessageWindowThread,
  dutil.remoting.transport.Pdu,
  dutil.remoting.transport.impl.TransportImpl,
  dutil.remoting.transport.impl.WMSenderThread;

type
  /// <summary>The class implements a transport resource via Windows messaging.</summary>
  TWMTransportImpl = class(TTransportImpl)
  private
    FReceiverThread: TMessageWindowThread;
    FSenderThread: TWMSenderThread;
    procedure CheckWMCopyData(var Message_: TMessage);
    function MessageTaken(const Message_: TWMCopyData): Boolean;
    function LocalWindow: HWND;
  public
    constructor Create;
    destructor Destroy; override;
    function WriteEnsured(const Pdu: TPdu): Boolean; override;
    function GetUri: string; override;
  end;

implementation

uses
{$IFDEF LOGGING}
  Log4D,
{$ENDIF}
  System.SysUtils,
  dutil.remoting.transport.impl.WMUri;

constructor TWMTransportImpl.Create;
begin
  inherited;

  FSenderThread := TWMSenderThread.Create(GetOutboundMessageQueue);
  FSenderThread.NameThreadForDebugging('dco.system.sender <wm>', FSenderThread.ThreadID);
  FReceiverThread := TMessageWindowThread.Create;
  FReceiverThread.NameThreadForDebugging('dco.system.receiver <wm>', FReceiverThread.ThreadID);
  FReceiverThread.OnMessage := CheckWMCopyData;

  FSenderThread.Start;
  FReceiverThread.Start;
end;

destructor TWMTransportImpl.Destroy;
begin
  FReceiverThread.Free;
  FSenderThread.Free;

  inherited;
end;

procedure TWMTransportImpl.CheckWMCopyData(var Message_: TMessage);
begin
  if Message_.Msg = WM_COPYDATA then
  begin
    if MessageTaken(TWMCopyData(Message_)) then
      Message_.Result := Integer({Handled=}True);
  end;
end;

function TWMTransportImpl.MessageTaken(const Message_: TWMCopyData): Boolean;
var
  Id: Word;
  Secret: Word;
  Pdu: TPdu;
begin
  Id := LoWord(Message_.CopyDataStruct.dwData);
  Secret := HiWord(Message_.CopyDataStruct.dwData);
  Pdu := TPdu.Create(
    TWMUri.Create(LocalWindow, Id, Secret).ToString,
    TWMUri.Create(Message_.From, Id, Secret).ToString,
    PChar(Message_.CopyDataStruct.lpData) // Copies data onto heap
  );

  GetInboundMessageQueue.Put(Pdu);
  Result := True;

{$IFDEF LOGGING}
  TLogLogger.GetLogger(ClassName).Trace(Format('<-%s: %s', [Pdu.Sender, Pdu.Message_]));
{$ENDIF}
end;

function TWMTransportImpl.LocalWindow: HWND;
begin
  Result := FReceiverThread.WindowHandle;
end;

function TWMTransportImpl.WriteEnsured(const Pdu: TPdu): Boolean;
begin
  // This message is expected to be sent immediately with ensurance, so we call the static method directly!
  Result := TWMSenderThread.SendMessage(Pdu);
end;

function TWMTransportImpl.GetUri: string;
begin
  Result := Format('%s%d', [TWMUri.WM_PROTOCOL, LocalWindow]);
end;

end.