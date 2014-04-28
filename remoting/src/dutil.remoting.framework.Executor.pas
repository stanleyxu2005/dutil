(**
 * $Id: dutil.remoting.framework.Executor.pas 794 2014-04-28 16:00:24Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.framework.Executor;

interface

uses
  System.TimeSpan,
  superobject { An universal object serialization framework with Json support },
  dutil.remoting.framework.Command;

type
  /// <summary>This interface defines a RPC executor.</summary>
  IExecutor = interface
    /// <summary>Exeuctes a command. The current thread is blocked until response is available.</summary>
    /// <exception cref="ERPCException">RPC error (typically network issue)</exception>
    function ExecuteAwait(Command: TCommand): ISuperObject; overload;
    /// <summary>Exeuctes a command. The current thread is blocked until response is available or timed out.</summary>
    /// <exception cref="ERPCException">RPC error (typically network issue)</exception>
    function ExecuteAwait(Command: TCommand; const Timeout: TTimeSpan): ISuperObject; overload;
    /// <summary>Sends a notification and then returns immediately without any delivery garantee.</summary>
    procedure Notify(Command: TCommand);
  end;

implementation

end.
