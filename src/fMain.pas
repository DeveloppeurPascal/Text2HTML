(* C2PP
  ***************************************************************************

  Text2HTML

  Copyright 2022-2025 Patrick PREMARTIN under AGPL 3.0 license.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
  THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
  DEALINGS IN THE SOFTWARE.

  ***************************************************************************

  Author(s) :
  Patrick PREMARTIN

  Site :
  https://text2html.olfsoftware.fr

  Project site :
  https://github.com/DeveloppeurPascal/Text2HTML

  ***************************************************************************
  File last update : 2025-10-16T10:43:07.914+02:00
  Signature : f4ba86ce1c2738b17befbe86d673f22b94c1e275
  ***************************************************************************
*)

unit fMain;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Memo.Types,
  FMX.StdCtrls, FMX.Controls.Presentation, FMX.ScrollBox, FMX.Memo;

type
  TfrmMain = class(TForm)
    mmoSource: TMemo;
    btnExecute: TButton;
    mmoDestination: TMemo;
    procedure mmoSourceClick(Sender: TObject);
    procedure mmoDestinationClick(Sender: TObject);
    procedure btnExecuteClick(Sender: TObject);
  private
    procedure StartTag(HTMLTag: string; var HTMLTagOpen: boolean;
      NewLine: boolean = true);
    procedure StopTag(HTMLTag: string; var HTMLTagOpen: boolean);
    procedure AddText(S: string; NewLine: boolean = true);
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  frmMain: TfrmMain;

implementation

{$R *.fmx}

procedure TfrmMain.StartTag(HTMLTag: string; var HTMLTagOpen: boolean;
  NewLine: boolean);
begin
  if HTMLTagOpen then
    StopTag(HTMLTag, HTMLTagOpen);
  HTMLTagOpen := true;
  AddText('<' + HTMLTag + '>', NewLine);
end;

procedure TfrmMain.StopTag(HTMLTag: string; var HTMLTagOpen: boolean);
begin
  if HTMLTagOpen then
  begin
    AddText('</' + HTMLTag + '>', false);
    HTMLTagOpen := false;
  end;
end;

procedure TfrmMain.AddText(S: string; NewLine: boolean);
begin
  if NewLine then
    mmoDestination.lines.add(S)
  else
    mmoDestination.lines[mmoDestination.lines.Count - 1] := mmoDestination.lines
      [mmoDestination.lines.Count - 1] + S;
end;

procedure TfrmMain.btnExecuteClick(Sender: TObject);
var
  PTag: boolean;
  ULTag: boolean;
  LITag: boolean;
  i: integer;
  S: string;
begin
  mmoDestination.lines.Clear;
  PTag := false;
  ULTag := false;
  LITag := false;
  for i := 0 to mmoSource.lines.Count - 1 do
  begin
    S := mmoSource.lines[i];
    if (S.IsEmpty) then
    begin
      StopTag('li', LITag);
      StopTag('ul', ULTag);
      StopTag('p', PTag);
    end
    else if (S.StartsWith('- ')) then
    begin
      if not ULTag then
      begin
        StopTag('p', PTag);
        StartTag('ul', ULTag);
      end
      else
        StopTag('li', LITag);
      StartTag('li', LITag);
      AddText(S.Substring(2), false);
    end
    else
    begin
      if PTag then
      begin
        AddText('<br>', false);
        AddText(S);
      end
      else
      begin
        StopTag('li', LITag);
        StopTag('ul', ULTag);
        StartTag('p', PTag);
        AddText(S, false);
      end;
    end;
  end;
  StopTag('li', LITag);
  StopTag('ul', ULTag);
  StopTag('p', PTag);
  if not mmoDestination.Text.IsEmpty then
  begin
    mmoDestination.SelectAll;
    mmoDestination.CopyToClipboard;
    showMessage('HTML source copied to the clipboard.');
  end;
end;

procedure TfrmMain.mmoDestinationClick(Sender: TObject);
begin
  tthread.ForceQueue(nil,
    procedure
    begin
      mmoDestination.SelectAll;
    end);
end;

procedure TfrmMain.mmoSourceClick(Sender: TObject);
begin
  tthread.ForceQueue(nil,
    procedure
    begin
      mmoSource.SelectAll;
    end);
end;

end.
