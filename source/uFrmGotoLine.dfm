object frmGotoLine: TfrmGotoLine
  Left = 403
  Top = 547
  BorderStyle = bsDialog
  Caption = 'Go to Line'
  ClientHeight = 93
  ClientWidth = 438
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -14
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnShow = FormShow
  PixelsPerInch = 120
  TextHeight = 16
  object lblLineNumber: TLabel
    Left = 20
    Top = 17
    Width = 76
    Height = 16
    Caption = 'Line Number'
  end
  object lblCharNumber: TLabel
    Left = 20
    Top = 58
    Width = 96
    Height = 16
    Caption = 'Column Number'
  end
  object edtCharNumber: TEdit
    Left = 148
    Top = 53
    Width = 149
    Height = 24
    TabOrder = 1
  end
  object edtLineNumber: TEdit
    Left = 148
    Top = 12
    Width = 149
    Height = 24
    TabOrder = 0
  end
  object Button1: TButton
    Left = 335
    Top = 50
    Width = 92
    Height = 31
    Cancel = True
    Caption = 'Cancel'
    ModalResult = 2
    TabOrder = 3
  end
  object btnGoto: TButton
    Left = 335
    Top = 9
    Width = 92
    Height = 31
    Caption = 'Go to'
    Default = True
    ModalResult = 1
    TabOrder = 2
  end
end
