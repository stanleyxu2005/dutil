// $Id: remote.command.NotifyPositionChanged.pas 802 2014-04-30 07:59:53Z QXu $

unit remote.command.NotifyPositionChanged;

interface

uses
  superobject { An universal object serialization framework with Json support },
  dutil.remoting.framework.Command;

type
  /// <summary>This command arranges to notify to change the visibility level of a renderer view.</summary>
  /// <remarks>Expected to be handled in main thread</remarks>
  TNotifyPositionChanged = class(TCommand)
  private
    FX: Integer;
    FY: Integer;
  public
    property X: Integer read FX;
    property Y: Integer read FY;
  public
    constructor Create(X: Integer; Y: Integer);
    function Params_: ISuperObject; override;
    class function Method_: string; override;
    class function Type_: TCommand.TType; override;
    class function HandleInMainThread_: Boolean; override;
    /// <exception cref="EJsonException">When parser error is occurred.</exception>
    class function FromJSON(const Composite: ISuperObject): TNotifyPositionChanged; static;
  end;

implementation

uses
  dutil.text.json.Validation;

constructor TNotifyPositionChanged.Create(X: Integer; Y: Integer);
begin
  inherited Create;

  FX := X;
  FY := Y;
end;

class function TNotifyPositionChanged.Method_: string;
begin
  Result := 'NotifyPositionChanged';
end;

class function TNotifyPositionChanged.Type_: TCommand.TType;
begin
  Result := TCommand.TType.NOTIFICATION
end;

class function TNotifyPositionChanged.HandleInMainThread_: Boolean;
begin
  Result := True;
end;

function TNotifyPositionChanged.Params_: ISuperObject;
begin
  Result := SO;
  Result.I['X'] := FX;
  Result.I['Y'] := FY;
end;

class function TNotifyPositionChanged.FromJSON(const Composite: ISuperObject): TNotifyPositionChanged;
var
  X: Integer;
  Y: Integer;
begin
  assert(Composite <> nil);

  X := TValidation.RequireUIntMember(Composite, 'X');
  Y := TValidation.RequireUIntMember(Composite, 'Y');

  Result := TNotifyPositionChanged.Create(X, Y);
end;

end.