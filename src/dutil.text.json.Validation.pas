(**
 * $Id: dutil.text.json.Validation.pas 712 2013-11-11 17:52:22Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.text.json.Validation;

interface

uses
  Types,
  superobject { An universal object serialization framework with Json support };

type
  /// <summary>This service class provides methods for simple JSON validity checks.</summary>
  TValidation = class
  public
    /// <exception cref="EJsonException">When the JSON object has a member with the specified name but the member is
    /// not a string.</exception>
    class function RequireStrMember(const Composite: ISuperObject; const Name: string): string; static;
    /// <exception cref="EJsonException">When the JSON object has a member with the specified name but the member is
    /// not a boolean.</exception>
    class function RequireBoolMember(const Composite: ISuperObject; const Name: string): Boolean; static;
    /// <exception cref="EJsonException">When the JSON object has a member with the specified name but the member is
    /// not an integer.</exception>
    class function RequireIntMember(const Composite: ISuperObject; const Name: string): Integer; static;
    /// <exception cref="EJsonException">When the JSON object has a member with the specified name but the member is
    /// not a non-negative integer.</exception>
    class function RequireUIntMember(const Composite: ISuperObject; const Name: string): Cardinal; static;
    /// <exception cref="EJsonException">When the JSON object has a member with the specified name but the member is
    /// not a string array.</exception>
    class function RequireStrArrayMember(const Composite: ISuperObject; const Name: string): TStringDynArray; static;
    /// <exception cref="EJsonException">When the JSON object has a member with the specified name but the member is
    /// not a boolean array.</exception>
    class function RequireBoolArrayMember(const Composite: ISuperObject; const Name: string): TBooleanDynArray; static;
    /// <exception cref="EJsonException">When the JSON object has a member with the specified name but the member is
    /// not an integer array.</exception>
    class function RequireIntArrayMember(const Composite: ISuperObject; const Name: string): TIntegerDynArray; static;
    /// <exception cref="EJsonException">When the JSON object has a member with the specified name but the member is
    /// not a non-negative integer array.</exception>
    class function RequireUIntArrayMember(const Composite: ISuperObject; const Name: string): TCardinalDynArray; static;
    /// <exception cref="EJsonException">When the specified value is not a string.</exception>
    class function RequireStr(const Value: ISuperObject): string; static;
    /// <exception cref="EJsonException">When the specified value is not a boolean.</exception>
    class function RequireBool(const Value: ISuperObject): Boolean; static;
    /// <exception cref="EJsonException">When the specified value is not an integer.</exception>
    class function RequireInt(const Value: ISuperObject): Integer; static;
    /// <exception cref="EJsonException">When the specified value is not a non-negative integer.</exception>
    class function RequireUInt(const Value: ISuperObject): Cardinal; static;
    /// <exception cref="EJsonException">When the specified value is not a string array.</exception>
    class function RequireStrArray(const Value: ISuperObject): TStringDynArray; static;
    /// <exception cref="EJsonException">When the specified value is not a boolean array.</exception>
    class function RequireBoolArray(const Value: ISuperObject): TBooleanDynArray; static;
    /// <exception cref="EJsonException">When the specified value is not an integer array.</exception>
    class function RequireIntArray(const Value: ISuperObject): TIntegerDynArray; static;
    /// <exception cref="EJsonException">When the specified value is not a non-negative array.</exception>
    class function RequireUIntArray(const Value: ISuperObject): TCardinalDynArray; static;
  private
    /// <exception cref="EJsonException">When the JSON object has no member with the specified name.</exception>
    class function RequireMember(const Composite: ISuperObject; const Name: string;
      DataType: TSuperType): ISuperObject; static;
    /// <exception cref="EJsonException">When the specified value is not a super array.</exception>
    class function RequireArray(const Value: ISuperObject): TSuperArray; static;
    /// <exception cref="EJsonException">When the specified value is not a JSON object.</exception>
    class procedure Require(const Value: ISuperObject; DataType: TSuperType); static;
  end;

implementation

uses
  SysUtils,
  supertypes { An universal object serialization framework with Json support },
  dutil.core.Exception;

class function TValidation.RequireStrMember(const Composite: ISuperObject; const Name: string): string;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := RequireMember(Composite, Name, TSuperType.stString);
  Result := Member.AsString;
end;

class function TValidation.RequireBoolMember(const Composite: ISuperObject; const Name: string): Boolean;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := RequireMember(Composite, Name, TSuperType.stBoolean);
  Result := Member.AsBoolean;
end;

class function TValidation.RequireIntMember(const Composite: ISuperObject; const Name: string): Integer;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := RequireMember(Composite, Name, TSuperType.stInt);
  Result := Member.AsInteger;
end;

class function TValidation.RequireUIntMember(const Composite: ISuperObject; const Name: string): Cardinal;
var
  Member: ISuperObject;
  Number: SuperInt;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := RequireMember(Composite, Name, TSuperType.stInt);
  Number := Member.AsInteger;
  if Number < 0 then
    raise EJsonException.Create(Format('Non-negative integer required but got %d', [Number]));

  Result := Number;
end;

class function TValidation.RequireStrArrayMember(const Composite: ISuperObject; const Name: string): TStringDynArray;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := RequireMember(Composite, Name, TSuperType.stArray);
  Result := RequireStrArray(Member);
end;

class function TValidation.RequireBoolArrayMember(const Composite: ISuperObject; const Name: string): TBooleanDynArray;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := RequireMember(Composite, Name, TSuperType.stArray);
  Result := RequireBoolArray(Member);
end;

class function TValidation.RequireIntArrayMember(const Composite: ISuperObject; const Name: string): TIntegerDynArray;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := RequireMember(Composite, Name, TSuperType.stArray);
  Result := RequireIntArray(Member);
end;

class function TValidation.RequireUIntArrayMember(const Composite: ISuperObject; const Name: string): TCardinalDynArray;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := RequireMember(Composite, Name, TSuperType.stArray);
  Result := RequireUIntArray(Member);
end;

class function TValidation.RequireMember(const Composite: ISuperObject; const Name: string;
  DataType: TSuperType): ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Result := Composite.O[Name];

  if Result = nil then
    raise EJsonException.Create(Format('"%s" element required', [Name]));

  if Result.DataType <> DataType then
    raise EJsonException.Create(Format('Data type %d required but got %s', [Ord(DataType), Result.AsJSon]));
end;

class function TValidation.RequireStr(const Value: ISuperObject): string;
begin
  assert(Value <> nil);

  Require(Value, TSuperType.stString);
  Result := Value.AsString;
end;

class function TValidation.RequireBool(const Value: ISuperObject): Boolean;
begin
  assert(Value <> nil);

  Require(Value, TSuperType.stBoolean);
  Result := Value.AsBoolean;
end;

class function TValidation.RequireInt(const Value: ISuperObject): Integer;
begin
  assert(Value <> nil);

  Require(Value, TSuperType.stInt);
  Result := Value.AsInteger;
end;

class function TValidation.RequireUInt(const Value: ISuperObject): Cardinal;
var
  Number: SuperInt;
begin
  assert(Value <> nil);

  Require(Value, TSuperType.stInt);
  Number := Value.AsInteger;
  if Number < 0 then
    raise EJsonException.Create(Format('Non-negative integer required but got %d', [Number]));

  Result := Number;
end;

class function TValidation.RequireStrArray(const Value: ISuperObject): TStringDynArray;
var
  Members: TSuperArray;
  I: Integer;
begin
  assert(Value <> nil);

  Members := RequireArray(Value);
  SetLength(Result, Members.Length);
  for I := 0 to Members.Length - 1 do
    Result[I] := RequireStr(Members[I]);
end;

class function TValidation.RequireBoolArray(const Value: ISuperObject): TBooleanDynArray;
var
  Members: TSuperArray;
  I: Integer;
begin
  assert(Value <> nil);

  Members := RequireArray(Value);
  SetLength(Result, Members.Length);
  for I := 0 to Members.Length - 1 do
    Result[I] := RequireBool(Members[I]);
end;

class function TValidation.RequireIntArray(const Value: ISuperObject): TIntegerDynArray;
var
  Members: TSuperArray;
  I: Integer;
begin
  assert(Value <> nil);

  Members := RequireArray(Value);
  SetLength(Result, Members.Length);
  for I := 0 to Members.Length - 1 do
    Result[I] := RequireInt(Members[I]);
end;

class function TValidation.RequireUIntArray(const Value: ISuperObject): TCardinalDynArray;
var
  Members: TSuperArray;
  I: Integer;
begin
  assert(Value <> nil);

  Members := RequireArray(Value);
  SetLength(Result, Members.Length);
  for I := 0 to Members.Length - 1 do
    Result[I] := RequireUInt(Members[I]);
end;

class function TValidation.RequireArray(const Value: ISuperObject): TSuperArray;
begin
  assert(Value <> nil);

  Require(Value, TSuperType.stArray);
  Result := Value.AsArray;
end;

class procedure TValidation.Require(const Value: ISuperObject; DataType: TSuperType);
begin
  assert(Value <> nil);

  if Value.DataType <> DataType then
    raise EJsonException.Create(Format('Data type %d required but got %s', [Ord(DataType), Value.AsJSon]));
end;

end.
