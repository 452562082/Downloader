object FFrmMain: TFFrmMain
  Left = 439
  Top = 219
  BorderIcons = [biSystemMenu, biMinimize]
  ClientHeight = 254
  ClientWidth = 487
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesigned
  OnClose = FormClose
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  OnResize = FormResize
  PixelsPerInch = 96
  TextHeight = 13
  object wb2: TEmbeddedWB
    Left = 8
    Top = 8
    Width = 57
    Height = 49
    TabOrder = 0
    Visible = False
    Silent = False
    OnNewWindow3 = wb2NewWindow3
    DisableCtrlShortcuts = 'N'
    UserInterfaceOptions = [DisableTextSelect, DisableHelpMenu, DontUse3DBorders, DontUseScrollBars, EnablesFormsAutoComplete, EnableThemes]
    DisabledPopupMenus = [rcmAll]
    About = ' EmbeddedWB http://bsalsa.com/'
    PrintOptions.Margins.Left = 19.050000000000000000
    PrintOptions.Margins.Right = 19.050000000000000000
    PrintOptions.Margins.Top = 19.050000000000000000
    PrintOptions.Margins.Bottom = 19.050000000000000000
    PrintOptions.HTMLHeader.Strings = (
      '<HTML></HTML>')
    PrintOptions.Orientation = poPortrait
    ControlData = {
      4C000000E4050000100500000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E12620A000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object wb3: TEmbeddedWB
    Left = 136
    Top = 72
    Width = 105
    Height = 137
    TabOrder = 1
    Visible = False
    DisableCtrlShortcuts = 'N'
    UserInterfaceOptions = [EnablesFormsAutoComplete, EnableThemes]
    About = ' EmbeddedWB http://bsalsa.com/'
    PrintOptions.Margins.Left = 19.050000000000000000
    PrintOptions.Margins.Right = 19.050000000000000000
    PrintOptions.Margins.Top = 19.050000000000000000
    PrintOptions.Margins.Bottom = 19.050000000000000000
    PrintOptions.HTMLHeader.Strings = (
      '<HTML></HTML>')
    PrintOptions.Orientation = poPortrait
    ControlData = {
      4C000000DA0A0000290E00000000000000000000000000000000000000000000
      000000004C000000000000000000000001000000E0D057007335CF11AE690800
      2B2E126208000000000000004C0000000114020000000000C000000000000046
      8000000000000000000000000000000000000000000000000000000000000000
      00000000000000000100000000000000000000000000000000000000}
  end
  object tmrTask: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tmrTaskTimer
    Left = 16
    Top = 72
  end
  object aplctnvnts1: TApplicationEvents
    Left = 16
    Top = 128
  end
  object pm1: TPopupMenu
    Left = 96
    Top = 24
    object N1: TMenuItem
      Caption = #25171#24320#20027#31243#24207
      OnClick = N1Click
    end
    object N2: TMenuItem
      Caption = '-'
    end
    object N3: TMenuItem
      Caption = #36864#20986#31243#24207
      OnClick = N3Click
    end
  end
end
