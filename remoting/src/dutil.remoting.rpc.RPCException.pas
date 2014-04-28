(**
 * $Id: dutil.remoting.rpc.RPCException.pas 786 2014-04-27 15:44:17Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.rpc.RPCException;

interface

uses
  System.SysUtils,
  dutil.remoting.rpc.ErrorObject,
  dutil.remoting.rpc.Identifier;

type
  /// <summary>Thrown when a RPC message is perceived to be invalid.</summary>
  ERPCException = class(Exception)
  private
    FError: TErrorObject;
    FId: TIdentifier;
  public
    property Error: TErrorObject read FError;
    property Id: TIdentifier read FId;
  public
    constructor Create(const Error: TErrorObject; const Id: TIdentifier);
  end;

implementation

constructor ERPCException.Create(const Error: TErrorObject; const Id: TIdentifier);
begin
  FError := Error;
  FId := Id;

  if (FId.Value = nil) then
    inherited Create(FError.ToString)
  else
    inherited Create(Format('%s (id=%s)', [FError.ToString, FId.ToString]));
end;

end.
