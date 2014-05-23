(**
 * $Id: dutil.text.json.Reader.pas 837 2014-05-23 16:12:25Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.text.json.Reader;

interface

uses
  System.Generics.Collections,
  System.Types,
  superobject { An universal object serialization framework with Json support };

type
  /// <summary>This service class provides methods for accessing JSON object.</summary>
  TReader = class
  public
    /// <summary>Retrieves specified member value as a string or fallback to default.</summary>
    class function ReadStrMember(const Composite: ISuperObject; const Name: string; const Fallback: string): string;
      static;
    /// <summary>Retrieves specified member value as a boolean or fallback to default.</summary>
    class function ReadBoolMember(const Composite: ISuperObject; const Name: string; Fallback: Boolean): Boolean;
      static;
    /// <summary>Retrieves specified member value as an integer or fallback to default.</summary>
    class function ReadIntMember(const Composite: ISuperObject; const Name: string; Fallback: Integer): Integer;
      static;
    /// <summary>Retrieves specified member value as a non-negative integer or fallback to default.</summary>
    class function ReadUIntMember(const Composite: ISuperObject; const Name: string; Fallback: Cardinal): Cardinal;
      static;
    /// <summary>Retrieves specified member value as a string pair or fallback to default.</summary>
    class function ReadStrPairMember(const Composite: ISuperObject; const Name: string;
      const Fallback: TPair<string, string>): TPair<string, string>; static;
    /// <summary>Retrieves specified member value as a string array or fallback to default.</summary>
    class function ReadStrArrayMember(const Composite: ISuperObject; const Name: string;
      const Fallback: TArray<string>): TArray<string>; static;
    /// <summary>Retrieves specified member value as a boolean array or fallback to default.</summary>
    class function ReadBoolArrayMember(const Composite: ISuperObject; const Name: string;
      const Fallback: TArray<Boolean>): TArray<Boolean>; static;
    /// <summary>Retrieves specified member value as an integer array or fallback to default.</summary>
    class function ReadIntArrayMember(const Composite: ISuperObject; const Name: string;
      const Fallback: TArray<Integer>): TArray<Integer>; static;
    /// <summary>Retrieves specified member value as a non-negative integer array or fallback to default.</summary>
    class function ReadUIntArrayMember(const Composite: ISuperObject; const Name: string;
      const Fallback: TArray<Cardinal>): TArray<Cardinal>; static;
    /// <summary>Retrieves specified member value as a string pair array or fallback to default.</summary>
    class function ReadStrPairArrayMember(const Composite: ISuperObject; const Name: string;
      const Fallback: TArray<TPair<string, string>>): TArray<TPair<string, string>>; static;
  private
    class function ReadMember(const Composite: ISuperObject; const Name: string; DataType: TSuperType): ISuperObject;
      static;
    class function ReadMemberAsArray(const Composite: ISuperObject; const Name: string): TSuperArray; static;
  end;

implementation

uses
  supertypes { An universal object serialization framework with Json support };

class function TReader.ReadStrMember(const Composite: ISuperObject; const Name: string; const Fallback: string): string;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := ReadMember(Composite, Name, TSuperType.stString);
  if Member <> nil then
    Result := Member.AsString
  else
    Result := Fallback;
end;

class function TReader.ReadBoolMember(const Composite: ISuperObject; const Name: string; Fallback: Boolean): Boolean;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := ReadMember(Composite, Name, TSuperType.stBoolean);
  if Member <> nil then
    Result := Member.AsBoolean
  else
    Result := Fallback;
end;

class function TReader.ReadIntMember(const Composite: ISuperObject; const Name: string; Fallback: Integer): Integer;
var
  Member: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := ReadMember(Composite, Name, TSuperType.stInt);
  if Member <> nil then
    Result := Member.AsInteger
  else
    Result := Fallback;
end;

class function TReader.ReadUIntMember(const Composite: ISuperObject; const Name: string; Fallback: Cardinal): Cardinal;
var
  Member: ISuperObject;
  Number: SuperInt;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Member := ReadMember(Composite, Name, TSuperType.stInt);
  if Member <> nil then
  begin
    Number := Member.AsInteger;
    if Number >= 0 then
      Result := Number
    else
      Result := Fallback;
  end
  else
    Result := Fallback;
end;

class function TReader.ReadStrPairMember(const Composite: ISuperObject; const Name: string;
  const Fallback: TPair<string, string>): TPair<string, string>;
var
  MemberAsArray: TSuperArray;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  MemberAsArray := ReadMemberAsArray(Composite, Name);
  if MemberAsArray <> nil then
  begin
    if (MemberAsArray.Length <> 2) or
       (MemberAsArray[0].DataType <> stString) or
       (MemberAsArray[1].DataType <> stString) then
      Exit(Fallback);

    Result := TPair<string, string>.Create(MemberAsArray[0].AsString, MemberAsArray[1].AsString);
  end
  else
    Result := Fallback;
end;

class function TReader.ReadStrArrayMember(const Composite: ISuperObject; const Name: string;
  const Fallback: TArray<string>): TArray<string>;
var
  MemberAsArray: TSuperArray;
  I: Integer;
  Item: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  MemberAsArray := ReadMemberAsArray(Composite, Name);
  if MemberAsArray <> nil then
  begin
    SetLength(Result, MemberAsArray.Length);
    for I := 0 to MemberAsArray.Length - 1 do
    begin
      Item := MemberAsArray[I];
      if Item.DataType <> stString then
        Exit(Fallback);
      Result[I] := Item.AsString;
    end;
  end
  else
    Result := Fallback;
end;

class function TReader.ReadBoolArrayMember(const Composite: ISuperObject; const Name: string;
  const Fallback: TArray<Boolean>): TArray<Boolean>;
var
  MemberAsArray: TSuperArray;
  I: Integer;
  Item: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  MemberAsArray := ReadMemberAsArray(Composite, Name);
  if MemberAsArray <> nil then
  begin
    SetLength(Result, MemberAsArray.Length);
    for I := 0 to MemberAsArray.Length - 1 do
    begin
      Item := MemberAsArray[I];
      if Item.DataType <> stBoolean then
        Exit(Fallback);
      Result[I] := Item.AsBoolean;
    end;
  end
  else
    Result := Fallback;
end;

class function TReader.ReadIntArrayMember(const Composite: ISuperObject; const Name: string;
  const Fallback: TArray<Integer>): TArray<Integer>;
var
  MemberAsArray: TSuperArray;
  I: Integer;
  Item: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  MemberAsArray := ReadMemberAsArray(Composite, Name);
  if MemberAsArray <> nil then
  begin
    SetLength(Result, MemberAsArray.Length);
    for I := 0 to MemberAsArray.Length - 1 do
    begin
      Item := MemberAsArray[I];
      if Item.DataType <> stInt then
        Exit(Fallback);
      Result[I] := Item.AsInteger;
    end;
  end
  else
    Result := Fallback;
end;

class function TReader.ReadUIntArrayMember(const Composite: ISuperObject; const Name: string;
  const Fallback: TArray<Cardinal>): TArray<Cardinal>;
var
  MemberAsArray: TSuperArray;
  I: Integer;
  Item: ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  MemberAsArray := ReadMemberAsArray(Composite, Name);
  if MemberAsArray <> nil then
  begin
    SetLength(Result, MemberAsArray.Length);
    for I := 0 to MemberAsArray.Length - 1 do
    begin
      Item := MemberAsArray[I];
      if (Item.DataType <> stInt) or (Item.AsInteger < 0) then
        Exit(Fallback);
      Result[I] := Item.AsInteger;
    end;
  end
  else
    Result := Fallback;
end;

class function TReader.ReadStrPairArrayMember(const Composite: ISuperObject; const Name: string;
  const Fallback: TArray<TPair<string, string>>): TArray<TPair<string, string>>;
var
  MemberAsArray: TSuperArray;
  I: Integer;
  Item: ISuperObject;
  ItemAsArray: TSuperArray;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  MemberAsArray := ReadMemberAsArray(Composite, Name);
  if MemberAsArray <> nil then
  begin
    SetLength(Result, MemberAsArray.Length);
    for I := 0 to MemberAsArray.Length - 1 do
    begin
      Item := MemberAsArray[I];
      if Item.DataType <> stArray then
        Exit(Fallback);

      ItemAsArray := Item.AsArray;
      if (ItemAsArray.Length <> 2) or
         (ItemAsArray[0].DataType <> stString) or
         (ItemAsArray[1].DataType <> stString) then
        Exit(Fallback);

      Result[I] := TPair<string, string>.Create(ItemAsArray[0].AsString, ItemAsArray[1].AsString);
    end;
  end
  else
    Result := Fallback;
end;

class function TReader.ReadMember(const Composite: ISuperObject; const Name: string;
  DataType: TSuperType): ISuperObject;
begin
  assert(Composite <> nil);
  assert(Name <> '');

  Result := Composite.O[Name];
  if (Result <> nil) and (Result.DataType <> DataType) then
    Result := nil;
end;

class function TReader.ReadMemberAsArray(const Composite: ISuperObject; const Name: string): TSuperArray;
var
  Temp: ISuperObject;
begin
  Temp := ReadMember(Composite, Name, TSuperType.stArray);
  if Temp <> nil then
    Result := Temp.AsArray
  else
    Result := nil;
end;

end.
