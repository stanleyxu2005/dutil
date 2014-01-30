(**
 * $Id: dutil.net.jsonrpc.framework.Sender.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.jsonrpc.framework.Sender;

interface

uses
  superobject { An universal object serialization framework with Json support },
  dutil.util.concurrent.Result;

type
  /// <summary>This interface defines the obligation to send JSON-RPC requests and JSON-RPC notifications. The attempt
  /// to retrieve the result value of a JSON-RPC request throws a JsonRpcException when an error response, an invalid
  /// response or no response at all is received.</summary>
  ISender = interface
    function SendRequest(const Method: string; const Params: ISuperObject): TResult<ISuperObject>;
    procedure SendNotification(const Method: string; const Params: ISuperObject);
  end;

implementation

end.
