unit remote.model.WindowOrigin;

interface

uses
  superobject {An universal object serialization framework with Json support} ,
  dutil.remoting.framework.RPCObjectImpl,
  remote.model.RPCObjectContainer,
  remote.command.ResizeWindow,
  remote.command.NotifyPositionChanged,
  remote.command.NotifySizeChanged,
  remote.command.NotifySystemTime;

type
  // The remote object can change the size of its corresponding remote window referent.
  TDemoObjectOrigin = class(TRPCObjectContainer)
  private type
    TRequestResizeWindowEvent = procedure(Width, Height: Cardinal) of object;
  public
    constructor Create(RPCObject: TRPCObjectImpl);
  // Callback
  private
    FOnRequestResizeWindow: TRequestResizeWindowEvent;
    procedure DecodeResizeWindow(const Params: ISuperObject; out Result: ISuperObject);
  public
    property OnRequestResizeWindow: TRequestResizeWindowEvent read FOnRequestResizeWindow write FOnRequestResizeWindow;
  // Requests
  public
    /// <exception cref="EExternalException"></exception>
    procedure NotifyPositionChanged(X, Y: Integer);
    /// <exception cref="EExternalException"></exception>
    procedure NotifySizeChanged(Width, Height: Cardinal);
    /// <exception cref="EExternalException"></exception>
    procedure NotifySystemTime;
  end;

implementation

uses
  System.SysUtils;

constructor TDemoObjectOrigin.Create(RPCObject: TRPCObjectImpl);
begin
  inherited Create(RPCObject);

  with GetHandler do
  begin
    AddRequestHandler(TResizeWindow, DecodeResizeWindow);
  end;
end;

procedure TDemoObjectOrigin.DecodeResizeWindow(const Params: ISuperObject; out Result: ISuperObject);
var
  Request: TResizeWindow;
begin
  assert(Params <> nil);

  Request := TResizeWindow.FromJSON(Params);
  try
    if Assigned(OnRequestResizeWindow) then
      OnRequestResizeWindow(Request.Width, Request.Height);
    Result := TResizeWindow.EncodeResponse(True);
  finally
    Request.Free;
  end;

  assert(Result <> nil, 'TResizeWindow.EncodeResponse() should be called');
end;

procedure TDemoObjectOrigin.NotifyPositionChanged(X, Y: Integer);
var
  Notification: TNotifyPositionChanged;
begin
  Notification := TNotifyPositionChanged.Create(X, Y);
  try
    GetExecutor.Notify(Notification);
  finally
    Notification.Free;
  end;
end;

procedure TDemoObjectOrigin.NotifySizeChanged(Width, Height: Cardinal);
var
  Notification: TNotifySizeChanged;
begin
  Notification := TNotifySizeChanged.Create(Width, Height);
  try
    GetExecutor.Notify(Notification);
  finally
    Notification.Free;
  end;
end;

procedure TDemoObjectOrigin.NotifySystemTime;
var
  Notification: TNotifySystemTime;
begin
  Notification := TNotifySystemTime.Create(Now);
  try
    GetExecutor.Notify(Notification);
  finally
    Notification.Free;
  end;
end;

end.
