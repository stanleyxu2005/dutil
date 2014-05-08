unit dutil.remoting.rpc.RPCHandlerMock;

interface

uses
  superobject,
  dutil.core.NonRefCountedInterfacedObject,
  dutil.remoting.rpc.ErrorObject,
  dutil.remoting.rpc.RPCHandler,
  dutil.remoting.rpc.Identifier;

type
  THandlerMock = class(TNonRefCountedInterfacedObject, IRPCHandler)
  public
    procedure HandleRequest(const Method: string; const Params: ISuperObject; const Id: TIdentifier);
    procedure HandleNotification(const Method: string; const Params: ISuperObject);
    procedure HandleResponse(const Result: ISuperObject; const Id: TIdentifier); overload;
    procedure HandleResponse(const Error: TErrorObject; const Id: TIdentifier); overload;
  private
    ExpectedResult: string;
    ActualResult: string;
  public
    procedure ExpectRequest(const Method: string; const Params: ISuperObject; const Id: TIdentifier);
    procedure ExpectNotification(const Method: string; const Params: ISuperObject);
    procedure ExpectResponse(const Result: ISuperObject; const Id: TIdentifier); overload;
    procedure ExpectResponse(const Error: TErrorObject; const Id: TIdentifier); overload;
    procedure Verify;
  end;

implementation

uses
  SysUtils,
  dutil.remoting.rpc.jsonrpc.Encoder;

procedure THandlerMock.HandleRequest(const Method: string; const Params: ISuperObject; const Id: TIdentifier);
begin
  ActualResult := TEncoder.EncodeRequest(Method, Params, Id);
end;

procedure THandlerMock.HandleNotification(const Method: string; const Params: ISuperObject);
begin
  ActualResult := TEncoder.EncodeNotification(Method, Params);
end;

procedure THandlerMock.HandleResponse(const Result: ISuperObject; const Id: TIdentifier);
begin
  ActualResult := TEncoder.EncodeResponse(Result, Id);
end;

procedure THandlerMock.HandleResponse(const Error: TErrorObject; const Id: TIdentifier);
begin
  ActualResult := TEncoder.EncodeResponse(Error, Id);
end;

procedure THandlerMock.ExpectRequest(const Method: string; const Params: ISuperObject; const Id: TIdentifier);
begin
  ExpectedResult := TEncoder.EncodeRequest(Method, Params, Id);
end;

procedure THandlerMock.ExpectNotification(const Method: string; const Params: ISuperObject);
begin
  ExpectedResult := TEncoder.EncodeNotification(Method, Params);
end;

procedure THandlerMock.ExpectResponse(const Result: ISuperObject; const Id: TIdentifier);
begin
  ExpectedResult := TEncoder.EncodeResponse(Result, Id);
end;

procedure THandlerMock.ExpectResponse(const Error: TErrorObject; const Id: TIdentifier);
begin
  ExpectedResult := TEncoder.EncodeResponse(Error, Id);
end;

(**
 * @raise EAssertionFailed:
 *)
procedure THandlerMock.Verify;
begin
  if ExpectedResult <> ActualResult then
    raise EAssertionFailed.Create(Format('expected: %s, but actual: %s', [ExpectedResult, ActualResult]));
end;

end.
