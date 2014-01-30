(**
 * $Id: dutil.net.jsonrpc.framework.Backlog.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.jsonrpc.framework.Backlog;

interface

uses
  Generics.Collections,
  SyncObjs,
  superobject { An universal object serialization framework with Json support },
  dutil.net.jsonrpc.message.Identifier,
  dutil.util.concurrent.Result;

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
    class procedure Abort(Result: TResult<ISuperObject>; SequenceNumber: Cardinal); static;
  public
    constructor Create;
    destructor Destroy; override;
    /// <exception cref="EJsonException">When the identifier does not represent a sequence number.</exception>
    function Take(const Id: TIdentifier): TResult<ISuperObject>;
    function Put(Result_: TResult<ISuperObject>): TIdentifier;
    procedure Close;
  end;

implementation

uses
{$IFDEF LOGGING}
  Log4D,
  SysUtils,
{$ENDIF}
  dutil.core.Exception,
  dutil.net.jsonrpc.message.Error,
  dutil.net.jsonrpc.message.JsonRpcException,
  dutil.text.json.Validation;

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

  FResults.Free;
  FResults := nil;
  FLock.Free;
  FLock := nil;

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

    if FClosed then
      Abort(Result_, SequenceNumber)
    else
      FResults.Add(SequenceNumber, Result_);

    Result := TIdentifier.NumberIdentifier(SequenceNumber);
  finally
    FLock.Release;
  end;
end;

function TBacklog.Take(const Id: TIdentifier): TResult<ISuperObject>;
var
  SequenceNumber: Cardinal;
begin
  assert(Id.Valid);

  Result := nil;
  FLock.Acquire;
  try
    SequenceNumber := TValidation.RequireUInt(Id.Value); // throws EJsonException

    if FResults.ContainsKey(SequenceNumber) then
      Result := FResults.ExtractPair(SequenceNumber).Value;
  finally
    FLock.Release;
  end;
end;

procedure TBacklog.Close;
var
  Item: TPair<Cardinal, TResult<ISuperObject>>;
begin
  FLock.Acquire;
  try
    for Item in FResults do
      Abort(Item.Value, Item.Key);

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

class procedure TBacklog.Abort(Result: TResult<ISuperObject>; SequenceNumber: Cardinal);
var
  Error: EError;
  Id: TIdentifier;
begin
  assert(Result <> nil);

  Error := EError.CreateNoResponseReceived('');
  Id := TIdentifier.NumberIdentifier(SequenceNumber);
  try
{$IFDEF LOGGING}
    TLogLogger.GetLogger(ClassName).Warn(Format('Abort to wait (id=%s)', [Id.ToString]));
{$ENDIF}
    Result.PutException(EJsonRpcException.Create(Error, Id));
  finally
    Error.Free;
  end;
end;

end.
