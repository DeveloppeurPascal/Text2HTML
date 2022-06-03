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
