(**
 * $Id: dutil.remoting.framework.Command.pas 778 2014-04-26 10:11:29Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.remoting.framework.Command;

interface

uses
  System.Types,
  superobject { An universal object serialization framework with Json support };

type
  /// <summary>This abstract class represents the basis of a RPC command. Any RPC command should be inherited from
  /// TCommand.</summary>
  TCommand = class
  public type
    TType = (REQUEST, NOTIFICATION);
    TClassReference = class of TCommand;
  public
    class function Type_: TType; virtual; abstract;
    class function HandleInMainThread_: Boolean; virtual; abstract;
    class function Method_: string; virtual; abstract;
    function Params_: ISuperObject; virtual; abstract;
    class function CreateArray(const DynArray: TArray<string>): ISuperObject; overload; static;
    class function CreateArray(const DynArray: TArray<Boolean>): ISuperObject; overload; static;
    class function CreateArray(const DynArray: TArray<Integer>): ISuperObject; overload; static;
    class function CreateArray(const DynArray: TArray<Cardinal>): ISuperObject; overload; static;
  end;

implementation

class function TCommand.CreateArray(const DynArray: TArray<String>): ISuperObject;
var
  Item: string;
begin
  Result := TSuperObject.Create(stArray);
  for Item in DynArray do
    Result.AsArray.Add(SO(Item));
end;

class function TCommand.CreateArray(const DynArray: TArray<Boolean>): ISuperObject;
var
  Item: Boolean;
begin
  Result := TSuperObject.Create(stArray);
  for Item in DynArray do
    Result.AsArray.Add(SO(Item));
end;

class function TCommand.CreateArray(const DynArray: TArray<Cardinal>): ISuperObject;
var
  Item: Cardinal;
begin
  Result := TSuperObject.Create(stArray);
  for Item in DynArray do
    Result.AsArray.Add(SO(Item));
end;

class function TCommand.CreateArray(const DynArray: TArray<Integer>): ISuperObject;
var
  Item: Integer;
begin
  Result := TSuperObject.Create(stArray);
  for Item in DynArray do
    Result.AsArray.Add(SO(Item));
end;

end.
