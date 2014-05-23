(**
 * $Id: dutil.text.json.Validation.pas 837 2014-05-23 16:12:25Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.text.json.Validation;

interface

uses
  System.Generics.Collections,
  System.Types,
  superobject { An universal object serialization framework with Json support };

type
  /// <summary>This service class provides methods for simple JSON validity checks.</summary>
  TValidation = class
  public
    /// <summary>Expects specified member value is a string.</summary>
    /// <exception cref="EJsonException">Member not found or value is not a string.</exception>
    class function RequireStrMember(const Composite: ISuperObject; const Name: string): string; static;
    /// <summary>Expects specified member value is a boolean.</summary>
    /// <exception cref="EJsonException">Member not found or value is not a boolean.</exception>
    class function RequireBoolMember(const Composite: ISuperObject; const Name: string): Boolean; static;
    /// <summary>Expects specified member value is an integer.</summary>
    /// <exception cref="EJsonException">Member not found or value is not an integer.</exception>
    class function RequireIntMember(const Composite: ISuperObject; const Name: string): Integer; static;
    /// <summary>Expects specified member value is a non-negative integer.</summary>
    /// <exception cref="EJsonException">Member not found or value is not a non-negative integer.</exception>
    class function RequireUIntMember(const Composite: ISuperObject; const Name: string): Cardinal; static;
    /// <summary>Expects specified member value is a string pair.</summary>
    /// <exception cref="EJsonException">Member not found or value is not a string pair.</exception>
    class function RequireStrPairMember(const Composite: ISuperObject; const Name: string): TPair<string, string>;
      static;
    /// <summary>Expects specified member value is a string array.</summary>
    /// <exception cref="EJsonException">Member not found or value is not a string array.</exception>
    class function RequireStrArrayMember(const Composite: ISuperObject; const Name: string): TArray<string>; static;
    /// <summary>Expects specified member value is a boolean array.</summary>
    /// <exception cref="EJsonException">Member not found or value is not a boolean array.</exception>
    class function RequireBoolArrayMember(const Composite: ISuperObject; const Name: string): TArray<Boolean>; static;
    /// <summary>Expects specified member value is an integer array.</summary>
    /// <exception cref="EJsonException">Member not found or value is not an integer array.</exception>
    class function RequireIntArrayMember(const Composite: ISuperObject; const Name: string): TArray<Integer>; static;
    /// <summary>Expects specified member value is a non-negative integer array.</summary>
    /// <exception cref="EJsonException">Member not found or value is not a non-negative integer array.</exception>
    class function RequireUIntArrayMember(const Composite: ISuperObject; const Name: string): TArray<Cardinal>; static;
    /// <summary>Expects specified member value is a string pair array.</summary>
    /// <exception cref="EJsonException">Member not found or value is not a string pair array.</exception>
    class function RequireStrPairArrayMember(const Composite: ISuperObject; const Name: string):
      TArray<TPair<string, string>>; static;
    /// <summary>Expects value as a string.</summary>
    /// <exception cref="EJsonException">Specified value is not a string.</exception>
    class function RequireStr(const Value: ISuperObject): string; static;
    /// <summary>Expects value as a boolean.</summary>
    /// <exception cref="EJsonException">Specified value is not a boolean.</exception>
    class function RequireBool(const Value: ISuperObject): Boolean; static;
    /// <summary>Expects value as an integer.</summary>
    /// <exception cref="EJsonException">Specified value is not an integer.</exception>
    class function RequireInt(const Value: ISuperObject): Integer; static;
    /// <summary>Expects value as a non-negative integer.</summary>
    /// <exception cref="EJsonException">Specified value is not a non-negative integer.</exception>
    class function RequireUInt(const Value: ISuperObject): Cardinal; static;
    /// <summary>Expects value as a string pair.</summary>
    /// <exception cref="EJsonException">Specified value is not a string pair.</exception>
    class function RequireStrPair(const Value: ISuperObject): TPair<string, string>; static;
    /// <summary>Expects value as a string array.</summary>
    /// <exception cref="EJsonException">Specified value is not a string array.</exception>
    class function RequireStrArray(const Value: ISuperObject): TArray<string>; static;
    /// <summary>Expects value as a boolean array.</summary>
    /// <exception cref="EJsonException">Specified value is not a boolean array.</exception>
    class function RequireBoolArray(const Value: ISuperObject): TArray<Boolean>; static;
    /// <summary>Expects value as an integer array.</summary>
    /// <exception cref="EJsonException">Specified value is not an integer array.</exception>
    class function RequireIntArray(const Value: ISuperObject): TArray<Integer>; static;
    /// <summary>Expects value as a non-negative integer array.</summary>
    /// <exception cref="EJsonException">Specified value is not a non-negative array.</exception>
    class function RequireUIntArray(const Value: ISuperObject): TArray<Cardinal>; static;
    /// <summary>Expects value as a string pair array.</summary>
    /// <exception cref="EJsonException">Specified value is not a string pair array.</exception>
    class function RequireStrPairArray(const Value: ISuperObject): TArray<TPair<string, string>>; static;
  private
    /// <exception cref="EJsonException">When the JSON object has no member with the specified name.</exception>
    class function RequireMember(const Composite: ISuperObject; const Name: string;
      DataType: TSuperType): ISuperObject; static;
    /// <exception cref="EJsonException">Specified value is not a super array.</exception>
    class function RequireArray(const Value: ISuperObject): TSuperArray; static;
    /// <exception cref="EJsonException">Specified value is not a JSON object.</exception>
    class procedure Require(const Value: ISuperObject; DataType: TSuperType); static;
  end;

implementation

uses
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
    raise EJsonException.CreateFmt('Non-negative integer required but got %d', [Number]);

  Result := Number;
end;

class function TValidation.RequireStrPairMember(const Composite: ISuperObject; const Name: string):
  TPair<string, string>;
var
  Elements: TArray<string>;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Elements := RequireStrArrayMember(Composite, Name);
  if Length(Elements) <> 2 then
    raise EJsonException.CreateFmt('Array should contain exactly 2 elements but got %s', [Composite.O[Name].AsJSon]);

  Result := TPair<string, string>.Create(Elements[0], Elements[1]);
end;

class function TValidation.RequireStrArrayMember(const Composite: ISuperObject; const Name: string): TArray<string>;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := RequireMember(Composite, Name, TSuperType.stArray);
  Result := RequireStrArray(Member);
end;

class function TValidation.RequireBoolArrayMember(const Composite: ISuperObject; const Name: string): TArray<Boolean>;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := RequireMember(Composite, Name, TSuperType.stArray);
  Result := RequireBoolArray(Member);
end;

class function TValidation.RequireIntArrayMember(const Composite: ISuperObject; const Name: string): TArray<Integer>;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := RequireMember(Composite, Name, TSuperType.stArray);
  Result := RequireIntArray(Member);
end;

class function TValidation.RequireUIntArrayMember(const Composite: ISuperObject; const Name: string): TArray<Cardinal>;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := RequireMember(Composite, Name, TSuperType.stArray);
  Result := RequireUIntArray(Member);
end;

class function TValidation.RequireStrPairArrayMember(const Composite: ISuperObject; const Name: string):
  TArray<TPair<string, string>>;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := RequireMember(Composite, Name, TSuperType.stArray);
  Result := RequireStrPairArray(Member);
end;

class function TValidation.RequireMember(const Composite: ISuperObject; const Name: string;
  DataType: TSuperType): ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Result := Composite.O[Name];

  if Result = nil then
    raise EJsonException.CreateFmt('"%s" element required', [Name]);

  if Result.DataType <> DataType then
    raise EJsonException.CreateFmt('Data type %d required but got %s', [Ord(DataType), Result.AsJSon]);
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
    raise EJsonException.CreateFmt('Non-negative integer required but got %d', [Number]);

  Result := Number;
end;

class function TValidation.RequireStrPair(const Value: ISuperObject): TPair<string, string>;
var
  Elements: TArray<string>;
begin
  assert(Value <> nil);

  Elements := RequireStrArray(Value);
  if Length(Elements) <> 2 then
    raise EJsonException.CreateFmt('Array should contain exactly 2 elements but got %s', [Value.AsJson]);

  Result := TPair<string, string>.Create(Elements[0], Elements[1]);
end;

class function TValidation.RequireStrArray(const Value: ISuperObject): TArray<string>;
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

class function TValidation.RequireBoolArray(const Value: ISuperObject): TArray<Boolean>;
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

class function TValidation.RequireIntArray(const Value: ISuperObject): TArray<Integer>;
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

class function TValidation.RequireUIntArray(const Value: ISuperObject): TArray<Cardinal>;
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

class function TValidation.RequireStrPairArray(const Value: ISuperObject): TArray<TPair<string, string>>;
var
  Members: TSuperArray;
  I: Integer;
begin
  assert(Value <> nil);

  Members := RequireArray(Value);
  SetLength(Result, Members.Length);
  for I := 0 to Members.Length - 1 do
    Result[I] := RequireStrPair(Members[I]);
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
    raise EJsonException.CreateFmt('Data type %d required but got %s', [Ord(DataType), Value.AsJSon]);
end;

end.
