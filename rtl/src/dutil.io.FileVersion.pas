(**
 * $Id: dutil.io.FileVersion.pas 718 2013-11-18 12:11:57Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
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
  end;

implementation

uses
  SysUtils,
  Windows;

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

end.
