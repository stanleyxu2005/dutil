(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dutil.text.Util;

interface

uses
  System.Types;

type
  /// <summary>This service class provides methods for string processing.</summary>
  TUtil = class
  public
    /// <summary>Trims the given array by stripping the provided match from both ends.</summary>
    class function Strip(const Source: string; Match: Char): string; static;
    /// <summary>Splits the string wherever a separator instance is found and return the resultant segments.</summary>
    /// <remarks>Consider use `some_string.Split([Seprator])` instead.</remarks>
    class function Split(const S: string; const Separator: string): TArray<string>; static;
  end;

implementation

uses
  System.SysUtils;

class function TUtil.Strip(const Source: string; Match: Char): string;
var
  Head: Integer;
  Tail: Integer;
  MakeCopy: Boolean;
begin
  Head := 1;
  Tail := Length(Source);
  MakeCopy := False;

  while (Head < Tail) and (Source[Head] = Match) do
  begin
    Inc(Head);
    MakeCopy := True;
  end;

  while (Tail > Head) and (Source[Tail] = Match) do
  begin
    Dec(Tail);
    MakeCopy := True;
  end;

  if MakeCopy then
    Result := Copy(Source, Head, Tail - Head + 1)
  else
    Result := Source;
end;

class function TUtil.Split(const S: string; const Separator: string): TArray<string>;
var
  SplitPoints: Integer;
  I: Integer;
  StartIndex: Integer;
  FoundIndex: Integer;
  CurrentSplit: Integer;
begin
  assert(Separator <> '');

  Result := nil;
  if S = '' then
    Exit;

  // Determine the length of the resulting array
  SplitPoints := 0;
  for I := 1 to Length(S) do
    if IsDelimiter(Separator, S, I) then
      Inc(SplitPoints);
  SetLength(Result, SplitPoints + 1);

  // Split the string and fill the resulting array
  StartIndex := 1;
  CurrentSplit := 0;
  repeat
    FoundIndex := FindDelimiter(Separator, S, StartIndex);
    if FoundIndex <> 0 then
    begin
      Result[CurrentSplit] := Copy(S, StartIndex, FoundIndex - StartIndex);
      Inc(CurrentSplit);
      StartIndex := FoundIndex + 1;
    end;
  until CurrentSplit = SplitPoints;

  // Copy the remaining part in case the string does not end in a delimiter
  Result[SplitPoints] := Copy(S, StartIndex, Length(S) - StartIndex + 1);
end;

end.
