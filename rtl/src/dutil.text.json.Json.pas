(**
 * $Id: dutil.text.json.Json.pas 835 2014-05-21 09:50:29Z QXu $
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
    /// <summary>Converts a dynamic string array to a JSON array.</summary>
    class function CreateArray(const DynArray: TArray<string>): ISuperObject; overload; static;
    /// <summary>Converts a dynamic boolean array to a JSON array.</summary>
    class function CreateArray(const DynArray: TArray<Boolean>): ISuperObject; overload; static;
    /// <summary>Converts a dynamic integer array to a JSON array.</summary>
    class function CreateArray(const DynArray: TArray<Integer>): ISuperObject; overload; static;
    /// <summary>Converts a dynamic non-negative integer array to a JSON array.</summary>
    class function CreateArray(const DynArray: TArray<Cardinal>): ISuperObject; overload; static;
  end;

implementation

class function TJson.Print(const Composite: ISuperObject): string;
begin
  if Composite = nil then
    Result := 'null'
  else
    Result := Composite.AsJson;
end;

class function TJson.CreateArray(const DynArray: TArray<String>): ISuperObject;
var
  Item: string;
begin
  Result := TSuperObject.Create(stArray);
  for Item in DynArray do
    Result.AsArray.Add(SO(Item));
end;

class function TJson.CreateArray(const DynArray: TArray<Boolean>): ISuperObject;
var
  Item: Boolean;
begin
  Result := TSuperObject.Create(stArray);
  for Item in DynArray do
    Result.AsArray.Add(SO(Item));
end;

class function TJson.CreateArray(const DynArray: TArray<Integer>): ISuperObject;
var
  Item: Integer;
begin
  Result := TSuperObject.Create(stArray);
  for Item in DynArray do
    Result.AsArray.Add(SO(Item));
end;

class function TJson.CreateArray(const DynArray: TArray<Cardinal>): ISuperObject;
var
  Item: Cardinal;
begin
  Result := TSuperObject.Create(stArray);
  for Item in DynArray do
    Result.AsArray.Add(SO(Item));
end;

end.
