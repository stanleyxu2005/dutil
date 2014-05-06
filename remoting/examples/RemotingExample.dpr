program RemotingExample;

uses
  Vcl.Forms,
  ControllerProcess in 'ControllerProcess.pas' {Form1},
  RemoteDemoProcess in 'RemoteDemoProcess.pas' {Form2},
  remote.model.WindowHost in 'remote.model.WindowHost.pas',
  remote.command.ResizeWindow in 'remote.command.ResizeWindow.pas',
  remote.command.NotifySizeChanged in 'remote.command.NotifySizeChanged.pas',
  remote.command.NotifyPositionChanged in 'remote.command.NotifyPositionChanged.pas',
  remote.model.WindowOrigin in 'remote.model.WindowOrigin.pas',
  remote.model.RPCObjectContainer in 'remote.model.RPCObjectContainer.pas',
  remote.command.NotifySystemTime in 'remote.command.NotifySystemTime.pas';

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;
  Application.Initialize;
  Application.MainFormOnTaskbar := True;

  if ParamCount > 0 then
  begin
    Application.CreateForm(TForm2, Form2);
  end
  else
  begin
    Application.CreateForm(TForm1, Form1);
  end;
  Application.Run;
end.
