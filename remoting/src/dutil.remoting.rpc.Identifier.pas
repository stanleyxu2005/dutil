(**
 * $Id: dutil.remoting.rpc.Identifier.pas 786 2014-04-27 15:44:17Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.rpc.Identifier;

interface

uses
  superobject { An universal object serialization framework with Json support };

type
  /// <summary>This immutable record represents a RPC request identifier.</summary>
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
    function Equals(const Other: TIdentifier): Boolean;
  end;

implementation

uses
  System.SysUtils;

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

function TIdentifier.Equals(const Other: TIdentifier): Boolean;
begin
  Result := Other.ToString = ToString;
end;

end.
