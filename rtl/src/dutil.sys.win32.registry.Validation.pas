(**
 * $Id: dutil.sys.win32.registry.Validation.pas 834 2014-05-20 18:43:27Z QXu $
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
    /// <summary>Expects a string value from registry.</summary>
    /// <exceptions cref="ERegistryException">The value does not exist.</exceptions>
    class function RequireStr(const Key: string; const Name: string;
      const RootKey: HKEY = HKEY_CURRENT_USER): string; static;
    /// <summary>Expects a non-negative integer value from registry.</summary>
    /// <exceptions cref="ERegistryException">The value does not exist.</exceptions>
    class function RequireUInt(const Key: string; const Name: string;
      const RootKey: HKEY = HKEY_CURRENT_USER): Cardinal; static;
  end;

implementation

uses
  dutil.sys.win32.registry.Reader;

type
  TReaderAccess = class(TReader)
  end;

class function TValidation.RequireStr(const Key: string; const Name: string; const RootKey: HKEY): string;
var
  Reg: TRegistry;
begin
  Reg := TRegistry.Create;
  try
    if TReaderAccess.ValueExists(Reg, Key, Name, RootKey) then
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

  raise ERegistryException.CreateFmt('String value does not exist: key=%s, value name=%s', [Key, Name]);
end;

type
  TRegistryAccess = class(TRegistry)
  end;

class function TValidation.RequireUInt(const Key: string; const Name: string; const RootKey: HKEY): Cardinal;
var
  Reg: TRegistry;
  RegData: TRegDataType;
begin
  Reg := TRegistry.Create;
  try
    if TReaderAccess.ValueExists(Reg, Key, Name, RootKey) then
    begin
      try
        TRegistryAccess(Reg).GetData(Name, @Result, SizeOf(Cardinal), RegData);
        if RegData <> rdInteger then
          raise ERegistryException.CreateFmt('Invalid data type for ''%s''', [Name]);
      finally
        Reg.CloseKey;
      end;
      Exit;
    end;
  finally
    Reg.Free;
  end;

  raise ERegistryException.CreateFmt('Non-negative integer value does not exist: key=%s, value name=%s', [Key, Name]);
end;

end.
