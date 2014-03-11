(**
 * $Id: dutil.text.arg.Arguments.pas 747 2014-03-11 07:42:35Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.text.arg.Arguments;

interface

uses
  System.Generics.Collections,
  dutil.text.arg.Arg;

type
  /// <summary>This view class provides methods to validate specified arguments.</summary>
  TArguments = class
  public const
    LONG_PREFIX = '--';
    EQUAL_SIGN = '=';
    SEPARATOR = ' ';
  private
    FArgs: TDictionary<string, TArg>;
    /// <exception cref="ENoSuchElementException">The argument does not exist.</exception>
    function Require(const Name: string): TArg;
  public
    constructor Create(const Args: TDictionary<string, TArg>);
    destructor Destroy; override;
    function ToString: string; override;
    /// <exception cref="ENoSuchElementException">The argument does not exist.</exception>
    function RequireInt(const Name: string): Integer;
    /// <exception cref="ENoSuchElementException">The argument does not exist or the value is negative.</exception>
    function RequireUInt(const Name: string): Cardinal;
    /// <exception cref="ENoSuchElementException">The argument does not exist.</exception>
    function RequireStr(const Name: string): string;
    /// <exception cref="ENoSuchElementException">The argument does not exist.</exception>
    function HasToken(const Name: string): Boolean;
    function HasArg(const Name: string): Boolean;
  end;

implementation

uses
  System.SysUtils,
  dutil.core.Exception,
  dutil.text.Convert;

constructor TArguments.Create(const Args: TDictionary<string, TArg>);
var
  Pair: TPair<string, TArg>;
begin
  assert(Args <> nil);

  FArgs := TDictionary<string, TArg>.Create;
  for Pair in Args do
    FArgs.Add(Pair.Key, Pair.Value);
end;

destructor TArguments.Destroy;
begin
  FArgs.Free;
  FArgs := nil;

  inherited;
end;

function TArguments.ToString: string;
var
  Builder: TStringBuilder;
  Arg: TArg;
begin
  Builder := TStringBuilder.Create;
  try
    for Arg in FArgs.Values do
    begin
      if Builder.Length > 0 then
        Builder.Append(SEPARATOR);

      case Arg.Type_ of
        Number, Str:
          Builder.AppendFormat('%s%s%s%s', [LONG_PREFIX, Arg.Name, EQUAL_SIGN, Arg.Value]);
        Token:
          Builder.AppendFormat('%s%s', [LONG_PREFIX, Arg.Name]);
      else
        raise EProgrammerNotFound.Create(Format('Unexpected argument type: %d', [Ord(Arg.Type_)]));
      end;
    end;

    Result := Builder.ToString;
  finally
    Builder.Free;
  end;
end;

function TArguments.Require(const Name: string): TArg;
begin
  assert(Name <> '');

  if not FArgs.ContainsKey(Name) then
    raise ENoSuchElementException.Create(Format('Key "%s" does not found', [Name]));

  Result := FArgs.Items[Name];
end;

function TArguments.RequireInt(const Name: string): Integer;
var
  Arg: TArg;
begin
  assert(Name <> '');

  Arg := Require(Name);
  if Arg.Type_ <> Number then
    raise ENoSuchElementException.Create(Format('Unexpected argument type: %d', [Ord(Arg.Type_)]));

  try
    Result := StrToInt(Arg.Value);
  except
    on E: EConvertError do
      raise ENoSuchElementException.Create(E.ToString);
  end;
end;

function TArguments.RequireUInt(const Name: string): Cardinal;
var
  Arg: TArg;
begin
  assert(Name <> '');

  Arg := Require(Name);
  if Arg.Type_ <> Number then
    raise ENoSuchElementException.Create(Format('Unexpected argument type: %d', [Ord(Arg.Type_)]));

  try
    Result := TConvert.StrToUInt(Arg.Value);
  except
    on E: EConvertError do
      raise ENoSuchElementException.Create(E.ToString);
  end;
end;

function TArguments.RequireStr(const Name: string): string;
var
  Arg: TArg;
begin
  assert(Name <> '');

  Arg := Require(Name);
  if not (Arg.Type_ in [Str, Number]) then
    raise ENoSuchElementException.Create(Format('Unexpected argument type: %d', [Ord(Arg.Type_)]));

  Result := Arg.Value;
end;

function TArguments.HasToken(const Name: string): Boolean;
var
  Arg: TArg;
begin
  assert(Name <> '');

  if FArgs.ContainsKey(Name) then
  begin
    Arg := FArgs.Items[Name];
    if Arg.Type_ <> Token then
      raise ENoSuchElementException.Create(Format('Unexpected argument type: %d', [Ord(Arg.Type_)]));

    Result := True;
  end
  else
    Result := False;
end;

function TArguments.HasArg(const Name: string): Boolean;
begin
  assert(Name <> '');

  Result := FArgs.ContainsKey(Name);
end;

end.
