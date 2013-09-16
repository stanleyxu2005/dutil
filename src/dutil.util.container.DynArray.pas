(**
 * $Id: dutil.util.container.DynArray.pas 32 2012-06-10 14:27:59Z sx.away@gmail.com $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.util.container.DynArray;

interface

uses
  Generics.Collections,
  Types;

type
  /// <summary>This service class provides methods for dealing dynmical arrays.</summary>
  TDynArray = class
  public
    /// <summary>Extends a string array with specified items.</summary>
    class function Extend(Destination: TStringDynArray; const Items: TStringDynArray): Cardinal; overload; static;
    /// <summary>Extends a boolean array with specified items.</summary>
    class function Extend(Destination: TBooleanDynArray; const Items: TBooleanDynArray): Cardinal; overload; static;
    /// <summary>Extends an integer array with specified items.</summary>
    class function Extend(Destination: TIntegerDynArray; const Items: TIntegerDynArray): Cardinal; overload; static;
    /// <summary>Extends a non-negative integer array with specified items.</summary>
    class function Extend(Destination: TCardinalDynArray; const Items: TCardinalDynArray): Cardinal; overload; static;
  end;

implementation

class function TDynArray.Extend(Destination: TStringDynArray; const Items: TStringDynArray): Cardinal;
var
  Item: string;
begin
  Result := Length(Destination);
  SetLength(Destination, Result + Cardinal(Length(Items)));

  for Item in Items do
  begin
    Destination[Result] := Item;
    Inc(Result);
  end;
end;

class function TDynArray.Extend(Destination: TBooleanDynArray; const Items: TBooleanDynArray): Cardinal;
var
  Item: Boolean;
begin
  Result := Length(Destination);
  SetLength(Destination, Result + Cardinal(Length(Items)));

  for Item in Items do
  begin
    Destination[Result] := Item;
    Inc(Result);
  end;
end;

class function TDynArray.Extend(Destination: TIntegerDynArray; const Items: TIntegerDynArray): Cardinal;
var
  Item: Integer;
begin
  Result := Length(Destination);
  SetLength(Destination, Result + Cardinal(Length(Items)));

  for Item in Items do
  begin
    Destination[Result] := Item;
    Inc(Result);
  end;
end;

class function TDynArray.Extend(Destination: TCardinalDynArray; const Items: TCardinalDynArray): Cardinal;
var
  Item: Integer;
begin
  Result := Length(Destination);
  SetLength(Destination, Result + Cardinal(Length(Items)));

  for Item in Items do
  begin
    Destination[Result] := Item;
    Inc(Result);
  end;
end;

end.
