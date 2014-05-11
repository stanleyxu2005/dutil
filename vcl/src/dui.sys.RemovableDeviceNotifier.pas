unit dui.sys.RemovableDeviceNotifier;

// $Id$

interface

uses
  System.Classes,
  Winapi.Messages,
  Winapi.Windows;

type
  /// <summary>This class arranges to monitor the insert and eject of removable devices.</summary>
  TRemovableDeviceNotifier = class(TComponent)
  private type
    TNotifyDeviceAttached = procedure(DriveLetter: Char) of object;
  private
    FWindowHandle: HWND;
    FOnUsbAttached: TNotifyDeviceAttached;
    FOnUsbRemoved: TNotifyEvent;
    FDeviceNotificationHandle: Pointer;
    procedure WndProc(var Message_: TMessage);
    function ReceiveDeviceNotification: Boolean;
    function StopRetrieveDeviceNotification: Boolean;
    class function GetFirstDriveLetter(UnitMask: LongInt): Char; static;
  protected
    procedure WMDeviceChange(var Message_: TMessage); dynamic;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property OnUsbAttached: TNotifyDeviceAttached read FOnUsbAttached write FOnUsbAttached;
    property OnUsbRemoved: TNotifyEvent read FOnUsbRemoved write FOnUsbRemoved;
  end;

implementation

uses
  Vcl.Forms,
  Winapi.Dbt;

constructor TRemovableDeviceNotifier.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);

  FDeviceNotificationHandle := nil;
  FWindowHandle := AllocateHWnd(WndProc);
  ReceiveDeviceNotification;
end;

destructor TRemovableDeviceNotifier.Destroy;
begin
  StopRetrieveDeviceNotification;
  DeallocateHWnd(FWindowHandle);

  inherited;
end;

procedure TRemovableDeviceNotifier.WndProc(var Message_: TMessage);
begin
  if Message_.Msg = WM_DEVICECHANGE then
  begin
    try
      WMDeviceChange(Message_);
    except
      Application.HandleException(Self);
    end;
  end
  else
    Message_.Result := DefWindowProc(FWindowHandle, Message_.Msg, Message_.WParam, Message_.LParam);
end;

procedure TRemovableDeviceNotifier.WMDeviceChange(var Message_: TMessage);
var
  DeviceType: Integer;
  Datos: PDevBroadcastHdr;
  Di: PDevBroadcastDeviceInterface;
  Letter: Char;
begin
  if (Message_.WParam <> DBT_DEVICEARRIVAL) and (Message_.WParam <> DBT_DEVICEREMOVECOMPLETE) then
    Exit;

  Datos := PDevBroadcastHdr(Message_.LParam);
  DeviceType := Datos^.dbch_devicetype;
  if DeviceType <> DBT_DEVTYP_DEVICEINTERFACE then
    Exit;

  if Message_.WParam = DBT_DEVICEARRIVAL then
  begin
   Di := PDevBroadcastDeviceInterface(Message_.LParam);
   //if (D2.dbcv_flags = DBTF_MEDIA) then
   Letter := Char(Di^.dbcc_name);
    if Assigned(FOnUsbAttached) then
      FOnUsbAttached(Letter);
  end
  else
  begin
    assert(Message_.WParam = DBT_DEVICEREMOVECOMPLETE);
    if Assigned(FOnUsbRemoved) then
      FOnUsbRemoved(Self);
  end;
end;

class function TRemovableDeviceNotifier.GetFirstDriveLetter(UnitMask: LongInt): Char;
var
  DriveLetter: ShortInt;
begin
  DriveLetter := Ord('A');
  while (UnitMask and 1) = 0 do
  begin
    UnitMask := UnitMask shr 1;
    Inc(DriveLetter);
  end;
  Result := Char(DriveLetter);
end;

function TRemovableDeviceNotifier.ReceiveDeviceNotification: Boolean;
var
  dbi: DEV_BROADCAST_DEVICEINTERFACE;
begin
  dbi.dbcc_size := SizeOf(dbi);
  dbi.dbcc_devicetype := DBT_DEVTYP_DEVICEINTERFACE;
  dbi.dbcc_reserved := 0;
  dbi.dbcc_classguid := GUID_DEVINTERFACE_USB_DEVICE;
  dbi.dbcc_name := 0;

  FDeviceNotificationHandle := RegisterDeviceNotification(FWindowHandle, @dbi, DEVICE_NOTIFY_WINDOW_HANDLE);
  Result := FDeviceNotificationHandle <> nil;
end;

function TRemovableDeviceNotifier.StopRetrieveDeviceNotification: Boolean;
begin
  if FDeviceNotificationHandle <> nil then
    Result := UnregisterDeviceNotification(FDeviceNotificationHandle)
  else
    Result := False;
end;

end.
