unit dutil.text.arg.ArgumentsTest;
{

 Delphi DUnit Test Case
 ----------------------
 This unit contains a skeleton test case class generated by the Test Case Wizard.
 Modify the generated code to correctly setup and call the methods from the unit
 being tested.

}

interface

uses
  TestFramework, Generics.Collections, dutil.text.arg.Arguments;

type
  // Test methods for class TArguments
  TArgumentsTest = class(TTestCase)
  strict private
    FArguments: TArguments;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestToString;
    procedure TestRequireInt;
    procedure TestRequireUInt;
    procedure TestRequireStr;
    procedure TestHasToken;
    procedure TestHasArg;
  end;

implementation

uses
  dutil.text.arg.Builder;

procedure TArgumentsTest.SetUp;
begin
  FArguments := nil;
end;

procedure TArgumentsTest.TearDown;
begin
  FArguments.Free;
  FArguments := nil;
end;

procedure TArgumentsTest.TestToString;
var
  Builder: TBuilder;
  ReturnValue: string;
begin
  Builder := TBuilder.Create;
  try
    Builder.AddInt('int', 42);
    Builder.AddStr('str', 'xx');
    Builder.AddToken('token');
    FArguments := Builder.CreateView;
  finally
    Builder.Free;
  end;

  ReturnValue := FArguments.ToString;
  CheckEquals('--str=xx --int=42 --token', ReturnValue);
end;

procedure TArgumentsTest.TestRequireInt;
var
  Builder: TBuilder;
  ReturnValue: Integer;
  Name: string;
  Value: Integer;
begin
  Name := 'foo';
  Value := -42;
  Builder := TBuilder.Create;
  try
    Builder.AddInt(Name, Value);
    FArguments := Builder.CreateView;
  finally
    Builder.Free;
  end;

  ReturnValue := FArguments.RequireInt(Name);
  CheckEquals(Value, ReturnValue);
end;

procedure TArgumentsTest.TestRequireUInt;
var
  Builder: TBuilder;
  ReturnValue: Cardinal;
  Name: string;
  Value: Cardinal;
begin
  Name := 'foo';
  Value := 42;
  Builder := TBuilder.Create;
  try
    Builder.AddInt(Name, Value);
    FArguments := Builder.CreateView;
  finally
    Builder.Free;
  end;

  ReturnValue := FArguments.RequireUInt(Name);
  CheckEquals(Value, ReturnValue);
end;

procedure TArgumentsTest.TestRequireStr;
var
  Builder: TBuilder;
  ReturnValue: string;
  Name: string;
  Value: string;
begin
  Name := 'foo';
  Value := 'bar';
  Builder := TBuilder.Create;
  try
    Builder.AddStr(Name, Value);
    FArguments := Builder.CreateView;
  finally
    Builder.Free;
  end;

  ReturnValue := FArguments.RequireStr(Name);
  CheckEquals(Value, ReturnValue);
end;

procedure TArgumentsTest.TestHasToken;
var
  Builder: TBuilder;
  ReturnValue: Boolean;
  Name: string;
begin
  Name := 'foo';
  Builder := TBuilder.Create;
  try
    Builder.AddToken(Name);
    FArguments := Builder.CreateView;
  finally
    Builder.Free;
  end;

  ReturnValue := FArguments.HasToken(Name);
  CheckTrue(ReturnValue);

  ReturnValue := FArguments.HasToken(Name + 'bar');
  CheckFalse(ReturnValue);
end;

procedure TArgumentsTest.TestHasArg;
var
  Builder: TBuilder;
  ReturnValue: Boolean;
  Name: string;
begin
  Name := 'foo';
  Builder := TBuilder.Create;
  try
    Builder.AddStr(Name, 'bar');
    FArguments := Builder.CreateView;
  finally
    Builder.Free;
  end;

  ReturnValue := FArguments.HasArg(Name);
  CheckTrue(ReturnValue);

  ReturnValue := FArguments.HasArg(Name + 'bar');
  CheckFalse(ReturnValue);
end;

initialization

// Register any test cases with the test runner
RegisterTest(TArgumentsTest.Suite);

end.