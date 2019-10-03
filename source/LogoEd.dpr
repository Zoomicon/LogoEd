//Logo highlighting editor (LogoEd)
//(C)2004-2019 George Birbilis <birbilis@zoomicon.com>

program LogoEd;

{%ToDo 'LogoEd.todo'}

uses
  Forms,
  MainForm in 'MainForm.pas' {Editor},
  dlgConfirmReplace in 'dlgConfirmReplace.pas' {ConfirmReplaceDialog},
  dlgReplaceText in 'dlgReplaceText.pas',
  dlgSearchText in 'dlgSearchText.pas' {TextSearchDialog},
  uFrmGotoLine in 'uFrmGotoLine.pas' {frmGotoLine};

{$R *.res}

begin
  Application.Initialize;
  Application.Title := 'LogoEd';
  Application.CreateForm(TEditor, Editor);
  Application.CreateForm(TConfirmReplaceDialog, ConfirmReplaceDialog);
  Application.CreateForm(TfrmGotoLine, frmGotoLine);
  Application.Run;
end.
