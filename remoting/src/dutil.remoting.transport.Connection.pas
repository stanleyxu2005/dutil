(**
 * $Id: dutil.remoting.transport.Connection.pas 789 2014-04-27 17:37:32Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.transport.Connection;

interface

uses
  System.Types,
  superobject { An universal object serialization framework with Json support };

type
  /// <summary>This interface defines the obligation of a tranport connection.</summary>
  IConnection = interface
    /// <summary>Returns the uri of the connection.</summary>
    function GetId: string;
    /// <summary>Sends an outbound message and waits for it is actually sent out.</summary>
    function WriteEnsured(const Message_: string): Boolean;
    /// <summary>Sends an outbound message and waits for it is actually sent out.</summary>
    procedure Write(const Message_: string);
    ///
    procedure HandleRead(const Message_: string);
  end;

implementation

end.
