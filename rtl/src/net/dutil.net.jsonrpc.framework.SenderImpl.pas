(**
 * $Id: dutil.net.jsonrpc.framework.SenderImpl.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.jsonrpc.framework.SenderImpl;

interface

uses
  superobject { An universal object serialization framework with Json support },
  dutil.core.NonRefCountedInterfacedObject,
  dutil.net.jsonrpc.framework.Backlog,
  dutil.net.jsonrpc.framework.Sender,
  dutil.util.concurrent.BlockingQueue,
  dutil.util.concurrent.Result;

type
  /// <summary>This boundary class allows to send JSON-RPC requests and notifications via the specified output queue to
  /// the named peer.</summary>
  TSenderImpl = class(TNonRefCountedInterfacedObject, ISender)
  private
    FPeer: string;
    FOutput: TBlockingQueue<string>;
    FBacklog: TBacklog;
  public
    constructor Create(const Peer: string; Output: TBlockingQueue<string>; Backlog: TBacklog);
    destructor Destroy; override;
    function SendRequest(const Method: string; const Params: ISuperObject): TResult<ISuperObject>;
    procedure SendNotification(const Method: string; const Params: ISuperObject);
  end;

implementation

uses
{$IFDEF LOGGING}
  Log4D,
  SysUtils,
{$ENDIF}
  dutil.net.jsonrpc.message.Encoder,
  dutil.net.jsonrpc.message.Identifier;

constructor TSenderImpl.Create(const Peer: string; Output: TBlockingQueue<string>; Backlog: TBacklog);
begin
  assert(Output <> nil);
  assert(Backlog <> nil);
  inherited Create;

  FPeer := Peer;
  FOutput := Output;
  FBacklog := Backlog;
end;

destructor TSenderImpl.Destroy;
begin
  FOutput := nil;
  FBacklog := nil;

  inherited;
end;

function TSenderImpl.SendRequest(const Method: string; const Params: ISuperObject): TResult<ISuperObject>;
var
  Id: TIdentifier;
  Message_: string;
begin
  assert((Params = nil) or (Params.DataType in [TSuperType.stArray, TSuperType.stObject]));

  Result := TResult<ISuperObject>.Create;
  Id := FBacklog.Put(Result);
  Message_ := TEncoder.EncodeRequest(Method, Params, Id);
{$IFDEF LOGGING}
  TLogLogger.GetLogger(ClassName).Trace(Format('->%s: %s', [FPeer, Message_]));
{$ENDIF}
  FOutput.Put(Message_);
end;

procedure TSenderImpl.SendNotification(const Method: string; const Params: ISuperObject);
var
  Message_: string;
begin
  assert((Params = nil) or (Params.DataType in [TSuperType.stArray, TSuperType.stObject]));

  Message_ := TEncoder.EncodeNotification(Method, Params);
{$IFDEF LOGGING}
  TLogLogger.GetLogger(ClassName).Trace(Format('->%s: %s', [FPeer, Message_]));
{$ENDIF}
  FOutput.Put(Message_);
end;

end.
