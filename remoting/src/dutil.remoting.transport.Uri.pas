(**
 * $Id: dutil.remoting.transport.Uri.pas 810 2014-05-08 03:29:38Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.transport.Uri;

interface

uses
  Winapi.Windows;

type
  /// <summary>The immutable value class represents the uri of a transport resource (or RPC object).</summary>
  TUri = record
  private
    FDomain: string;
    FId: Cardinal;
  public
    property Domain: string read FDomain;
    property Id: Cardinal read FId;
  public
    constructor Create(const Domain: string; Id: Cardinal);
    function ToString: string;
    /// <exception cref="EParseError">Parse error</exception>
    class function FromString(const S: string): TUri; static;
  end;

implementation

uses
  System.StrUtils,
  System.SysUtils,
  dutil.core.Exception,
  dutil.text.Util;

constructor TUri.Create(const Domain: string; Id: Cardinal);
begin
  assert(Domain <> '');
  assert(not ContainsStr(Domain, ':'));

  FDomain := Domain;
  FId := Id;
end;

function TUri.ToString: string;
begin
  Result := FDomain + ':' + IntToStr(FId);
end;

class function TUri.FromString(const S: string): TUri;
var
  Tokens: TArray<string>;
begin
  Tokens := TUtil.Split(S, ':');
  if Length(Tokens) = 1 then
    try
      Exit(TUri.Create(Tokens[0], 0));
    except
    end
  else if Length(Tokens) = 2 then
    try
      Exit(TUri.Create(Tokens[0], StrToInt(Tokens[1])));
    except
    end;
  raise EParseError.Create('Failed to parse uri: ' + S);
end;

end.