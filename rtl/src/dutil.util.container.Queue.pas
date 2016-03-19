(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dutil.util.container.Queue;

interface

uses
  System.Generics.Collections;

type
  /// <summary>This container class holds elements in a first-in-first-out manner, where retrieving an element waits
  /// for the queue to become non-empty.</summary>
  IQueue<T> = interface
    function Count: Cardinal;
    function Take: T;
    procedure Put(const Element: T);
  end;

implementation

end.
