(**
 * $Id: dutil.text.arg.Arg.pas 747 2014-03-11 07:42:35Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.text.arg.Arg;

interface

type
  /// <summary>This immutable record represents an argument.</summary>
  /// <remarks>Expected to be used only within the package.</remarks>
  TArg = record
  private type
    TType = (Str, Number, Token);
  private
    FType: TType;
    FName: string;
    FValue: string;
  public
    property Type_: TType read FType;
    property Name: string read FName;
    property Value: string read FValue;
    class function StrArg(const Name: string; const Value: string): TArg; static;
    class function NumberArg(const Name: string; const Value: Int64): TArg; static;
    class function TokenArg(const Name: string): TArg; static;
  end;

implementation

uses
  System.SysUtils;

class function TArg.StrArg(const Name: string; const Value: string): TArg;
begin
  assert(Name <> '');

  Result.FType := Str;
  Result.FName := Name;
  Result.FValue := Value;
end;

class function TArg.NumberArg(const Name: string; const Value: Int64): TArg;
begin
  assert(Name <> '');

  Result.FType := Number;
  Result.FName := Name;
  Result.FValue := IntToStr(Value);
end;

class function TArg.TokenArg(const Name: string): TArg;
begin
  assert(Name <> '');

  Result.FType := Token;
  Result.FName := Name;
  Result.FValue := '';
end;

end.
