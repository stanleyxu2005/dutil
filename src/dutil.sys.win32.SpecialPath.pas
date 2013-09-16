(**
 * $Id: dutil.sys.win32.SpecialPath.pas 540 2012-06-09 20:16:01Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.sys.win32.SpecialPath;

interface

type
  /// <summary>This service class provides methods for retreive special paths.</summary>
  TSpecialPath = class
    /// <summary>Retrieves the path of a known folder's csidl.</summary>
    /// <remarks>see ShlObj.pas</remarks>
    /// <exception cref="EOSError">Failed to get the path of a particular csidl.</exception>
    class function FromCsidl(Csidl: Integer; CanCreate: Boolean): string; static;
  end;

implementation

uses
  Windows,
  ShlObj,
  SysUtils;

class function TSpecialPath.FromCsidl(Csidl: Integer; CanCreate: Boolean): string;
var
  Folder: Integer;
  Buffer: array [0 .. MAX_PATH] of Char;
begin
  Folder := Csidl;
  if CanCreate then
    Folder := Folder or CSIDL_FLAG_CREATE;

  if SHGetFolderPath({hwndOwner=}0, Folder, {hToken=}0, {dwFlags=}SHGFP_TYPE_CURRENT, {pszPath=}Buffer) = S_OK then
  begin
    Result := Buffer;
  end
  else
    RaiseLastOSError;
end;

end.
