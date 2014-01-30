(**
 * $Id: dutil.net.jsonrpc.message.Handler.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.jsonrpc.message.Handler;

interface

uses
  superobject { An universal object serialization framework with Json support },
  dutil.net.jsonrpc.message.Error,
  dutil.net.jsonrpc.message.Identifier;

type
  /// <summary>This interface defines the obligation to handle JSON-RPC requests and responses. The implementation may
  /// require that the specified error and the identifier are not null.</summary>
  IHandler = interface
    procedure HandleRequest(const Method: string; const Params: ISuperObject; const Id: TIdentifier);
    procedure HandleNotification(const Method: string; const Params: ISuperObject);
    procedure HandleResponse(const Result: ISuperObject; const Id: TIdentifier); overload;
    procedure HandleResponse(Error: EError; const Id: TIdentifier); overload;
  end;

implementation

end.
