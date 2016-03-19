(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
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
  RegisterComponents('dui', [TSkinButton]);
end;

end.
