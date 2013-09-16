(**
 * $Id: dutil.util.concurrent.FailSafeThread.pas 520 2012-05-23 04:09:21Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.util.concurrent.FailSafeThread;

interface

uses
  Classes;

type
  /// <summary>This service class allows to execute a specified action where uncaught exceptions will terminate the
  /// process.</summary>
  TFailSafeThread = class(TThread)
  private
    FName: AnsiString;
    FAction: TThreadMethod;
  protected
    procedure Execute; override;
  public
    constructor Create(Action: TThreadMethod; const Name: AnsiString);
    destructor Destroy; override;
  end;

implementation

uses
{$IFDEF LOGGING}
  Log4D,
{$ENDIF}
  SysUtils;

constructor TFailSafeThread.Create(Action: TThreadMethod; const Name: AnsiString);
begin
  assert(Assigned(Action));

  inherited Create({CreateSuspended=}True);

  FAction := Action;
  FName := Name;
end;

destructor TFailSafeThread.Destroy;
begin
  FAction := nil;

  inherited;
end;

procedure TFailSafeThread.Execute;
begin
  NameThreadForDebugging(FName);

  try
    FAction;
  except
    on E: Exception do
    begin
{$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Fatal(E.ToString);
{$ENDIF}
      Halt(1);
    end;
  end;
end;

end.
