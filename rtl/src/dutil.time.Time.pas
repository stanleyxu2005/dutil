(**
 * $Id: dutil.time.Time.pas 430 2012-04-17 09:45:52Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.time.Time;

interface

type
  /// <summary>This service class provides some important constants of time.</summary>
  TTime_ = class
  private
    class var FEpoch: TDateTime;
    class var FEpoch1601: TDateTime;
    class var FEpoch1970: TDateTime;
    class var FMax: TDateTime;
    class constructor Create;
  public
    class property EPOCH: TDateTime read FEpoch;
    class property EPOCH_1601: TDateTime read FEpoch1601;
    class property EPOCH_1970: TDateTime read FEpoch1970;
    class property MAX: TDateTime read FMax;
  end;

implementation

uses
  DateUtils;

class constructor TTime_.Create;
begin
  FEpoch := EncodeDateTime(1, 1, 1, 0, 0, 0, 0);
  FEpoch1601 := EncodeDateTime(1601, 1, 1, 0, 0, 0, 0);
  FEpoch1970 := EncodeDateTime(1970, 1, 1, 0, 0, 0, 0);
  FMax := EncodeDateTime(9999, 12, 31, 23, 59, 59, 999);
end;

end.
