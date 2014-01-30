(**
 * $Id: dutil.net.jsonrpc.message.JsonRpcException.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.jsonrpc.message.JsonRpcException;

interface

uses
  SysUtils,
  dutil.net.jsonrpc.message.Error,
  dutil.net.jsonrpc.message.Identifier;

type
  /// <summary>This immutable value class represents a JSON-RPC request identifier.</summary>
  EJsonRpcException = class(Exception)
  private
    FError: EError;
    FId: TIdentifier;
  public
    property Error: EError read FError;
    property Id: TIdentifier read FId;
  public
    constructor Create(Error: EError; const Id: TIdentifier);
    destructor Destroy; override;
  end;

implementation

constructor EJsonRpcException.Create(Error: EError; const Id: TIdentifier);
begin
  assert(Error <> nil);

  FError := EError.Create(Error.Code, Error.Message_, Error.Data);
  FId := Id;

  if (FId.Value = nil) then
    inherited Create(FError.ToString)
  else
    inherited Create(Format('%s (id=%s)', [FError.ToString, FId.ToString]));
end;

destructor EJsonRpcException.Destroy;
begin
  FError.Free;
  FError := nil;

  inherited;
end;

end.
