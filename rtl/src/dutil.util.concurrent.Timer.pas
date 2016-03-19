(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dutil.util.concurrent.Timer;

interface

uses
  System.Classes,
  System.TimeSpan,
  dutil.util.concurrent.TimerImpl;

type
  /// <summary>This service class implements a timer.</summary>
  TTimer = class
  private
    class var FTimerImpl: TTimerImpl;
    class constructor Create;
  public
    class destructor Destroy;
    /// <summary>Schedules a new action to be carried out at a given relative time.</summary>
    /// <remarks>If the given time has already passed, the action will be carried out as soon as possible.</remarks>
    class function Schedule(const Delay: TTimeSpan; Action: TThreadMethod): TDateTime; static;
    /// <summary>Removes all occurrences of the given action from the timer.</summary>
    class function Remove(const Time: TDateTime): Boolean; static;
    /// <summary>Removes all events from the timer.</summary>
    class procedure Clear; static;
  end;

implementation

class constructor TTimer.Create;
begin
  FTimerImpl := TTimerImpl.Create;
  FTimerImpl.Start;
end;

class destructor TTimer.Destroy;
begin
  FTimerImpl.Free;
end;

class function TTimer.Schedule(const Delay: TTimeSpan; Action: TThreadMethod): TDateTime;
begin
  assert(Assigned(Action));

  Result := FTimerImpl.Schedule(Delay, Action);
end;

class function TTimer.Remove(const Time: TDateTime): Boolean;
begin
  Result := FTimerImpl.Remove(Time);
end;

class procedure TTimer.Clear;
begin
  FTimerImpl.Clear;
end;

end.
