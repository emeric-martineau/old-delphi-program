object Form1: TForm1
  Left = 192
  Top = 114
  Width = 490
  Height = 237
  Caption = 'Form1'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  DesignSize = (
    482
    203)
  PixelsPerInch = 96
  TextHeight = 13
  object ListView1: TListView
    Left = 16
    Top = 16
    Width = 449
    Height = 177
    Anchors = [akLeft, akTop, akRight, akBottom]
    Columns = <>
    FullDrag = True
    TabOrder = 0
    OnCustomDrawItem = ListView1CustomDrawItem
  end
end
