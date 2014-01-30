unit dutil.net.jsonrpc.message.HandlerMock;

interface

uses
  superobject,
  dutil.core.NonRefCountedInterfacedObject,
  dutil.net.jsonrpc.message.Error,
  dutil.net.jsonrpc.message.Handler,
  dutil.net.jsonrpc.message.Identifier;

type
  THandlerMock = class(TNonRefCountedInterfacedObject, IHandler)
  public
    procedure HandleRequest(const Method: string; const Params: ISuperObject; const Id: TIdentifier);
    procedure HandleNotification(const Method: string; const Params: ISuperObject);
    procedure HandleResponse(const Result: ISuperObject; const Id: TIdentifier); overload;
    procedure HandleResponse(Error: EError; const Id: TIdentifier); overload;
  private
    ExpectedResult: string;
    ActualResult: string;
  public
    procedure ExpectRequest(const Method: string; const Params: ISuperObject; const Id: TIdentifier);
    procedure ExpectNotification(const Method: string; const Params: ISuperObject);
    procedure ExpectResponse(const Result: ISuperObject; const Id: TIdentifier); overload;
    procedure ExpectResponse(Error: EError; const Id: TIdentifier); overload;
    procedure Verify;
  end;

implementation

uses
  SysUtils,
  dutil.net.jsonrpc.message.Encoder;

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

procedure THandlerMock.HandleResponse(Error: EError; const Id: TIdentifier);
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

procedure THandlerMock.ExpectResponse(Error: EError; const Id: TIdentifier);
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
