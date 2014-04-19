unit dutil.util.container.DynArrayTest;
{

  Delphi DUnit Test Case
  ----------------------
  This unit contains a skeleton test case class generated by the Test Case Wizard.
  Modify the generated code to correctly setup and call the methods from the unit 
  being tested.

}

interface

uses
  TestFramework, dutil.util.container.DynArray;

type
  // Test methods for class TDynArray
  TDynArrayTest = class(TTestCase)
  strict private
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestAppend;
    procedure TestAppend_More;
    procedure TestInsert0;
    procedure TestInsert0_More;
    procedure TestInsert1;
    procedure TestInsert1_More;
  end;

implementation

procedure TDynArrayTest.SetUp;
begin
end;

procedure TDynArrayTest.TearDown;
begin
end;

procedure TDynArrayTest.TestAppend;
var
  ReturnValue: Cardinal;
  Item: string;
  Destination: TArray<string>;
begin
  SetLength(Destination, 2);
  Destination[0] := 'item 1';
  Destination[1] := 'item 2';
  Item := 'item 3';

  ReturnValue := TDynArray.Append<string>(Destination, Item);
  CheckEquals(3, ReturnValue);
  CheckEquals(Item, Destination[2]);
end;

procedure TDynArrayTest.TestAppend_More;
var
  ReturnValue: Cardinal;
  Items: TArray<string>;
  Destination: TArray<string>;
begin
  SetLength(Destination, 2);
  Destination[0] := 'item 1';
  Destination[1] := 'item 2';
  SetLength(Items, 2);
  Items[0] := 'item 3';
  Items[1] := 'item 4';

  ReturnValue := TDynArray.Append<string>(Destination, Items);
  CheckEquals(4, ReturnValue);
  CheckEquals(Items[0], Destination[2]);
  CheckEquals(Items[1], Destination[3]);
end;

procedure TDynArrayTest.TestInsert0;
var
  ReturnValue: Cardinal;
  Item: string;
  Destination: TArray<string>;
begin
  SetLength(Destination, 2);
  Destination[0] := 'item 1';
  Destination[1] := 'item 2';
  Item := 'item 3';

  ReturnValue := TDynArray.Insert<string>(Destination, Item, 0);
  CheckEquals(3, ReturnValue);
  CheckEquals(Item, Destination[0]);
  CheckEquals('item 1', Destination[1]);
  CheckEquals('item 2', Destination[2]);
end;

procedure TDynArrayTest.TestInsert0_More;
var
  ReturnValue: Cardinal;
  Items: TArray<string>;
  Destination: TArray<string>;
begin
  SetLength(Destination, 2);
  Destination[0] := 'item 1';
  Destination[1] := 'item 2';
  SetLength(Items, 2);
  Items[0] := 'item 3';
  Items[1] := 'item 4';

  ReturnValue := TDynArray.Insert<string>(Destination, Items, 0);
  CheckEquals(4, ReturnValue);
  CheckEquals(Items[0], Destination[0]);
  CheckEquals(Items[1], Destination[1]);
  CheckEquals('item 1', Destination[2]);
  CheckEquals('item 2', Destination[3]);
end;

procedure TDynArrayTest.TestInsert1;
var
  ReturnValue: Cardinal;
  Item: string;
  Destination: TArray<string>;
begin
  SetLength(Destination, 2);
  Destination[0] := 'item 1';
  Destination[1] := 'item 2';
  Item := 'item 3';

  ReturnValue := TDynArray.Insert<string>(Destination, Item, 1);
  CheckEquals(3, ReturnValue);
  CheckEquals('item 1', Destination[0]);
  CheckEquals(Item, Destination[1]);
  CheckEquals('item 2', Destination[2]);
end;

procedure TDynArrayTest.TestInsert1_More;
var
  ReturnValue: Cardinal;
  Items: TArray<string>;
  Destination: TArray<string>;
begin
  SetLength(Destination, 2);
  Destination[0] := 'item 1';
  Destination[1] := 'item 2';
  SetLength(Items, 2);
  Items[0] := 'item 3';
  Items[1] := 'item 4';

  ReturnValue := TDynArray.Insert<string>(Destination, Items, 1);
  CheckEquals(4, ReturnValue);
  CheckEquals('item 1', Destination[0]);
  CheckEquals(Items[0], Destination[1]);
  CheckEquals(Items[1], Destination[2]);
  CheckEquals('item 2', Destination[3]);
end;

initialization
  // Register any test cases with the test runner
  RegisterTest(TDynArrayTest.Suite);
end.

