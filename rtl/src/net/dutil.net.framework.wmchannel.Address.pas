(**
 * $Id: dutil.net.framework.wmchannel.Address.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.framework.wmchannel.Address;

interface

uses
  Windows;

type
  /// <summary>This immutable record represents the address of message channel connection.</summary>
  TAddress = record
  private const
    DIVIDER = ':';
  private
    FMessageWindow: HWND;
    FPort: Cardinal;
  public
    property MessageWindow: HWND read FMessageWindow;
    property Port: Cardinal read FPort;
    class function Assign(MessageWindow: HWND; Port: Cardinal): TAddress; static;
    /// <exceptions cref="EConvertError">Invalid address notation.</summary>
    class function FromString(const S: string): TAddress; static;
    function ToString: string;
  end;

implementation

uses
  SysUtils,
  Types,
  dutil.text.Convert,
  dutil.text.Util;

class function TAddress.Assign(MessageWindow: HWND; Port: Cardinal): TAddress;
begin
  Result.FMessageWindow := MessageWindow;
  Result.FPort:= Port;
end;

class function TAddress.FromString(const S: string): TAddress;
var
  Pieces: TStringDynArray;
begin
  Pieces := TUtil.Split(S, DIVIDER);
  if Length(Pieces) = 2 then
  begin
    Result.FMessageWindow := TConvert.StrToUInt(Pieces[0]);
    Result.FPort := TConvert.StrToUInt(Pieces[1]);
    Exit;
  end;

  raise EConvertError.Create(Format('Invalid address notation: %s', [S]));
end;

function TAddress.ToString: string;
begin
  Result := Format('%d%s%d', [FMessageWindow, DIVIDER, FPort]);
end;

end.
