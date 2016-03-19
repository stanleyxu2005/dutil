(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dui.control.menu.MessageListener;

interface

uses
  Winapi.Messages;

type
  /// <summary>This service class arranges to listen menu messages.</summary>
  TMessageListener = class
  private type
    TNotifyMenuItemClickedEvent = procedure(Command: Word; NotifyCode: Word) of object;
  public
    /// <summary>Registers a menu click handler. It will be triggered when any menu items are clicked.</summary>
    /// <remarks>Click tracking will be deactivated, after all menus are closed.</remarks>
    class procedure TrackMenuItemClick(Callback: TNotifyMenuItemClickedEvent); static;
  private
    constructor Create;
    class constructor Create;
    class var FInstance: TMessageListener;
  public
    class destructor Destroy;
    destructor Destroy; override;
  private
    FNotifyMenuItemClickedEvent: TNotifyMenuItemClickedEvent;
    procedure ProcessWindowsMessage(var Message_: TMessage);
  end;

implementation

uses
  System.Classes,
  Vcl.Menus,
  Winapi.Windows;

type
  TPopupListOverride = class(TPopupList)
  protected
    FOnCustomWndProc: TWndMethod;
    procedure WndProc(var Message_: TMessage); override;
  public
    property OnCustomWndProc: TWndMethod read FOnCustomWndProc write FOnCustomWndProc;
  end;

procedure TPopupListOverride.WndProc(var Message_: TMessage);
begin
  if Assigned(FOnCustomWndProc) then
  begin
    FOnCustomWndProc(Message_);
    if Message_.Result = 1 then
      Exit;
  end;
  inherited;
end;

constructor TMessageListener.Create;
begin
  inherited;

  TPopupListOverride(PopupList).OnCustomWndProc := ProcessWindowsMessage;
  FNotifyMenuItemClickedEvent := nil;
end;

destructor TMessageListener.Destroy;
begin
  FNotifyMenuItemClickedEvent := nil;
  TPopupListOverride(PopupList).OnCustomWndProc := nil;

  inherited;
end;

procedure TMessageListener.ProcessWindowsMessage(var Message_: TMessage);
var
  I: Integer;
begin
  case Message_.Msg of
    WM_COMMAND:
      begin
        // Checks whether the menu click can be handled by any form components
        for I := 0 to PopupList.Count - 1 do
          if TPopupMenu(PopupList.Items[I]).DispatchCommand(Message_.wParam) then
          begin
            Message_.Result := 1;
            Exit;
          end;

        // Tries to trigger any registered handler, if the clicking is not dispatched to any form components
        if Assigned(FInstance.FNotifyMenuItemClickedEvent) then
        begin
          with TWMCommand(Message_) do
            FNotifyMenuItemClickedEvent(ItemID, NotifyCode);
          FNotifyMenuItemClickedEvent := nil;
        end;

        Message_.Result := 1;
      end;
  end;
end;

class procedure TMessageListener.TrackMenuItemClick(Callback: TNotifyMenuItemClickedEvent);
begin
  assert(Assigned(Callback));

  FInstance.FNotifyMenuItemClickedEvent := Callback;
end;

class constructor TMessageListener.Create;
begin
  // Replaces the original popup list instance with the overriden instance.
  Vcl.Menus.PopupList.Free;
  Vcl.Menus.PopupList := TPopupListOverride.Create;

  FInstance := TMessageListener.Create;
end;

class destructor TMessageListener.Destroy;
begin
  FInstance.Free;
  FInstance := nil;
end;

end.
