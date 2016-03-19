(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dui.control.menu.Util;

interface

uses
  Vcl.Menus,
  System.Types,
  Winapi.Windows;

type
  /// <summary>This service class provides methods for using menus.</summary>
  TUtil = class
  public
    /// <summary>Computes the position to popup the menu. Expectedly the top-left corner of the menu should be at the
    /// bottom-left corner of the control.</summary>
    class function ComputeLeftBottomPopupPosition(Menu: TPopupMenu; const ControlRect: TRect): TPoint; static;
    /// <summary>Computes the position to popup the menu. Expectedly the top-right corner of the menu should be at the
    /// bottom-right corner of the control.</summary>
    class function ComputeRightBottomPopupPosition(Menu: TPopupMenu; const ControlRect: TRect): TPoint; static;
    /// <summary>Replaces the sub-menu of a menu item.</summary>
    class function ReplaceSubMenu(MenuItem: TMenuItem; SubMenuHandle: HMENU): Boolean; static;
  private
    /// <summary>Some menu items might become invisible, if the menu is too long. In this case we should make the
    /// left-bottom edge of the menu at the top-left corner of the control.</summary>
    class function ExpectedBottomItemsNotClipped(Menu: TPopupMenu; const Pt: TPoint; ControlHeight: Cardinal): TPoint;
      static;
  end;

implementation

uses
  Vcl.Forms,
  dui.metrics.MenuExtent;

class function TUtil.ComputeLeftBottomPopupPosition(Menu: TPopupMenu; const ControlRect: TRect): TPoint;
begin
  assert(Menu <> nil);

  Result := Point(ControlRect.Left, ControlRect.Bottom);
  Result := ExpectedBottomItemsNotClipped(Menu, Result, {ControlHeight=}ControlRect.Bottom - ControlRect.Top);
end;

class function TUtil.ComputeRightBottomPopupPosition(Menu: TPopupMenu; const ControlRect: TRect): TPoint;
var
  LeftMonitor: TMonitor;
  RightMonitor: TMonitor;
begin
  assert(Menu <> nil);

  Result := Point(ControlRect.Right, ControlRect.Bottom);
  Result := ExpectedBottomItemsNotClipped(Menu, Result, {ControlHeight=}ControlRect.Bottom - ControlRect.Top);

  // Expects the menu can be shown on the right screen for multi-monitor environment.
  LeftMonitor := Screen.MonitorFromPoint(Point(ControlRect.Left, ControlRect.Bottom));
  RightMonitor := Screen.MonitorFromPoint(Point(ControlRect.Right, ControlRect.Bottom));
  if LeftMonitor <> RightMonitor then
  begin
    // Without minus 1, the menu will be still shown on the right monitor.
    Result.X := LeftMonitor.WorkareaRect.Right - 1;
  end;
end;

class function TUtil.ExpectedBottomItemsNotClipped(Menu: TPopupMenu; const Pt: TPoint; ControlHeight: Cardinal): TPoint;
var
  MenuHeight: Cardinal;
begin
  assert(Menu <> nil);

  MenuHeight := TMenuExtent.ComputeMenuHeight(Menu);
  if Integer(MenuHeight) + Pt.Y > Screen.MonitorFromPoint(Pt).WorkareaRect.Bottom then
    Result := Point(Pt.X, Pt.Y - Integer(ControlHeight + MenuHeight))
  else
    Result := Pt;
end;

class function TUtil.ReplaceSubMenu(MenuItem: TMenuItem; SubMenuHandle: HMENU): Boolean;
var
  MII: MENUITEMINFO;
begin
  assert(MenuItem <> nil);
  assert(SubMenuHandle > 0);

  ZeroMemory(@MII, SizeOf(MII));
  MII.cbSize := SizeOf(MENUITEMINFO);
  MII.fMask := MIIM_SUBMENU;
  MII.hSubMenu := SubMenuHandle;

  Result := SetMenuItemInfo(MenuItem.Parent.Handle, MenuItem.MenuIndex, {fByPosition=}True, MII);
end;

end.
