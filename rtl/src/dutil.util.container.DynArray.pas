(**
 * $Id: dutil.util.container.DynArray.pas 747 2014-03-11 07:42:35Z QXu $
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
    /// <summary>Appends an item to the end of a dynamic array.</summary>
    class function Append<T>(var Destination: TArray<T>; const Item: T): Cardinal; overload; static;
    /// <summary>Appends items to the end of a dynamic array.</summary>
    class function Append<T>(var Destination: TArray<T>; const Items: TArray<T>): Cardinal; overload; static;
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

end.
