(**
 * $Id: dutil.remoting.rpc.Serializer.pas 786 2014-04-27 15:44:17Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.rpc.Serializer;

interface

uses
  superobject { An universal object serialization framework with Json support },
  dutil.remoting.rpc.ErrorObject,
  dutil.remoting.rpc.Identifier,
  dutil.remoting.rpc.RPCHandler;

type
  /// <summary>This interface defines the obligation of RPC data serialization.</summary>
  ISerializer = interface
    /// <summary>Encodes a request.</summary>
    function EncodeRequest(const Method: string; const Params: ISuperObject; const Id: TIdentifier): string;
    /// <summary>Encodes a notification.</summary>
    function EncodeNotification(const Method: string; const Params: ISuperObject): string;
    /// <summary>Encodes a valid response.</summary>
    function EncodeResponse(const Result_: ISuperObject; const Id: TIdentifier): string; overload;
    /// <summary>Encodes an error response.</summary>
    function EncodeResponse(const Error: TErrorObject; const Id: TIdentifier): string; overload;
    /// <summary>Decodes a message and executes it with specified handler.</summary>
    /// <exception cref="ERPCException">Specified message does not represent a valid request or response.</exception>
    procedure Decode(const Message_: string; const Handler: IRPCHandler);
  end;

implementation

end.
