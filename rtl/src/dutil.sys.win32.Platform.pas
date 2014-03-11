(**
 * $Id: dutil.sys.win32.Platform.pas 747 2014-03-11 07:42:35Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.sys.win32.Platform;

interface

uses
  Winapi.Windows;

type
  /// <summary>This service class provides methods for retrieving platform information.</summary>
  TPlatform = class
    /// <summary>Checks whether you are running on a specific level (or higher) of the Windows operating
    /// system.</summary>
    class function VersionGreaterThanOrEquals(Major: DWORD; Minor: DWORD; ServicePackMajor: Word;
      ServicePackMinor: Word): Boolean; static;
  end;

implementation

uses
  System.SysUtils,
  header.Windows,
  header.Winnt;

class function TPlatform.VersionGreaterThanOrEquals(Major: DWORD; Minor: DWORD; ServicePackMajor: Word;
  ServicePackMinor: Word): Boolean;
var
  VersionInfo: TOSVersionInfoEx;
  ConditionMask: LONGLONG;
begin
  // Initializes the condition mask.
  ConditionMask := 0;
  ConditionMask := VerSetConditionMask(ConditionMask, VER_MAJORVERSION, VER_GREATER_EQUAL);
  ConditionMask := VerSetConditionMask(ConditionMask, VER_MINORVERSION, VER_GREATER_EQUAL);
  ConditionMask := VerSetConditionMask(ConditionMask, VER_SERVICEPACKMAJOR, VER_GREATER_EQUAL);
  ConditionMask := VerSetConditionMask(ConditionMask, VER_SERVICEPACKMINOR, VER_GREATER_EQUAL);

  // Initializes the OSVERSIONINFOEX structure.
  ZeroMemory(@VersionInfo, SizeOf(VersionInfo));
  VersionInfo.dwOSVersionInfoSize := SizeOf(VersionInfo);
  VersionInfo.dwMajorVersion := Major;
  VersionInfo.dwMinorVersion := Minor;
  VersionInfo.wServicePackMajor := ServicePackMajor;
  VersionInfo.wServicePackMinor := ServicePackMinor;

  Result := VerifyVersionInfo(VersionInfo,
    VER_MAJORVERSION or VER_MINORVERSION or VER_SERVICEPACKMAJOR or VER_SERVICEPACKMINOR, ConditionMask);
end;

end.
