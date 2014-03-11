(**
 * $Id: dutil.io.device.File_.pas 747 2014-03-11 07:42:35Z QXu $
 *
 * Software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTY OF ANY KIND, either
 * express or implied. See the License for the specific language governing rights and limitations under the License.
 *)

unit dutil.io.device.File_;

interface

uses
  System.Classes;

type
  /// <summary>This service class provides methods for file operations.</summary>
  TFile = class
  public
    /// <summary>Determines whether two files contain identical contents.</summary>
    /// <exception cref="EFOpenError">When failed to open a file.</exception>
    class function ContentsEqual(const FilenameA: string; const FilenameB: string): Boolean; overload; static;
    /// <summary>Determines whether two (file or memory) streams contain identical contents.</summary>
    class function ContentsEqual(StreamA: TStream; StreamB: TStream): Boolean; overload; static;
  end;

implementation

uses
  System.SysUtils;

class function TFile.ContentsEqual(const FilenameA: string; const FilenameB: string): Boolean;
const
  OPEN_FLAG = fmOpenRead or fmShareDenyNone;
var
  FileStreamA: TFileStream;
  FileStreamB: TFileStream;
begin
  FileStreamA := TFileStream.Create(FilenameA, OPEN_FLAG);
  try
    FileStreamB := TFileStream.Create(FilenameB, OPEN_FLAG);
    try
      Result := ContentsEqual(FileStreamA, FileStreamB);
    finally
      FileStreamB.Free;
    end;
  finally
    FileStreamA.Free;
  end;
end;

class function TFile.ContentsEqual(StreamA: TStream; StreamB: TStream): Boolean;
const
  READ_BYTES_AMOUNT = 8196;
var
  FileSizeA: Int64;
  BufferA: TBytes;
  BufferB: TBytes;
  BytesReadA: Longint;
  BytesReadB: Longint;
begin
  assert(StreamA <> nil);
  assert(StreamB <> nil);

  FileSizeA := StreamA.Size;
  if FileSizeA <> StreamB.Size then
  begin
    Result := False;
    Exit;
  end;

  while StreamA.Position < FileSizeA do
  begin
    SetLength(BufferA, READ_BYTES_AMOUNT);
    SetLength(BufferB, READ_BYTES_AMOUNT);
    BytesReadA := StreamA.Read(Pointer(BufferA)^, READ_BYTES_AMOUNT);
    BytesReadB := StreamB.Read(Pointer(BufferB)^, READ_BYTES_AMOUNT);

    if (BytesReadA <> BytesReadB) or not CompareMem(Pointer(BufferA), Pointer(BufferB), BytesReadA) then
    begin
      Result := False;
      Exit;
    end;
  end;
  Result := True;
end;

end.
