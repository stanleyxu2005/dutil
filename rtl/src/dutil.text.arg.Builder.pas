(**
 * $Id: dutil.text.arg.Builder.pas 822 2014-05-13 17:06:20Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.text.arg.Builder;

interface

uses
  System.Generics.Collections,
  dutil.text.arg.Arg,
  dutil.text.arg.Arguments;

type
  /// <summary>This class provides methods to parse and build command-line arguments.</summary>
  TBuilder = class
  private
    FArgs: TDictionary<string, TArg>;
    /// <exception cref="EDuplicateElementException"></exception>
    procedure Add(const Arg: TArg);
    /// <exception cref="EParseError"></exception>
    class function ParseArg(const Text: string): TArg; static;
  public
    constructor Create;
    destructor Destroy; override;
    function ToString: string; override;
    function CreateView: TArguments;
    /// <exception cref="EDuplicateElementException"></exception>
    procedure AddInt(const Name: string; const Value: Int64);
    /// <exception cref="EDuplicateElementException"></exception>
    procedure AddStr(const Name: string; const Value: string);
    /// <exception cref="EDuplicateElementException"></exception>
    procedure AddToken(const Name: string);
    /// <exception cref="EParseError"></exception>
    class function FromCommandLine: TArguments; static;
  end;

implementation

uses
  System.StrUtils,
  System.SysUtils,
  dutil.core.Exception;

constructor TBuilder.Create;
begin
  FArgs := TDictionary<string, TArg>.Create;
end;

destructor TBuilder.Destroy;
begin
  FArgs.Free;

  inherited;
end;

function TBuilder.ToString: string;
var
  View: TArguments;
begin
  View := CreateView;
  try
    Result := View.ToString;
  finally
    View.Free;
  end;
end;

function TBuilder.CreateView: TArguments;
begin
  Result := TArguments.Create(FArgs);
end;

procedure TBuilder.Add(const Arg: TArg);
begin
  assert(Arg.Name <> '');

  if FArgs.ContainsKey(Arg.Name) then
    raise EDuplicateElementException.CreateFmt('Key ''%s'' exists already', [Arg.Name]);

  FArgs.Add(Arg.Name, Arg);
end;

procedure TBuilder.AddInt(const Name: string; const Value: Int64);
begin
  assert(Name <> '');

  Add(TArg.NumberArg(Name, Value));
end;

procedure TBuilder.AddStr(const Name: string; const Value: string);
begin
  assert(Name <> '');

  Add(TArg.StrArg(Name, Value));
end;

procedure TBuilder.AddToken(const Name: string);
begin
  assert(Name <> '');

  Add(TArg.TokenArg(Name));
end;

class function TBuilder.FromCommandLine: TArguments;
var
  Builder: TBuilder;
  I: Integer;
  Piece: string;
begin
  Builder := TBuilder.Create;
  try
    for I := 1 to ParamCount do
    begin
      Piece := ParamStr(I);
      try
        Builder.Add(ParseArg(Piece));
      except
        on E: EParseError do
        begin
          Result := nil;
          raise EParseError.CreateFmt('Failed to parse argument: %s', [Piece]);
        end;
      end;
    end;

    Result := Builder.CreateView;
  finally
    Builder.Free;
  end;
end;

class function TBuilder.ParseArg(const Text: string): TArg;
var
  EqualSignPos: Integer;
  Offset: Integer;
  Name: string;
  Value: string;
  Int64Value: Int64;
begin
  if not StartsStr(TArguments.LONG_PREFIX, Text) then
    raise EParseError.Create('');

  EqualSignPos := Pos(TArguments.EQUAL_SIGN, Text);

  if EqualSignPos > 0 then
  begin
    Offset := Length(TArguments.LONG_PREFIX) + 1;
    Name := Copy(Text, Offset, EqualSignPos - Offset);
    if Name = '' then
      raise EParseError.Create('');
    Value := Copy(Text, EqualSignPos + Length(TArguments.EQUAL_SIGN), MaxInt);

    try
      Int64Value := StrToInt64(Value);
      if (Int64Value > High(Cardinal)) or (Int64Value < Low(Integer)) then
        raise EConvertError.Create('')
      else
        Result := TArg.NumberArg(Name, Int64Value);
    except
      on EConvertError do
        Result := TArg.StrArg(Name, Value);
    end;
  end
  else
  begin
    Name := Copy(Text, Length(TArguments.LONG_PREFIX) + 1, MaxInt);
    if Name = '' then
      raise EParseError.Create('');

    Result := TArg.TokenArg(Name);
  end;
end;

end.
