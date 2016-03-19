(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dutil.core.NonRefCountedInterfacedObject;

interface

type
  /// <summary>A non-reference-counted IInterface implementation.</summary>
  TNonRefCountedInterfacedObject = class(TObject, IInterface)
  protected
    function QueryInterface(const IID: TGUID; out Obj): HResult; stdcall;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
  end;

implementation

function TNonRefCountedInterfacedObject.QueryInterface(const IID: TGUID; out Obj): HResult;
begin
  if GetInterface(IID, Obj) then
    Result := S_OK
  else
    Result := E_NOINTERFACE;
end;

function TNonRefCountedInterfacedObject._AddRef: Integer;
begin
  Result := -1;
end;

function TNonRefCountedInterfacedObject._Release: Integer;
begin
  Result := -1;
end;

end.
