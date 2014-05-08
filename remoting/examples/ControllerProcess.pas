unit ControllerProcess;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  dutil.remoting.framework.RemotingSystem,
  remote.model.WindowHost;

type
  TForm1 = class(TForm)
    Button2: TButton;
    Button3: TButton;
    LabeledEdit1: TLabeledEdit;
    LabeledEdit2: TLabeledEdit;
    procedure FormDestroy(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    FDemoObjectHost: TDemoObjectHost;
    FRemotingSystem: TRemotingSystem;
    procedure SetupCommunication;
    procedure ConfigureLogger;
    procedure NotifyPositionChanged(X, Y: Integer);
    procedure NotifySizeChanged(NewWidth, NewHeight: Cardinal);
    procedure NotifySystemTime(NewTime: TDateTime);
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

uses
  Log4D,
  System.DateUtils,
  System.SysUtils,
  dutil.sys.win32.Process,
  dutil.remoting.transport.np.TransportImpl,
  dutil.remoting.framework.RPCObjectImpl;

procedure TForm1.SetupCommunication;
const
  PROCESS_UUID = 'remote1';
var
  LocalUri: string;
  StartTime: TDateTime;
  RPCObject: TRPCObjectImpl;
begin
  // Create a remote object
  LocalUri := FRemotingSystem.ExpectHandshake;
  TProcess.Folk(Application.ExeName, Format('%s %s', [PROCESS_UUID, LocalUri]));
  RPCObject := nil;
  StartTime := Now;
  while RPCObject = nil do
  begin
    if MilliSecondsBetween(Now, StartTime) > 10000 then
      Halt;
    RPCObject := FRemotingSystem.Handshaked(LocalUri);
    Application.ProcessMessages;
  end;
  assert(RPCObject <> nil);
  BringToFront;

  FDemoObjectHost := TDemoObjectHost.Create(RPCObject);
  FDemoObjectHost.OnWindowSizeChanged := NotifySizeChanged;
  FDemoObjectHost.OnWindowPositionChanged := NotifyPositionChanged;
  FDemoObjectHost.OnSystemTimeNotified := NotifySystemTime;
end;

procedure TForm1.ConfigureLogger;
var
  LogFile: string;
  Layout: TLogPatternLayout;
  FileAppender: TLogRollingFileAppender;
begin
  LogFile := Application.ExeName + '.log';

  Layout := TLogPatternLayout.Create('%d %p %c [%t] %m%n');
  Layout.Options[DateFormatOpt] := 'hh:nn:ss.zzz';

  FileAppender := TLogRollingFileAppender.Create('default', LogFile, Layout, {Append=}True);
  FileAppender.Options[MaxFileSizeOpt] := '10MB';
  FileAppender.Options[MaxBackupIndexOpt] := IntToStr(5);
  TLogLogger.GetRootLogger.AddAppender(FileAppender);
  TLogLogger.GetRootLogger.Level := Trace;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  FDemoObjectHost.ResizeWindow(100, 100);
end;

procedure TForm1.Button3Click(Sender: TObject);
begin
  FDemoObjectHost.ResizeWindow(200, 200);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  TThread.NameThreadForDebugging('ui');
  ConfigureLogger;
  FRemotingSystem := TRemotingSystem.Create(TTransportImpl.Create('form1'));
  FRemotingSystem.Start;
  SetupCommunication;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  TProcess.Terminate(ExtractFileName(Application.ExeName), { IncludeSelf= } False);

  if Assigned(FDemoObjectHost) then
  begin
    FRemotingSystem.Remove(FDemoObjectHost.GetRPCObjectId);
    FDemoObjectHost.Free;
  end;

  FRemotingSystem.Free;
end;

procedure TForm1.NotifyPositionChanged(X, Y: Integer);
begin
  LabeledEdit1.Text := Format('%d, %d', [X, Y]);
end;

procedure TForm1.NotifySizeChanged(NewWidth, NewHeight: Cardinal);
begin
  LabeledEdit2.Text := Format('%d, %d', [NewWidth, NewHeight]);
end;

procedure TForm1.NotifySystemTime(NewTime: TDateTime);
begin
  //Caption := DateTimeToStr(NewTime);
end;

end.
