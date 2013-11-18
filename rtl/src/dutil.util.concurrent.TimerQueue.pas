(**
 * $Id: dutil.util.concurrent.TimerQueue.pas 520 2012-05-23 04:09:21Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.util.concurrent.TimerQueue;

interface

uses
  Classes,
  Generics.Collections,
  SyncObjs;

type
  /// <summary>This container class holds elements in a first-in-first-out manner.</summary>
  TTimerQueue = class
  private
    FGuard: TCriticalSection;
    FTimeList: TList<TDateTime>;
    FElements: TDictionary<TDateTime, TThreadMethod>;
  public
    constructor Create;
    destructor Destroy; override;
    function FirstTime: TDateTime;
    function Add(const Time: TDateTime; Action: TThreadMethod): TDateTime;
    function TakeNotAfter(const Time: TDateTime): TThreadMethod;
    function RemoveAction(const Time: TDateTime): Boolean;
    procedure Clear;
  end;

implementation

uses
  DateUtils,
  dutil.time.Time;

constructor TTimerQueue.Create;
begin
  inherited;

  FGuard := TCriticalSection.Create;
  FTimeList := TList<TDateTime>.Create;
  FElements := TDictionary<TDateTime, TThreadMethod>.Create;
end;

destructor TTimerQueue.Destroy;
begin
  FElements.Free;
  FElements := nil;
  FTimeList.Free;
  FTimeList := nil;
  FGuard.Free;
  FGuard := nil;

  inherited;
end;

function TTimerQueue.FirstTime: TDateTime;
begin
  FGuard.Acquire;
  try
    assert(FTimeList.Count = FElements.Count);

    if FTimeList.Count = 0 then
      Result := TTime_.MAX
    else
      Result := FTimeList.First;
  finally
    FGuard.Release;
  end;
end;

function TTimerQueue.Add(const Time: TDateTime; Action: TThreadMethod): TDateTime;
begin
  assert(Time < TTime_.MAX);
  assert(Assigned(Action));

  FGuard.Acquire;
  try
    assert(FTimeList.Count = FElements.Count);

    Result := Time;
    while FElements.ContainsKey(Result) do
    begin
      Result := DateUtils.IncMilliSecond(Result);
    end;

    FElements.Add(Result, Action);
    FTimeList.Add(Result);
    FTimeList.Sort;
  finally
    assert(FTimeList.Count = FElements.Count);
    FGuard.Release;
  end;
end;

function TTimerQueue.TakeNotAfter(const Time: TDateTime): TThreadMethod;
var
  FirstTime_: TDateTime;
begin
  FGuard.Acquire;
  try
    assert(FTimeList.Count = FElements.Count);
    Result := nil;

    if FElements.Count > 0 then
    begin
      FirstTime_ := FTimeList.First;
      assert(FElements.ContainsKey(FirstTime_));

      if FirstTime_ <= Time then
      begin
        Result := FElements.Items[FirstTime_];
        FElements.Remove(FirstTime_);
        FTimeList.Delete(0);
      end;
    end;
  finally
    assert(FTimeList.Count = FElements.Count);
    FGuard.Release;
  end;
end;

function TTimerQueue.RemoveAction(const Time: TDateTime): Boolean;
begin
  FGuard.Acquire;
  try
    assert(FTimeList.Count = FElements.Count);

    Result := FElements.ContainsKey(Time);
    if Result then
    begin
      assert(FTimeList.Contains(Time));
      FElements.Remove(Time);
      FTimeList.Remove(Time);
    end;
  finally
    assert(FTimeList.Count = FElements.Count);
    FGuard.Release;
  end;
end;

procedure TTimerQueue.Clear;
begin
  FGuard.Acquire;
  try
    assert(FTimeList.Count = FElements.Count);

    FElements.Clear;
    FTimeList.Clear;
  finally
    FGuard.Release;
  end;
end;

end.
