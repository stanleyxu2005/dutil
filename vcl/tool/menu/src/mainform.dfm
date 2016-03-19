object MainWindow: TMainWindow
  Left = 0
  Top = 0
  Caption = 'Menu Extent Metrics Tool'
  ClientHeight = 705
  ClientWidth = 635
  Color = 16772313
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  DesignSize = (
    635
    705)
  PixelsPerInch = 96
  TextHeight = 13
  object btnRunNoIcon: TButton
    Left = 503
    Top = 461
    Width = 116
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = 'Test NoIcon'
    TabOrder = 0
    OnClick = btnRunNoIconClick
  end
  object lbResults: TListBox
    Left = 25
    Top = 484
    Width = 472
    Height = 205
    BorderStyle = bsNone
    ItemHeight = 13
    TabOrder = 1
  end
  object btnRunIcon16: TButton
    Left = 503
    Top = 500
    Width = 116
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = 'Test Icon16'
    TabOrder = 2
    OnClick = btnRunIcon16Click
  end
  object btnRunIcon18: TButton
    Left = 503
    Top = 539
    Width = 116
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = 'Test Icon18'
    TabOrder = 3
    OnClick = btnRunIcon18Click
  end
  object btnRunIcon13: TButton
    Left = 503
    Top = 617
    Width = 116
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = 'Test Icon13'
    TabOrder = 4
    OnClick = btnRunIcon13Click
  end
  object btnRunIcon12: TButton
    Left = 503
    Top = 656
    Width = 116
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = 'Test Icon12'
    TabOrder = 5
    OnClick = btnRunIcon12Click
  end
  object btnRunIcon15: TButton
    Left = 503
    Top = 578
    Width = 116
    Height = 33
    Anchors = [akRight, akBottom]
    Caption = 'Test Icon15'
    TabOrder = 6
    OnClick = btnRunIcon15Click
  end
  object cbVerifyResults: TCheckBox
    Left = 25
    Top = 461
    Width = 472
    Height = 17
    Caption = 'Verify measured results using MenuExtent module'
    Checked = True
    State = cbChecked
    TabOrder = 7
  end
  object tmTakeScreenShotAndCloseMenu: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tmTakeScreenShotAndCloseMenuTimer
    Left = 24
    Top = 576
  end
  object tmMethodExecuter: TTimer
    Enabled = False
    Interval = 200
    OnTimer = tmMethodExecuterTimer
    Left = 24
    Top = 528
  end
end
