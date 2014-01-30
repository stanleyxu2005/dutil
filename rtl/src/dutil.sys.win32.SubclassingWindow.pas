(**
 * $Id: dutil.sys.win32.SubclassingWindow.pas 530 2012-06-05 14:31:51Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.sys.win32.SubclassingWindow;

interface

uses
  Classes,
  Messages,
  Windows;

type
  /// <summary>This class helps to subclass a window.</summary>
  TSubclassingWindowHelper = class
  private
    FTargetWindow: HWND;
    FWindowsMessageHandler: TWndMethod;
    FOriginalWindowsMessageProcPtr: Pointer;
    FSubclassWindowsMessageProcPtr: Pointer;
    procedure ProcessWindowsMessage(var Message_: TMessage);
  public
    /// <exception cref="EOSError">Operating system failure.</exception>
    constructor Create(TargetWindow: HWND; WindowsMessageHandler: TWndMethod);
    /// <exception cref="EOSError">Operating system failure.</exception>
    destructor Destroy; override;
  end;

implementation

uses
  SysUtils;

constructor TSubclassingWindowHelper.Create(TargetWindow: HWND; WindowsMessageHandler: TWndMethod);
begin
  assert(Assigned(WindowsMessageHandler));

  inherited Create;

  FTargetWindow := TargetWindow;
  FWindowsMessageHandler := WindowsMessageHandler;

  FOriginalWindowsMessageProcPtr := Pointer(GetWindowLong(FTargetWindow, GWL_WNDPROC));
  if FOriginalWindowsMessageProcPtr = nil then
    RaiseLastOSError;

  FSubclassWindowsMessageProcPtr := Classes.MakeObjectInstance(Self.ProcessWindowsMessage);
  if SetWindowLongPtr(FTargetWindow, GWL_WNDPROC, LONG_PTR(FSubclassWindowsMessageProcPtr)) = 0 then
    RaiseLastOSError;

  assert(FOriginalWindowsMessageProcPtr <> nil);
  assert(FSubclassWindowsMessageProcPtr <> nil);
end;

destructor TSubclassingWindowHelper.Destroy;
begin
  if IsWindow(FTargetWindow) then
  begin
    if SetWindowLongPtr(FTargetWindow, GWL_WNDPROC, LONG_PTR(FOriginalWindowsMessageProcPtr)) = 0 then
      RaiseLastOSError;
  end;
  Classes.FreeObjectInstance(FSubclassWindowsMessageProcPtr);

  inherited;
end;

procedure TSubclassingWindowHelper.ProcessWindowsMessage(var Message_: TMessage);
begin
  FWindowsMessageHandler(Message_);
  if Message_.Result <> Integer(True{=Handled}) then
    Message_.Result := CallWindowProc(FOriginalWindowsMessageProcPtr, FTargetWindow, Message_.Msg, Message_.WParam,
      Message_.LParam);
end;

end.