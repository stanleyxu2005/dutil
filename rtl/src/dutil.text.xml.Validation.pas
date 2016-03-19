(**
 * Software distributed under the MIT License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)
unit dutil.text.xml.Validation;

interface

uses
  System.Generics.Collections,
  NativeXml; {$I simdesign.inc}

type
  /// <summary>This service class provides methods for simple XML validity checks.</summary>
  TValidation = class
  public
    /// <summary>Checks whether the name of the XML element matches the specified name.</summary>
    /// <exception cref="EXmlException">Validity violation.</exception>
    class procedure RequireElement(Node: TXmlNode; const Name: string); static;
    /// <summary>Checks whether the XML element has exactly one child element of the specified name.</summary>
    /// <exception cref="EXmlException">Validity violation.</exception>
    class function RequireChild(Node: TXmlNode; const Name: string): TXmlNode; static;
    /// <summary>Checks whether the XML element has at least one child element of the specified name.</summary>
    /// <exception cref="EXmlException">Validity violation.</exception>
    class function RequireChildren(Node: TXmlNode; const Name: string): TList<TXmlNode>; static;
    /// <summary>Checks whether the XML element has an attribute with the specified name.</summary>
    /// <exception cref="EXmlException">Validity violation.</exception>
    class function RequireStr(Node: TXmlNode; const Name: string): string; static;
    /// <summary>Checks whether the content of the XML element represents a boolean value.</summary>
    /// <exception cref="EXmlException">Validity violation.</exception>
    class function RequireBool(Node: TXmlNode; const Name: string): Boolean; static;
    /// <summary>Checks whether the content of the XML element represents an integer value.</summary>
    /// <exception cref="EXmlException">Validity violation.</exception>
    class function RequireInt(Node: TXmlNode; const Name: string): Integer; static;
    /// <summary>Checks whether the content of the XML element represents a non-negative integer value.</summary>
    /// <exception cref="EXmlException">Validity violation.</exception>
    class function RequireUInt(Node: TXmlNode; const Name: string): Cardinal; static;
  end;

implementation

uses
  System.Classes,
  System.SysUtils,
  dutil.core.Exception,
  dutil.text.Convert;

class procedure TValidation.RequireElement(Node: TXmlNode; const Name: string);
begin
  assert(Node <> nil);

  if Node.Name <> Name then
    raise EXmlException.CreateFmt('element ''%s'': unexpected element (expected is ''%s'')', [Node.name, Name]);
end;

class function TValidation.RequireChild(Node: TXmlNode; const Name: string): TXmlNode;
var
  Children: TList<TXmlNode>;
begin
  assert(Node <> nil);
  Result := nil;

  Children := TValidation.RequireChildren(Node, Name);
  try
    if Children.Count > 1 then
      raise EXmlException.CreateFmt('element ''%s'': unexpected extra child element ''%s''', [Node.name, Name]);

    Result := Children[0];
  finally
    Children.Free;
  end;
end;

class function TValidation.RequireChildren(Node: TXmlNode; const Name: string): TList<TXmlNode>;
var
  Children: TList;
  ChildNode: Pointer;
begin
  assert(Node <> nil);
  Result := nil;

  Children := TList.Create;
  try
    Node.FindNodes(Name, Children);

    if Children.Count = 0 then
      raise EXmlException.CreateFmt('element ''%s'': unexpected child element ''%s'' is missing', [Node.name, Name]);

    Result := TList<TXmlNode>.Create;
    for ChildNode in Children do
      Result.Add(ChildNode);
  finally
    Children.Free;
  end;
end;

class function TValidation.RequireStr(Node: TXmlNode; const Name: string): string;
var
  Attribute: TsdAttribute;
begin
  assert(Node <> nil);

  Attribute := Node.AttributeByName[Name];
  if Attribute = nil then
    raise EXmlException.CreateFmt('element ''%s'': equired attribute ''%s'' is missing', [Node.name, Name]);

  Result := Attribute.Value;
end;

class function TValidation.RequireBool(Node: TXmlNode; const Name: string): Boolean;
var
  Value: string;
begin
  assert(Node <> nil);

  Value := RequireStr(Node, Name);
  try
    Result := StrToBool(Value);
  except
    on EConvertError do
      raise EXmlException.CreateFmt('element ''%s'', attribute ''%s'': ''%s''', [Node.name, Name]);
  end;
end;

class function TValidation.RequireInt(Node: TXmlNode; const Name: string): Integer;
var
  Value: string;
begin
  assert(Node <> nil);

  Value := RequireStr(Node, Name);
  try
    Result := StrToInt(Value);
  except
    on EConvertError do
      raise EXmlException.CreateFmt('element ''%s'', attribute ''%s'': ''%s''', [Node.name, Name]);
  end;
end;

class function TValidation.RequireUInt(Node: TXmlNode; const Name: string): Cardinal;
var
  Value: string;
begin
  assert(Node <> nil);

  Value := RequireStr(Node, Name);
  try
    Result := TConvert.StrToUInt(Value);
  except
    on EConvertError do
      raise EXmlException.CreateFmt('element ''%s'', attribute ''%s'': ''%s''', [Node.name, Name]);
  end;
end;

end.
