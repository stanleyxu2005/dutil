(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dui.metrics.TextExtent;

interface

uses
  Winapi.Windows;

type
  /// <summary>This service class provides methods for measuring text extent.</summary>
  TTextExtent = class
    /// <summary>Computes the width and height of the specified string of text (no text wrapping).</summary>
    /// <exception cref="EOSError">When failed to retrieve font extent.</exception>
    class function ComputeTextExtent(const Text: string; FontHandle: HFONT): TSize; static;
    /// <summary>Computes the width and height of the specified string of (multiline) text.</summary>
    /// <exception cref="EOSError">When failed to retrieve font extent.</exception>
    class function ComputeMultiLineTextExtent(Text: string; FontHandle: HFONT; LineSpacing: Integer = 0): TSize; static;
  end;

implementation

uses
  System.SysUtils;

class function TTextExtent.ComputeTextExtent(const Text: string; FontHandle: HFONT): TSize;
var
  ScreenDeviceContext: HDC;
  ExistingFontHandle: HFONT;
  Success: Boolean;
begin
  assert(FontHandle > 0);

  Result.cx := 0;
  Result.cy := 0;

  ScreenDeviceContext := GetDC(0);
  if ScreenDeviceContext <> 0 then
    try
      ExistingFontHandle := SelectObject(ScreenDeviceContext, FontHandle);
      Success := GetTextExtentPoint32(ScreenDeviceContext, PChar(Text), Length(Text), Result);
      SelectObject(ScreenDeviceContext, ExistingFontHandle);
      if not Success then
        RaiseLastOSError;
    finally
      ReleaseDC(0, ScreenDeviceContext);
    end;
end;

class function TTextExtent.ComputeMultiLineTextExtent(Text: string; FontHandle: HFONT; LineSpacing: Integer = 0): TSize;
const
  LINE_BREAK_LENGTH = Length(sLineBreak);
var
  P: Integer;
  LineExtent: TSize;
begin
  assert(FontHandle > 0);
  assert(LineSpacing >= 0);

  Result.cx := 0;
  Result.cy := 0;

  P := Pos(sLineBreak, Text);
  while P > 0 do
  begin
    LineExtent := ComputeTextExtent(Copy(Text, 1, P - 1), FontHandle);
    if Result.cx < LineExtent.cx then
      Result.cx := LineExtent.cx;
    Inc(Result.cy, LineExtent.cy + LineSpacing);

    Delete(Text, 1, P + LINE_BREAK_LENGTH - 1);
    P := Pos(sLineBreak, Text);
  end;

  LineExtent := ComputeTextExtent(Text, FontHandle);
  if Result.cx < LineExtent.cx then
    Result.cx := LineExtent.cx;
  Inc(Result.cy, LineExtent.cy);
end;

end.
