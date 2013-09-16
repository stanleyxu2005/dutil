unit dutil.util.concurrent.TimerQueueTest;
{

 Delphi DUnit Test Case
 ----------------------
 This unit contains a skeleton test case class generated by the Test Case Wizard.
 Modify the generated code to correctly setup and call the methods from the unit
 being tested.

}

interface

uses
  TestFramework, Classes, Generics.Collections, SyncObjs,
  dutil.util.concurrent.TimerQueue;

type
  // Test methods for class TTimerQueue
  TTimerQueueTest = class(TTestCase)
  strict private
    FTimerQueue: TTimerQueue;
    procedure Callback1;
    procedure Callback2;
    procedure Callback3;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestFirstTime_EmptyQueueRetrieveTime;
    procedure TestFirstTime_OneElementInQueueAndRetrieveTime;
    procedure TestFirstTime_TwoElementsInQueue;
    procedure TestTakeNotAfter_EmptyQueueRetrieveEvent;
    procedure TestTakeNotAfter_OneElementInQueueAndRetrieveEvent;
    procedure TestTakeNotAfter_TwoElementsInQueueRetrievalBeforeEither;
    procedure TestTakeNotAfter_RetrievalTimeAfterEvent;
    procedure TestTakeNotAfter_RetrievalTimeBeforeEvent;
    procedure TestTakeNotAfter_RetrievalTimeExactlyAtEvent;
    procedure TestTakeNotAfter_TwoElementsAtSameTimeRetrievalInCorrectOrder;
    procedure TestTakeNotAfter_TwoElementsAtSameTimeRetrievalTwice;
    procedure TestTakeNotAfter_ThreeElementsInAscendingOrderRetrievalInCorrectOrder;
    procedure TestTakeNotAfter_ThreeElementsInDescendingOrderRetrievalInCorrectOrder;
    procedure TestRemoveAction_OneElementInQueueRemoveItQueueBecomesEmpty;
    procedure TestRemoveAction_RemoveSomethingNotPresent;
    procedure TestRemoveAction_SameEventAtDifferentTimesRemove1st;
    procedure TestRemoveAction_SameEventAtDifferentTimesRemove2nd;
  private
    class function CheckEquals(Expected, Actual: TThreadMethod): Boolean; overload; static;
  private type
    TTestThread = class(TThread);
    end;

implementation

uses
  DateUtils,
  Math,
  SysUtils,
  TimeSpan,
  dutil.time.Time;

class function TTimerQueueTest.CheckEquals(Expected, Actual: TThreadMethod): Boolean;
begin
  Result := (TMethod(Expected).Code = TMethod(Actual).Code) and (TMethod(Expected).Data = TMethod(Actual).Data);
end;

procedure TTimerQueueTest.Callback1;
begin
  // dummy
end;

procedure TTimerQueueTest.Callback2;
begin
  // dummy
end;

procedure TTimerQueueTest.Callback3;
begin
  // dummy
end;

procedure TTimerQueueTest.SetUp;
begin
  FTimerQueue := TTimerQueue.Create;
end;

procedure TTimerQueueTest.TearDown;
begin
  FTimerQueue.Free;
  FTimerQueue := nil;
end;

procedure TTimerQueueTest.TestFirstTime_EmptyQueueRetrieveTime;
var
  ReturnValue: TDateTime;
begin
  ReturnValue := FTimerQueue.FirstTime;
  CheckTrue(SameValue(TTime_.MAX, ReturnValue));
end;

procedure TTimerQueueTest.TestFirstTime_OneElementInQueueAndRetrieveTime;
var
  Reference: TDateTime;
  ReturnValue: TDateTime;
begin
  Reference := TTime_.EPOCH_1970;

  FTimerQueue.Add(Reference, Callback1);
  ReturnValue := FTimerQueue.FirstTime;
  CheckEquals(Reference, ReturnValue);
end;

procedure TTimerQueueTest.TestFirstTime_TwoElementsInQueue;
var
  Reference: TDateTime;
  ReturnValue: TDateTime;
begin
  Reference := TTime_.EPOCH_1970;
  FTimerQueue.Add(IncMilliSecond(Reference, 120), Callback2);
  FTimerQueue.Add(IncMilliSecond(Reference, 60), Callback1);

  ReturnValue := FTimerQueue.FirstTime;
  CheckEquals(IncMilliSecond(Reference, 60), ReturnValue);
end;

procedure TTimerQueueTest.TestTakeNotAfter_EmptyQueueRetrieveEvent;
var
  ReturnValue: TThreadMethod;
begin
  ReturnValue := FTimerQueue.TakeNotAfter(TTime_.MAX);
  CheckNull(@ReturnValue);
end;

procedure TTimerQueueTest.TestTakeNotAfter_OneElementInQueueAndRetrieveEvent;
var
  Reference: TDateTime;
  ReturnValue: TThreadMethod;
begin
  Reference := TTime_.EPOCH_1970;

  FTimerQueue.Add(Reference, Callback1);
  ReturnValue := FTimerQueue.TakeNotAfter(TTime_.MAX);
  CheckEquals(Callback1, ReturnValue);
end;

procedure TTimerQueueTest.TestTakeNotAfter_TwoElementsInQueueRetrievalBeforeEither;
var
  Reference: TDateTime;
  ReturnValue: TThreadMethod;
begin
  Reference := TTime_.EPOCH_1970;
  FTimerQueue.Add(IncMilliSecond(Reference, 60), Callback1);
  FTimerQueue.Add(IncMilliSecond(Reference, 120), Callback2);

  ReturnValue := FTimerQueue.TakeNotAfter(Reference);
  CheckNull(@ReturnValue);
end;

procedure TTimerQueueTest.TestTakeNotAfter_RetrievalTimeAfterEvent;
var
  Reference: TDateTime;
  ReturnValue: TThreadMethod;
begin
  Reference := TTime_.EPOCH_1970;
  FTimerQueue.Add(Reference, Callback1);

  ReturnValue := FTimerQueue.TakeNotAfter(IncMilliSecond(Reference, 30));
  CheckEquals(Callback1, ReturnValue);
end;

procedure TTimerQueueTest.TestTakeNotAfter_RetrievalTimeBeforeEvent;
var
  Reference: TDateTime;
  ReturnValue: TThreadMethod;
begin
  Reference := TTime_.EPOCH_1970;
  FTimerQueue.Add(Reference, Callback1);

  ReturnValue := FTimerQueue.TakeNotAfter(IncMilliSecond(Reference, -30));
  CheckNull(@ReturnValue);
end;

procedure TTimerQueueTest.TestTakeNotAfter_RetrievalTimeExactlyAtEvent;
var
  Reference: TDateTime;
  ReturnValue: TThreadMethod;
begin
  Reference := TTime_.EPOCH_1970;
  FTimerQueue.Add(Reference, Callback1);

  ReturnValue := FTimerQueue.TakeNotAfter(Reference);
  CheckEquals(Callback1, ReturnValue);
end;

procedure TTimerQueueTest.TestTakeNotAfter_TwoElementsAtSameTimeRetrievalInCorrectOrder;
var
  Reference: TDateTime;
  ReturnValue1: TThreadMethod;
  ReturnValue2: TThreadMethod;
begin
  Reference := TTime_.EPOCH_1970;
  FTimerQueue.Add(Reference, Callback1);
  FTimerQueue.Add(Reference, Callback2);

  ReturnValue1 := FTimerQueue.TakeNotAfter(TTime_.MAX);
  ReturnValue2 := FTimerQueue.TakeNotAfter(TTime_.MAX);

  CheckEquals(Callback1, ReturnValue1);
  CheckEquals(Callback2, ReturnValue2);
end;

procedure TTimerQueueTest.TestTakeNotAfter_TwoElementsAtSameTimeRetrievalTwice;
var
  Reference: TDateTime;
  ReturnValue1: TThreadMethod;
  ReturnValue2: TThreadMethod;
begin
  Reference := TTime_.EPOCH_1970;
  FTimerQueue.Add(Reference, Callback1);
  FTimerQueue.Add(Reference, Callback1);

  ReturnValue1 := FTimerQueue.TakeNotAfter(TTime_.MAX);
  ReturnValue2 := FTimerQueue.TakeNotAfter(TTime_.MAX);

  CheckEquals(Callback1, ReturnValue1);
  CheckEquals(Callback1, ReturnValue2);
end;

procedure TTimerQueueTest.TestTakeNotAfter_ThreeElementsInAscendingOrderRetrievalInCorrectOrder;
var
  Reference: TDateTime;
  ReturnValue1: TThreadMethod;
  ReturnValue2: TThreadMethod;
  ReturnValue3: TThreadMethod;
begin
  Reference := TTime_.EPOCH_1970;
  FTimerQueue.Add(IncMilliSecond(Reference, 60), Callback1);
  FTimerQueue.Add(IncMilliSecond(Reference, 120), Callback2);
  FTimerQueue.Add(IncMilliSecond(Reference, 180), Callback3);

  ReturnValue1 := FTimerQueue.TakeNotAfter(TTime_.MAX);
  ReturnValue2 := FTimerQueue.TakeNotAfter(TTime_.MAX);
  ReturnValue3 := FTimerQueue.TakeNotAfter(TTime_.MAX);

  CheckEquals(Callback1, ReturnValue1);
  CheckEquals(Callback2, ReturnValue2);
  CheckEquals(Callback3, ReturnValue3);
end;

procedure TTimerQueueTest.TestTakeNotAfter_ThreeElementsInDescendingOrderRetrievalInCorrectOrder;
var
  Reference: TDateTime;
  ReturnValue1: TThreadMethod;
  ReturnValue2: TThreadMethod;
  ReturnValue3: TThreadMethod;
begin
  Reference := TTime_.EPOCH_1970;
  FTimerQueue.Add(IncMilliSecond(Reference, 180), Callback3);
  FTimerQueue.Add(IncMilliSecond(Reference, 60), Callback1);
  FTimerQueue.Add(IncMilliSecond(Reference, 120), Callback2);

  ReturnValue1 := FTimerQueue.TakeNotAfter(TTime_.MAX);
  ReturnValue2 := FTimerQueue.TakeNotAfter(TTime_.MAX);
  ReturnValue3 := FTimerQueue.TakeNotAfter(TTime_.MAX);

  CheckEquals(Callback1, ReturnValue1);
  CheckEquals(Callback2, ReturnValue2);
  CheckEquals(Callback3, ReturnValue3);
end;

procedure TTimerQueueTest.TestRemoveAction_OneElementInQueueRemoveItQueueBecomesEmpty;
var
  TimeAdded: TDateTime;
  ReturnResult: Boolean;
  ReturnTime: TDateTime;
begin
  TimeAdded := TTime_.EPOCH_1970;
  FTimerQueue.Add(TimeAdded, Callback1);

  ReturnResult := FTimerQueue.RemoveAction(TimeAdded);
  ReturnTime := FTimerQueue.FirstTime;

  CheckTrue(SameValue(TTime_.MAX, ReturnTime));
  CheckTrue(ReturnResult);
end;

procedure TTimerQueueTest.TestRemoveAction_RemoveSomethingNotPresent;
var
  ReturnValue: Boolean;
begin
  ReturnValue := FTimerQueue.RemoveAction(SysUtils.Now);
  CheckFalse(ReturnValue);
end;

procedure TTimerQueueTest.TestRemoveAction_SameEventAtDifferentTimesRemove1st;
var
  Reference: TDateTime;
  ReturnResult: Boolean;
  ReturnValue1: TThreadMethod;
  ReturnValue2: TThreadMethod;
begin
  Reference := TTime_.EPOCH_1970;
  FTimerQueue.Add(IncMilliSecond(Reference, 60), Callback1);
  FTimerQueue.Add(IncMilliSecond(Reference, 120), Callback2);
  FTimerQueue.Add(IncMilliSecond(Reference, 180), Callback1);

  ReturnResult := FTimerQueue.RemoveAction(IncMilliSecond(Reference, 60));
  ReturnValue1 := FTimerQueue.TakeNotAfter(TTime_.MAX);
  ReturnValue2 := FTimerQueue.TakeNotAfter(TTime_.MAX);

  CheckEquals(Callback2, ReturnValue1);
  CheckEquals(Callback1, ReturnValue2);
  CheckTrue(ReturnResult);
end;

procedure TTimerQueueTest.TestRemoveAction_SameEventAtDifferentTimesRemove2nd;
var
  Reference: TDateTime;
  ReturnResult: Boolean;
  ReturnValue1: TThreadMethod;
  ReturnValue2: TThreadMethod;
begin
  Reference := TTime_.EPOCH_1970;
  FTimerQueue.Add(IncMilliSecond(Reference, 60), Callback1);
  FTimerQueue.Add(IncMilliSecond(Reference, 120), Callback2);
  FTimerQueue.Add(IncMilliSecond(Reference, 180), Callback1);

  ReturnResult := FTimerQueue.RemoveAction(IncMilliSecond(Reference, 180));
  ReturnValue1 := FTimerQueue.TakeNotAfter(TTime_.MAX);
  ReturnValue2 := FTimerQueue.TakeNotAfter(TTime_.MAX);

  CheckEquals(Callback1, ReturnValue1);
  CheckEquals(Callback2, ReturnValue2);
  CheckTrue(ReturnResult);
end;

initialization

// Register any test cases with the test runner
RegisterTest(TTimerQueueTest.Suite);

end.
