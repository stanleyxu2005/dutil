program memt;

{$R 'imags.res' 'imags.rc'}

uses
  Forms,
  mainform in 'mainform.pas' {MainWindow};

{$R *.res}

begin
  ReportMemoryLeaksOnShutdown := True;

  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TMainWindow, MainWindow);
  Application.Run;
end.
