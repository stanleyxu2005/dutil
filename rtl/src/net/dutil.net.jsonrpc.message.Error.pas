(**
 * $Id: dutil.net.jsonrpc.message.Error.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.jsonrpc.message.Error;

interface

uses
  SysUtils,
  superobject { An universal object serialization framework with Json support };

type
  /// <summary>This immutable value class represents a JSON-RPC error.</summary>
  EError = class(Exception)
  private
    FCode: Integer;
    FMessage_: string;
    FData: ISuperObject;
  public
    property Code: Integer read FCode;
    property Message_: string read FMessage_;
    property Data: ISuperObject read FData;
  public
    constructor Create(Code: Integer; const Message_: string; const Data: ISuperObject);
    destructor Destroy; override;
    function ToString: string; override;
    class function CreateParseError(const Detail: string): EError; static;
    class function CreateInvalidRequest(const Detail: string): EError; static;
    class function CreateMethodNotFound(const Detail: string): EError; static;
    class function CreateInvalidParams(const Detail: string): EError; static;
    class function CreateInternalError(const Detail: string): EError; static;
    class function CreateInvalidResult(const Detail: string): EError; static; deprecated 'non-standard error';
    class function CreateNoResponseReceived(const Detail: string): EError; static;
  end;

implementation

uses
  dutil.text.Util;

constructor EError.Create(Code: Integer; const Message_: string; const Data: ISuperObject);
begin
  FCode := Code;
  FMessage_ := Message_;
  FData := Data;

  inherited Create(ToString);
end;

destructor EError.Destroy;
begin
  FData := nil;

  inherited;
end;

function EError.ToString: string;
var
  Detail: string;
begin
  Detail := '';
  if FData <> nil then
    Detail := TUtil.Strip(FData.AsJson, '"');

  if Detail = '' then
    Result := Format('%s (%d)', [FMessage_, FCode])
  else
    Result := Format('%s (%d): %s', [FMessage_, FCode, Detail]);
end;

class function EError.CreateParseError(const Detail: string): EError;
begin
  Result := EError.Create(-32700, 'Parse error', SO(Detail));

  assert(Result <> nil);
end;

class function EError.CreateInvalidRequest(const Detail: string): EError;
begin
  Result := EError.Create(-32600, 'Invalid request', SO(Detail));

  assert(Result <> nil);
end;

class function EError.CreateMethodNotFound(const Detail: string): EError;
begin
  Result := EError.Create(-32601, 'Method not found', SO(Detail));

  assert(Result <> nil);
end;

class function EError.CreateInvalidParams(const Detail: string): EError;
begin
  Result := EError.Create(-32602, 'Invalid params', SO(Detail));

  assert(Result <> nil);
end;

class function EError.CreateInternalError(const Detail: string): EError;
begin
  Result := EError.Create(-32603, 'Internal error', SO(Detail));

  assert(Result <> nil);
end;

class function EError.CreateInvalidResult(const Detail: string): EError;
begin
  Result := EError.Create(-2, 'Invalid result', SO(Detail));

  assert(Result <> nil);
end;

class function EError.CreateNoResponseReceived(const Detail: string): EError;
begin
  Result := EError.Create(-1, 'No response received', SO(Detail));

  assert(Result <> nil);
end;

end.
