(**
 * $Id: dutil.remoting.transport.np.TransportImpl.pas 813 2014-05-08 15:08:01Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.transport.np.TransportImpl;

interface

uses
  dutil.remoting.transport.AbstractTransportImpl,
  dutil.remoting.transport.Pdu,
  dutil.remoting.util.ThreadedConsumer,
  Cromis.Comm.Custom,
  Cromis.Comm.IPC;

type
  /// <summary>The class implements a transport resource via named pipe.</summary>
  TTransportImpl = class(TAbstractTransportImpl)
  private
    FReceivingServer: TIPCServer;
    FSenderClient: TIPCClient;
    FSenderThread: TThreadedConsumer<TPdu>;
    procedure HandleExecuteRequest(const Context: ICommContext; const Request: IMessageData;
      const Response: IMessageData);
  public
    function WriteEnsured(const Pdu: TPdu): Boolean; override;
    function GetUri: string; override;
  private
    procedure SendMessage(const Pdu: TPdu);
    function SendMessageAwait(const Pdu: TPdu): Boolean;
  public
    constructor Create(const Name: string);
    destructor Destroy; override;
  end;

implementation

uses
{$IFDEF LOGGING}
  Log4D,
{$ENDIF}
  System.SysUtils,
  dutil.remoting.transport.Uri;

const
  IPC_RECIPIENT = 'r';
  IPC_MESSAGE = 'm';

constructor TTransportImpl.Create(const Name: string);
begin
  inherited Create;

  FSenderClient := TIPCClient.Create;
  FSenderThread := TThreadedConsumer<TPdu>.Create(FOutboundQueue, SendMessage);
  FSenderThread.NameThreadForDebugging('dco.system.sender <np>', FSenderThread.ThreadID);

  FReceivingServer := TIPCServer.Create;
  FReceivingServer.MinPoolSize := 1;
  //FReceivingServer.NameThreadForDebugging('dco.system.receiver <np>', FReceiverThread.ThreadID);
  FReceivingServer.ServerName := Name;
  FReceivingServer.OnExecuteRequest := HandleExecuteRequest;

  FSenderThread.Start;
  FReceivingServer.Start;
end;

destructor TTransportImpl.Destroy;
begin
  FReceivingServer.Free;
  FSenderThread.Free;
  FSenderClient.Free;

  inherited;
end;

procedure TTransportImpl.HandleExecuteRequest(const Context: ICommContext; const Request: IMessageData;
  const Response: IMessageData);
var
  Pdu: TPdu;
begin
  try
    Pdu := TPdu.Create(
      TUri.FromString(Request.Data.ReadString(IPC_RECIPIENT)).ToString,
      TUri.FromString(Request.ID).ToString,
      Request.Data.ReadString(IPC_MESSAGE)
    );
  except
    Exit; // Unexpected message
  end;

  FInboundQueue.Put(Pdu);

{$IFDEF LOGGING}
  TLogLogger.GetLogger(ClassName).Trace(Format('<-%s: %s', [Pdu.Sender, Pdu.Message_]));
{$ENDIF}
end;

function TTransportImpl.WriteEnsured(const Pdu: TPdu): Boolean;
begin
  // This message is expected to be sent immediately with ensurance, so we call the static method directly!
  Result := SendMessageAwait(Pdu);
end;

function TTransportImpl.GetUri: string;
begin
  Result := FReceivingServer.ServerName;
end;

procedure TTransportImpl.SendMessage(const Pdu: TPdu);
begin
  SendMessageAwait(Pdu);
end;

function TTransportImpl.SendMessageAwait(const Pdu: TPdu): Boolean;
var
  Recipient: TUri;
  Sender: TUri;
  Data: IIPCData;
begin
  try
    Recipient := TUri.FromString(Pdu.Recipient);
    Sender := TUri.FromString(Pdu.Sender);
  except
    on E: Exception do
    begin
      {$IFDEF LOGGING}
      TLogLogger.GetLogger(ClassName).Error(E.ToString);
      {$ENDIF}
      Exit(False);
    end;
  end;
  if Recipient.Id <> Sender.Id then
  begin
    {$IFDEF LOGGING}
    TLogLogger.GetLogger(ClassName).Error(
      Format('Untrusted message header detected: Recipient=%s, Sender=%s, Message=%s',
        [Pdu.Recipient, Pdu.Sender, Pdu.Message_]));
    {$ENDIF}
    Exit(False);
  end;

  Data := AcquireIPCData;
  Data.ID := Pdu.Sender;
  Data.Data.WriteString(IPC_RECIPIENT, Pdu.Recipient);
  Data.Data.WriteString(IPC_MESSAGE, Pdu.Message_);

  Result := False;
  try
    FSenderClient.ServerName := Recipient.Domain;
    FSenderClient.ExecuteRequest(Data);
    if FSenderClient.AnswerValid then
      Result := True;
  except
  end;

{$IFDEF LOGGING}
  TLogLogger.GetLogger(ClassName).Trace(Format('->%s: %s', [Pdu.Recipient, Pdu.Message_]));
{$ENDIF}
end;

end.