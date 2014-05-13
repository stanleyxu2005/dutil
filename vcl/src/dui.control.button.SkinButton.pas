(**
 * $Id: dui.control.button.SkinButton.pas 822 2014-05-13 17:06:20Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dui.control.button.SkinButton;

interface

uses
  System.Classes,
  Vcl.Buttons,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Imaging.PngImage,
  Vcl.Menus,
  Winapi.Messages,
  Winapi.Windows,
  dui.control.button.SkinButtonImages;

type
  /// <summary>This button control implements all the features of a TButton (except having a Caption) with skin
  /// support.</summary>
  /// <remarks>32-bit alpha blend images are supported.</remarks>
  TSkinButton = class(TCustomControl)
  private type
    TDropDownMenuPopupPosition = (LeftBottom, RightBottom);
  private
    FButtonState: TButtonState;
    FDown: Boolean;
    FDragging: Boolean;
    FDropDownMenu: TPopupMenu;
    FDropDownMenuPopupPosition: TDropDownMenuPopupPosition;
    FDropTime: TDateTime;
    FImages: TSkinButtonImages;
    FIsFocused: Boolean;
    FModalResult: TModalResult;
    FMouseOverButton: Boolean;
    FShowFocus: Boolean;
    FSkipNextClick: Boolean;
    function GetPaintImage: TPngImage;
    procedure DrawPlaceHolderOnCanvas;
    procedure DoDropDownMenu;
    procedure ImageChanged(Sender: TObject);
    procedure WMLButtonDblClk(var Msg: TWMLButtonDown); message WM_LBUTTONDBLCLK;
    procedure WMSetFocus(var Msg: TWMSetFocus); message WM_SETFOCUS;
    procedure WMKillFocus(var Msg: TWMKillFocus); message WM_KILLFOCUS;
    procedure WMSize(var Msg: TWMSize); message WM_SIZE;
    procedure WMEraseBkgnd(var Msg: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CMEnabledChanged(var Msg: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseEnter(var Msg: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Msg: TMessage); message CM_MOUSELEAVE;
  protected
    function GetPalette: HPALETTE; override;
    procedure Loaded; override;
    procedure Paint; override;
    procedure UpdateExclusive;
    procedure ClickButton(DoClick: Boolean);
    procedure Notification(Component: TComponent; Operation: TOperation); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure SetDropDownMenu(Value: TPopupMenu); virtual;
    procedure SetShowFocus(Value: Boolean); virtual;
  public
    constructor Create(Owner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
  published
    property DropDownMenu: TPopupMenu Read FDropDownMenu Write SetDropDownMenu;
    property DropDownMenuPopupPosition: TDropDownMenuPopupPosition Read FDropDownMenuPopupPosition Write
      FDropDownMenuPopupPosition default LeftBottom;
    property Images: TSkinButtonImages read FImages write FImages;
    property ModalResult: TModalResult read FModalResult write FModalResult default mrNone;
    property ShowFocus: Boolean read FShowFocus write SetShowFocus default True;
  published
    property Action;
    property Anchors;
    property Color;
    property Constraints;
    property DoubleBuffered default False;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property Height default 30;
    property ParentColor;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property Width default 80;
    property OnClick;
    property OnContextPopup;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag;
  end;

implementation

uses
  System.DateUtils,
  System.SysUtils,
  Vcl.Forms,
  dui.control.menu.Util;

constructor TSkinButton.Create(Owner: TComponent);
begin
  inherited;

  Width := 80;
  Height := 30;
  TabStop := True;
  ControlStyle := [csCaptureMouse, csOpaque, csDoubleClicks];

  FImages := TSkinButtonImages.Create;
  FImages.OnChange := ImageChanged;

  FShowFocus := True;
  FIsFocused := False;
  FDragging := False;
  FMouseOverButton := False;
  FDropDownMenuPopupPosition := LeftBottom;
end;

destructor TSkinButton.Destroy;
begin
  FImages.Free;
  FImages := nil;

  inherited;
end;

procedure TSkinButton.Loaded;
var
  Msg: TWMSize;
begin
  inherited;

  WMSize(Msg);
end;

procedure TSkinButton.ImageChanged(Sender: TObject);
var
  Msg: TWMSize;
begin
  WMSize(Msg);
  Invalidate;
end;

procedure TSkinButton.WMSize(var Msg: TWMSize);
begin
  if csLoading in ComponentState then
    Exit;

  if not FImages.Normal.Empty then
  begin
    Width := FImages.Normal.Width;
    Height := FImages.Normal.Height;
    Invalidate;
  end;
end;

procedure TSkinButton.WMSetFocus(var Msg: TWMSetFocus);
begin
  inherited;

  FIsFocused := True;
  Invalidate;
end;

procedure TSkinButton.WMKillFocus(var Msg: TWMKillFocus);
begin
  inherited;

  FIsFocused := False;
  Invalidate;
end;

procedure TSkinButton.Paint;
var
  PaintImage: TPngImage;
begin
  if not Enabled and not (csDesigning in ComponentState) then
  begin
    FButtonState := bsDisabled;
    FDragging := False;
  end
  else if FButtonState = bsDisabled then
  begin
    if FDown then
      FButtonState := bsDown
    else
      FButtonState := bsUp;
  end;

  if not FImages.Normal.Empty then
  begin
    PaintImage := GetPaintImage;
    if (csGlassPaint in ControlState) and (PaintImage <> nil) and PaintImage.SupportsPartialTransparency then
      Canvas.Brush.Color := clBlack
    else
      Canvas.Brush.Color := Color;
    Canvas.FillRect(ClientRect);
    Canvas.Draw(0, 0, PaintImage);
  end
  else
    DrawPlaceHolderOnCanvas;
end;

function TSkinButton.GetPaintImage: TPngImage;
begin
  assert(not FImages.Normal.Empty);

  Result := nil;

  case FButtonState of
    bsUp:
      if FMouseOverButton and not FImages.Hover.Empty then
        Result := FImages.Hover
      else if FIsFocused and FShowFocus and not FImages.NormalAndFocused.Empty then
        Result := FImages.NormalAndFocused;

    bsDisabled:
      if not FImages.Disabled.Empty then
        Result := FImages.Disabled;

    bsDown:
      if not FImages.Down.Empty then
        Result := FImages.Down;

    bsExclusive:
      if not FImages.Down.Empty then
        Result := FImages.Down;
  else
    raise ENotImplemented.CreateFmt('Unexpected button state: %d', [Ord(FButtonState)]);
  end;

  if Result = nil then
    // Fallback to default button image
    Result := FImages.Normal;

  assert(not Result.Empty);
end;

procedure TSkinButton.DrawPlaceHolderOnCanvas;
begin
  assert(FImages.Normal.Empty);

  if csGlassPaint in ControlState then
    Exit;

  Canvas.Brush.Color := Color;
  if csDesigning in ComponentState then
  begin
    Canvas.Pen.Style := psDot;
    Canvas.Pen.Color := clBlack;
    Canvas.Brush.Style := bsBDiagonal;
  end;
  Canvas.FillRect(ClientRect);
end;

procedure TSkinButton.Notification(Component: TComponent; Operation: TOperation);
begin
  inherited;

  if Operation = opRemove then
  begin
    if Component = FDropDownMenu then
      FDropDownMenu := nil;
  end;
end;

procedure TSkinButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if Key = VK_RETURN then
    Click
  else if (Key = VK_SPACE) and Enabled then
  begin
    if not FDown then
    begin
      FButtonState := bsDown;
      Repaint;
    end;
    FDragging := True;
  end;
end;

procedure TSkinButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;

  if FDragging then
  begin
    FDragging := False;
    FButtonState := bsUp;
    ClickButton(True);
  end;
end;

procedure TSkinButton.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  ClickIntiatedInternally: Boolean;
begin
  inherited;

  if Enabled and not FIsFocused and IsWindowVisible(Handle) then
    Winapi.Windows.SetFocus(Handle);

  if (Button = mbLeft) and Enabled and Focused then
  begin
    if not FDown then
    begin
      FButtonState := bsDown;
      Repaint;

      if FDropDownMenu <> nil then
      begin
        ClickIntiatedInternally := MilliSecondSpan(System.SysUtils.Now, FDropTime) < 100;
        if (FDropTime > 0) and ClickIntiatedInternally then
        begin
          if ClickIntiatedInternally then
            FSkipNextClick := True;
          FDropTime := 0;
          ReleaseCapture;
        end
        else
        begin
          DoDropDownMenu; // code will be blocked until the popup menu disappears
          FSkipNextClick := True;
          FDropTime := System.SysUtils.Now;

          inherited MouseUp(Button, Shift, X, Y); // generates a MouseUp event
          FButtonState := bsUp;
          Repaint;
        end;
      end;
    end;
    FDragging := True;
  end;
end;

procedure TSkinButton.DoDropDownMenu;
var
  ScreenRect: TRect;
  Offset: TPoint;
  Pt: TPoint;
begin
  assert(FDropDownMenu <> nil);

  ScreenRect := ClientRect;
  Offset := ClientToScreen(ScreenRect.TopLeft);
  OffsetRect(ScreenRect, Offset.X, Offset.Y);

  if FDropDownMenuPopupPosition = LeftBottom then
  begin
    FDropDownMenu.Alignment := paLeft;
    Pt := TUtil.ComputeLeftBottomPopupPosition(FDropDownMenu, ScreenRect);
  end
  else
  begin
    FDropDownMenu.Alignment := paRight;
    Pt := TUtil.ComputeRightBottomPopupPosition(FDropDownMenu, ScreenRect);
  end;

  FDropDownMenu.PopupComponent := Self;
  FDropDownMenu.Popup(Pt.X, Pt.Y);
end;

procedure TSkinButton.ClickButton(DoClick: Boolean);
begin
  Repaint;
  if DoClick then
    Click;
end;

procedure TSkinButton.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  DoClick: Boolean;
begin
  inherited;

  if FDragging then
  begin
    FDragging := False;
    DoClick := (X >= 0) and (X < ClientWidth) and (Y >= 0) and (Y <= ClientHeight);
    UpdateExclusive;

    ClickButton(DoClick);
  end;
end;

procedure TSkinButton.Click;
var
  Form: TCustomForm;
begin
  if FSkipNextClick then
  begin
    FSkipNextClick := False;
    Exit;
  end;

  if FDropDownMenu <> nil then
    MouseDown(mbLeft, [ssLeft], 0, 0)
  else
  begin
    Form := GetParentForm(Self);
    if Form <> nil then
      Form.ModalResult := ModalResult;

    inherited;
  end;
end;

function TSkinButton.GetPalette: HPALETTE;
begin
  Result := FImages.Normal.Palette;
end;

procedure TSkinButton.UpdateExclusive;
begin
  FButtonState := bsUp;
end;

procedure TSkinButton.SetDropDownMenu(Value: TPopupMenu);
begin
  if Value <> FDropDownMenu then
  begin
    FDropDownMenu := Value;
    if Value <> nil then
      Value.FreeNotification(Self);
  end;
end;

procedure TSkinButton.SetShowFocus(Value: Boolean);
begin
  if FShowFocus <> Value then
  begin
    FShowFocus := Value;
    Invalidate;
  end;
end;

procedure TSkinButton.WMLButtonDblClk(var Msg: TWMLButtonDown);
begin
  inherited;

  if FDown then
    DblClick;
end;

procedure TSkinButton.WMEraseBkgnd(var Msg: TWMEraseBkgnd);
begin
  Msg.Result := {Handled=}Integer(True);
end;

procedure TSkinButton.CMEnabledChanged(var Msg: TMessage);
begin
  inherited;

  Invalidate;
end;

procedure TSkinButton.CMMouseEnter(var Msg: TMessage);
begin
  FMouseOverButton := True;
  inherited;

  if not FImages.Hover.Empty then
    Invalidate;
end;

procedure TSkinButton.CMMouseLeave(var Msg: TMessage);
begin
  FMouseOverButton := False;
  inherited;

  if not FImages.Hover.Empty then
    Invalidate;
end;

end.
