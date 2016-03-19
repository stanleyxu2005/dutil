(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dui.imaging.Convert;

interface

uses
  Vcl.Graphics,
  System.Classes;

type
  /// <summary>This service class provides methods for converting graphics.</summary>
  TConvert = class
  private type
    TPictureQuality = 1..100;
  public
    // <summary>Converts a bitmap to a JPEG stream.</summary>
    class function ToJPEGStream(Bitmap: TBitmap; Quality: TPictureQuality = 85): TMemoryStream; static;
    // <summary>Converts a bitmap to a PNG stream.</summary>
    class function ToPNGStream(Bitmap: TBitmap): TMemoryStream; static;
  end;

implementation

uses
  Vcl.Imaging.jpeg,
  Vcl.Imaging.pngimage;

class function TConvert.ToJPEGStream(Bitmap: TBitmap; Quality: TPictureQuality = 85): TMemoryStream;
var
  Image: TJPEGImage;
begin
  assert(Bitmap <> nil);
  assert(not Bitmap.Empty);

  Image := TJPEGImage.Create;
  try
    Image.Assign(Bitmap);
    Result := TMemoryStream.Create;
    Image.SaveToStream(Result);
    Result.Position := 0;
  finally
    Image.Free;
  end;
end;

class function TConvert.ToPNGStream(Bitmap: TBitmap): TMemoryStream;
var
  Image: TPngImage;
begin
  assert(Bitmap <> nil);
  assert(not Bitmap.Empty);

  Image := TPngImage.Create;
  try
    // Note that use Image.Assign(BMP) will raise an exception.
    Image.AssignHandle(Bitmap.Handle, False, 0);
    Result := TMemoryStream.Create;
    Image.SaveToStream(Result);
    Result.Position := 0;
  finally
    Image.Free;
  end;
end;

end.
