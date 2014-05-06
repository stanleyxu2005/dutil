object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsSingle
  Caption = 'Controller'
  ClientHeight = 170
  ClientWidth = 323
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 13
  object Button2: TButton
    Left = 16
    Top = 32
    Width = 129
    Height = 33
    Caption = 'Resize to 100x100'
    TabOrder = 0
    OnClick = Button2Click
  end
  object Button3: TButton
    Left = 16
    Top = 71
    Width = 129
    Height = 34
    Caption = 'Resize to 200x200'
    TabOrder = 1
    OnClick = Button3Click
  end
  object LabeledEdit1: TLabeledEdit
    Left = 184
    Top = 44
    Width = 121
    Height = 21
    EditLabel.Width = 44
    EditLabel.Height = 13
    EditLabel.Caption = 'Top, Left'
    TabOrder = 2
  end
  object LabeledEdit2: TLabeledEdit
    Left = 184
    Top = 92
    Width = 121
    Height = 21
    EditLabel.Width = 66
    EditLabel.Height = 13
    EditLabel.Caption = 'Width, Height'
    TabOrder = 3
  end
end
