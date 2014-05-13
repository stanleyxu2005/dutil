(**
 * $Id: dui.control.ComponentRegister.pas 819 2014-05-11 06:45:16Z QXu $
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
