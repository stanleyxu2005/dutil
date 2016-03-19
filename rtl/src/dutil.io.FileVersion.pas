(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dutil.io.FileVersion;

interface

uses
  header.Windows;

type
  /// <summary>This service class provides methods for retrieving file version information.</summary>
  TFileVersion = class
  public
    /// <summary>Retrieves file version information from a file.</summary>
    /// <exception cref="EOSError">OS error</exception>
    class function Retrieve(const Filename: string): TFixedFileInfo; overload; static;
    /// <summary>Retrieves file version information from a module.</summary>
    /// <exception cref="EOSError">OS error</exception>
    class function Retrieve(Module: HMODULE): TFixedFileInfo; overload; static;
    /// <summary>Converts a fixed file info to a string file version representation.</summary>
    class function Convert(const FixedFileInfo: TFixedFileInfo): string; static;
  end;

implementation

uses
  System.SysUtils,
  Winapi.Windows;

class function TFileVersion.Retrieve(const Filename: string): TFixedFileInfo;
var
  Handle: DWORD;
  InfoSize: DWORD;
  DataBlock: Pointer;
  Buffer: Pointer;
begin
  ZeroMemory(@Result, SizeOf(Result));

  InfoSize := GetFileVersionInfoSize(PChar(Filename), Handle);
  if InfoSize = 0 then
    RaiseLastOSError;

  GetMem(DataBlock, InfoSize);
  try
    if not GetFileVersionInfo(PChar(Filename), Handle, InfoSize, DataBlock) then
      RaiseLastOSError;

    if VerQueryValue(DataBlock, '\', Buffer, InfoSize) then
      Result := PFixedFileInfo(Buffer)^;
  finally
    FreeMem(DataBlock);
  end;
end;

class function TFileVersion.Retrieve(Module: HMODULE): TFixedFileInfo;
var
  Buffer: array [0 .. MAX_PATH] of Char;
begin
  if GetModuleFileName(Module, Buffer, SizeOf(Buffer)) = 0 then
    RaiseLastOSError;
  Result := Retrieve({Filename=}string(Buffer));
end;

class function TFileVersion.Convert(const FixedFileInfo: TFixedFileInfo): string;
begin
  Result := Format('%d.%d.%d.%d', [FixedFileInfo.dwFileVersionLS, FixedFileInfo.dwFileVersionMS,
    FixedFileInfo.dwProductVersionLS, FixedFileInfo.dwProductVersionMS]);
end;

end.
