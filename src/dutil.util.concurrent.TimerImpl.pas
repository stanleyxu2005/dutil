(**
 * $Id: dutil.util.concurrent.TimerImpl.pas 520 2012-05-23 04:09:21Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.util.concurrent.TimerImpl;

interface

uses
  Classes,
  SyncObjs,
  TimeSpan,
  dutil.util.concurrent.FailSafeThread,
  dutil.util.concurrent.TimerQueue;

type
  /// <summary>This controller class implements a timer.</summary>
  TTimerImpl = class
  private
    FGuard: TCriticalSection;
    FCondition: TConditionVariableCS;
    FQueue: TTimerQueue;
    FNextWake: TDateTime;
    FTerminated: Boolean;
    FThread: TFailSafeThread;
    procedure RunForever;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Start;
    function Schedule(const Delay: TTimeSpan; Action: TThreadMethod): TDateTime;
    function Remove(const Time: TDateTime): Boolean;
    procedure Clear;
    procedure HandleTimeChange;
  end;

implementation

uses
  DateUtils,
  Math,
  SysUtils,
  Windows,
  dutil.time.Time;

constructor TTimerImpl.Create;
begin
  inherited;

  FGuard := TCriticalSection.Create;
  FCondition := TConditionVariableCS.Create;
  FQueue := TTimerQueue.Create;
  FNextWake := TTime_.MAX;
  FThread := TFailSafeThread.Create(RunForever, 'timer');
  FTerminated := False;
end;

destructor TTimerImpl.Destroy;
begin
  if not FTerminated then
  begin
    FGuard.Acquire;
    try
      FTerminated := True;
      FCondition.ReleaseAll;
    finally
      FGuard.Release;
    end;
  end;

  FThread.WaitFor;
  FThread.Free;
  FThread := nil;
  FQueue.Free;
  FQueue := nil;
  FCondition.Free;
  FCondition := nil;
  FGuard.Free;
  FGuard := nil;

  inherited;
end;

procedure TTimerImpl.Start;
begin
  FThread.Start;
end;

function TTimerImpl.Schedule(const Delay: TTimeSpan; Action: TThreadMethod): TDateTime;
var
  Time: TDateTime;
begin
  assert(Assigned(Action));

  Time := IncMilliSecond(SysUtils.Now, Round(Delay.TotalMilliseconds));
  Result := FQueue.Add(Time, Action);

  FGuard.Acquire;
  try
    if Time < FNextWake then
      FCondition.ReleaseAll;
  finally
    FGuard.Release;
  end;
end;

function TTimerImpl.Remove(const Time: TDateTime): Boolean;
begin
  Result := FQueue.RemoveAction(Time);
end;

procedure TTimerImpl.Clear;
begin
  FQueue.Clear;
end;

procedure TTimerImpl.HandleTimeChange;
begin
  FGuard.Acquire;
  try
    FCondition.ReleaseAll;
  finally
    FGuard.Release;
  end;
end;

procedure TTimerImpl.RunForever;
var
  WaitForMillis: Double;
  Action: TThreadMethod;
begin
  while True do
  begin
    FGuard.Acquire;
    try
      if FTerminated then
        Break;

      FNextWake := FQueue.FirstTime;
      if Math.SameValue(FNextWake, TTime_.MAX) then
        FCondition.WaitFor(FGuard)
      else
      begin
        WaitForMillis := MilliSecondSpan(FNextWake, SysUtils.Now);
        if WaitForMillis > 0 then
        begin
          FCondition.WaitFor(FGuard, {Timeout=}Round(WaitForMillis) + 1)
        end;
      end;
    finally
      FGuard.Release;
    end;

    Action := FQueue.TakeNotAfter(SysUtils.Now);
    while @Action <> nil do
    begin
      Action();
      Action := FQueue.TakeNotAfter(SysUtils.Now);
    end;
  end;
end;

end.