//Logo highlighting editor (LogoEd)
//(C)2004-2006 George Birbilis <birbilis@kagi.com>
//Version: 1.2 (24May2006)

(***************************************************************************
To compile the sources (Delphi7 version suggested) you also need
SynEdit (http://synedit.sf.net)
[for Delphi7 use synedit_d7 package from RemObjects binaries newsgroup,
see reference at RemObjects PascalScript newsgroup],
UniHighlighter (see link to that at "Third party files" section of SynEdit
home website) and JCL & JVCL (http://jcl.sf.net, http://jvcl.sf.net) 

Please give due credit at any derivative projects
***************************************************************************)

unit MainForm;

interface

uses
  Windows, SysUtils, Classes, Controls, Forms,
  Dialogs,
  StdActns, ActnList, ActnCtrls,
  ActnMan, ActnMenus, CustomizeDlg, 
  BandActn, ComCtrls,
  SynEdit,
  SynEditExport, SynExportHTML, SynExportRTF,
  SynUniHighlighter,
  SynEditRegexSearch, SynEditSearch, SynEditMiscClasses, ImgList,
  XPStyleActnCtrls, SynEditHighlighter, ToolWin, JvComponent,
  JvComponentBase, JvMRUList;

type
  TEditor = class(TForm)
    SynEdit1: TSynEdit;
    SynUniSyn1: TSynUniSyn;
    SynExporterHTML1: TSynExporterHTML;
    SynExporterRTF1: TSynExporterRTF;
    CustomizeDlg1: TCustomizeDlg;
    ActionManager1: TActionManager;
    ActionMainMenuBar1: TActionMainMenuBar;
    ActionToolBar1: TActionToolBar;
    FileOpen1: TFileOpen;
    FileExit1: TFileExit;
    FileSaveAs1: TFileSaveAs;
    FileSave1: TAction;
    EditCut1: TEditCut;
    EditCopy1: TEditCopy;
    EditPaste1: TEditPaste;
    EditSelectAll1: TEditSelectAll;
    EditDelete1: TEditDelete;
    EditUndo1: TEditUndo;
    FileNew1: TAction;
    About1: TAction;
    ImageList1: TImageList;
    CustomizeActionBars1: TCustomizeActionBars;
    StatusBar1: TStatusBar;
    SynEditSearch1: TSynEditSearch;
    SynEditRegexSearch1: TSynEditRegexSearch;
    SearchFind1: TAction;
    SearchFindNext1: TAction;
    SearchReplace1: TAction;
    SearchFindFirst1: TAction;
    SearchGoto1: TAction;
    MRUList: TJvMruList;
    procedure SynEdit1DropFiles(Sender: TObject; X, Y: Integer; AFiles: TStrings);
    procedure FormCreate(Sender: TObject);
    procedure FileExit1Hint(var HintStr: String; var CanShow: Boolean);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FileSaveAs1Accept(Sender: TObject);
    procedure FileOpen1Accept(Sender: TObject);
    procedure FileSave1Execute(Sender: TObject);
    procedure FileNew1Execute(Sender: TObject);
    procedure About1Execute(Sender: TObject);
    procedure SearchFind1Execute(Sender: TObject);
    procedure SearchReplace1Execute(Sender: TObject);
    procedure SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
    procedure SearchFindFirst1Execute(Sender: TObject);
    procedure SearchFindNext1Execute(Sender: TObject);
    procedure SearchGoto1Execute(Sender: TObject);
  private
    procedure setFilename(const Value: string);
  protected
    fSearchFromCaret:boolean;
    fFileName:string;
    procedure newFile;
    function checkSaved:boolean;
    procedure load(const filename: string);
    procedure save;
    procedure saveAsLogo(filename: string);
    procedure saveAsHTML(filename: string);
    procedure saveAsRTF(filename: string);
    procedure DoSearchReplaceText(AReplace, ABackwards: boolean);
    procedure ShowSearchReplaceDialog(AReplace: boolean);
    property CurrentFilename:string read fFilename write setFilename;
  end;

var
  Editor: TEditor;

implementation

uses
 SynEditTypes,
 uFrmGotoLine,
 dlgSearchText, dlgReplaceText, dlgConfirmReplace;

{$R *.dfm}

const
 NEWLINE=#13#10;

resourcestring
 STR_VERSION='Version 1.2';
 STR_COPYRIGHT='(C)2004-2006 George Birbilis <birbilis@kagi.com>'+NEWLINE+'http://www.kagi.com/birbilis';
 STR_SYNUNIHIGHLIGHT_FILTER='Logo.hgl';
 STR_FILE_EXT='.logo';
 STR_NOTSAVED='File has not been saved, save now?';
 STR_TEXT_NOTFOUND='Text not found';
 STR_TITLE='LogoEd';

// options - to be saved to the registry
var
  gbSearchBackwards: boolean;
  gbSearchCaseSensitive: boolean;
  gbSearchFromCaret: boolean;
  gbSearchSelectionOnly: boolean;
  gbSearchTextAtCaret: boolean;
  gbSearchWholeWords: boolean;
  gbSearchRegex: boolean;
  gsSearchText: string;
  gsSearchTextHistory: string;
  gsReplaceText: string;
  gsReplaceTextHistory: string;

//////////////////////////////////

procedure TEditor.DoSearchReplaceText(AReplace: boolean; ABackwards: boolean);
var
 Options: TSynSearchOptions;
begin
 Statusbar1.SimpleText := '';
 if AReplace then
  Options := [ssoPrompt, ssoReplace, ssoReplaceAll]
 else
  Options := [];
 if ABackwards then
  Include(Options, ssoBackwards);
 if gbSearchCaseSensitive then
  Include(Options, ssoMatchCase);
 if not fSearchFromCaret then
  Include(Options, ssoEntireScope);
 if gbSearchSelectionOnly then
  Include(Options, ssoSelectedOnly);
 if gbSearchWholeWords then
  Include(Options, ssoWholeWord);
 if gbSearchRegex then
  SynEdit1.SearchEngine := SynEditRegexSearch1
 else
  SynEdit1.SearchEngine := SynEditSearch1;
 if SynEdit1.SearchReplace(gsSearchText, gsReplaceText, Options) = 0 then
  begin
  MessageBeep(MB_ICONASTERISK);
  Statusbar1.SimpleText := STR_TEXT_NOTFOUND;
  if ssoBackwards in Options then
   SynEdit1.BlockEnd := SynEdit1.BlockBegin
  else
   SynEdit1.BlockBegin := SynEdit1.BlockEnd;
  SynEdit1.CaretXY := SynEdit1.BlockBegin;
  end;

 if ConfirmReplaceDialog <> nil then
  ConfirmReplaceDialog.Free;
end;

procedure TEditor.ShowSearchReplaceDialog(AReplace: boolean);
var
 dlg: TTextSearchDialog;
begin
 Statusbar1.SimpleText := '';
 if AReplace then
  dlg := TTextReplaceDialog.Create(Self)
 else
  dlg := TTextSearchDialog.Create(Self);
 with dlg do
  try
   // assign search options
   SearchBackwards := gbSearchBackwards;
   SearchCaseSensitive := gbSearchCaseSensitive;
   SearchFromCursor := gbSearchFromCaret;
   SearchInSelectionOnly := gbSearchSelectionOnly;
   // start with last search text
   SearchText := gsSearchText;
   if gbSearchTextAtCaret then begin
    // if something is selected search for that text
    if SynEdit1.SelAvail
       and (SynEdit1.BlockBegin.Line = SynEdit1.BlockEnd.Line) //Birb (fix at SynEdit's SearchReplaceDemo)
    then
     SearchText := SynEdit1.SelText
    else
     SearchText := SynEdit1.GetWordAtRowCol(SynEdit1.CaretXY);
  end;
  SearchTextHistory := gsSearchTextHistory;
  if AReplace then
   with dlg as TTextReplaceDialog do
    begin
    ReplaceText := gsReplaceText;
    ReplaceTextHistory := gsReplaceTextHistory;
    end;
  SearchWholeWords := gbSearchWholeWords;
  if ShowModal = mrOK then
   begin
   gbSearchBackwards := SearchBackwards;
   gbSearchCaseSensitive := SearchCaseSensitive;
   gbSearchFromCaret := SearchFromCursor;
   gbSearchSelectionOnly := SearchInSelectionOnly;
   gbSearchWholeWords := SearchWholeWords;
   gbSearchRegex := SearchRegularExpression;
   gsSearchText := SearchText;
   gsSearchTextHistory := SearchTextHistory;
   if AReplace then
    with dlg as TTextReplaceDialog do
     begin
     gsReplaceText := ReplaceText;
     gsReplaceTextHistory := ReplaceTextHistory;
     end;
   fSearchFromCaret := gbSearchFromCaret;
   if gsSearchText <> '' then
    begin
    DoSearchReplaceText(AReplace, gbSearchBackwards);
    fSearchFromCaret := TRUE;
    end;
   end;
  finally
   dlg.Free;
  end;
end;

//////////////////////////////////

procedure TEditor.setFilename(const Value: string);
begin
 fFilename := Value;
 if Value<>'' then
  caption:=ExtractFileName(Value)+' - '+STR_TITLE
 else
  caption:=STR_TITLE;
end;

function TEditor.checkSaved:boolean;
begin
 if SynEdit1.Modified then
  case MessageDlg(STR_NOTSAVED, mtConfirmation, mbYesNoCancel, 0) of
   idYes:
    result := FileSave1.Execute;
   idNo:
    result := true;
   else
    result := false;
   end
 else
  Result := True;
end;

procedure TEditor.newFile;
begin
 if checkSaved then
  begin
  SynEdit1.Lines.Clear;
  SynEdit1.Modified:=false;
  CurrentFilename:='';
  end;
end;

procedure TEditor.load(const filename:string);
begin
 if checkSaved then
  begin
  SynEdit1.Lines.LoadFromFile(filename);
  CurrentFilename:=filename;
  FileSaveAs1.Dialog.FileName:=ChangeFileExt(ExtractFileName(filename),''); //set same filename (without extension in case user wants to save as HTML or RTF) at the save dialog too
  MRUList.AddString(filename); 
  end;
end;

procedure TEditor.save;
begin
 if CurrentFilename='' then
  FileSaveAs1.Execute;
end;

procedure TEditor.saveAsLogo(filename:string);
begin
 if ExtractFileExt(filename)='' then
  filename:=ChangeFileExt(filename,STR_FILE_EXT);
 SynEdit1.Lines.SaveToFile(filename);
 SynEdit1.modified:=false; //clear "modified" flag of text editor
 CurrentFilename:=filename;
end;

procedure TEditor.saveAsHTML(filename:string);
begin
 with SynExporterHTML1 do
  try
   //Title:=...;
   Highlighter := SynUniSyn1;
   ExportAsText := TRUE;
   //CreateHTMLFragment := FALSE;
   ExportAll(SynEdit1.Lines);
   //CopyToClipboard;
   if ExtractFileExt(filename)='' then
    filename:=ChangeFileExt(filename,'.html');
   SaveToFile(filename);
  finally
  end;
end;

procedure TEditor.saveAsRTF(filename:string);
begin
 with SynExporterRTF1 do
  try
   //Title:=...;
   Highlighter := SynUniSyn1;
   ExportAsText := TRUE;
   ExportAll(SynEdit1.Lines);
   //CopyToClipboard;
   if ExtractFileExt(filename)='' then
    filename:=ChangeFileExt(filename,'.rtf');
   SaveToFile(filename);
  finally
  end;
end;

//////////////////////////////////

procedure TEditor.SynEdit1DropFiles(Sender: TObject; X, Y: Integer; AFiles: TStrings);
begin
 if AFiles.Count>=1 then
  load(AFiles[0]);
end;

procedure TEditor.FormCreate(Sender: TObject);
begin
 SynEdit1.Highlighter:=nil;
 with SynUniSyn1 do
  begin
  MainRules.Reset;
  MainRules.clear;
  DefaultFilter:=ExtractFilePath(Application.ExeName)+STR_SYNUNIHIGHLIGHT_FILTER; //make sure we don't search for the highlighter in the current folder, but in the application folder
  LoadFromFile(SynUniSyn1.DefaultFilter);
  end;
 SynEdit1.Highlighter:=SynUniSyn1;

 if paramCount<>0 then
  load(paramStr(1));
end;

procedure TEditor.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
 CanClose:=checkSaved;
end;

procedure TEditor.FileNew1Execute(Sender: TObject);
begin
 newFile;
end;

procedure TEditor.FileOpen1Accept(Sender: TObject);
begin
 load(FileOpen1.Dialog.FileName);
end;

procedure TEditor.FileSave1Execute(Sender: TObject);
begin
 save;
end;

procedure TEditor.FileSaveAs1Accept(Sender: TObject);
begin
 with FileSaveAs1.Dialog do
  case filterIndex of
   1: saveAsLogo(FileName);
   2: saveAsHTML(FileName);
   3: saveAsRTF(FileName);
   end;
end;

procedure TEditor.FileExit1Hint(var HintStr: String; var CanShow: Boolean);
begin
 Application.Terminate;
end;

procedure TEditor.SearchFind1Execute(Sender: TObject);
begin
 ShowSearchReplaceDialog(false);
end;

procedure TEditor.SearchReplace1Execute(Sender: TObject);
begin
 ShowSearchReplaceDialog(true);
end;

procedure TEditor.SynEdit1StatusChange(Sender: TObject; Changes: TSynStatusChanges);
begin
 StatusBar1.Panels[0].Text:=IntToStr(SynEdit1.CaretY)+':'+IntToStr(SynEdit1.CaretX)
end;

procedure TEditor.SearchFindFirst1Execute(Sender: TObject);
begin
 SynEdit1.CaretY:=1;
 SearchFindNext1.Execute;
end;

procedure TEditor.SearchFindNext1Execute(Sender: TObject);
begin
 DoSearchReplaceText(false, false);
end;

procedure TEditor.About1Execute(Sender: TObject);
begin
 ShowMessage(STR_COPYRIGHT+NEWLINE+NEWLINE+STR_VERSION);
end;

procedure TEditor.SearchGoto1Execute(Sender: TObject);
begin
 with TfrmGotoLine.Create(self) do
  try
   Char := SynEdit1.CaretX;
   Line := SynEdit1.CaretY;
   ShowModal;
   if ModalResult = mrOK then
     SynEdit1.CaretXY := CaretXY;
  finally
   Free;
   SynEdit1.SetFocus;
  end;
end;

end.

