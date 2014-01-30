(**
 * $Id: dutil.net.jsonrpc.framework.NotificationHandler.pas 738 2014-01-30 08:08:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.net.jsonrpc.framework.NotificationHandler;

interface

uses
  superobject { An universal object serialization framework with Json support };

type
  /// <summary>This interface defines the obligation to handle JSON-RPC notifications.</summary>
  INotificationHandler = interface
    procedure HandleNotification(const Method: string; const Params: ISuperObject);
  end;

implementation

end.
