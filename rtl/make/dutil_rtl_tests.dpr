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
//{$APPTYPE CONSOLE}
{$ENDIF}

uses
  DUnitTestRunner,
  dutil.io.device.FileTest in '..\test\dutil.io.device.FileTest.pas',
  dutil.io.device.TempFileTest in '..\test\dutil.io.device.TempFileTest.pas',
  dutil.sys.win32.PlatformTest in '..\test\dutil.sys.win32.PlatformTest.pas',
  dutil.sys.win32.ProcessTest in '..\test\dutil.sys.win32.ProcessTest.pas',
  dutil.sys.win32.registry.ValidationTest in '..\test\dutil.sys.win32.registry.ValidationTest.pas',
  dutil.sys.win32.SpecialPathTest in '..\test\dutil.sys.win32.SpecialPathTest.pas',
  dutil.text.arg.ArgumentsTest in '..\test\dutil.text.arg.ArgumentsTest.pas',
  dutil.text.arg.BuilderTest in '..\test\dutil.text.arg.BuilderTest.pas',
  dutil.text.ConvertTest in '..\test\dutil.text.ConvertTest.pas',
  dutil.text.UtilTest in '..\test\dutil.text.UtilTest.pas',
  dutil.text.xml.ValidationTest in '..\test\dutil.text.xml.ValidationTest.pas',
  dutil.util.concurrent.BlockingQueueTest in '..\test\dutil.util.concurrent.BlockingQueueTest.pas',
  dutil.util.concurrent.TimerQueueTest in '..\test\dutil.util.concurrent.TimerQueueTest.pas',
  dutil.util.container.DynArrayTest in '..\test\dutil.util.container.DynArrayTest.pas',
  dutil.util.digest.Crc32Test in '..\test\dutil.util.digest.Crc32Test.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

