(**
 * $Id: dui.sys.TaskBarEffects.pas 819 2014-05-11 06:45:16Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dui.sys.TaskBarEffects;

interface

uses
  Winapi.ShlObj,
  Winapi.Windows;

type
  /// <summary>This service class provides methods for controlling the new taskbar button functionalities added in
  /// Windows 7.</summary>
  TTaskBarEffects = class
  private type
    TTaskBarProgressState = (
      // Stops displaying progress and returns the button to its normal state.
      NONE = TBPF_NOPROGRESS,
      // Does not grow in size, but cycles repeatedly along the length of the taskbar button.
      INDETERMINATE = TBPF_INDETERMINATE,
      // Grows in size from left to right in proportion to the estimated amount of the operation completed.
      NORMAL = TBPF_NORMAL,
      // Turns red to show that an error has occurred in one of the windows.
      ERROR = TBPF_ERROR,
      // Turns yellow to show that progress is currently stopped in one of the windows.
      PAUSED = TBPF_PAUSED
    );
  public
    /// <summary>Sets the type and state of the progress indicator displayed on a taskbar button.</summary>
    class function SetProgressState(State: TTaskBarProgressState): Boolean; static;
    /// <summary>Displays or updates a progress bar hosted in a taskbar button to show the specific percentage
    /// completed of the full operation.</summary>
    class function SetTaskbarProgressValue(const Current: ULONGLONG; const MaxProgress: ULONGLONG): Boolean; static;
    /// <summary>Specifies or updates the text of the tooltip that is displayed when the mouse pointer rests on an
    /// individual preview thumbnail in a taskbar button flyout.</summary>
    class function SetThumbnailTooltip(const Tooltip: string): Boolean; static;
  private
    class var FTaskBarListInterfaceAvailable: Boolean;
    class var FTaskBarListPtr: ITaskbarList3;
    class constructor Create;
    class function OnTaskBarHandle: HWND; static;
  public
    class destructor Destroy;
  end;

implementation

uses
  Vcl.Forms,
  System.Win.ComObj,
  System.SysUtils;

class function TTaskBarEffects.SetProgressState(State: TTaskBarProgressState): Boolean;
begin
  if FTaskBarListInterfaceAvailable then
  begin
    assert(FTaskBarListPtr <> nil);

    Result := FTaskBarListPtr.SetProgressState(OnTaskBarHandle, Ord(State)) = S_OK;
  end
  else
    Result := False;
end;

class function TTaskBarEffects.SetTaskbarProgressValue(const Current: ULONGLONG; const MaxProgress: ULONGLONG): Boolean;
begin
  if FTaskBarListInterfaceAvailable then
  begin
    assert(FTaskBarListPtr <> nil);
    assert(Current <= MaxProgress);

    Result := FTaskBarListPtr.SetProgressValue(OnTaskBarHandle, Current, MaxProgress) = S_OK;
  end
  else
    Result := False;
end;

class function TTaskBarEffects.SetThumbnailTooltip(const Tooltip: string): Boolean;
begin
  if FTaskBarListInterfaceAvailable then
  begin
    assert(FTaskBarListPtr <> nil);

    Result := FTaskBarListPtr.SetThumbnailTooltip(OnTaskBarHandle, PChar(Tooltip)) = S_OK;
  end
  else
    Result := False;
end;

class constructor TTaskBarEffects.Create;
begin
  FTaskBarListInterfaceAvailable := CheckWin32Version(6, 1) and //
    Supports(CreateComObject(CLSID_TaskbarList), ITaskbarList3, FTaskBarListPtr);

  assert(not FTaskBarListInterfaceAvailable or (FTaskBarListPtr <> nil));
end;

class destructor TTaskBarEffects.Destroy;
begin
  FTaskBarListPtr := nil;
end;

class function TTaskBarEffects.OnTaskBarHandle: HWND;
begin
  if Application.MainFormOnTaskbar then
    Result := Application.MainFormHandle
  else
    Result := Application.Handle;
end;

end.
