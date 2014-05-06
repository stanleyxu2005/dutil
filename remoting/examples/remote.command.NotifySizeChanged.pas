// $Id: remote.command.NotifySizeChanged.pas 802 2014-04-30 07:59:53Z QXu $

unit remote.command.NotifySizeChanged;

interface

uses
  superobject { An universal object serialization framework with Json support },
  dutil.remoting.framework.Command;

type
  /// <summary>This command arranges to notify to change the visibility level of a renderer view.</summary>
  /// <remarks>Expected to be handled in main thread</remarks>
  TNotifySizeChanged = class(TCommand)
  private
    FWidth: Cardinal;
    FHeight: Cardinal;
  public
    property Width: Cardinal read FWidth;
    property Height: Cardinal read FHeight;
  public
    constructor Create(Width: Cardinal; Height: Cardinal);
    function Params_: ISuperObject; override;
    class function Method_: string; override;
    class function Type_: TCommand.TType; override;
    class function HandleInMainThread_: Boolean; override;
    /// <exception cref="EJsonException">When parser error is occurred.</exception>
    class function FromJSON(const Composite: ISuperObject): TNotifySizeChanged; static;
  end;

implementation

uses
  dutil.text.json.Validation;

constructor TNotifySizeChanged.Create(Width: Cardinal; Height: Cardinal);
begin
  inherited Create;

  FWidth := Width;
  FHeight := Height;
end;

class function TNotifySizeChanged.Method_: string;
begin
  Result := 'NotifySizeChanged';
end;

class function TNotifySizeChanged.Type_: TCommand.TType;
begin
  Result := TCommand.TType.NOTIFICATION
end;

class function TNotifySizeChanged.HandleInMainThread_: Boolean;
begin
  Result := True;
end;

function TNotifySizeChanged.Params_: ISuperObject;
begin
  Result := SO;
  Result.I['Width'] := FWidth;
  Result.I['Height'] := FHeight;
end;

class function TNotifySizeChanged.FromJSON(const Composite: ISuperObject): TNotifySizeChanged;
var
  Width: Cardinal;
  Height: Cardinal;
begin
  assert(Composite <> nil);

  Width := TValidation.RequireUIntMember(Composite, 'Width');
  Height := TValidation.RequireUIntMember(Composite, 'Height');

  Result := TNotifySizeChanged.Create(Width, Height);
end;

end.