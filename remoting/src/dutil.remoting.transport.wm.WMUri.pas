(**
 * $Id: dutil.remoting.transport.wm.WMUri.pas 806 2014-05-01 04:57:21Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.transport.wm.WMUri;

interface

uses
  Winapi.Windows;

type
  /// <summary>The immutable value class represents the uri of an Windows messaging transport resource.</summary>
  TWMUri = record
  const
    WM_PROTOCOL = 'wm:';
  private
    FWindow: HWND;
    FId: Word; // Id and secret build up an Integer, which is a member of WM_COPYDATA
    FSecret: Word;
  public
    /// <summary>The window handle that listens WM_COPYDATA messages</summary>
    property Window: HWND read FWindow;
    /// <summary>The unique resource id of a remote callable object within the remoting system.</summary>
    /// <remarks>Value range is [1, 65525]. '0' is used as disconnection indicator.</remarks>
    property Id: Word read FId;
    /// <summary>A simple encrypt secret to encode the message payload.</summary>
    property Secret: Word read FSecret;
  public
    constructor Create(Window: HWND; Id: Word; Secret: Word = 0);
    function ToString: string;
    /// <exception cref="EParseError">Parse error</exception>
    class function FromString(const Uri: string): TWMUri; static;
    /// <exception cref="EParseError">Parse error</exception>
    class function Encode(const RootUri: string; Id: Word; Secret: Word = 0): TWMUri; static;
  private
    /// <exception cref="EParseError">Parse error</exception>
    class function ValidateProtocolAndStrip(const Uri: string): string; static;
  end;

implementation

uses
  System.StrUtils,
  System.SysUtils,
  dutil.core.Exception,
  dutil.text.Util;

constructor TWMUri.Create(Window: HWND; Id: Word; Secret: Word);
begin
  assert(Window > 0);

  FWindow := Window;
  FId := Id;
  FSecret := Secret;
end;

function TWMUri.ToString: string;
begin
  Result := Format('%s%d:%d:%d', [WM_PROTOCOL, FWindow, FId, FSecret]);
end;

class function TWMUri.FromString(const Uri: string): TWMUri;
var
  Tokens: TArray<string>;
begin
  Tokens := TUtil.Split(ValidateProtocolAndStrip(Uri), ':');
  if Length(Tokens) = 3 then
    try
      Exit(TWMUri.Create(StrToInt(Tokens[0]), StrToInt(Tokens[1]), StrToInt(Tokens[2])));
    except
    end;
  raise EParseError.Create('Failed to parse (WM) uri: ' + Uri);
end;

class function TWMUri.Encode(const RootUri: string; Id: Word; Secret: Word): TWMUri;
var
  Window: HWND;
begin
  try
    Window := StrToInt(ValidateProtocolAndStrip(RootUri));
    Exit(TWMUri.Create(Window, Id, Secret));
  except
  end;
  raise EParseError.Create(Format('Failed to parse (WM) uri: %s, %d, %d', [RootUri, Id, Secret]));
end;

class function TWMUri.ValidateProtocolAndStrip(const Uri: string): string;
begin
  if StartsStr(WM_PROTOCOL, Uri) then
    Exit(Copy(Uri, Length(WM_PROTOCOL) + 1, MaxInt));
  raise EParseError.Create(Format('Invalid protocol: %s', [Uri]));
end;

end.