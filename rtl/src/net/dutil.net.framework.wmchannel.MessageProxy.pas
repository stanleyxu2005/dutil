(**
 * $Id: dutil.net.framework.wmchannel.MessageProxy.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.framework.wmchannel.MessageProxy;

interface

uses
  Generics.Collections,
  Messages,
  SyncObjs,
  Windows,
  dutil.net.framework.wmchannel.Address,
  dutil.net.framework.wmchannel.Connection,
  dutil.net.framework.wmchannel.ConnectionMessage,
  dutil.sys.win32.SubclassingWindow,
  dutil.util.concurrent.BlockingQueue,
  dutil.util.concurrent.FailSafeThread;

type
  /// <summary>The boundary class arranges to exchange data between multiple processes using WM_COPYDATA messages. Each
  /// channel connection has own input and output message queues. The message proxy monitors the Windows message loop 
  /// and put related messages into input message queues of channel connections. The output messages are taken from 
  /// output message queues and are sent to desination using a sender thread.</summary>
  TMessageProxy = class
  private
    FLock: TCriticalSection;
    FTerminated: Boolean;
    FLocalWindow: HWND;
    FOutput: TBlockingQueue<TConnectionMessage>;
    FConnections: TDictionary<TAddress, TConnection>;
    FHelper: TSubclassingWindowHelper;
    FSender: TFailSafeThread;
    procedure SendForever;
    procedure StopSending;
    function Terminated: Boolean;
    /// <exception cref="ENoSuchElementException">Specified channel is not activated.</exception>
    function RequireConnection(const Address: TAddress): TConnection;
    procedure CheckMessage(var Message_: TMessage);
    function MessageTaken(const Message_: TWMCopyData): Boolean;
    function SendMessage(const Address: TAddress; const Pdu: string): Boolean;
  public
    constructor Create(LocalWindow: HWND); overload;
    destructor Destroy; override;
    /// <exception cref="EDuplicateElementException"Specified channel is occupied.</exception>
    function AddConnection(const Address: TAddress; Input: TBlockingQueue<string>): TConnection;
    /// <exception cref="ENoSuchElementException">Specified channel is not activated.</exception>
    procedure RemoveConnection(Connection: TConnection);
  end;

implementation

uses
{$IFDEF LOGGING}
  Log4D,
{$ENDIF}
  SysUtils,
  dutil.core.Exception;

constructor TMessageProxy.Create(LocalWindow: HWND);
begin
  assert(LocalWindow > 0);
  assert(Windows.GetCurrentThreadId = MainThreadID, 'the proxy is expected to work in the main thread');
  inherited Create;

  FLock := TCriticalSection.Create;
  FTerminated := False;

  FLocalWindow := LocalWindow;
  FOutput := TBlockingQueue<TConnectionMessage>.Create;
  FConnections := TDictionary<TAddress, TConnection>.Create;
  FHelper := TSubclassingWindowHelper.Create(FLocalWindow, CheckMessage);

  FSender := TFailSafeThread.Create(SendForever, 'sendwm');
  FSender.Start;
end;

destructor TMessageProxy.Destroy;
begin
  StopSending;
  FSender.Free;
  FSender := nil;

  FHelper.Free;
  FHelper := nil;
  FConnections.Free;
  FConnections := nil;
  FOutput.Free;
  FOutput := nil;

  FLock.Free;
  FLock := nil;

  inherited;
end;

procedure TMessageProxy.StopSending;
var
  PoisonPill: TConnectionMessage;
begin
  FLock.Acquire;
  try
    FTerminated := True;
  finally
    FLock.Release;
  end;

  // After having set FTerminated to be true, we put a poison pill into output queue to inform sender thread to stop.
  PoisonPill := TConnectionMessage.Assign(TAddress.Assign(0, 0), '');
  FOutput.Put(PoisonPill);
  FSender.WaitFor;

  assert(FTerminated);
end;

function TMessageProxy.Terminated: Boolean;
begin
  FLock.Acquire;
  try
    Result := FTerminated;
  finally
    FLock.Release;
  end;
end;

function TMessageProxy.RequireConnection(const Address: TAddress): TConnection;
begin
  Result := nil;

  FLock.Acquire;
  try
    if not FConnections.ContainsKey(Address) then
      raise ENoSuchElementException.Create(Format('Channel %d is not activated', [Address.Port]));

    Result := FConnections.Items[Address];
  finally
    FLock.Release;
  end;
end;

function TMessageProxy.AddConnection(const Address: TAddress; Input: TBlockingQueue<string>): TConnection;
begin
  assert(Input <> nil);

  FLock.Acquire;
  try
    Result := nil;
    if FConnections.ContainsKey(Address) then
      raise EDuplicateElementException.Create(Format('Channel %d is occupied already', [Address.Port]));

    Result := TConnection.Create(Address, Input, FOutput);
    FConnections.Add(Address, Result);
  finally
    FLock.Release;
  end;
end;

procedure TMessageProxy.RemoveConnection(Connection: TConnection);
begin
  assert(Connection <> nil);

  FLock.Acquire;
  try
    if not FConnections.ContainsKey(Connection.Address) then
      raise ENoSuchElementException.Create(Format('Channel %d is not activated', [Connection.Address.Port]));

    FConnections.Remove(Connection.Address);
  finally
    FLock.Release;
  end;
end;

procedure TMessageProxy.CheckMessage(var Message_: TMessage);
begin
  if Message_.Msg = WM_COPYDATA then
  begin
    if MessageTaken(TWMCopyData(Message_)) then
      Message_.Result := Integer({Handled=}True);
  end;
end;

function TMessageProxy.MessageTaken(const Message_: TWMCopyData): Boolean;
var
  Address: TAddress;
  Connection: TConnection;
  Pdu: string;
begin
  try
    Address := TAddress.Assign({MessageWindow=}Message_.From, {Port=}Message_.CopyDataStruct.dwData);
    Connection := RequireConnection(Address);
  except
    on ENoSuchElementException do
    begin
      Result := False;
      Exit;
    end;
  end;

  Pdu := PChar(Message_.CopyDataStruct.lpData); // Copies data onto heap
  Connection.Input.Put(Pdu);
  Result := True;
end;

function TMessageProxy.SendMessage(const Address: TAddress; const Pdu: string): Boolean;
var
  CopyData: CopyDataStruct;
begin
  assert(Pdu <> '');

  Result := IsWindow(Address.MessageWindow);
  if not Result then
    Exit;

  CopyData.dwData := Address.Port;
  CopyData.lpData := PChar(Pdu);
  CopyData.cbData := (Length(Pdu) + 1) * StringElementSize(Pdu);

  Windows.SendMessage(Address.MessageWindow, WM_COPYDATA, WPARAM(FLocalWindow), LPARAM(@CopyData));
end;

procedure TMessageProxy.SendForever;
var
  ConnectionMessage: TConnectionMessage;
  Connection: TConnection;
begin
  while not Terminated do
  begin
    ConnectionMessage := FOutput.Take;
    if Terminated then
      Exit;

    try
      Connection := RequireConnection(ConnectionMessage.Address);
      if (ConnectionMessage.Pdu = '') or not SendMessage(Connection.Address, ConnectionMessage.Pdu) then
        Connection.Input.Put(''); // poison pill
    except
      on ENoSuchElementException do
      begin
{$IFDEF LOGGING}
        TLogLogger.GetLogger(ClassName).Info(Format('Connection not found, failed to send the message: %s',
            [ConnectionMessage.Pdu]));
{$ENDIF}
      end;
    end;
  end;
end;

end.
