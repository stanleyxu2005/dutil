(**
 * $Id: dutil.remoting.util.ThreadedConsumer.pas 794 2014-04-28 16:00:24Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.util.ThreadedConsumer;

interface

uses
  System.Classes,
  dutil.util.concurrent.BlockingQueue;

type
  /// <summary>The consumer class keeps to *consume* the elements of a blocking queue in a first-in-first-out manner. A
  /// common way to convince a producer-consumer service to shut down is with a "poison pill": a recognizable object
  /// placed on the queue that means "when you get this, stop."</summary>
  TThreadedConsumer<T> = class(TThread)
  private type
    TThreadedMethod = procedure(const Elem: T)of object;
  private
    FElems: TBlockingQueue<T>;
    FHandleMethod: TThreadedMethod;
  protected
    procedure Execute; override;
  public
    constructor Create(Elems: TBlockingQueue<T>; const HandleMethod: TThreadedMethod);
    destructor Destroy; override;
  end;

implementation

uses
  System.Generics.Defaults;

constructor TThreadedConsumer<T>.Create(Elems: TBlockingQueue<T>; const HandleMethod: TThreadedMethod);
begin
  assert(Elems <> nil);
  assert(Assigned(HandleMethod));
  inherited Create({CreateSuspended=}True);

  FElems := Elems;
  FHandleMethod := HandleMethod;
end;

destructor TThreadedConsumer<T>.Destroy;
begin
  FElems.Put(Default(T)); // Put a poison pill
  WaitFor;

  FHandleMethod := nil;
  FElems := nil;

  inherited;
end;

procedure TThreadedConsumer<T>.Execute;
var
  Comparer: IEqualityComparer<T>;
  Elem: T;
begin
  Comparer := TEqualityComparer<T>.Default;
  Elem := FElems.Take;
  while not Comparer.Equals(Elem, Default(T)) do
  begin
    try
      FHandleMethod(Elem);
    except
    end;
    Elem := FElems.Take;
  end;
end;

end.