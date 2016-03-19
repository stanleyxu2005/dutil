(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dui.control.button.SkinButtonImages;

interface

uses
  System.Classes,
  Vcl.Imaging.PngImage;

type
  /// <summary>This gui control holds images of different button states.</summary>
  TSkinButtonImages = class(TPersistent)
  private
    FNormal: TPngImage;
    FNormalAndFocused: TPngImage;
    FHover: TPngImage;
    FDown: TPngImage;
    FDisabled: TPngImage;
    FOnChange: TNotifyEvent;
    procedure BitmapsChanged(Sender: TObject);
  protected
    procedure SetNormal(Value: TPngImage); virtual;
    procedure SetNormalAndFocused(Value: TPngImage); virtual;
    procedure SetHover(Value: TPngImage); virtual;
    procedure SetDown(Value: TPngImage); virtual;
    procedure SetDisabled(Value: TPngImage); virtual;
  public
    constructor Create;
    destructor Destroy; override;
  published
    property Normal: TPngImage read FNormal write SetNormal;
    property NormalAndFocused: TPngImage read FNormalAndFocused write SetNormalAndFocused;
    property Hover: TPngImage read FHover write SetHover;
    property Down: TPngImage read FDown write SetDown;
    property Disabled: TPngImage read FDisabled write SetDisabled;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

constructor TSkinButtonImages.Create;
begin
  inherited;

  FNormal := TPngImage.Create;
  FNormal.OnChange := BitmapsChanged;
  FNormalAndFocused := TPngImage.Create;
  FNormalAndFocused.OnChange := BitmapsChanged;
  FHover := TPngImage.Create;
  FHover.OnChange := BitmapsChanged;
  FDown := TPngImage.Create;
  FDown.OnChange := BitmapsChanged;
  FDisabled := TPngImage.Create;
  FDisabled.OnChange := BitmapsChanged;
end;

destructor TSkinButtonImages.Destroy;
begin
  FDisabled.Free;
  FDisabled := nil;
  FDown.Free;
  FDown := nil;
  FHover.Free;
  FHover := nil;
  FNormalAndFocused.Free;
  FNormalAndFocused := nil;
  FNormal.Free;
  FNormal := nil;

  inherited;
end;

procedure TSkinButtonImages.SetNormal(Value: TPngImage);
begin
  FNormal.Assign(Value);
end;

procedure TSkinButtonImages.SetNormalAndFocused(Value: TPngImage);
begin
  FNormalAndFocused.Assign(Value);
end;

procedure TSkinButtonImages.SetHover(Value: TPngImage);
begin
  FHover.Assign(Value);
end;

procedure TSkinButtonImages.SetDown(Value: TPngImage);
begin
  FDown.Assign(Value);
end;

procedure TSkinButtonImages.SetDisabled(Value: TPngImage);
begin
  FDisabled.Assign(Value);
end;

procedure TSkinButtonImages.BitmapsChanged(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

end.
