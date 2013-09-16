program dutil_rtl_tests;
{

 Delphi DUnit Test Project
 -------------------------
 This project contains the DUnit test framework and the GUI/Console test runners.
 Add "CONSOLE_TESTRUNNER" to the conditional defines entry in the project options
 to use the console test runner.  Otherwise the GUI test runner will be used by
 default.

}
{$IFDEF CONSOLE_TESTRUNNER}
{$APPTYPE CONSOLE}
{$ENDIF}

uses
  Forms,
  TestFramework,
  GUITestRunner,
  TextTestRunner,
  dutil.io.device.File_ in '..\..\src\dutil.io.device.File_.pas',
  dutil.io.device.TempFile in '..\..\src\dutil.io.device.TempFile.pas',
  dutil.sys.win32.Platform in '..\..\src\dutil.sys.win32.Platform.pas',
  dutil.sys.win32.Process in '..\..\src\dutil.sys.win32.Process.pas',
  dutil.sys.win32.registry.Validation in '..\..\src\dutil.sys.win32.registry.Validation.pas',
  dutil.sys.win32.SpecialPath in '..\..\src\dutil.sys.win32.SpecialPath.pas',
  dutil.text.arg.Arguments in '..\..\src\dutil.text.arg.Arguments.pas',
  dutil.text.arg.Builder in '..\..\src\dutil.text.arg.Builder.pas',
  dutil.text.Convert in '..\..\src\dutil.text.Convert.pas',
  dutil.text.xml.Validation in '..\..\src\dutil.text.xml.Validation.pas',
  dutil.text.Util in '..\..\src\dutil.text.Util.pas',
  dutil.util.concurrent.BlockingQueue in '..\..\src\dutil.util.concurrent.BlockingQueue.pas',
  dutil.util.concurrent.TimerQueue in '..\..\src\dutil.util.concurrent.TimerQueue.pas',
  dutil.io.device.FileTest in '..\..\test\dutil.io.device.FileTest.pas',
  dutil.io.device.TempFileTest in '..\..\test\dutil.io.device.TempFileTest.pas',
  dutil.sys.win32.PlatformTest in '..\..\test\dutil.sys.win32.PlatformTest.pas',
  dutil.sys.win32.ProcessTest in '..\..\test\dutil.sys.win32.ProcessTest.pas',
  dutil.sys.win32.registry.ValidationTest in '..\..\test\dutil.sys.win32.registry.ValidationTest.pas',
  dutil.sys.win32.SpecialPathTest in '..\..\test\dutil.sys.win32.SpecialPathTest.pas',
  dutil.text.arg.ArgumentsTest in '..\..\test\dutil.text.arg.ArgumentsTest.pas',
  dutil.text.arg.BuilderTest in '..\..\test\dutil.text.arg.BuilderTest.pas',
  dutil.text.ConvertTest in '..\..\test\dutil.text.ConvertTest.pas',
  dutil.text.xml.ValidationTest in '..\..\test\dutil.text.xml.ValidationTest.pas',
  dutil.text.UtilTest in '..\..\test\dutil.text.UtilTest.pas',
  dutil.util.concurrent.BlockingQueueTest in '..\..\test\dutil.util.concurrent.BlockingQueueTest.pas',
  dutil.util.concurrent.TimerQueueTest in '..\..\test\dutil.util.concurrent.TimerQueueTest.pas';

{$R *.RES}

var
  Results: TTestResult;

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  if IsConsole then
  begin
    Results := TextTestRunner.RunRegisteredTests;
    try
      if not Results.WasSuccessful then
        ReadLn;
    finally
      Results.Free;
    end;
  end
  else
    GUITestRunner.RunRegisteredTests;

end.
