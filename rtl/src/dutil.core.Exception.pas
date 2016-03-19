(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dutil.core.Exception;

interface

uses
  System.SysUtils;

type
  /// <summary>Represents a text processing error.</summary>
  ETextException = class(Exception)
  end;

  /// <summary>Base class for Xml exceptions.</summary>
  EXmlException = class(ETextException)
  end;

  /// <summary>Base class for JSON exceptions.</summary>
  EJsonException = class(ETextException)
  end;

  /// <summary>Base class for parsing errors.</summary>
  /// <remarks>Error means the exception can be handled or popup to top.</summary>
  EParseError = class(ETextException)
  end;

  /// <summary>Thrown on past-the-end errors by iterators and containers.</summary>
  ENoSuchElementException = class(Exception)
  end;

  /// <summary>Thrown on past-the-end errors by iterators and containers.</summary>
  EDuplicateElementException = class(Exception)
  end;

  /// <summary>The base class of RPC exception</summary>
  ERPCException = class(Exception);

implementation

end.
