(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dutil.sys.win32.Process;

interface

uses
  System.Generics.Collections,
  System.SysUtils,
  Winapi.ShellAPI,
  Winapi.TLHelp32,
  Winapi.Windows;

type
  /// <summary>This service class provides methods for retrieving process information.</summary>
  TProcess = class
  public
    /// <summary>Lists all active processes.</summary>
    /// <exception cref="EOSError">Operating system failure.</exception>
    class function ListAll: TArray<TProcessEntry32>; static;
    /// <summary>Lists processes that have a specified process name (case sensitive).</summary>
    /// <exception cref="EOSError">Operating system failure.</exception>
    class function ListFiltered(const ProcessName: string): TArray<TProcessEntry32>; static;
    /// <summary>Forks a process.</summary>
    /// <exception cref="EOSError">Operating system failure.</exception>
    class procedure Fork(const FileName: string; const Parameters: string; const Directory: string;
      Masks: Cardinal; ShowMode: Integer); overload; static;
    /// <summary>Forks a process.</summary>
    /// <exception cref="EOSError">Operating system failure.</exception>
    class procedure Fork(const FileName: string; const Parameters: string); overload; static;
    /// <summary>Terminates a process by its process id.</summary>
    /// <exception cref="EOSError">Operating system failure.</exception>
    class procedure Terminate(Pid: Cardinal; ExitCode: Cardinal = 0); overload; static;
    /// <summary>Terminates all processes that match the specfied process name.</summary>
    class procedure Terminate(const ProcessName: string; IncludeSelf: Boolean; ExitCode: Cardinal = 0); overload; static;
  end;

implementation

uses
  dutil.util.container.DynArray;

class function TProcess.ListAll: TArray<TProcessEntry32>;
var
  Handle: THandle;
  Process: TProcessEntry32;
  Found: Boolean;
begin
  Handle := CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Handle = INVALID_HANDLE_VALUE then
    RaiseLastOSError;

  SetLength(Result, 0);
  ZeroMemory(@Process, SizeOf(Process));
  Process.dwSize := SizeOf(Process);
  Found := Process32First(Handle, Process);
  while Found do
  begin
    TDynArray.Append<TProcessEntry32>(Result, Process);

    ZeroMemory(@Process, SizeOf(Process));
    Process.dwSize := SizeOf(Process);
    Found := Process32Next(Handle, Process);
  end;
  CloseHandle(Handle);
end;

class function TProcess.ListFiltered(const ProcessName: string): TArray<TProcessEntry32>;
var
  Process: TProcessEntry32;
begin
  assert(ProcessName <> '');

  SetLength(Result, 0);
  for Process in ListAll do
  begin
    if Process.szExeFile = ProcessName then
      TDynArray.Append<TProcessEntry32>(Result, Process);
  end;
end;

class procedure TProcess.Fork(const FileName: string; const Parameters: string; const Directory: string;
  Masks: Cardinal; ShowMode: Integer);
var
  Info: TShellExecuteInfo;
begin
  assert(FileName <> '');

  ZeroMemory(@Info, SizeOf(Info));
  Info.cbSize := SizeOf(Info);
  Info.fMask := Masks;
  Info.Wnd := HWND_DESKTOP;
  Info.lpVerb := 'open';
  Info.lpFile := PChar(FileName);
  Info.lpParameters := PChar(Parameters);
  Info.lpDirectory := PChar(Directory);
  Info.nShow := ShowMode;

  if not ShellExecuteEx(@Info) then
    RaiseLastOSError;
end;

class procedure TProcess.Fork(const FileName: string; const Parameters: string);
const
  DEFAULT_WORKING_DIR = '';
  // madExcept reports a handle leak if `SEE_MASK_NOCLOSEPROCESS` is set
  DEFAULT_MASKS = {SEE_MASK_NOCLOSEPROCESS or }SEE_MASK_FLAG_NO_UI or SEE_MASK_FLAG_DDEWAIT;
  DEFAULT_SHOW_MODE = SW_NORMAL;
begin
  assert(FileName <> '');

  Fork(FileName, Parameters, DEFAULT_WORKING_DIR, DEFAULT_MASKS, DEFAULT_SHOW_MODE);
end;

class procedure TProcess.Terminate(Pid: Cardinal; ExitCode: Cardinal);
var
  Handle: THandle;
  Success: Boolean;
begin
  assert(Pid > 0);

  Handle := OpenProcess(PROCESS_TERMINATE, {bInheritHandle=}False, Pid);
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

class procedure TProcess.Terminate(const ProcessName: string; IncludeSelf: Boolean; ExitCode: Cardinal);
var
  Process: TProcessEntry32;
  PIDs: TArray<Cardinal>;
  PID: Cardinal;
begin
  assert(ProcessName <> '');

  SetLength(PIDs, 0);
  for Process in ListFiltered(ProcessName) do
    if Process.th32ProcessID = GetCurrentProcessId then
    begin
      if IncludeSelf then
        // Keeps the current process to be terminated at the end
        TDynArray.Append<Cardinal>(PIDs, Process.th32ProcessID)
    end
    else
      TDynArray.Insert<Cardinal>(PIDs, Process.th32ProcessID, 0);

  for PID in PIDs do
    try
      TProcess.Terminate(PID, ExitCode);
    except
      on EOSError do ;
    end;
end;

end.
