unit remote.command.ResizeWindow;

interface

uses
  superobject,
  dutil.remoting.framework.Command;

type
  TResizeWindow = class(TCommand)
  private
    FWidth: Cardinal;
    FHeight: Cardinal;
  public
    property Width: Cardinal read FWidth;
    property Height: Cardinal read FHeight;
  public
    constructor Create(Width, Height: Cardinal);
    function Params_: ISuperObject; override;
    class function Method_: string; override;
    class function Type_: TCommand.TType; override;
    class function HandleInMainThread_: Boolean; override;
    /// <exception cref="EJsonException">When parser error is occurred.</exception>
    class function FromJSON(const Composite: ISuperObject): TResizeWindow; static;
  public type
    TResponse = record
    private
      FSuccess: Boolean;
    public
      property Success: Boolean read FSuccess;
      function Result_: ISuperObject;
    end;
    class function EncodeResponse(Success: Boolean): ISuperObject; static;
    /// <exception cref="EJsonException">When parser error is occurred.</exception>
    class function DecodeResponse(const Composite: ISuperObject): TResponse; static;
  end;

implementation

uses
  dutil.text.json.Validation;

constructor TResizeWindow.Create(Width, Height: Cardinal);
begin
  inherited Create;

  FWidth := Width;
  FHeight := Height;
end;

class function TResizeWindow.Method_: string;
begin
  Result := 'ResizeWindow';
end;

class function TResizeWindow.Type_: TCommand.TType;
begin
  Result := TCommand.TType.REQUEST;
end;

class function TResizeWindow.HandleInMainThread_: Boolean;
begin
  Result := True;
end;

function TResizeWindow.Params_: ISuperObject;
begin
  Result := SO;
  Result.I['Width'] := FWidth;
  Result.I['Height'] := FHeight;
end;

class function TResizeWindow.FromJSON(const Composite: ISuperObject): TResizeWindow;
var
  Width: Cardinal;
  Height: Cardinal;
begin
  assert(Composite <> nil);

  Width := TValidation.RequireUIntMember(Composite, 'Width');
  Height := TValidation.RequireUIntMember(Composite, 'Height');

  Result := TResizeWindow.Create(Width, Height);
end;

function TResizeWindow.TResponse.Result_: ISuperObject;
begin
  Result := SO;
  Result.B['Success'] := FSuccess;
end;

class function TResizeWindow.EncodeResponse(Success: Boolean): ISuperObject;
var
  Response: TResponse;
begin
  Response.FSuccess := Success;
  Result := Response.Result_;
end;

class function TResizeWindow.DecodeResponse(const Composite: ISuperObject): TResponse;
begin
  assert(Composite <> nil);

  Result.FSuccess := TValidation.RequireBoolMember(Composite, 'Success');
end;

end.
