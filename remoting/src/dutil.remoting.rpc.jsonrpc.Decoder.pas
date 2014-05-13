(**
 * $Id: dutil.remoting.rpc.jsonrpc.Decoder.pas 822 2014-05-13 17:06:20Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.rpc.jsonrpc.Decoder;

interface

uses
  superobject { An universal object serialization framework with Json support },
  dutil.remoting.rpc.ErrorObject,
  dutil.remoting.rpc.Identifier,
  dutil.remoting.rpc.RPCHandler;

type
  /// <summary>This service class allows to decode JSON-RPC requests and responses, which are forwarded to the
  /// specified handler.</summary>
  TDecoder = class
{$IFNDEF OMIT_JSONRPC_PROTOCOL_VERSION}
  private const
    VERSION = '2.0';
{$ENDIF}
  public
    /// <exception cref="ERPCException">When the specified message does not represent a valid JSON-RPC request or
    /// response.</exception>
    class procedure Decode(const Message_: string; const Handler: IRPCHandler); static;
  private type
    TMessageType = (REQUEST, NOTIFICATION, RESPONSE, ERROR);
  private
    /// <exception cref="EJsonException">When the specified JSON object has an invalid identifier.</exception>
    class function ValidateId(const Composite: ISuperObject): TIdentifier; static;
{$IFNDEF OMIT_JSONRPC_PROTOCOL_VERSION}
    /// <exception cref="EJsonException">When the specified JSON object has no or not the expected version
    /// value.</exception>
    class function ValidateProtocolVersion(const Composite: ISuperObject): string; static;
{$ENDIF}
    /// <exception cref="EJsonException">When the specified JSON object is neither a request object nor a response
    /// object.</exception>
    class function ValidateType(const Composite: ISuperObject): TMessageType;
    /// <exception cref="EJsonException">When the specified JSON object has an invalid parameters value.</exception>
    class function ValidateParams(const Composite: ISuperObject): ISuperObject; static;
    /// <exception cref="EJsonException">When the specified JSON object has an invalid error value.</exception>
    class function ValidateError(const Composite: ISuperObject): TErrorObject; static;
  end;

implementation

uses
  System.SysUtils,
  dutil.core.Exception,
  dutil.text.json.Validation,
  dutil.remoting.rpc.RPCException;

class procedure TDecoder.Decode(const Message_: string; const Handler: IRPCHandler);
var
  Id: TIdentifier;
  Composite: ISuperObject;
  Error: TErrorObject; // record
begin
  assert(Handler <> nil);

  Id := TIdentifier.NullIdentifier;

  Composite := SO(Message_);
  if Composite.DataType <> TSuperType.stObject then
  begin
    Error := TErrorObject.CreateParseError(Message_);
    raise ERPCException.Create(Error, Id);
  end;

  try
    Id := ValidateId(Composite);
  {$IFNDEF OMIT_JSONRPC_PROTOCOL_VERSION}
    ValidateProtocolVersion(Composite);
  {$ENDIF}

    case ValidateType(Composite) of
      TMessageType.REQUEST:
        Handler.HandleRequest(Composite.S['method'], ValidateParams(Composite), Id);
      TMessageType.NOTIFICATION:
        Handler.HandleNotification(Composite.S['method'], ValidateParams(Composite));
      TMessageType.RESPONSE:
        Handler.HandleResponse(Composite.O['result'], Id);
      TMessageType.ERROR:
        Handler.HandleResponse(ValidateError(Composite), Id);
    else
      raise ENotImplemented.CreateFmt('Unexpected message type: %s', [Message_]);
    end;
  except
    on E: EJsonException do
    begin
      Error := TErrorObject.CreateInvalidRequest(E.ToString);
      raise ERPCException.Create(Error, Id);
    end;
  end;
end;

class function TDecoder.ValidateId(const Composite: ISuperObject): TIdentifier;
var
  Value: ISuperObject;
begin
  assert(Composite <> nil);

  Value := Composite.O['id'];
  try
    Result := TIdentifier.FromValue(Value);
  except
    on EArgumentException do
      raise EJsonException.Create('"id" value must be string, number or null');
  end;
end;

{$IFNDEF OMIT_JSONRPC_PROTOCOL_VERSION}
class function TDecoder.ValidateProtocolVersion(const Composite: ISuperObject): string;
begin
  assert(Composite <> nil);

  Result := TValidation.RequireStrMember(Composite, 'jsonrpc');
  if Result <> VERSION then
    raise EJsonException.CreateFmt('protocol version must be "%s"', [VERSION]);
end;
{$ENDIF}

class function TDecoder.ValidateType(const Composite: ISuperObject): TMessageType;
var
  Types: SmallInt;
  Id: ISuperObject;
begin
  assert(Composite <> nil);

  Types := 0;
  Id := Composite.O['id'];
  Result := TMessageType(0);

  if Composite.S['method'] <> '' then
  begin
    if Id <> nil then
      Result := TMessageType.REQUEST
    else
      Result := TMessageType.NOTIFICATION;
    Inc(Types);
  end;

  if Composite.O['result'] <> nil then
  begin
    Result := TMessageType.RESPONSE;
    Inc(Types);
  end;

  if Composite.O['error'] <> nil then
  begin
    Result := TMessageType.ERROR;
    Inc(Types);
  end;

  if Types <> 1 then
    raise EJsonException.Create('exactly one of "method", "result", and "error" required');

  if (Result in [TMessageType.RESPONSE, TMessageType.ERROR]) and (Id = nil) then
    raise EJsonException.Create('"id" value required for response');
end;

class function TDecoder.ValidateParams(const Composite: ISuperObject): ISuperObject;
begin
  assert(Composite <> nil);

  Result := Composite.O['params'];
  if Result = nil then
    Exit; // may be omitted

  if not (Result.DataType in [TSuperType.stArray, TSuperType.stObject]) then
    raise EJsonException.Create('"params" value must be array or object');
end;

class function TDecoder.ValidateError(const Composite: ISuperObject): TErrorObject;
var
  ErrorObject: ISuperObject;
  Code: Integer;
  Message_: string;
  Data: ISuperObject;
begin
  assert(Composite <> nil);

  ErrorObject := Composite.O['error'];
  if ErrorObject = nil then
    raise EJsonException.Create('"error" value not found');
  if ErrorObject.DataType <> TSuperType.stObject then
    raise EJsonException.CreateFmt('object required but got %s', [ErrorObject.AsJSon]);

  Code := TValidation.RequireIntMember(ErrorObject, 'code');
  Message_ := TValidation.RequireStrMember(ErrorObject, 'message');
  Data := ErrorObject.O['data']; // may be omitted

  Result := TErrorObject.Create(Code, Message_, Data);
end;

end.
