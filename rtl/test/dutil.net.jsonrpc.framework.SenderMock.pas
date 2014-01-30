unit dutil.net.jsonrpc.framework.SenderMock;

interface

uses
  superobject,
  dutil.util.concurrent.Result,
  dutil.net.jsonrpc.framework.Sender;

type
  TSenderMock = class(TInterfacedObject, ISender)
  public
    function SendRequest(const Method: string; const Params: ISuperObject): TResult<ISuperObject>;
    procedure SendNotification(const Method: string; const Params: ISuperObject);
  private
    ExpectedMethod: string;
    ExpectedParams: ISuperObject;
    ExpectedResult: TResult<ISuperObject>;
    ActualMethod: string;
    ActualParams: ISuperObject;
  public
    procedure ExpectSendRequest(const Method: string; const Params: ISuperObject; Result: TResult<ISuperObject>);
    procedure ExpectSendNotification(const Method: string; const Params: ISuperObject);
    procedure Verify;
  end;

implementation

uses
  SysUtils;

function TSenderMock.SendRequest(const Method: string; const Params: ISuperObject): TResult<ISuperObject>;
begin
  ActualMethod := Method;
  ActualParams := Params;
  Result := ExpectedResult;
end;

procedure TSenderMock.SendNotification(const Method: string; const Params: ISuperObject);
begin
  ActualMethod := Method;
  ActualParams := Params;
end;

procedure TSenderMock.ExpectSendRequest(const Method: string; const Params: ISuperObject;
  Result: TResult<ISuperObject>);
begin
  ExpectedMethod := Method;
  ExpectedParams := Params;
  ExpectedResult := Result;
end;

procedure TSenderMock.ExpectSendNotification(const Method: string; const Params: ISuperObject);
begin
  ExpectedMethod := Method;
  ExpectedParams := Params;
  ExpectedResult := nil;
end;

(**
 * @raise EAssertionFailed:
 *)
procedure TSenderMock.Verify;
begin
  if ExpectedMethod <> ActualMethod then
    raise EAssertionFailed.Create(Format('expected: %s, but actual: %s', [ExpectedMethod, ActualMethod]));
  if ExpectedParams <> ActualParams then
    raise EAssertionFailed.Create(Format('expected: %s, but actual: %s', [ExpectedMethod, ActualMethod]));
end;

end.
