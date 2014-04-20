(**
 * $Id: dutil.util.concurrent.TimerImpl.pas 747 2014-03-11 07:42:35Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.util.concurrent.TimerImpl;

interface

uses
  System.Classes,
  System.SyncObjs,
  System.TimeSpan,
  dutil.util.concurrent.FailSafeThread,
  dutil.util.concurrent.TimerQueue;

type
  /// <summary>This controller class implements a timer.</summary>
  TTimerImpl = class
  private
    FLock: TCriticalSection;
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
  System.DateUtils,
  System.Math,
  System.SysUtils,
  Winapi.Windows,
  dutil.time.Time;

constructor TTimerImpl.Create;
begin
  inherited;

  FLock := TCriticalSection.Create;
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
    FLock.Acquire;
    try
      FTerminated := True;
      FCondition.ReleaseAll;
    finally
      FLock.Release;
    end;
  end;

  FThread.WaitFor;
  FThread.Free;
  FQueue.Free;
  FCondition.Free;
  FLock.Free;

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

  Time := IncMilliSecond(Now, Round(Delay.TotalMilliseconds));
  Result := FQueue.Add(Time, Action);

  FLock.Acquire;
  try
    if Time < FNextWake then
      FCondition.ReleaseAll;
  finally
    FLock.Release;
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
  FLock.Acquire;
  try
    FCondition.ReleaseAll;
  finally
    FLock.Release;
  end;
end;

procedure TTimerImpl.RunForever;
var
  WaitForMillis: Double;
  Action: TThreadMethod;
begin
  while True do
  begin
    FLock.Acquire;
    try
      if FTerminated then
        Break;

      FNextWake := FQueue.FirstTime;
      if SameValue(FNextWake, TTime_.MAX) then
        FCondition.WaitFor(FLock)
      else
      begin
        WaitForMillis := MilliSecondSpan(FNextWake, Now);
        if WaitForMillis > 0 then
        begin
          FCondition.WaitFor(FLock, {Timeout=}Round(WaitForMillis) + 1)
        end;
      end;
    finally
      FLock.Release;
    end;

    Action := FQueue.TakeNotAfter(Now);
    while @Action <> nil do
    begin
      Action();
      Action := FQueue.TakeNotAfter(Now);
    end;
  end;
end;

end.
