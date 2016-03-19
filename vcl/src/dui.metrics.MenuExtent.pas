(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dui.metrics.MenuExtent;

interface

uses
  Vcl.Menus;

type
  /// <summary>This service class provides methods for measuring menu extent.</summary>
  TMenuExtent = class
  public
    /// <summary>Computes the height of a menu with consideration of menu-bar breaks.</summary>
    class function ComputeMenuHeight(Menu: TPopupMenu): Cardinal; static;
  private
    /// <summary>Retrieves the number of menu items and line breaks until the end or the next menu break.</summary>
    class function ScanMenuBeforeMenuBarBreak(Menu: TPopupMenu; StartIndex: Cardinal; var NumOfVisibleItems: Cardinal;
      var NumOfVisibleLines: Cardinal): Cardinal; static;
  private type
    TVisualStyle = (Classic, WindowsXPThemed, Windows7Themed);
  private const
    // The following values are measured on different operating systems (see 'tool/menu')
    BORDER = {Outer=}1 + {Inner=}2;
    NOICON_ITEMHEIGHT: array [TVisualStyle] of Cardinal = (17, 17, 22);
    NOICON_LINEHEIGHT: array [TVisualStyle] of Cardinal = (9, 9, 8);
    NOICON_MULTICOLUMN_ITEMHEIGHT: array [TVisualStyle] of Cardinal = (17, 17, 19);
    NOICON_MULTICOLUMN_LINEHEIGHT: array [TVisualStyle] of Cardinal = (9, 9, 9);
    ICON16_LINEHEIGHT: array [TVisualStyle] of Cardinal = (8, 8, 7);
    // The height of an imaged menu item equals the image height plus basis
    ICON16_MINIMAGEHEIGHT: array [TVisualStyle] of Cardinal = (12, 12, 16);
    ICON16_ITEMBASISHEIGHT: array [TVisualStyle] of Cardinal = (3, 3, 6);
  private
    class function DetermineVisualStyle: TVisualStyle; static;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Vcl.Themes,
  Winapi.Windows;

class function TMenuExtent.ComputeMenuHeight(Menu: TPopupMenu): Cardinal;
var
  Columns: Cardinal;
  StartIndex: Cardinal;
  NumOfVisibleItems: Cardinal;
  NumOfVisibleLines: Cardinal;
  NumOfVisibleItemsInCurrentColumn: Cardinal;
  NumOfVisibleLinesInCurrentColumn: Cardinal;
  VisualStyle: TVisualStyle;
  ItemHeight: Cardinal;
begin
  assert(Menu <> nil);

  NumOfVisibleItems := 0;
  NumOfVisibleLines := 0;
  Columns := 0;
  StartIndex := 0;
  while StartIndex < Cardinal(Menu.Items.Count) do
  begin
    Inc(Columns);
    StartIndex := ScanMenuBeforeMenuBarBreak(Menu, StartIndex, NumOfVisibleItemsInCurrentColumn,
      NumOfVisibleLinesInCurrentColumn);
    NumOfVisibleItems := Max(NumOfVisibleItems, NumOfVisibleItemsInCurrentColumn);
    NumOfVisibleLines := Max(NumOfVisibleLines, NumOfVisibleLinesInCurrentColumn);
  end;

  VisualStyle := DetermineVisualStyle;
  Result := 2 * BORDER;

  if Menu.Images <> nil then
  begin
    assert(Menu.Images <> nil);
    if Menu.Images.Height < 12 then
      raise ENotImplemented.CreateFmt('Image height is expected to be >= 12px, but was %dpx', [Menu.Images.Height]);

    ItemHeight := ICON16_ITEMBASISHEIGHT[VisualStyle] + Max(ICON16_MINIMAGEHEIGHT[VisualStyle], Menu.Images.Height);
    Inc(Result, NumOfVisibleItems * ItemHeight);
    Inc(Result, NumOfVisibleLines * ICON16_LINEHEIGHT[VisualStyle]);
  end
  else
  begin
    if Columns > 1 then
    begin
      Inc(Result, NumOfVisibleItems * NOICON_MULTICOLUMN_ITEMHEIGHT[VisualStyle]);
      Inc(Result, NumOfVisibleLines * NOICON_MULTICOLUMN_LINEHEIGHT[VisualStyle]);
    end
    else
    begin
      Inc(Result, NumOfVisibleItems * NOICON_ITEMHEIGHT[VisualStyle]);
      Inc(Result, NumOfVisibleLines * NOICON_LINEHEIGHT[VisualStyle]);
    end;
  end;
end;

class function TMenuExtent.ScanMenuBeforeMenuBarBreak(Menu: TPopupMenu; StartIndex: Cardinal;
  var NumOfVisibleItems: Cardinal; var NumOfVisibleLines: Cardinal): Cardinal;
var
  Item: TMenuItem;
begin
  assert(Menu <> nil);
  assert(Menu.Items <> nil);

  NumOfVisibleItems := 0;
  NumOfVisibleLines := 0;

  for Result := StartIndex to Menu.Items.Count - 1 do
  begin
    Item := Menu.Items[Result];
    if not Item.Visible then
      Continue;

    if Item.Break = mbBarBreak then
    begin
      if NumOfVisibleItems + NumOfVisibleLines > 0 then
        Exit;
    end;

    if Item.IsLine then
      Inc(NumOfVisibleLines)
    else
      Inc(NumOfVisibleItems);
  end;

  Result := Menu.Items.Count;
end;

class function TMenuExtent.DetermineVisualStyle: TVisualStyle;
begin
  if StyleServices.Enabled then
  begin
    // TODO: verify against the Windows 8
    // if CheckWin32Version(6, 2) then
    // Result := Windows7Themed
    // else
    if CheckWin32Version(6) then
      // Windows Vista or Window 7
      Result := Windows7Themed
    else
      Result := WindowsXPThemed;
  end
  else
    Result := Classic;
end;

end.
