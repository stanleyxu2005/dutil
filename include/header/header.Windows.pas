(**
 * $Id: header.Windows.pas 465 2012-05-03 17:07:03Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit header.Windows;

interface

uses
  Windows;

const
  // A mask that indicates the member of the OSVERSIONINFOEX structure whose comparison type is being set. This value 
  // corresponds to one of the bits specified in the dwTypeMask parameter for the VerifyVersionInfo function. This 
  // parameter can be one of the following values.
  VER_MINORVERSION = $0000001;
  VER_MAJORVERSION = $0000002;
  VER_BUILDNUMBER = $0000004;
  VER_PLATFORMID = $0000008;
  VER_SERVICEPACKMINOR = $0000010;
  VER_SERVICEPACKMAJOR = $0000020;
  VER_SUITENAME = $0000040;
  VER_PRODUCT_TYPE = $0000080;
  // For all values of dwTypeBitMask other than VER_SUITENAME, this parameter can be one of the following values.
  VER_EQUAL = 1;
  VER_GREATER = 2;
  VER_GREATER_EQUAL = 3;
  VER_LESS = 4;
  VER_LESS_EQUAL = 5;
  // If dwTypeBitMask is VER_SUITENAME, this parameter can be one of the following values.
  VER_AND = 6;
  VER_OR = 7;

// Bugfix: Windows.pas declares TOSVersionInfo instead of TOSVersionInfoEx as the first parameter!
function VerifyVersionInfoA(var VersionInformation: TOSVersionInfoExA; dwTypeMask: DWORD; 
  dwlConditionMask: LONGLONG): BOOL; stdcall;
{$EXTERNALSYM VerifyVersionInfoA}
function VerifyVersionInfoW(var VersionInformation: TOSVersionInfoExW; dwTypeMask: DWORD; 
  dwlConditionMask: LONGLONG): BOOL; stdcall;
{$EXTERNALSYM VerifyVersionInfoA}
function VerifyVersionInfo(var VersionInformation: TOSVersionInfoEx; dwTypeMask: DWORD; 
  dwlConditionMask: LONGLONG): BOOL; stdcall;
{$EXTERNALSYM VerifyVersionInfo}

implementation

function VerifyVersionInfoA; external kernel32 name 'VerifyVersionInfoA';
function VerifyVersionInfoW; external kernel32 name 'VerifyVersionInfoW';
function VerifyVersionInfo; external kernel32 name {$IFDEF UNICODE} 'VerifyVersionInfoW'
                                                   {$ELSE}          'VerifyVersionInfoA'
                                                   {$ENDIF};

end.
