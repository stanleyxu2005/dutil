(**
 * $Id: dui.control.rebar32.Util.pas 851 2014-06-02 08:03:08Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dui.control.rebar32.Util;

interface

uses
  Vcl.ActnList,
  Vcl.ComCtrls,
  System.Classes;

type
  /// <summary>This service class provides methods to manage TToolbar related components.</summary>
  TUtil = class
  public
    /// <summary>Removes all tool buttons from a toolbar.</summary>
    class procedure RemoveAllToolButtons(ToolBar: TToolBar); static;
    /// <summary>Removes a tool button by a specified button index.</summary>
    class function RemoveToolButton(ToolBar: TToolBar; ButtonIndex: Cardinal): Boolean; static;
    /// <summary>Creates a tool button with an action assigned at the end of a toolbar.</summary>
    class function CreateToolButton(ToolBar: TToolBar; Action: TAction): TToolButton; overload; static;
    /// <summary>Creates a tool button with an action assigned.</summary>
    class function CreateToolButton(ToolBar: TToolBar; Position: Cardinal; Action: TAction): TToolButton; overload;
      static;
    /// <summary>Creates a tool button with a caption and an onclick event at the end of a toolbar.</summary>
    class function CreateToolButton(ToolBar: TToolBar; const Caption: string; OnClick: TNotifyEvent): TToolButton;
      overload; static;
    /// <summary>Creates a tool button with a caption and an onclick event.</summary>
    class function CreateToolButton(ToolBar: TToolBar; Position: Cardinal; const Caption: string;
      OnClick: TNotifyEvent): TToolButton; overload; static;
    /// <summary>Creates a separator (divider line) at the end of a toolbar.</summary>
    class procedure CreateTooButtonSeparator(ToolBar: TToolBar); overload; static;
    /// <summary>Creates a separator (divider line) onto a toolbar.</summary>
    class procedure CreateTooButtonSeparator(ToolBar: TToolBar; Position: Cardinal); overload; static;
  private
    class function CreateToolButton(ToolBar: TToolBar; Position: Cardinal; Style: TToolButtonStyle): TToolButton;
      overload; static;
  end;

implementation

uses
  System.Math,
  Vcl.Controls,
  Winapi.Windows;

class procedure TUtil.RemoveAllToolButtons(ToolBar: TToolBar);
begin
  assert(ToolBar <> nil);

  while ToolBar.ButtonCount > 0 do
  begin
    // Removes from the tail
    RemoveToolButton(ToolBar, ToolBar.ButtonCount - 1);
  end;
end;

class function TUtil.RemoveToolButton(ToolBar: TToolBar; ButtonIndex: Cardinal): Boolean;
var
  Button: TToolButton;
begin
  assert(ToolBar <> nil);

  if ButtonIndex < Cardinal(ToolBar.ButtonCount) then
  begin
    Button := ToolBar.Buttons[ButtonIndex];
    try
      // http://docwiki.embarcadero.com/RADStudio/XE3/en/Deleting_Toolbar_Buttons
      ToolBar.Perform(CM_CONTROLCHANGE, WPARAM(Button), 0);
      Button.Free;
      Exit(True);
    except
    end;
  end;

  Result := False;
end;

class function TUtil.CreateToolButton(ToolBar: TToolBar; Position: Cardinal; Style: TToolButtonStyle): TToolButton;
var
  LeftButton: TToolButton;
begin
  assert(ToolBar <> nil);

  Position := Min(Position, ToolBar.ButtonCount);
  Result := TToolButton.Create(ToolBar);
  if Position > 0 then
  begin
    LeftButton := ToolBar.Buttons[Position - 1];
    Result.Left := LeftButton.Left + LeftButton.Width;
  end;
  Result.AllowAllUp := True;
  Result.AutoSize := True;
  Result.Style := Style;
  Result.Parent := ToolBar;
end;

class function TUtil.CreateToolButton(ToolBar: TToolBar; Action: TAction): TToolButton;
begin
  assert(ToolBar <> nil);
  assert(Action <> nil);

  Result := CreateToolButton(ToolBar, ToolBar.ButtonCount, tbsTextButton);
  Result.Action := Action;
end;

class function TUtil.CreateToolButton(ToolBar: TToolBar; Position: Cardinal; Action: TAction): TToolButton;
begin
  assert(ToolBar <> nil);
  assert(Action <> nil);

  Result := CreateToolButton(ToolBar, Position, tbsTextButton);
  Result.Action := Action;
end;

class function TUtil.CreateToolButton(ToolBar: TToolBar; const Caption: string; OnClick: TNotifyEvent): TToolButton;
begin
  assert(ToolBar <> nil);

  Result := CreateToolButton(ToolBar, ToolBar.ButtonCount, tbsTextButton);
  Result.Caption := Caption;
  Result.OnClick := OnClick;
end;

class function TUtil.CreateToolButton(ToolBar: TToolBar; Position: Cardinal; const Caption: string;
  OnClick: TNotifyEvent): TToolButton;
begin
  assert(ToolBar <> nil);

  Result := CreateToolButton(ToolBar, Position, tbsTextButton);
  Result.Caption := Caption;
  Result.OnClick := OnClick;
end;

class procedure TUtil.CreateTooButtonSeparator(ToolBar: TToolBar);
begin
  assert(ToolBar <> nil);

  CreateToolButton(ToolBar, ToolBar.ButtonCount, tbsSeparator);
end;

class procedure TUtil.CreateTooButtonSeparator(ToolBar: TToolBar; Position: Cardinal);
begin
  assert(ToolBar <> nil);

  CreateToolButton(ToolBar, Position, tbsSeparator);
end;

end.