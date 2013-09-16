(**
 * $Id: dutil.util.concurrent.BlockingQueue.pas 518 2012-05-22 16:46:34Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.util.concurrent.BlockingQueue;

interface

uses
  Generics.Collections,
  SyncObjs;

type
  /// <summary>This container class holds elements in a first-in-first-out manner, where retrieving an element waits
  /// for the queue to become non-empty.</summary>
  /// <remarks>Blocking queues support the producer-consumer design pattern. A common way to convince a
  /// producer-consumer service to shut down is with a "poison pill": a recognizable object placed on the queue that
  /// means "when you get this, stop."</remarks>
  TBlockingQueue<T> = class
  private
    FGuard: TCriticalSection;
    FCondition: TConditionVariableCS;
    FQueue: TQueue<T>;
  public
    constructor Create;
    destructor Destroy; override;
    function Count: Cardinal;
    function Take: T; virtual;
    procedure Put(const Element: T); virtual;
  end;

implementation

constructor TBlockingQueue<T>.Create;
begin
  inherited;

  FGuard := TCriticalSection.Create;
  FCondition := TConditionVariableCS.Create;
  FQueue := TQueue<T>.Create;
end;

destructor TBlockingQueue<T>.Destroy;
begin
  FQueue.Free;
  FQueue := nil;
  FCondition.Free;
  FCondition := nil;
  FGuard.Free;
  FGuard := nil;

  inherited;
end;

function TBlockingQueue<T>.Count: Cardinal;
begin
  FGuard.Acquire;
  try
    Result := FQueue.Count;
  finally
    FGuard.Release;
  end;
end;

function TBlockingQueue<T>.Take: T;
begin
  FGuard.Acquire;
  try
    while FQueue.Count = 0 do
    begin
      FCondition.WaitFor(FGuard);
    end;
    Result := FQueue.Dequeue;
  finally
    FGuard.Release;
  end;
end;

procedure TBlockingQueue<T>.Put(const Element: T);
begin
  FGuard.Acquire;
  try
    FQueue.Enqueue(Element);
    FCondition.ReleaseAll;
  finally
    FGuard.Release;
  end;
end;

end.
