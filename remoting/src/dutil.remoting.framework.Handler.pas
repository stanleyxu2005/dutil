(**
 * $Id: dutil.remoting.framework.Handler.pas 794 2014-04-28 16:00:24Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.framework.Handler;

interface

uses
  superobject { An universal object serialization framework with Json support },
  dutil.remoting.framework.Command;

type
  THandleNotificationMethod = procedure(const Params: ISuperObject) of object;
  THandleRequestMethod = procedure(const Params: ISuperObject; out Result: ISuperObject) of object;

type
  /// <summary>This interface defines a RPC handler.</summary>
  IHandler = interface
    /// <summary>Returns the identifier of the object.</summary>
    function GetId: string;
    /// <summary>Pushs a protocol specific message to handling queue.</summary>
    procedure Write(const Message_: string);
    /// <summary>Registers a notification handler.</summary>
    procedure AddNotificationHandler(Command: TCommand.TClassReference; Method: THandleNotificationMethod);
    /// <summary>Registers a request handler.</summary>
    procedure AddRequestHandler(Command: TCommand.TClassReference; Method: THandleRequestMethod);
  end;

implementation

end.
