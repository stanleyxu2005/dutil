(**
 * $Id: dutil.sys.win32.Process.pas 718 2013-11-18 12:11:57Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.sys.win32.Process;

interface

uses
  Generics.Collections,
  ShellAPI,
  SysUtils,
  TLHelp32,
  Windows;

type
  /// <summary>This service class provides methods for retrieving process information.</summary>
  TProcess = class
  public
    /// <summary>Lists all active processes.</summary>
    /// <exception cref="EOSError">Operating system failure.</exception>
    class function ListAll: TList<TProcessEntry32>; static;
    /// <summary>Lists all active processes that have a specified process name (case sensitive).</summary>
    /// <exception cref="EOSError">Operating system failure.</exception>
    class function ListFilteredByProcessName(const ProcessName: string): TList<TProcessEntry32>; static;
    /// <summary>Folks a process.</summary>
    /// <exception cref="EOSError">Operating system failure.</exception>
    class procedure Folk(const Filename: string; const Parameters: string; const WorkingDir: string;
      Masks: Cardinal; ShowMode: Integer); overload; static;
    /// <summary>Folks a process.</summary>
    /// <exception cref="EOSError">Operating system failure.</exception>
    class procedure Folk(const Filename: string; const Parameters: string); overload; static;
    /// <summary>Terminates a process by its process id.</summary>
    /// <exception cref="EOSError">Operating system failure.</exception>
    class procedure Terminate(PID: Cardinal; ExitCode: Cardinal); static;
  end;

implementation

class function TProcess.ListAll: TList<TProcessEntry32>;
var
  Handle: THandle;
  Process: TProcessEntry32;
  Found: Boolean;
begin
  Handle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Handle = INVALID_HANDLE_VALUE then
    RaiseLastOSError;

  try
    Result := TList<TProcessEntry32>.Create;
    ZeroMemory(@Process, SizeOf(Process));
    Process.dwSize := SizeOf(Process);

    Found := Process32First(Handle, Process);
    while Found do
    begin
      Result.Add(Process);

      ZeroMemory(@Process, SizeOf(Process));
      Process.dwSize := SizeOf(Process);
      Found := Process32Next(Handle, Process);
    end;
  finally
    CloseHandle(Handle);
  end;
end;

class function TProcess.ListFilteredByProcessName(const ProcessName: string): TList<TProcessEntry32>;
var
  ProcessList: TList<TProcessEntry32>;
  Process: TProcessEntry32;
begin
  Result := TList<TProcessEntry32>.Create;

  ProcessList := ListAll;
  try
    for Process in ProcessList do
    begin
      if Process.szExeFile = ProcessName then
        Result.Add(Process);
    end;
  finally
    ProcessList.Free;
  end;
end;

class procedure TProcess.Folk(const Filename: string; const Parameters: string; const WorkingDir: string;
  Masks: Cardinal; ShowMode: Integer);
var
  Info: TShellExecuteInfo;
begin
  ZeroMemory(@Info, SizeOf(Info));
  Info.cbSize := SizeOf(Info);
  Info.fMask := Masks;
  Info.Wnd := HWnd_Desktop;
  Info.lpVerb := PChar('open');
  Info.lpFile := PChar(Filename);
  Info.lpParameters := PChar(Parameters);
  Info.lpDirectory := PChar(WorkingDir);
  Info.nShow := ShowMode;

  if not ShellExecuteEx(@Info) then
    RaiseLastOSError;
end;

class procedure TProcess.Folk(const Filename: string; const Parameters: string);
const
  DEFAULT_WORKING_DIR = '';
  DEFAULT_MASKS = SEE_MASK_NOCLOSEPROCESS or SEE_MASK_FLAG_NO_UI or SEE_MASK_FLAG_DDEWAIT;
  DEFAULT_SHOW_MODE = SW_NORMAL;
begin
  Folk(Filename, Parameters, DEFAULT_WORKING_DIR, DEFAULT_MASKS, DEFAULT_SHOW_MODE);
end;

class procedure TProcess.Terminate(PID: Cardinal; ExitCode: Cardinal);
var
  Handle: THandle;
  Success: Boolean;
begin
  Handle := OpenProcess(PROCESS_TERMINATE, {bInheritHandle=}False, PID);
  if Handle = THandle(nil) then
    RaiseLastOSError;

  try
    Success := TerminateProcess(Handle, ExitCode);
    if not Success then
      RaiseLastOSError;
  finally
    CloseHandle(Handle);
  end;
end;

end.
