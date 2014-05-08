unit remote.model.WindowHost;

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
  TDemoObjectHost = class(TRPCObjectContainer)
  private type
    TWindowSizeChangedEvent = procedure(Width, Height: Cardinal) of object;
    TWindowPositionChangedEvent = procedure(Left, Top: Integer) of object;
    TSystemTimeNotifiedEvent = procedure(SystemTime: TDateTime) of object;
  public
    constructor Create(RPCObject: TRPCObjectImpl);
    // Notifications
  private
    FOnWindowSizeChanged: TWindowSizeChangedEvent;
    FOnWindowPositionChanged: TWindowPositionChangedEvent;
    FOnSystemTimeNotified: TSystemTimeNotifiedEvent;
    procedure DecodeNotfiySizeChanged(const Params: ISuperObject);
    procedure DecodeNotfiyPositionChanged(const Params: ISuperObject);
    procedure DecodeNotfiySystemTime(const Params: ISuperObject);
  public
    property OnWindowSizeChanged: TWindowSizeChangedEvent read FOnWindowSizeChanged write FOnWindowSizeChanged;
    property OnWindowPositionChanged: TWindowPositionChangedEvent read FOnWindowPositionChanged
      write FOnWindowPositionChanged;
    property OnSystemTimeNotified: TSystemTimeNotifiedEvent read FOnSystemTimeNotified write FOnSystemTimeNotified;
    // Requests
  public
    /// <exception cref="EExternalException"></exception>
    function ResizeWindow(Width, Height: Cardinal): TResizeWindow.TResponse;
  end;

implementation

uses
  Log4D,
  System.Classes,
  System.SysUtils;

constructor TDemoObjectHost.Create(RPCObject: TRPCObjectImpl);
begin
  inherited Create(RPCObject);

  with GetHandler do
  begin
    AddNotificationHandler(TNotifySizeChanged, DecodeNotfiySizeChanged);
    AddNotificationHandler(TNotifyPositionChanged, DecodeNotfiyPositionChanged);
    AddNotificationHandler(TNotifySystemTime, DecodeNotfiySystemTime);
  end;
end;

procedure TDemoObjectHost.DecodeNotfiySizeChanged(const Params: ISuperObject);
var
  Notification: TNotifySizeChanged;
begin
  assert(Params <> nil);

  Notification := TNotifySizeChanged.FromJSON(Params);
  try
    if Assigned(FOnWindowSizeChanged) then
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          FOnWindowSizeChanged(Notification.Width, Notification.Height);
        end);
    end;
  finally
    Notification.Free;
  end;
end;

procedure TDemoObjectHost.DecodeNotfiyPositionChanged(const Params: ISuperObject);
var
  Notification: TNotifyPositionChanged;
begin
  assert(Params <> nil);

  Notification := TNotifyPositionChanged.FromJSON(Params);
  try
    if Assigned(FOnWindowPositionChanged) then
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          FOnWindowPositionChanged(Notification.X, Notification.Y);
        end);
    end;
  finally
    Notification.Free;
  end;
end;

procedure TDemoObjectHost.DecodeNotfiySystemTime(const Params: ISuperObject);
var
  Notification: TNotifySystemTime;
begin
  assert(Params <> nil);

  Notification := TNotifySystemTime.FromJSON(Params);
  try
    if Assigned(FOnSystemTimeNotified) then
    begin
      TThread.Synchronize(nil,
        procedure
        begin
          FOnSystemTimeNotified(Notification.SystemTime);
        end);
    end;
  finally
    Notification.Free;
  end;
end;

function TDemoObjectHost.ResizeWindow(Width, Height: Cardinal): TResizeWindow.TResponse;
var
  Request: TResizeWindow;
  ResponseContainer: ISuperObject;
begin
  try
    Request := TResizeWindow.Create(Width, Height);
    try
      ResponseContainer := GetExecutor.ExecuteAwait(Request);
      Result := Request.DecodeResponse(ResponseContainer);
    finally
      Request.Free;
    end;
  except
    on E: Exception do
      raise EExternalException.Create(E.ToString);
  end;
end;

end.
