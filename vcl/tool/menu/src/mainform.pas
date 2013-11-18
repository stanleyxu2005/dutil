unit mainform;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Menus, ImgList, ExtCtrls, Generics.Collections;

type
  TMainWindow = class(TForm)
    btnRunNoIcon: TButton;
    tmTakeScreenShotAndCloseMenu: TTimer;
    lbResults: TListBox;
    tmMethodExecuter: TTimer;
    btnRunIcon16: TButton;
    btnRunIcon18: TButton;
    btnRunIcon13: TButton;
    btnRunIcon12: TButton;
    btnRunIcon15: TButton;
    cbVerifyResults: TCheckBox;
    procedure btnRunNoIconClick(Sender: TObject);
    procedure tmTakeScreenShotAndCloseMenuTimer(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure tmMethodExecuterTimer(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnRunIcon16Click(Sender: TObject);
    procedure btnRunIcon18Click(Sender: TObject);
    procedure btnRunIcon13Click(Sender: TObject);
    procedure btnRunIcon12Click(Sender: TObject);
    procedure btnRunIcon15Click(Sender: TObject);
  private
    FMeasureTests: TList<TThreadMethod>;
    FResults: TList<Cardinal>;
    FTestPopupMenu: TPopupMenu;
    FNumOfVisibleItems: Cardinal;
    FNumOfVisibleLines: Cardinal;
    FFirstColumn: Boolean;
    function ExcludeNonClientArea(const Rect: TRect): TRect;
    function ExtractMenuArea(Bitmap: TBitmap): TBitmap;
  private
    procedure UpdateButtonStates(Enabled: Boolean);
    procedure CreateNoImagePopupMenuAndRunTests;
    procedure CreateImagedPopupMenuAndRunTests(ImageWidth: Cardinal);
    function CreateTestImageList(Width: Cardinal): TImageList;
    function CreateTestPopupMenu(var NumOfVisibleItems: Cardinal; var NumOfVisibleLines: Cardinal): TPopupMenu;
    class function NewMenuItem(Number: Integer): TMenuItem; static;
  private const
    LONGEST_MENU_TEXT = 'This is the longest menu text';
  private
    procedure MeasurePopupMenuExtent;
    procedure AddItemAndMeasurePopupMenuExtent;
    procedure AddLineAndMeasurePopupMenuExtent;
    procedure AddBarBreakAndMeasurePopupMenuExtent;
    procedure SummarizeMeasureExtentResult;
  end;

var
  MainWindow: TMainWindow;

implementation

{$R *.dfm}

uses
  Types,
  dui.metrics.MenuExtent,
  dui.metrics.TextExtent,
  dui.sys.ScreenShot,
  dui.sys.UserInput;

procedure TMainWindow.FormCreate(Sender: TObject);
begin
  lbResults.Color := Color;

  FResults := TList<Cardinal>.Create;
  FMeasureTests := TList<TThreadMethod>.Create;
end;

procedure TMainWindow.FormDestroy(Sender: TObject);
begin
  FMeasureTests.Free;
  FMeasureTests := nil;
  FResults.Free;
  FResults := nil;
end;

procedure TMainWindow.UpdateButtonStates(Enabled: Boolean);
var
  I: Integer;
begin
  for I := 0 to ComponentCount - 1 do
    if Components[I] is TButton then
      TButton(Components[I]).Enabled := Enabled;
end;

procedure TMainWindow.CreateNoImagePopupMenuAndRunTests;
begin
  UpdateButtonStates({Enabled=}False);

  Self.lbResults.Clear;
  FResults.Clear;
  FMeasureTests.Clear;

  if FTestPopupMenu <> nil then
    FTestPopupMenu.Free;
  FTestPopupMenu := CreateTestPopupMenu(FNumOfVisibleItems, FNumOfVisibleLines);
  FFirstColumn := True;

  FMeasureTests.Add(MeasurePopupMenuExtent);
  FMeasureTests.Add(AddItemAndMeasurePopupMenuExtent);
  FMeasureTests.Add(AddLineAndMeasurePopupMenuExtent);
  FMeasureTests.Add(AddItemAndMeasurePopupMenuExtent);
  FMeasureTests.Add(AddLineAndMeasurePopupMenuExtent);
  FMeasureTests.Add(AddItemAndMeasurePopupMenuExtent);
  FMeasureTests.Add(AddBarBreakAndMeasurePopupMenuExtent);
  FMeasureTests.Add(AddItemAndMeasurePopupMenuExtent);
  FMeasureTests.Add(AddLineAndMeasurePopupMenuExtent);
  FMeasureTests.Add(SummarizeMeasureExtentResult);

  tmMethodExecuter.Enabled := True;
end;

procedure TMainWindow.CreateImagedPopupMenuAndRunTests(ImageWidth: Cardinal);
begin
  tmMethodExecuter.Enabled := False;
  try
    CreateNoImagePopupMenuAndRunTests;

    FTestPopupMenu.Images := CreateTestImageList(ImageWidth);
    assert(FTestPopupMenu.Images.Count > 0);
    assert(FTestPopupMenu.Items.Count > 0);
    assert(not FTestPopupMenu.Items[0].IsLine);

    FTestPopupMenu.Items[0].ImageIndex := 0;
  finally
    tmMethodExecuter.Enabled := True;
  end;
end;

function TMainWindow.CreateTestImageList(Width: Cardinal): TImageList;
var
  Icon: TIcon;
begin
  assert(Width >= 12);

  Result := TImageList.Create(Self);
  Result.Width := Width;
  Result.Height := Width;

  Icon := TIcon.Create;
  try
    Icon.LoadFromResourceName(HInstance, 'REFRESH');
    assert(Icon.HandleAllocated);
    Result.AddIcon(Icon);
  finally
    Icon.Free;
  end;

  assert(Result.Count = 1);
end;

function TMainWindow.CreateTestPopupMenu(var NumOfVisibleItems: Cardinal; var NumOfVisibleLines: Cardinal): TPopupMenu;
begin
  Result := TPopupMenu.Create(Self);
  Result.Items.Add(NewMenuItem(1));
  Result.Items.Add(NewMenuItem(2));
  Result.Items.Add(NewLine);
  Result.Items.Add(NewMenuItem(3));
  Result.Items.Add(NewMenuItem(4));
  Result.Items[4].Visible := False;

  NumOfVisibleItems := 3; // the fourth item is invisible, it is ignored
  NumOfVisibleLines := 1;
end;

class function TMainWindow.NewMenuItem(Number: Integer): TMenuItem;
begin
  Result := NewItem(Format('Menu Item #%d', [Number]), 0, False, True, nil, 0, '');
end;

procedure TMainWindow.btnRunNoIconClick(Sender: TObject);
begin
  CreateNoImagePopupMenuAndRunTests;
end;

procedure TMainWindow.btnRunIcon16Click(Sender: TObject);
begin
  CreateImagedPopupMenuAndRunTests(16);
end;

procedure TMainWindow.btnRunIcon18Click(Sender: TObject);
begin
  CreateImagedPopupMenuAndRunTests(18);
end;

procedure TMainWindow.btnRunIcon15Click(Sender: TObject);
begin
  CreateImagedPopupMenuAndRunTests(15);
end;

procedure TMainWindow.btnRunIcon13Click(Sender: TObject);
begin
  CreateImagedPopupMenuAndRunTests(13);
end;

procedure TMainWindow.btnRunIcon12Click(Sender: TObject);
begin
  CreateImagedPopupMenuAndRunTests(12);
end;

procedure TMainWindow.tmMethodExecuterTimer(Sender: TObject);
var
  MeasureTest: TThreadMethod;
begin
  TTimer(Sender).Enabled := False;

  if FMeasureTests.Count > 0 then
  begin
    MeasureTest := FMeasureTests.Items[0];
    FMeasureTests.Delete(0);

    assert(@MeasureTest <> nil);
    MeasureTest;
  end;
end;

procedure TMainWindow.tmTakeScreenShotAndCloseMenuTimer(Sender: TObject);
var
  Rect: TRect;
  ScreenShot: TBitmap;
  MenuImage: TBitmap;
  Delta: Integer;
  Expected: Integer;
begin
  TTimer(Sender).Enabled := False;

  Rect := BoundsRect;
  OffsetRect(Rect, Screen.MonitorFromRect(Rect).Left, 0);
  Rect := ExcludeNonClientArea(Rect);

  ScreenShot := TScreenShot.TakeFromDesktop(Rect); // TakeActiveWindow() is not able to capture the menu window
  try
    MenuImage := ExtractMenuArea(ScreenShot);
    try
      if FResults.Count > 0 then
        Delta := MenuImage.Height - Integer(FResults[FResults.Count - 1])
      else
        Delta := 0;

      Expected := TMenuExtent.ComputeMenuHeight(FTestPopupMenu);
      Self.lbResults.Items.Add(Format('Height: %dpx, delta: %dpx, Width: %dpx, Text: %dpx', [MenuImage.Height, Delta,
          MenuImage.Width, TTextExtent.ComputeTextExtent(LONGEST_MENU_TEXT, Screen.MenuFont.Handle).cx]));

      if cbVerifyResults.Checked then
      begin
        if Expected <> MenuImage.Height then
          Application.MessageBox(PChar(Format('Expected is %dpx, but actual was: %dpx', [Expected, MenuImage.Height])),
            'Error');
      end;

      FResults.Add(MenuImage.Height);
    finally
      MenuImage.Free;
    end;
  finally
    ScreenShot.Free;
  end;

  TUserInput.SendKeyPress(VK_ESCAPE);
  if FMeasureTests.Count > 0 then
    tmMethodExecuter.Enabled := True
  else
    UpdateButtonStates({Enabled=}True);
end;

function TMainWindow.ExcludeNonClientArea(const Rect: TRect): TRect;
begin
  Result := Types.Rect(Rect.Left + 10, Rect.Top + 30, Rect.Right - 200, Rect.Bottom - 30 - cbVerifyResults.Top);
end;

function TMainWindow.ExtractMenuArea(Bitmap: TBitmap): TBitmap;
var
  MenuRect: TRect;
  Y: Integer;
  X: Integer;
begin
  assert(Bitmap <> nil);

  MenuRect := Rect(0, 0, 0, 0);

  for Y := 0 to Bitmap.Height - 1 do
    for X := 0 to Bitmap.Width - 1 do
    begin
      if Bitmap.Canvas.Pixels[X, Y] <> Color then
      begin
        MenuRect.Top := Y;
        MenuRect.Left := X;
        Break;
      end;
      if MenuRect.Top > 0 then
        Break;
    end;

  for Y := Bitmap.Height - 1 downto 0 do
    for X := Bitmap.Width - 1 downto 0 do
    begin
      if Bitmap.Canvas.Pixels[X, Y] <> Color then
      begin
        MenuRect.Bottom := Y;
        MenuRect.Right := X;
        Break;
      end;
      if MenuRect.Bottom > 0 then
        Break;
    end;

  Result := TBitmap.Create;
  Result.Width := MenuRect.Right - MenuRect.Left + 1;
  Result.Height := MenuRect.Bottom - MenuRect.Top + 1;
  Windows.BitBlt(Result.Canvas.Handle, 0, 0, Result.Width, Result.Height, Bitmap.Canvas.Handle, MenuRect.Left,
    MenuRect.Top, SRCCOPY);
end;

(**
 * Tests should be defined below
 *)
procedure TMainWindow.MeasurePopupMenuExtent;
var
  Pt: TPoint;
begin
  assert(FTestPopupMenu <> nil);

  tmTakeScreenShotAndCloseMenu.Enabled := True;
  Pt := ClientToScreen(Point(10, 10));
  FTestPopupMenu.Popup(Pt.X, Pt.Y);
end;

procedure TMainWindow.AddItemAndMeasurePopupMenuExtent;
var
  Item: TMenuItem;
begin
  assert(FTestPopupMenu <> nil);

  if FFirstColumn then
    Inc(FNumOfVisibleItems);
  Item := NewMenuItem(-1);
  Item.Caption := LONGEST_MENU_TEXT;
  FTestPopupMenu.Items.Insert(1, Item);
  MeasurePopupMenuExtent;
end;

procedure TMainWindow.AddLineAndMeasurePopupMenuExtent;
begin
  if FFirstColumn then
    Inc(FNumOfVisibleLines);
  FTestPopupMenu.Items.Insert(1, Menus.NewLine);
  MeasurePopupMenuExtent;
end;

procedure TMainWindow.AddBarBreakAndMeasurePopupMenuExtent;
var
  Item: TMenuItem;
begin
  assert(FTestPopupMenu <> nil);

  FFirstColumn := False;
  Item := NewMenuItem(-1);
  Item.Break := mbBarBreak;
  FTestPopupMenu.Items.Add(Item);
  FTestPopupMenu.Items.Add(NewMenuItem(-1));
  MeasurePopupMenuExtent;
end;

procedure TMainWindow.SummarizeMeasureExtentResult;
const
  BORDER = 1;
var
  ItemHeight: Cardinal;
  LineHeight: Cardinal;
  DoubleSpacing: Cardinal;
begin
  assert(FResults.Count >= 6);

  ItemHeight := FResults[1] - FResults[0];
  LineHeight := FResults[2] - FResults[1];
  assert(FResults[3] - FResults[2] = ItemHeight);
  assert(FResults[4] - FResults[3] = LineHeight);
  DoubleSpacing := (FResults[5] - 2 * BORDER - FNumOfVisibleItems * ItemHeight - FNumOfVisibleLines * LineHeight);
  assert(DoubleSpacing mod 2 = 0, Format('%d is expected to be odd', [DoubleSpacing]));

  lbResults.Items.Add(Format('Border: %dpx, Spacing: %dpx, Item: %dpx, Line: %dpx', [BORDER, DoubleSpacing div 2,
      ItemHeight, LineHeight]));

  UpdateButtonStates({Enabled=}True);
end;

end.
