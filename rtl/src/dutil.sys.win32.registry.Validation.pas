(**
 * $Id: dutil.sys.win32.registry.Validation.pas 747 2014-03-11 07:42:35Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.sys.win32.registry.Validation;

interface

uses
  System.Win.Registry,
  Winapi.Windows;

type
  /// <summary>This service class provides methods for simple Windows Registry validity checks.</summary>
  TValidation = class
  public
    /// <summary>Retrieves a string value from registry.</summary>
    /// <exceptions cref="ERegistryException">The value does not exist.</exceptions>
    class function RequireStr(const Key: string; const Name: string; RootKey: HKEY = HKEY_CURRENT_USER): string; static;
    /// <summary>Retrieves a non-negative integer value from registry.</summary>
    /// <exceptions cref="ERegistryException">The value does not exist.</exceptions>
    class function RequireUInt(const Key: string; const Name: string; RootKey: HKEY = HKEY_CURRENT_USER): Cardinal;
      static;
  private
    class function RequireValue(Reg: TRegistry; const Key: string; const Name: string; RootKey: HKEY): Boolean;
      overload; static;
  end;

implementation

uses
  System.SysUtils;

class function TValidation.RequireValue(Reg: TRegistry; const Key: string; const Name: string; RootKey: HKEY): Boolean;
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

class function TValidation.RequireStr(const Key: string; const Name: string; RootKey: HKEY = HKEY_CURRENT_USER): string;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    if RequireValue(Reg, Key, Name, RootKey) then
    begin
      try
        Result := Reg.ReadString(Name); // this might raise ERegistryException
      finally
        Reg.CloseKey;
      end;
      Exit;
    end;
  finally
    Reg.Free;
  end;

  raise ERegistryException.Create(Format('String value does not exist: key=%s, value name=%s', [Key, Name]));
end;

type
  TRegistryAccess = class(TRegistry)
  end;

class function TValidation.RequireUInt(const Key: string; const Name: string;
  RootKey: HKEY = HKEY_CURRENT_USER): Cardinal;
var
  Reg: TRegistry;
  RegData: TRegDataType;
begin
  Reg := TRegistry.Create;
  try
    if RequireValue(Reg, Key, Name, RootKey) then
    begin
      try
        TRegistryAccess(Reg).GetData(Name, @Result, SizeOf(Cardinal), RegData);
        if RegData <> rdInteger then
          raise ERegistryException.Create(Format('Invalid data type for ''%s''', [Name]));
      finally
        Reg.CloseKey;
      end;
      Exit;
    end;
  finally
    Reg.Free;
  end;

  raise ERegistryException.Create(Format('Non-negative integer value does not exist: key=%s, value name=%s',
      [Key, Name]));
end;

end.
