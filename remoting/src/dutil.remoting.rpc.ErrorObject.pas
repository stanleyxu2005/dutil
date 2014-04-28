(**
 * $Id: dutil.remoting.rpc.ErrorObject.pas 786 2014-04-27 15:44:17Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.rpc.ErrorObject;

interface

uses
  System.SysUtils,
  superobject { An universal object serialization framework with Json support };

type
  /// <summary>This immutable value class represents a RPC error.</summary>
  TErrorObject = record
  private
    FCode: Integer;
    FMessage_: string;
    FData: ISuperObject;
  public
    property Code: Integer read FCode;
    property Message_: string read FMessage_;
    property Data: ISuperObject read FData;
  public
    function ToString: string;
    class function Create(Code: Integer; const Message_: string; const Data: ISuperObject): TErrorObject; static;
    class function CreateParseError(const Detail: string): TErrorObject; static;
    class function CreateInvalidRequest(const Detail: string): TErrorObject; static;
    class function CreateMethodNotFound(const Detail: string): TErrorObject; static;
    class function CreateInvalidParams(const Detail: string): TErrorObject; static;
    class function CreateInternalError(const Detail: string): TErrorObject; static;
    class function CreateInvalidResult(const Detail: string): TErrorObject; static; deprecated 'non-standard error';
    class function CreateNoResponseReceived(const Detail: string): TErrorObject; static;
  end;

implementation

uses
  dutil.text.Util;

class function TErrorObject.Create(Code: Integer; const Message_: string; const Data: ISuperObject): TErrorObject;
begin
  Result.FCode := Code;
  Result.FMessage_ := Message_;
  Result.FData := Data;
end;

function TErrorObject.ToString: string;
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

class function TErrorObject.CreateParseError(const Detail: string): TErrorObject;
begin
  Result := TErrorObject.Create(-32700, 'Parse error', SO(Detail));
end;

class function TErrorObject.CreateInvalidRequest(const Detail: string): TErrorObject;
begin
  Result := TErrorObject.Create(-32600, 'Invalid request', SO(Detail));
end;

class function TErrorObject.CreateMethodNotFound(const Detail: string): TErrorObject;
begin
  Result := TErrorObject.Create(-32601, 'Method not found', SO(Detail));
end;

class function TErrorObject.CreateInvalidParams(const Detail: string): TErrorObject;
begin
  Result := TErrorObject.Create(-32602, 'Invalid params', SO(Detail));
end;

class function TErrorObject.CreateInternalError(const Detail: string): TErrorObject;
begin
  Result := TErrorObject.Create(-32603, 'Internal error', SO(Detail));
end;

class function TErrorObject.CreateInvalidResult(const Detail: string): TErrorObject;
begin
  Result := TErrorObject.Create(-2, 'Invalid result', SO(Detail));
end;

class function TErrorObject.CreateNoResponseReceived(const Detail: string): TErrorObject;
begin
  Result := TErrorObject.Create(-1, 'No response received', SO(Detail));
end;

end.
