(**
 * $Id: dutil.net.jsonrpc.message.Identifier.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.jsonrpc.message.Identifier;

interface

uses
  superobject { An universal object serialization framework with Json support };

type
  /// <summary>This immutable record represents a JSON-RPC request identifier.</summary>
  TIdentifier = record
  private
    FValue: ISuperObject;
  public
    property Value: ISuperObject read FValue;
  public
    class function NullIdentifier: TIdentifier; static;
    class function StringIdentifier(const Value: string): TIdentifier; static;
    class function NumberIdentifier(Value: Integer): TIdentifier; static;
    /// <exception cref="EArgumentException">Invalid identifier type</exception>
    class function FromValue(const Value: ISuperObject): TIdentifier; static;
    function ToString: string;
    function Valid: Boolean;
  end;

implementation

uses
  SysUtils;

class function TIdentifier.NullIdentifier: TIdentifier;
begin
  Result.FValue := nil;
end;

class function TIdentifier.StringIdentifier(const Value: string): TIdentifier;
begin
  Result.FValue := SO(Value);
end;

class function TIdentifier.NumberIdentifier(Value: Integer): TIdentifier;
begin
  Result.FValue := SO(Value);
end;

class function TIdentifier.FromValue(const Value: ISuperObject): TIdentifier;
begin
  Result.FValue := Value;
  if not Result.Valid then
    raise EArgumentException.Create('Invalid identifier type');
end;

function TIdentifier.ToString: string;
begin
  if FValue = nil then
    Result := ''
  else
    Result := FValue.AsJson;
end;

function TIdentifier.Valid: Boolean;
begin
  Result := (FValue = nil) or (FValue.DataType in [TSuperType.stNull, TSuperType.stString, TSuperType.stInt]);
end;

end.
