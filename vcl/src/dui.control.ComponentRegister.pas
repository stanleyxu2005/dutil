(**
 * $Id: dui.control.ComponentRegister.pas 717 2013-11-16 17:20:31Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dui.control.ComponentRegister;

interface

procedure Register;

implementation

uses
  System.Classes,
  dui.control.button.SkinButton;

procedure Register;
begin
  RegisterComponents('dutil/dui', [TSkinButton]);
end;

end.
