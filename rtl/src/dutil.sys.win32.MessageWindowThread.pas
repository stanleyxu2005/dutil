(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dutil.sys.win32.MessageWindowThread;

interface

uses
  System.Classes,
  Winapi.Messages,
  Winapi.Windows;
  
type
  /// <summary>This class arranges to maintain an own message loop in a thread.</summary>
  TMessageWindowThread = class(TThread)
  private
    FWindowHandle: HWND;
    FOnMessage: TWndMethod;
  public
    property WindowHandle: HWND read FWindowHandle;
    property OnMessage: TWndMethod read FOnMessage write FOnMessage;
  private
    procedure WindowProc(var Message_: TMessage);
  protected
    procedure Execute; override;
  public
    constructor Create;
    destructor Destroy; override;
  end;

implementation

constructor TMessageWindowThread.Create;
begin
  inherited Create({CreateSuspended=}True);
  NameThreadForDebugging(ClassName, ThreadID);

  FWindowHandle := AllocateHWnd(WindowProc);
  assert(FWindowHandle > 0);
end;

destructor TMessageWindowThread.Destroy;
begin
  inherited;

  if FWindowHandle > 0 then
  begin
    DeallocateHWnd(FWindowHandle);
    FWindowHandle := 0;
  end;
end;

procedure TMessageWindowThread.Execute;
var
  Message_: TMsg;
begin
  while not Terminated do
  begin
    if MsgWaitForMultipleObjects({nCount=}0, {pHandles=}nil^, {bWaitAll=}False, {dwMilliseconds=}1000,
        {dwWakeMask=}QS_ALLINPUT) = WAIT_OBJECT_0 then
    begin
      while not Terminated and
        PeekMessage(Message_, {hWnd=}0, {wMsgFilterMin=}0, {wMsgFilterMax=}0, {wRemoveMsg=}PM_REMOVE) do
      begin
        TranslateMessage(Message_);
        DispatchMessage(Message_);
      end;
    end;
  end;
end;

procedure TMessageWindowThread.WindowProc(var Message_: TMessage);
begin
  if Assigned(FOnMessage) then
  begin
    FOnMessage(Message_);
    if Message_.Result = Integer(True) then
      Exit;
  end;

  Message_.Result := DefWindowProc(FWindowHandle, Message_.Msg, Message_.WParam, Message_.LParam);
end;

end.