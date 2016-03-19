(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dui.sys.UserInput;

interface

uses
  System.Classes,
  Vcl.Controls;

type
  /// <summary>This service class provides methods for making user inputs.</summary>
  TUserInput = class
    /// <summary>Determines whether a key is pressed.</summary>
    class function KeyPressed(VirtualKey: Word): Boolean; static;
    /// <summary>Returns the current key state of the SHIFT, ALT and CTRL keys.</summary>
    class function KeyShiftState: TShiftState; static;
    /// <summary>Sends a key press.</summary>
    class procedure SendKeyPress(VirtualKey: Word); static;
    /// <summary>Sends a mouse click.</summary>
    class function SendMouseClick(TargetControl: TWinControl; MouseButton: TMouseButton): Boolean; static;
  end;

implementation

uses
  Winapi.Windows,
  Winapi.Messages,
  System.Types;

class function TUserInput.KeyPressed(VirtualKey: Word): Boolean;
var
  ActualVirtualKey: Word;
begin
  ActualVirtualKey := VirtualKey;

  case VirtualKey of
    VK_LBUTTON:
      if GetSystemMetrics(SM_SWAPBUTTON) <> 0 then
        ActualVirtualKey := VK_RBUTTON;

    VK_RBUTTON:
      if GetSystemMetrics(SM_SWAPBUTTON) <> 0 then
        ActualVirtualKey := VK_LBUTTON;
  end;

  Result := GetAsyncKeyState(ActualVirtualKey) < 0;
end;

class function TUserInput.KeyShiftState: TShiftState;
begin
  Result := [];

  if GetKeyState(VK_SHIFT) < 0 then
    Include(Result, ssShift);

  if GetKeyState(VK_CONTROL) < 0 then
    Include(Result, ssCtrl);

  if GetKeyState(VK_MENU) < 0 then
    Include(Result, ssAlt);
end;

class procedure TUserInput.SendKeyPress(VirtualKey: Word);
// TODO: KEYEVENTF_EXTENDEDKEY (Some keys on numpad)
var
  ScanCode: Byte;
begin
  ScanCode := Lo(MapVirtualKey(VirtualKey, 0));
  keybd_event(VirtualKey, ScanCode, 0, 0);
  keybd_event(VirtualKey, ScanCode, KEYEVENTF_KEYUP, 0);
end;

class function TUserInput.SendMouseClick(TargetControl: TWinControl; MouseButton: TMouseButton): Boolean;
const
  VIRTUAL_KEY: array [TMouseButton] of Word = (MK_LBUTTON, MK_RBUTTON, MK_MBUTTON);
var
  Pt: TPoint;
  TargetWindow: HWND;
  MessageWParam: WPARAM;
  MessageLParam: LPARAM;
begin
  assert(TargetControl <> nil);

  if not TargetControl.HandleAllocated then
  begin
    Result := False;
    Exit;
  end;

  GetCursorPos(Pt);
  Pt := TargetControl.ScreenToClient(Pt);
  TargetWindow := TargetControl.Handle;
  MessageWParam := VIRTUAL_KEY[MouseButton];
  MessageLParam := PointToLParam(Pt);

  SendMessage(TargetWindow, WM_LBUTTONDOWN, MessageWParam, MessageLParam);
  SendMessage(TargetWindow, WM_LBUTTONUP, MessageWParam, MessageLParam);
  Result := True;
end;

end.
