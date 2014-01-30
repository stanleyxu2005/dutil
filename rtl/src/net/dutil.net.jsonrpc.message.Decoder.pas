(**
 * $Id: dutil.net.jsonrpc.message.Decoder.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.jsonrpc.message.Decoder;

interface

uses
  superobject { An universal object serialization framework with Json support },
  dutil.net.jsonrpc.message.Error,
  dutil.net.jsonrpc.message.Handler,
  dutil.net.jsonrpc.message.Identifier;

type
  /// <summary>This service class allows to decode JSON-RPC requests and responses, which are forwarded to the
  /// specified handler.</summary>
  TDecoder = class
{$IFNDEF OMIT_JSONRPC_PROTOCOL_VERSION}
  private const
    VERSION = '2.0';
{$ENDIF}
  public
    /// <exception cref="EJsonRpcException">When the specified message does not represent a valid JSON-RPC request or
    /// response.</exception>
    class procedure Decode(const Message_: string; const Handler: IHandler); static;
  private
    /// <exception cref="EJsonException">When the specified JSON object has an invalid identifier.</exception>
    class function ValidateId(const Composite: ISuperObject): TIdentifier; static;
{$IFNDEF OMIT_JSONRPC_PROTOCOL_VERSION}
    /// <exception cref="EJsonException">When the specified JSON object has no or not the expected version
    /// value.</exception>
    class function ValidateProtocolVersion(const Composite: ISuperObject): string; static;
{$ENDIF}
    /// <exception cref="EJsonException">When the specified JSON object has an invalid parameters value.</exception>
    class function ValidateParams(const Composite: ISuperObject): ISuperObject; static;
    /// <exception cref="EJsonException">When the specified JSON object has an invalid error value.</exception>
    class function ValidateError(const Composite: ISuperObject): EError; static;
  end;

implementation

uses
  SysUtils,
  dutil.core.Exception,
  dutil.net.jsonrpc.message.JsonRpcException,
  dutil.text.json.Validation;

class procedure TDecoder.Decode(const Message_: string; const Handler: IHandler);
var
  Id: TIdentifier;
  Composite: ISuperObject;
  Method: string;
  Params: ISuperObject;
  Result: ISuperObject;
  Error: EError;
begin
  assert(Handler <> nil);

  Id := TIdentifier.NullIdentifier;

  Composite := SO(Message_);
  if Composite.DataType <> TSuperType.stObject then
  begin
    Error := EError.CreateParseError(Message_);
    try
      raise EJsonRpcException.Create(Error, Id);
    finally
      Error.Free;
    end;
  end;

  try
    Id := ValidateId(Composite);
{$IFNDEF OMIT_JSONRPC_PROTOCOL_VERSION}
    ValidateProtocolVersion(Composite);
{$ENDIF}
    Method := Composite.S['method'];
    Result := Composite.O['result'];
    Error := ValidateError(Composite);

    try
      if (Integer(Method <> '') + Integer(Result <> nil) + Integer(Error <> nil)) <> 1 then
        raise EJsonException.Create('exactly one of "method", "result", and "error" required');

      if (Method = '') and (Id.Value = nil) then
        raise EJsonException.Create('"id" value required for response');

      if Method <> '' then
      begin
        Params := ValidateParams(Composite);
        if Id.Value = nil then
          Handler.HandleNotification(Method, Params)
        else
          Handler.HandleRequest(Method, Params, Id);
      end
      else if Result <> nil then
        Handler.HandleResponse(Result, Id)
      else if Error <> nil then
        Handler.HandleResponse(Error, Id);
    finally
      if Error <> nil then
        Error.Free;
    end;
  except
    on E: EJsonException do
    begin
      Error := EError.CreateInvalidRequest(E.ToString);
      try
        raise EJsonRpcException.Create(Error, Id);
      finally
        Error.Free;
      end;
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
    raise EJsonException.Create(Format('protocol version must be "%s"', [VERSION]));
end;
{$ENDIF}

class function TDecoder.ValidateParams(const Composite: ISuperObject): ISuperObject;
begin
  assert(Composite <> nil);

  Result := Composite.O['params'];
  if Result = nil then
    Exit; // may be omitted

  if not (Result.DataType in [TSuperType.stArray, TSuperType.stObject]) then
    raise EJsonException.Create('"params" value must be array or object');
end;

class function TDecoder.ValidateError(const Composite: ISuperObject): EError;
var
  ErrorObject: ISuperObject;
  Code: Integer;
  Message_: string;
  Data: ISuperObject;
begin
  assert(Composite <> nil);

  ErrorObject := Composite.O['error'];
  if ErrorObject = nil then
  begin
    Result := nil; // may be omitted
    Exit;
  end;

  if ErrorObject.DataType <> TSuperType.stObject then
    raise EJsonException.Create(Format('object required but got %s', [ErrorObject.AsJSon]));

  Code := TValidation.RequireIntMember(ErrorObject, 'code');
  Message_ := TValidation.RequireStrMember(ErrorObject, 'message');
  Data := ErrorObject.O['data']; // may be omitted

  Result := EError.Create(Code, Message_, Data);
end;

end.
