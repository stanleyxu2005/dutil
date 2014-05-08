program remoting_tests;
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
  DUnitTestRunner,
  dutil.remoting.rpc.jsonrpc.DecoderTest in '..\test\dutil.remoting.rpc.jsonrpc.DecoderTest.pas',
  dutil.remoting.rpc.jsonrpc.EncoderTest in '..\test\dutil.remoting.rpc.jsonrpc.EncoderTest.pas',
  dutil.remoting.rpc.RPCHandlerMock in '..\test\dutil.remoting.rpc.RPCHandlerMock.pas';

{$R *.RES}

begin
  DUnitTestRunner.RunRegisteredTests;
end.

