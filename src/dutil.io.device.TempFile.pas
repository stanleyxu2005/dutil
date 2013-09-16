(**
 * $Id: dutil.io.device.TempFile.pas 530 2012-06-05 14:31:51Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.io.device.TempFile;

interface

type
  /// <summary>This service class provides methods for generating temporary files and directories.</summary>
  TTempFile = class
  public
    /// <summary>Creates a temporary directory.</summary>
    /// <exception cref="EInOutError">When failed to create the directory.</exception>
    class function MakeTempDirectory(const ParentDirectory: string; const Prefix: string = 'tmp';
      const Suffix: string = ''): string; static;
  end;

implementation

uses
  IOUtils,
  SysUtils;

class function TTempFile.MakeTempDirectory(const ParentDirectory: string; const Prefix: string = 'tmp';
  const Suffix: string = ''): string;
const
  FORMAT_PATTERN = '%s%d%s';
var
  I: Integer;
begin
  I := 1000;
  Result := TPath.Combine(ParentDirectory, Format(FORMAT_PATTERN, [Prefix, I, Suffix]));

  while TDirectory.Exists(Result) do
  begin
    if I = MaxInt then
      raise EInOutError.Create('Temp directory is full');
    Inc(I);
    Result := TPath.Combine(ParentDirectory, Format(FORMAT_PATTERN, [Prefix, I, Suffix]));
  end;

  TDirectory.CreateDirectory(Result);
end;

end.
