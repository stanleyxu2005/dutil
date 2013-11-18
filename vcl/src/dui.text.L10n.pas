(**
 * $Id: dui.text.L10n.pas 506 2012-05-15 16:30:06Z QXu $
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
    function Require(Identifier: Cardinal; const DefaultText: string): string;
  end;

implementation

constructor TL10n.Create;
begin
  inherited;
end;

destructor TL10n.Destroy;
begin
  inherited;
end;

function TL10n.Require(Identifier: Cardinal; const DefaultText: string): string;
begin
  // TODO:
  Result := DefaultText;
end;

end.
