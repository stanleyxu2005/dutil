(**
 * $Id: dutil.util.container.DynArray.pas 769 2014-04-19 16:50:27Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.util.container.DynArray;

interface

type
  /// <summary>This service class provides methods for dealing dynmical arrays.</summary>
  TDynArray = class
  public
    /// <summary>Inserts an item to the end of a dynamic array.</summary>
    class function Append<T>(var Destination: TArray<T>; const Item: T): Cardinal; overload; static;
    /// <summary>Inserts items to the end of a dynamic array.</summary>
    class function Append<T>(var Destination: TArray<T>; const Items: TArray<T>): Cardinal; overload; static;
    /// <summary>Inserts an item to the end of a dynamic array.</summary>
    class function Insert<T>(var Destination: TArray<T>; const Item: T; Index: Cardinal): Cardinal; overload; static;
    /// <summary>Inserts items to the end of a dynamic array.</summary>
    class function Insert<T>(var Destination: TArray<T>; const Items: TArray<T>; Index: Cardinal): Cardinal; overload; static;
  end;

implementation

class function TDynArray.Append<T>(var Destination: TArray<T>; const Item: T): Cardinal;
begin
  Result := Length(Destination);
  SetLength(Destination, Result + 1);

  Destination[Result] := Item;
  Inc(Result);
end;

class function TDynArray.Append<T>(var Destination: TArray<T>; const Items: TArray<T>): Cardinal;
var
  Item: T;
begin
  Result := Length(Destination);
  SetLength(Destination, Result + Cardinal(Length(Items)));

  for Item in Items do
  begin
    Destination[Result] := Item;
    Inc(Result);
  end;
end;

class function TDynArray.Insert<T>(var Destination: TArray<T>; const Item: T; Index: Cardinal): Cardinal;
var
  L0, L1: Cardinal;
  I: Cardinal;
begin
  assert(Index <= Cardinal(Length(Destination)));

  L0 := Length(Destination);
  L1 := 1;
  Result := L0 + L1;
  SetLength(Destination, Result);

  if Index + 1 <= L0 then
    for I := L0 - 1 downto Index do
      Destination[I + L1] := Destination[I];
  Destination[Index] := Item;
end;

class function TDynArray.Insert<T>(var Destination: TArray<T>; const Items: TArray<T>; Index: Cardinal): Cardinal;
var
  L0, L1: Cardinal;
  I: Cardinal;
  Item: T;
begin
  assert(Index <= Cardinal(Length(Destination)));

  L0 := Length(Destination);
  L1 := Length(Items);
  Result := L0 + L1;
  SetLength(Destination, Result);

  if Index + 1 <= L0 then
    for I := L0 - 1 downto Index do
      Destination[I + L1] := Destination[I];

  for Item in Items do
  begin
    Destination[Index] := Item;
    Inc(Index);
  end;
end;

end.
