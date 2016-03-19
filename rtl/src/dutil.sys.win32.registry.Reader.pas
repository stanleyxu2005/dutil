(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dutil.sys.win32.registry.Reader;

interface

uses
  System.Win.Registry,
  Winapi.Windows;

type
  /// <summary>This service class provides methods for quick accessing the Windows Registry.</summary>
  TReader = class
  public
    /// <summary>Retrieves a string value from registry or fallback to default.</summary>
    class function ReadStr(const Key: string; const Name: string; const Fallback: string;
      const RootKey: HKEY = HKEY_CURRENT_USER): string; static;
    /// <summary>Retrieves a non-negative integer value from registry or fallback to default.</summary>
    class function ReadUInt(const Key: string; const Name: string; Fallback: Cardinal;
      const RootKey: HKEY = HKEY_CURRENT_USER): Cardinal; static;
  protected // trick to make the following methods package wide visible
    class function ValueExists(Reg: TRegistry; const Key: string; const Name: string; const RootKey: HKEY): Boolean;
      overload; static;
  end;

implementation

class function TReader.ValueExists(Reg: TRegistry; const Key: string; const Name: string; const RootKey: HKEY): Boolean;
begin
  assert(Reg <> nil);

  Reg.RootKey := RootKey;
  if Reg.OpenKeyReadOnly(Key) then
  begin
    Result := Reg.ValueExists(Name);
    if not Result then
      Reg.CloseKey;
  end
  else
    Result := False;
end;

class function TReader.ReadStr(const Key: string; const Name: string; const Fallback: string;
  const RootKey: HKEY): string;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    if ValueExists(Reg, Key, Name, RootKey) then
    begin
      try
        Result := Reg.ReadString(Name); // this might raise ERegistryException
      except
        Result := Fallback;
      end;
      Reg.CloseKey;
    end
    else
      Result := Fallback;
  finally
    Reg.Free;
  end;
end;

type
  TRegistryAccess = class(TRegistry)
  end;

class function TReader.ReadUInt(const Key: string; const Name: string; Fallback: Cardinal;
  const RootKey: HKEY): Cardinal;
var
  Reg: TRegistry;
  RegData: TRegDataType;
begin
  Reg := TRegistry.Create;
  try
    if ValueExists(Reg, Key, Name, RootKey) then
    begin
      try
        TRegistryAccess(Reg).GetData(Name, @Result, SizeOf(Cardinal), RegData);
        if RegData <> rdInteger then
          Result := Fallback;
      finally
        Reg.CloseKey;
      end;
    end
    else
      Result := Fallback;
  finally
    Reg.Free;
  end;
end;

end.
