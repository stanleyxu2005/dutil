(**
 * $Id: dui.sys.Screenshot.pas 819 2014-05-11 06:45:16Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dui.sys.Screenshot;

interface

uses
  Winapi.Windows,
  Vcl.Graphics;

type
  /// <summary>This service class provides methods for taking screenshots.</summary>
  TScreenshot = class
  public
    /// <summary>Takes a screenshot of the active window.</summary>
    /// <exceptions cref="EOSError">Error occurred by operating system.</exceptions>
    class function TakeFromActiveWindow: TBitmap; static;
    /// <summary>Takes a screenshot of the full screen.</summary>
    /// <exceptions cref="EOSError">Error occurred by operating system.</exceptions>
    class function TakeFromDesktop: TBitmap; overload; static;
    /// <summary>Takes a screenshot of the full screen.</summary>
    /// <exceptions cref="EOSError">Error occurred by operating system.</exceptions>
    class function TakeFromDesktop(const Rect: TRect): TBitmap; overload; static;
  private
    /// <exceptions cref="EOSError">Error occurred by operating system.</exceptions>
    class function Take(TargetWindow: HWND; const Rect: TRect): TBitmap; static;
  end;

implementation

uses
  Vcl.Forms,
  System.SysUtils,
  System.Types;

class function TScreenshot.TakeFromActiveWindow: TBitmap;
var
  TargetWindow: HWND;
  Rect: TRect;
begin
  TargetWindow := GetForegroundWindow;
  if not GetWindowRect(TargetWindow, Rect) then
    RaiseLastOSError;

  Result := Take(TargetWindow, {Rect=}Rect);
end;

class function TScreenshot.TakeFromDesktop: TBitmap;
begin
  Result := Take(GetDesktopWindow, {Rect=}Screen.DesktopRect);
end;

class function TScreenshot.TakeFromDesktop(const Rect: TRect): TBitmap;
begin
  Result := Take(GetDesktopWindow, {Rect=}Rect);
end;

class function TScreenshot.Take(TargetWindow: HWND; const Rect: TRect): TBitmap;
var
  DeviceContext: HDC;
begin
  assert(TargetWindow > 0);

  DeviceContext := GetWindowDC(TargetWindow);
  if DeviceContext = 0 then
    RaiseLastOSError;

  try
    Result := TBitmap.Create;
    Result.Width := Rect.Right - Rect.Left;
    Result.Height := Rect.Bottom - Rect.Top;

    Winapi.Windows.BitBlt(Result.Canvas.Handle, 0, 0, Result.Width, Result.Height, DeviceContext, Rect.Left, Rect.Top,
      SRCCOPY);
  finally
    ReleaseDC(TargetWindow, DeviceContext);
  end;
end;

end.
