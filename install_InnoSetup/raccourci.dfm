object ShortCutForm: TShortCutForm
  Left = 379
  Top = 283
  BorderStyle = bsToolWindow
  Caption = 'Raccourci'
  ClientHeight = 183
  ClientWidth = 311
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 3
    Top = 48
    Width = 31
    Height = 13
    Caption = 'Fichier'
    Transparent = True
  end
  object ShortCutName: TLabeledEdit
    Left = 3
    Top = 16
    Width = 303
    Height = 21
    EditLabel.Width = 49
    EditLabel.Height = 13
    EditLabel.Caption = 'Raccourci'
    EditLabel.Transparent = True
    LabelPosition = lpAbove
    LabelSpacing = 3
    TabOrder = 0
  end
  object ComboBox1: TComboBox
    Left = 3
    Top = 64
    Width = 303
    Height = 21
    Style = csDropDownList
    ItemHeight = 13
    TabOrder = 1
  end
  object Ok: TButton
    Left = 232
    Top = 152
    Width = 75
    Height = 25
    Caption = 'Ok'
    TabOrder = 2
    OnClick = OkClick
  end
  object Annuler: TButton
    Left = 3
    Top = 152
    Width = 75
    Height = 25
    Caption = 'Annuler'
    ModalResult = 2
    TabOrder = 3
  end
  object Params: TLabeledEdit
    Left = 3
    Top = 112
    Width = 303
    Height = 21
    EditLabel.Width = 53
    EditLabel.Height = 13
    EditLabel.Caption = 'Param'#232'tres'
    EditLabel.Transparent = True
    LabelPosition = lpAbove
    LabelSpacing = 3
    TabOrder = 4
  end
end
