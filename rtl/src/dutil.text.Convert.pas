(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dutil.text.Convert;

interface

type
  /// <summary>This service class provides methods for converting between string and other value types.</summary>
  TConvert = class
  public
    /// <summary>Converts a string that represents a non-negative integer into a number.</summary>
    /// <exceptions cref="EConvertError">When S does not represent a valid number</exceptions>
    class function StrToUInt(const S: string): Cardinal; static;
  end;

implementation

uses
  System.SysUtils;

class function TConvert.StrToUInt(const S: string): Cardinal;
var
  Int64Value: Int64;
begin
  Int64Value := StrToInt64(S);
  if (Int64Value >= 0) and (Int64Value <= High(Cardinal)) then
    Result := Int64Value
  else
    raise EConvertError.CreateFmt('''%s'' is not a valid cardinal value', [S]);
end;

end.
