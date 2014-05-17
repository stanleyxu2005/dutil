(* *
  * $Id: dui.sys.InstanceManager.pas 819 2014-05-11 06:45:16Z QXu $
  *
  * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
  * express or implied. See the License for the specific language governing rights and limitations under the License.
*)

unit dui.sys.InstanceManager;

interface

type
  TInstanceManager = class
  public
    /// <summary>Indicates whether another instance of a given application is running.</summary>
    class function OtherInstanceIsRunning(MatchFileContent: Boolean): Boolean; static;
    /// <summary>Retrieves the most recent command-line send to this instance.</summary>
    class function GetLastCommandLine: string; static;
  end;

var
  nUIActivationKey: Integer = 0;
  // This message is posted to the (hidden) application window (and can be handled anywhere by
  // hooking this window) if another instance was started and forwarded execution to this instance.
  WM_OTHERINSTANCE: Cardinal;

const
  WPARAM_NO_UI_ACTIVATION = 10;

implementation

uses
  VCL.Forms,
  Winapi.Messages,
  Winapi.Windows,
  System.SysUtils,
  dutil.util.digest.Crc32,
  dui.sys.UserInput;

type
  // Standard record containing general info shared between all instances.
  PInstanceInfo = ^TInstInfo;

  TInstInfo = record
    hFirstInstance: THandle;
    Params: array [0 .. 4096 - 1] of Char;
    bLocked: Boolean;
  end;

  // Restores application window to foreground.
procedure AppBringToFront(Handle: THandle);
var
  TopWindow: HWND;
begin
  if Handle <> 0 then
  begin
    if IsIconic(Handle) then
      // NOTE: Do not use ShowWindow(Handle, SW_RESTORE);
      SendMessage(Handle, WM_SYSCOMMAND, SC_RESTORE, 0);

    TopWindow := GetLastActivePopup(Handle);
    if (TopWindow <> 0) and (TopWindow <> Handle) and IsWindowVisible(TopWindow) and IsWindowEnabled(TopWindow) then
    begin
      SetForegroundWindow(TopWindow);
      // NOTE: Do not add SendMessage(TopWindow, WM_SYSCOMMAND, SC_RESTORE, 0);
    end;
  end;
end;

var
  // Non-shared file mapping handle used in this instance to access the shared data.
  hSharedMapping: THandle;

  // Indicates whether another instance of a given application is running.
  // If this object exists then there is already an instance and True is returned.
  // Otherwise the file mapping object is freshly created and this method returns false.
class function TInstanceManager.OtherInstanceIsRunning(MatchFileContent: Boolean): Boolean;
var
  Info: PInstanceInfo;
  InfoSize: DWORD;
  Buffer: PChar;
  MappingName: string;
  wParam: Integer;
begin
  // This test should not be necessary unless an application calls this method twice.
  Result := hSharedMapping <> 0;
  if Result then
    Exit;

  // Determine name to be used for the file mapping object.
  if MatchFileContent then
    MappingName := IntToStr(TCrc32.DigestFromFile(Application.ExeName))
  else
    MappingName := IntToStr(TCrc32.digest(UpperCase(Application.ExeName)));

  // Registers a window message, which remains registered until the session ends.
  WM_OTHERINSTANCE := RegisterWindowMessage(PChar(MappingName));

  InfoSize := SizeOf(TInstInfo);
  hSharedMapping := CreateFileMapping(DWORD(-1), nil, PAGE_READWRITE, 0, InfoSize, PChar(MappingName));
  if hSharedMapping = 0 then
    RaiseLastOSError;
  // Did the mapping already exist?
  Result := GetLastError = ERROR_ALREADY_EXISTS;

  // Get a pointer to the shared memory area.
  Info := MapViewOfFile(hSharedMapping, FILE_MAP_READ or FILE_MAP_WRITE, 0, 0, InfoSize);
  if Info <> nil then
    try
      if Result then
      begin
        // There was already an instance that registered the shared area. Pass it our command line and return.
        // Command line can only be passed if we are dealing with an instance of same application.
        if not Info.bLocked then
        begin
          Buffer := PChar(Trim(string(UTF8Encode(GetCommandLine))));
          try
            Info.bLocked := True;
            Move(Buffer^, Info.Params, lstrlen(Buffer) + 1);
            // Move one char more for #0.
          finally
            Info.bLocked := False;
          end;
        end;

        if (nUIActivationKey > 0) and TUserInput.KeyPressed(nUIActivationKey) then
          wParam := WPARAM_NO_UI_ACTIVATION
        else
        begin
          wParam := 0;
          AppBringToFront(Info.hFirstInstance);
          // NOTE: Do not activate application in async way!
        end;
        PostMessage(Info.hFirstInstance, WM_OTHERINSTANCE, wParam, 0 { unused } );
      end
      else
      begin
        // This is the first instance. Store our info in the shared area.
        FillChar(Info^, InfoSize, #0);
        // The handle is that of the main form so WM_OTHERINSTANCE must be handled there if needed.
        Info.hFirstInstance := Application.Handle;
      end;
    finally
      // Free mapping to memory area.
      UnmapViewOfFile(Info);
    end;
end;

class function TInstanceManager.GetLastCommandLine: string;
var
  Info: PInstanceInfo;
begin
  if hSharedMapping = 0 then
    Exit;

  Info := MapViewOfFile(hSharedMapping, FILE_MAP_READ, 0, 0, SizeOf(TInstInfo));
  if (Info <> nil) and not Info.bLocked then
    try
      Result := UTF8ToString(RawByteString(Info.Params));
    finally
      UnmapViewOfFile(Info);
    end;
end;

initialization

finalization

if hSharedMapping <> 0 then
  CloseHandle(hSharedMapping);

end.
