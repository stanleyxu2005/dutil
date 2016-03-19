(**
 * $Id: header.Winnt.pas 465 2012-05-03 17:07:03Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit header.Winnt;

interface

uses
  Windows;

function VerSetConditionMask(ConditionMask: LONGLONG; TypeMask: DWORD; Condition: Byte): LONGLONG; stdcall;
{$EXTERNALSYM VerSetConditionMask}


implementation

function VerSetConditionMask; external kernel32 name 'VerSetConditionMask';

end.
