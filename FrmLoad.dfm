object FFrmLoad: TFFrmLoad
  Left = 0
  Top = 0
  BorderStyle = bsNone
  ClientHeight = 149
  ClientWidth = 221
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object tmr1: TTimer
    Enabled = False
    Interval = 500
    OnTimer = tmr1Timer
    Left = 8
    Top = 104
  end
  object aplctnvnts1: TApplicationEvents
    Left = 48
    Top = 104
  end
end
