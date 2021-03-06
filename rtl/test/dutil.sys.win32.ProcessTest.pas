unit dutil.sys.win32.ProcessTest;
{

 Delphi DUnit Test Case
 ----------------------
 This unit contains a skeleton test case class generated by the Test Case Wizard.
 Modify the generated code to correctly setup and call the methods from the unit
 being tested.

}

interface

uses
  TestFramework, Windows, TLHelp32, Generics.Collections, dutil.sys.win32.Process,
  SysUtils, ShellAPI;

type
  // Test methods for class TProcess

  TProcessTest = class(TTestCase)
  strict private
    FProcess: TProcess;
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestListAll;
    procedure TestListFiltered;
    procedure TestFork;
    procedure TestFork_LessOptions;
    procedure TestTerminate_ByPID;
    procedure TestTerminate_ByName;
  private
    procedure ExpectProcessCount(const ProcessName: string; Expected: Cardinal);
  end;

implementation

uses
  Forms;

procedure TProcessTest.SetUp;
begin
  FProcess := TProcess.Create;
end;

procedure TProcessTest.TearDown;
begin
  FProcess.Free;
  FProcess := nil;
end;

procedure TProcessTest.TestListAll;
var
  ReturnValue: TArray<TProcessEntry32>;
begin
  ReturnValue := FProcess.ListAll;
  CheckTrue(Length(ReturnValue) > 2, 'At least the test runner itself and ''System Idle Process'' should exist');
end;

procedure TProcessTest.TestListFiltered;
var
  ProcessName: string;
begin
  ProcessName := ExtractFileName(Application.ExeName);

  ExpectProcessCount(ProcessName, {Expected=}1);
end;

procedure TProcessTest.ExpectProcessCount(const ProcessName: string; Expected: Cardinal);
var
  ProcessList: TArray<TProcessEntry32>;
begin
  ProcessList := FProcess.ListFiltered(ProcessName);
  CheckEquals(Expected, Length(ProcessList));
end;

procedure TProcessTest.TestFork;
var
  ShowMode: Integer;
  Masks: System.Cardinal;
  WorkingDir: string;
  Parameters: string;
  Filename: string;
begin
  Filename := '..\fixture\processtest.exe';
  Parameters := '--close';
  WorkingDir := '';
  Masks := SEE_MASK_DEFAULT;
  ShowMode := SW_HIDE;

  FProcess.Fork(Filename, Parameters, WorkingDir, Masks, ShowMode);
  ExpectProcessCount('processtest.exe', {Expected=}1);
  Windows.Sleep(50);
  ExpectProcessCount('processtest.exe', {Expected=}0);
end;

procedure TProcessTest.TestFork_LessOptions;
var
  Parameters: string;
  Filename: string;
begin
  Filename := '..\fixture\processtest.exe';
  Parameters := '--close';

  FProcess.Fork(Filename, Parameters);
  ExpectProcessCount('processtest.exe', {Expected=}1);
  Windows.Sleep(50);
  ExpectProcessCount('processtest.exe', {Expected=}0);
end;

procedure TProcessTest.TestTerminate_ByPID;
var
  Filename: string;
  ProcessList: TArray<TProcessEntry32>;
  ExitCode: System.Cardinal;
  PID: System.Cardinal;
begin
  Filename := '..\fixture\processtest.exe';
  FProcess.Fork(Filename, {Paramters=}'');
  ProcessList := TProcess.ListFiltered('processtest.exe');
  CheckEquals(1, Length(ProcessList));
  PID := ProcessList[0].th32ProcessID;
  ExitCode := 1;

  FProcess.Terminate(PID, ExitCode);
  Windows.Sleep(50);
  ExpectProcessCount('processtest.exe', {Expected=}0);
end;

procedure TProcessTest.TestTerminate_ByName;
var
  Filename: string;
  ProcessList: TArray<TProcessEntry32>;
  ExitCode: System.Cardinal;
begin
  Filename := '..\fixture\processtest.exe';
  FProcess.Fork(Filename, {Paramters=}'');
  FProcess.Fork(Filename, {Paramters=}'');
  ProcessList := TProcess.ListFiltered('processtest.exe');
  CheckEquals(2, Length(ProcessList));
  ExitCode := 1;

  FProcess.Terminate('processtest.exe', {IncludeSelf=}True, ExitCode);
  Windows.Sleep(50);
  ExpectProcessCount('processtest.exe', {Expected=}0);
end;

initialization

// Register any test cases with the test runner
RegisterTest(TProcessTest.Suite);

end.
