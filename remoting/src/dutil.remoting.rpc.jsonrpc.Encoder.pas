(**
 * $Id: dutil.remoting.rpc.jsonrpc.Encoder.pas 800 2014-04-30 07:18:42Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.rpc.jsonrpc.Encoder;

interface

uses
  superobject { An universal object serialization framework with Json support },
  dutil.remoting.rpc.ErrorObject,
  dutil.remoting.rpc.Identifier;

type
  /// <summary>This service class allows to encode JSON-RPC requests and responses.</summary>
  TEncoder = class
{$IFNDEF OMIT_JSONRPC_PROTOCOL_VERSION}
  private const
    VERSION = '2.0';
{$ENDIF}
  public
    class function EncodeRequest(const Method: string; const Params: ISuperObject; const Id: TIdentifier): string;
      static;
    class function EncodeNotification(const Method: string; const Params: ISuperObject): string; static;
    class function EncodeResponse(const Result_: ISuperObject; const Id: TIdentifier): string; overload; static;
    class function EncodeResponse(const Error: TErrorObject; const Id: TIdentifier): string; overload; static;
  private
    class function EncodeProtocolVersion: ISuperObject; static;
    class function Encode(const Error: TErrorObject): ISuperObject; static;
  end;

implementation

class function TEncoder.EncodeRequest(const Method: string; const Params: ISuperObject; const Id: TIdentifier): string;
var
  Request: ISuperObject;
begin
  assert(Method <> '');
  assert((Params = nil) or (Params.DataType in [TSuperType.stArray, TSuperType.stObject]));
  assert(Id.Value <> nil);

  Request := EncodeProtocolVersion;
  Request.S['method'] := Method;
  if Params <> nil then
    Request.O['params'] := Params;
  Request.O['id'] := Id.Value;

  Result := Request.AsJson;
end;

class function TEncoder.EncodeNotification(const Method: string; const Params: ISuperObject): string;
var
  Notification: ISuperObject;
begin
  assert(Method <> '');
  assert((Params = nil) or (Params.DataType in [TSuperType.stArray, TSuperType.stObject]));

  Notification := EncodeProtocolVersion;
  Notification.S['method'] := Method;
  if Params <> nil then
    Notification.O['params'] := Params;

  Result := Notification.AsJson;
end;

class function TEncoder.EncodeResponse(const Result_: ISuperObject; const Id: TIdentifier): string;
var
  Response: ISuperObject;
begin
  assert(Id.Value <> nil);

  Response := EncodeProtocolVersion;
  Response.O['result'] := Result_;
  Response.O['id'] := Id.Value;

  Result := Response.AsJson;
end;

class function TEncoder.EncodeResponse(const Error: TErrorObject; const Id: TIdentifier): string;
var
  Response: ISuperObject;
begin
  assert(Id.Valid);

  Response := EncodeProtocolVersion;
  Response.O['error'] := Encode(Error);
  Response.O['id'] := Id.Value;

  Result := Response.AsJson;
end;

class function TEncoder.EncodeProtocolVersion: ISuperObject;
begin
  Result := SO;
{$IFNDEF OMIT_JSONRPC_PROTOCOL_VERSION}
  Result.S['jsonrpc'] := VERSION;
{$ENDIF}
end;

class function TEncoder.Encode(const Error: TErrorObject): ISuperObject;
begin
  Result := SO;
  Result.I['code'] := Error.Code;
  Result.S['message'] := Error.Message_;
  if Error.Data <> nil then
    Result.O['data'] := Error.Data;
end;

end.
