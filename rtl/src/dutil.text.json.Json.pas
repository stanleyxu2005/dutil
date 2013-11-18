(**
 * $Id: dutil.text.json.Json.pas 412 2012-04-12 08:24:25Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.text.json.Json;

interface

uses
  superobject { An universal object serialization framework with Json support };

type
  /// <summary>This service class provides methods for JSON.</summary>
  TJson = class
  public
    /// <summary>Returns the string representation of the specified JSON value.</summary>
    class function Print(const Composite: ISuperObject): string; static;
  end;

implementation

class function TJson.Print(const Composite: ISuperObject): string;
begin
  if Composite = nil then
    Result := 'null'
  else
    Result := Composite.AsJson;
end;

end.
