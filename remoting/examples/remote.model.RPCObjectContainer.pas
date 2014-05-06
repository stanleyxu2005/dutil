unit remote.model.RPCObjectContainer;

interface

uses
  dutil.remoting.framework.Executor,
  dutil.remoting.framework.Handler,
  dutil.remoting.framework.RPCObjectImpl;

type
  // The remote object can change the size of its corresponding remote window referent.
  TRPCObjectContainer = class
  private
    FRPCObject: TRPCObjectImpl;
  protected
    function GetExecutor: IExecutor;
    function GetHandler: IHandler;
  public
    constructor Create(RPCObject: TRPCObjectImpl);
    destructor Destroy; override;
    function GetRPCObjectId: string;
  end;

implementation

constructor TRPCObjectContainer.Create(RPCObject: TRPCObjectImpl);
begin
  assert(RPCObject <> nil);
  inherited Create;
  FRPCObject := RPCObject;
end;

destructor TRPCObjectContainer.Destroy;
begin
  inherited;
  FRPCObject := nil;
end;

function TRPCObjectContainer.GetExecutor: IExecutor;
begin
  Result := FRPCObject;
end;

function TRPCObjectContainer.GetHandler: IHandler;
begin
  Result := FRPCObject;
end;

function TRPCObjectContainer.GetRPCObjectId: string;
begin
  Result := FRPCObject.GetId;
end;

end.
