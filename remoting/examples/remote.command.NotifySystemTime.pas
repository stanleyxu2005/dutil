// $Id: remote.command.NotifySystemTime.pas 802 2014-04-30 07:59:53Z QXu $

unit remote.command.NotifySystemTime;

interface

uses
  superobject { An universal object serialization framework with Json support },
  dutil.remoting.framework.Command;

type
  /// <summary>This command arranges to notify to change the visibility level of a renderer view.</summary>
  /// <remarks>Expected to be handled in main thread</remarks>
  TNotifySystemTime = class(TCommand)
  private
    FSystemTime: TDateTime;
  public
    property SystemTime: TDateTime read FSystemTime;
  public
    constructor Create(SystemTime: TDateTime);
    function Params_: ISuperObject; override;
    class function Method_: string; override;
    class function Type_: TCommand.TType; override;
    class function HandleInMainThread_: Boolean; override;
    /// <exception cref="EJsonException">When parser error is occurred.</exception>
    class function FromJSON(const Composite: ISuperObject): TNotifySystemTime; static;
  end;

implementation

uses
  System.SysUtils,
  dutil.text.json.Validation;

constructor TNotifySystemTime.Create(SystemTime: TDateTime);
begin
  inherited Create;

  FSystemTime := SystemTime;
end;

class function TNotifySystemTime.Method_: string;
begin
  Result := 'NotifySystemTime';
end;

class function TNotifySystemTime.Type_: TCommand.TType;
begin
  Result := TCommand.TType.NOTIFICATION
end;

class function TNotifySystemTime.HandleInMainThread_: Boolean;
begin
  Result := True;
end;

function TNotifySystemTime.Params_: ISuperObject;
begin
  Result := SO;
  Result.S['SystemTime'] := DateTimeToStr(FSystemTime);
end;

class function TNotifySystemTime.FromJSON(const Composite: ISuperObject): TNotifySystemTime;
var
  SystemTime: TDateTime;
begin
  assert(Composite <> nil);

  SystemTime := StrToDateTime(TValidation.RequireStrMember(Composite, 'SystemTime'));

  Result := TNotifySystemTime.Create(SystemTime);
end;

end.