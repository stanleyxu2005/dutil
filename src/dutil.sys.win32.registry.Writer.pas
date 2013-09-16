(**
 * $Id: dutil.sys.win32.registry.Writer.pas 541 2012-06-09 20:16:12Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.sys.win32.registry.Writer;

interface

uses
  Registry,
  Windows;

type
  /// <summary>This service class provides methods for quick accessing the Windows Registry.</summary>
  TWriter = class
  public
    /// <summary>Writes a string value into the registry.</summary>
    /// <exceptions cref="ERegistryException">Failed to write data.</exceptions>
    class procedure WriteStr(const Key: string; const Name: string; const Value: string;
      RootKey: HKEY = HKEY_CURRENT_USER); static;
    /// <summary>Writes a non-negative integer value into the registry.</summary>
    /// <exceptions cref="ERegistryException">Failed to write data.</exceptions>
    class procedure WriteUInt(const Key: string; const Name: string; Value: Cardinal;
      RootKey: HKEY = HKEY_CURRENT_USER); static;
    /// <summary>Removes an entrie key from the registry.</summary>
    /// <exceptions cref="ERegistryException">Failed to remove data.</exceptions>
    class procedure RemoveKey(const Key: string; RootKey: HKEY = HKEY_CURRENT_USER); static;
    /// <summary>Removes an item of a key from the registry.</summary>
    /// <exceptions cref="ERegistryException">Failed to remove data.</exceptions>
    class procedure RemoveValue(const Key: string; const Name: string; RootKey: HKEY = HKEY_CURRENT_USER); static;
  private
    /// <exceptions cref="ERegistryException">Failed to open or to create the key.</exceptions>
    class procedure RequireOpenKey(Reg: TRegistry; const Key: string; RootKey: HKEY); static;
  end;

implementation

uses
  SysUtils;

class procedure TWriter.RequireOpenKey(Reg: TRegistry; const Key: string; RootKey: HKEY);
begin
  assert(Reg <> nil);

  Reg.RootKey := RootKey;
  if not Reg.OpenKey(Key, {CanCreate=}True) then
    raise ERegistryException.Create(Format('Failed to open key: %s', [Key]));
end;

class procedure TWriter.WriteStr(const Key: string; const Name: string; const Value: string;
  RootKey: HKEY = HKEY_CURRENT_USER);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    RequireOpenKey(Reg, Key, RootKey); // this might raise ERegistryException
    try
      Reg.WriteString(Name, Value); // this might raise ERegistryException
    finally
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

type
  TRegistryAccess = class(TRegistry)
  end;

class procedure TWriter.WriteUInt(const Key: string; const Name: string; Value: Cardinal;
  RootKey: HKEY = HKEY_CURRENT_USER);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    RequireOpenKey(Reg, Key, RootKey); // this might raise ERegistryException
    try
      TRegistryAccess(Reg).PutData(Name, @Value, SizeOf(Cardinal), rdInteger); // this might raise ERegistryException
    finally
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

class procedure TWriter.RemoveKey(const Key: string; RootKey: HKEY = HKEY_CURRENT_USER);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    RequireOpenKey(Reg, Key, RootKey); // this might raise ERegistryException
    try
      Reg.DeleteKey(Key);
    finally
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

class procedure TWriter.RemoveValue(const Key: string; const Name: string; RootKey: HKEY = HKEY_CURRENT_USER);
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    RequireOpenKey(Reg, Key, RootKey); // this might raise ERegistryException
    try
      if Reg.ValueExists(Name) then
        Reg.DeleteValue(Name);
    finally
      Reg.CloseKey;
    end;
  finally
    Reg.Free;
  end;
end;

end.