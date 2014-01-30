(**
 * $Id: dutil.net.jsonrpc.framework.RequestHandler.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.jsonrpc.framework.RequestHandler;

interface

uses
  superobject { An universal object serialization framework with Json support };

type
  /// <summary>This interface defines the obligation to handle JSON-RPC requests.</summary>
  IRequestHandler = interface
    function HandleRequest(const Method: string; const Params: ISuperObject): ISuperObject;
  end;

implementation

end.
