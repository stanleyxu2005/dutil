unit dutil.text.arg.BuilderTest;
{

 Delphi DUnit Test Case
 ----------------------
 This unit contains a skeleton test case class generated by the Test Case Wizard.
 Modify the generated code to correctly setup and call the methods from the unit
 being tested.

}

interface

uses
  TestFramework, Generics.Collections, dutil.text.arg.Builder;

type
  // Test methods for class TBuilder
  TBuilderTest = class(TTestCase)
  strict private
    FBuilder: TBuilder;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestToString;
    procedure TestAddInt;
    procedure TestAddStr;
    procedure TestAddToken;
    procedure TestFromCommandLine;
  end;

implementation

uses
  dutil.text.arg.Arguments;

procedure TBuilderTest.SetUp;
begin
  FBuilder := TBuilder.Create;
end;

procedure TBuilderTest.TearDown;
begin
  FBuilder.Free;
  FBuilder := nil;
end;

procedure TBuilderTest.TestToString;
var
  ReturnValue: string;
begin
  FBuilder.AddInt('int', 42);
  FBuilder.AddStr('str', 'xx');
  FBuilder.AddToken('token');

  ReturnValue := FBuilder.ToString;
  CheckEquals('--int=42 --str=xx --token', ReturnValue);
end;

procedure TBuilderTest.TestAddInt;
var
  Value: Integer;
  Name: string;
  View: TArguments;
begin
  Name := 'foo';
  Value := 42;

  FBuilder.AddInt(Name, Value);
  View := FBuilder.Build;
  try
    CheckEquals(Value, View.RequireInt(Name));
  finally
    View.Free;
  end;
end;

procedure TBuilderTest.TestAddStr;
var
  Value: string;
  Name: string;
  View: TArguments;
begin
  Name := 'foo';
  Value := 'bar';

  FBuilder.AddStr(Name, Value);
  View := FBuilder.Build;
  try
    CheckEquals(Value, View.RequireStr(Name));
  finally
    View.Free;
  end;
end;

procedure TBuilderTest.TestAddToken;
var
  Name: string;
  View: TArguments;
begin
  Name := 'foo';

  FBuilder.AddToken(Name);
  View := FBuilder.Build;
  try
    CheckTrue(View.HasToken(Name));
  finally
    View.Free;
  end;
end;

procedure TBuilderTest.TestFromCommandLine;
var
  ReturnValue: TArguments;
begin
  ReturnValue := FBuilder.FromCommandLine;
  try
    CheckNotNull(ReturnValue);
  finally
    ReturnValue.Free;
  end;
end;

initialization

// Register any test cases with the test runner
RegisterTest(TBuilderTest.Suite);

end.
