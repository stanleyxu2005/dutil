(**
 * $Id: dui.text.L10n.pas 820 2014-05-11 15:47:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dui.text.L10n;

interface

type
  /// <summary>This service class provides methods for localization.</summary>
  TL10n = class
  public
    constructor Create;
    destructor Destroy; override;
    function Get(Identifier: Cardinal; const DefaultText: string): string; overload;
    function Get(Identifier: Cardinal; const DefaultText: string; const Args: array of const): string; overload;
  end;

implementation

uses
  System.SysUtils;

constructor TL10n.Create;
begin
  inherited;
end;

destructor TL10n.Destroy;
begin
  inherited;
end;

function TL10n.Get(Identifier: Cardinal; const DefaultText: string): string;
begin
  // TODO:
  Result := DefaultText;
end;

function TL10n.Get(Identifier: Cardinal; const DefaultText: string; const Args: array of const): string;
begin
  // TODO:
  Result := Format(DefaultText, Args);
end;

end.
