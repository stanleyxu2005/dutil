(**
 * $Id: dutil.remoting.rpc.jsonrpc.SerializerImpl.pas 800 2014-04-30 07:18:42Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.rpc.jsonrpc.SerializerImpl;

interface

uses
  superobject { An universal object serialization framework with Json support },
  dutil.remoting.rpc.ErrorObject,
  dutil.remoting.rpc.Identifier,
  dutil.remoting.rpc.RPCHandler,
  dutil.remoting.rpc.Serializer;

type
  /// <summary>This class implement a JSON-RPC data serializer.</summary>
  TSerializerImpl = class(TInterfacedObject, ISerializer)
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

uses
  dutil.remoting.rpc.jsonrpc.Encoder,
  dutil.remoting.rpc.jsonrpc.Decoder;

function TSerializerImpl.EncodeRequest(const Method: string; const Params: ISuperObject; 
  const Id: TIdentifier): string;
begin
  Result := TEncoder.EncodeRequest(Method, Params, Id);
end;

function TSerializerImpl.EncodeNotification(const Method: string; const Params: ISuperObject): string;
begin
  Result := TEncoder.EncodeNotification(Method, Params);
end;

function TSerializerImpl.EncodeResponse(const Result_: ISuperObject; const Id: TIdentifier): string;
begin
  Result := TEncoder.EncodeResponse(Result_, Id);
end;

function TSerializerImpl.EncodeResponse(const Error: TErrorObject; const Id: TIdentifier): string;
begin
  Result := TEncoder.EncodeResponse(Error, Id);
end;

procedure TSerializerImpl.Decode(const Message_: string; const Handler: IRPCHandler);
begin
  TDecoder.Decode(Message_, Handler);
end;

end.