(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dutil.util.concurrent.Result;

interface

uses
  System.SyncObjs,
  System.SysUtils;

type
  /// <summary>This container class holds a result value, where the retrieval blocks until the value becomes
  /// available.</summary>
  TResult<V> = class
  private
    FLock: TCriticalSection;
    FCondition: TConditionVariableCS;
    FValue: V;
    FException: Exception;
    FAvailable: Boolean;
  public
    constructor Create;
    destructor Destroy; override;
    /// <summary>Takes the result value or an exception from the container.</summary>
    /// <exception cref="Exception">When an exception is put into the result.</exception>
    function Take: V;
    /// <summary>Puts a result value into the container.</summary>
    procedure Put(const Value: V);
    /// <summary>Puts an exception into the container.</summary>
    procedure PutException(Ex: Exception);
    /// <summary>Indicates whether the contain is filled with something.</summary>
    function Available: Boolean;
  end;

implementation

constructor TResult<V>.Create;
begin
  inherited;

  FLock := TCriticalSection.Create;
  FCondition := TConditionVariableCS.Create;
end;

destructor TResult<V>.Destroy;
begin
  FCondition.Free;
  FLock.Free;

  inherited;
end;

function TResult<V>.Take: V;
begin
  FLock.Acquire;
  try
    while not FAvailable do
    begin
      FCondition.WaitFor(FLock);
    end;
    if FException <> nil then
      raise FException;
    Result := FValue;
  finally
    FLock.Release;
  end;
end;

procedure TResult<V>.Put(const Value: V);
begin
  FLock.Acquire;
  try
    FValue := Value;
    FException := nil;
    FAvailable := True;
    FCondition.ReleaseAll;
  finally
    FLock.Release;
  end;
end;

procedure TResult<V>.PutException(Ex: Exception);
begin
  assert(Ex <> nil);

  FLock.Acquire;
  try
    FException := Ex;
    FAvailable := True;
    FCondition.ReleaseAll;
  finally
    FLock.Release;
  end;
end;

function TResult<V>.Available: Boolean;
begin
  FLock.Acquire;
  try
    Result := FAvailable;
  finally
    FLock.Release;
  end;
end;

end.
