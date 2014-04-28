(**
 * $Id: dutil.remoting.framework.Backlog.pas 786 2014-04-27 15:44:17Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.framework.Backlog;

interface

uses
  System.Generics.Collections,
  System.SyncObjs,
  superobject { An universal object serialization framework with Json support },
  dutil.util.concurrent.Result,
  dutil.remoting.rpc.Identifier;

type
  /// <summary>This repository class allows to store and retrieve specified result containers using consecutively
  /// numbered asynchronous completion tokens.</summary>
  TBacklog = class
  private
    FLock: TCriticalSection;
    FResults: TDictionary<Cardinal, TResult<ISuperObject>>;
    FSequenceNumber: Cardinal;
    FClosed: Boolean;
    function NextSequenceNumber: Cardinal;
    class procedure Abort(Result: TResult<ISuperObject>; const Id: TIdentifier); static;
    /// <exception cref="EJsonException">When the identifier does not represent a sequence number.</exception>
    function TakeInternal(const Id: TIdentifier; FailResult: Boolean): TResult<ISuperObject>;
  public
    constructor Create;
    destructor Destroy; override;
    /// <exception cref="EJsonException">When the identifier does not represent a sequence number.</exception>
    function Take(const Id: TIdentifier): TResult<ISuperObject>;
    /// <exception cref="EJsonException">When the identifier does not represent a sequence number.</exception>
    function TakeAndFailResult(const Id: TIdentifier): TResult<ISuperObject>;
    function Put(Result_: TResult<ISuperObject>): TIdentifier;
    procedure Close;
  end;

implementation

uses
{$IFDEF LOGGING}
  Log4D,
  System.SysUtils,
{$ENDIF}
  dutil.core.Exception,
  dutil.text.json.Validation,
  dutil.remoting.rpc.ErrorObject,
  dutil.remoting.rpc.RPCException;

constructor TBacklog.Create;
begin
  inherited;

  FLock := TCriticalSection.Create;
  FResults := TDictionary<Cardinal, TResult<ISuperObject>>.Create;
  FClosed := False;
  FSequenceNumber := 0;
end;

destructor TBacklog.Destroy;
begin
  assert(FResults.Count = 0);

  FLock.Acquire;
  try
    FResults.Free;
  finally
    FLock.Release;
  end;
  FLock.Free;

  inherited;
end;

function TBacklog.Put(Result_: TResult<ISuperObject>): TIdentifier;
var
  SequenceNumber: Cardinal;
begin
  assert(Result_ <> nil);

  FLock.Acquire;
  try
    SequenceNumber := NextSequenceNumber;
    Result := TIdentifier.NumberIdentifier(SequenceNumber);

    if FClosed then
      Abort(Result_, Result)
    else
      FResults.Add(SequenceNumber, Result_);
  finally
    FLock.Release;
  end;
end;

function TBacklog.TakeInternal(const Id: TIdentifier; FailResult: Boolean): TResult<ISuperObject>;
var
  SequenceNumber: Cardinal;
begin
  assert(Id.Valid);

  Result := nil;
  FLock.Acquire;
  try
    SequenceNumber := TValidation.RequireUInt(Id.Value); // throws EJsonException

    if FResults.ContainsKey(SequenceNumber) then
    begin
      Result := FResults.ExtractPair(SequenceNumber).Value;
      assert(Result <> nil);
      if FailResult then
        Abort(Result, Id);
    end;
  finally
    FLock.Release;
  end;
end;

function TBacklog.Take(const Id: TIdentifier): TResult<ISuperObject>;
begin
  Result := TakeInternal(Id, {FailResult=}False);
end;

function TBacklog.TakeAndFailResult(const Id: TIdentifier): TResult<ISuperObject>;
begin
  Result := TakeInternal(Id, {FailResult=}True);
end;

procedure TBacklog.Close;
var
  Item: TPair<Cardinal, TResult<ISuperObject>>;
begin
  FLock.Acquire;
  try
    for Item in FResults do
      Abort(Item.Value, TIdentifier.NumberIdentifier(Item.Key));
    FResults.Clear;
    FClosed := True;
  finally
    FLock.Release;
  end;
end;

function TBacklog.NextSequenceNumber: Cardinal;
begin
  // To avoid potential problems, only non-negative values of the signed 32-bit integral type are used.
  if FSequenceNumber < High(Cardinal) then
    FSequenceNumber := FSequenceNumber + 1
  else
  begin
    {$IFDEF LOGGING}
    TLogLogger.GetLogger(ClassName).Warn('Sequence number wraparound');
    {$ENDIF}
    FSequenceNumber := 1;
  end;
  Result := FSequenceNumber;
end;

class procedure TBacklog.Abort(Result: TResult<ISuperObject>; const Id: TIdentifier);
var
  Error: TErrorObject;
begin
  assert(Result <> nil);
  assert(Id.Valid);


  Error := TErrorObject.CreateNoResponseReceived('');
  {$IFDEF LOGGING}
  TLogLogger.GetLogger(ClassName).Warn(Format('Abort to wait (id=%s)', [Id.ToString]));
  {$ENDIF}

  Result.PutException(ERPCException.Create(Error, Id));
end;

end.
