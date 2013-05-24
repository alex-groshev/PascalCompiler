object MainForm: TMainForm
  Left = 167
  Top = 174
  Width = 708
  Height = 458
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Compiler'
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'MS Sans Serif'
  Font.Style = []
  Menu = MainMenu
  OldCreateOrder = False
  Position = poDesktopCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Splitter: TSplitter
    Left = 0
    Top = 318
    Width = 700
    Height = 3
    Cursor = crVSplit
    Align = alTop
  end
  object ToolBar: TToolBar
    Left = 0
    Top = 0
    Width = 700
    Height = 26
    AutoSize = True
    Caption = 'ToolBar'
    EdgeBorders = [ebTop, ebBottom]
    Flat = True
    Images = ImageList
    TabOrder = 0
    object ToolButton1: TToolButton
      Left = 0
      Top = 0
      Width = 8
      Caption = 'ToolButton1'
      Style = tbsSeparator
    end
    object btnNew: TToolButton
      Left = 8
      Top = 0
      Action = acNew
      ImageIndex = 0
    end
    object btnOpen: TToolButton
      Left = 31
      Top = 0
      Action = acOpen
      ImageIndex = 1
    end
    object btnSave: TToolButton
      Left = 54
      Top = 0
      Action = acSave
      ImageIndex = 3
    end
    object ToolButton4: TToolButton
      Left = 77
      Top = 0
      Width = 8
      Caption = 'ToolButton4'
      ImageIndex = 1
      Style = tbsSeparator
    end
    object btnCompile: TToolButton
      Left = 85
      Top = 0
      Action = acCompile
      ImageIndex = 2
    end
  end
  object Memo: TMemo
    Left = 0
    Top = 26
    Width = 700
    Height = 292
    Align = alTop
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -13
    Font.Name = 'Courier New'
    Font.Style = []
    ParentFont = False
    ScrollBars = ssBoth
    TabOrder = 1
  end
  object ListBox: TListBox
    Left = 0
    Top = 321
    Width = 700
    Height = 91
    Align = alClient
    Font.Charset = DEFAULT_CHARSET
    Font.Color = clWindowText
    Font.Height = -11
    Font.Name = 'Courier New'
    Font.Style = []
    ItemHeight = 14
    ParentFont = False
    TabOrder = 2
  end
  object ActionList: TActionList
    Left = 624
    Top = 352
    object acExit: TAction
      Caption = 'E&xit'
      ShortCut = 32856
      OnExecute = acExitExecute
    end
    object acCompile: TAction
      Caption = 'Compile'
      ShortCut = 120
      OnExecute = acCompileExecute
    end
    object acOpen: TAction
      Caption = 'Open'
      ShortCut = 16463
      OnExecute = acOpenExecute
    end
    object acNew: TAction
      Caption = 'New'
      ShortCut = 16462
      OnExecute = acNewExecute
    end
    object acSave: TAction
      Caption = 'Save'
      ShortCut = 16467
      OnExecute = acSaveExecute
    end
  end
  object MainMenu: TMainMenu
    Left = 632
    Top = 312
    object mmiFile: TMenuItem
      Caption = '&File'
      object New1: TMenuItem
        Action = acNew
      end
      object Open1: TMenuItem
        Action = acOpen
      end
      object Save1: TMenuItem
        Action = acSave
      end
      object N1: TMenuItem
        Caption = '-'
      end
      object mmiExit: TMenuItem
        Action = acExit
      end
    end
    object mmiView: TMenuItem
      Caption = '&View'
      object mmiCode: TMenuItem
        Caption = 'Code'
        ShortCut = 49219
        OnClick = mmiCodeClick
      end
      object mmiScopes: TMenuItem
        Caption = 'Scopes'
        ShortCut = 49235
        OnClick = mmiScopesClick
      end
      object mmiSymboltable: TMenuItem
        Caption = 'Symbol table'
        ShortCut = 49236
        OnClick = mmiSymboltableClick
      end
    end
    object mmiProject: TMenuItem
      Caption = '&Project'
      object Compile1: TMenuItem
        Action = acCompile
      end
    end
  end
  object ImageList: TImageList
    Left = 552
    Top = 352
    Bitmap = {
      494C010104000900040010001000FFFFFFFFFF10FFFFFFFFFFFFFFFF424D3600
      0000000000003600000028000000400000003000000001001000000000000018
      000000000000000000000000000000000000B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B5560000000000000000
      000000000000000000000000000000000000B556B556B5560000B5560000B556
      0000B5560000B5560000B5560000B55600000000000000000000000000000000
      00000000000000000000B556B556B556B5560000000000000000000000000000
      00000000000000000000000000000000B556B556B556B5560000B5565A6BB556
      5A6BB5565A6BB5565A6BB5565A6BB5560000B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B5560000B556E07FB556E07FB556E07F
      B556E07FB556E07F0000B556B556B556B5560000B556E07FB556E07FB556E07F
      B556E07FB556E07FB556E07FB5560000B556B556B556B55600005A6B00000000
      00000000000000000000000000005A6B0000B556B556B5560000B556B5560000
      B5560000B5560000B5560000B556B55600000000E07FB556E07FB556E07FB556
      E07FB556E07FB5560000B556B556B556B5560000E07FB556E07FB556E07FB556
      E07FB556E07FB556E07FB556E07F0000B556B556B556B5560000B5565A6B5A6B
      5A6B5A6B5A6B5A6B5A6B5A6B5A6BB5560000B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B5560000B556E07FB556E07FB556E07F
      B556E07FB556E07F0000B556B556B556B5560000B556E07FB556E07F00000000
      0000000000000000B556E07FB5560000B556B556B556B55600005A6B00000000
      00000000000000000000000000005A6B0000B556B556B5560000B556B5560000
      B5560000B5560000B5560000B556B55600000000E07FB556E07FB556E07FB556
      E07FB556E07FB5560000B556B556B556B5560000E07FB556E07FB5560000B556
      E07FB556E07FB556E07FB556E07F0000B5560000B556B5560000B5565A6B5A6B
      5A6B5A6B5A6B5A6B5A6B5A6B5A6BB5560000B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B5560000B556E07FB556E07FB556E07F
      B556E07FB556E07F0000B556B5560000B5560000B556E07FB556E07F0000E07F
      B556E07FB556E07FB556E07FB5560000B556B5560000B55600005A6B00005A6B
      B5565A6BB5565A6BE001E001E0015A6B0000B556B556B5560000B556B556B556
      B556B556B5560000B5560000B556B55600000000E07FB556E07FB556E07FB556
      E07FB556E07FB5560000B5560000B556B5560000E07FB5560000000000000000
      0000B556E07FB556E07FB556E07F0000B556B556B5560000000000005A6BB556
      5A6BB5565A6BB556E003E003E003B5560000007C007CB556B556007C007CB556
      B556B556B556B556B556B556B556B556B5560000B556E07FB556E07FB556E07F
      B556E07FB556E07F00000000B556B556B5560000B556E07FB556000000000000
      B556E07FB556E07FB556E07FB5560000B55600000000B556B556000000000000
      000000000000000000000000000000000000B556007C007C007C007CB556B556
      0000B5560000B5560000B5560000B55600000000000000000000000000000000
      0000000000000000B556B5560000B55600000000E07FB556E07FB5560000B556
      E07FB556E07FB556E07FB556E07F0000B556B556B5560000B5560000B556B556
      B556B556B556B556B556B556B556B556B556B556B556007C007CB556B556B556
      B556B556B556B556B556B556B556B556B556B5560000E07FB556E07FB5560000
      B556B556B5560000B5560000B556B556B5560000B556E07FB556E07FB556E07F
      B556E07FB556E07FB556E07FB5560000B556B5560000B5560000B5560000B556
      B556B556B556B556B556B556B556B556B556B556007C007C007C007CB556B556
      B556B556B556B556B556B556B556B556B556B556B5560000000000000000B556
      B556B5560000B5560000B5560000B556B5560000000000000000000000000000
      0000000000000000000000000000B556B5560000B556B556B556B556B5560000
      B556B556B556B556B556B556B556B556B556007C007CB556B556007C007CB556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B5560000B556B556B556B556B5560000B556B5560000E07FB556E07FB556E07F
      0000B556B556B556B556B556B556B556B556B556B556B5560000B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B5560000B556B556B556B556B556B55600000000000000000000
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B5560000B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B5560000B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B5560F000F000F000F00
      B556B556B556B556B556B556003CB556B5560F000F000F000F000F000F000F00
      0F000F00B556B556B556B556003CB556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556003CB556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556003CB556B556B556B5560F000F00B556B5560F00
      0F00B556B556B556B556003C003C003CB5560F005A6B5A6B5A6B5A6B5A6B5A6B
      5A6B0F00B556B556B556003C003C003CB556B556B556B556B556B556B556B556
      B556B556B556B556B556003C003C003CB5560F000F000F000F000F000F000F00
      0F00B556B556B556B556003C003C003CB556B556B5560F000F00B556B556B556
      B556B556B556B556003C003C003C003C003C0F005A6B5A6B5A6B5A6B5A6B5A6B
      5A6B0F00B556B556003C003C003C003C003CB556B556B556B556B556B556B556
      B556B556B556B556003C003C003C003C003C0F005A6B5A6B5A6B5A6B5A6B5A6B
      0F00B556B556B556003C003C003C003C003CB556B5560F000F000F000F000F00
      0F00B556B556B556B556B556003CB556B5560F005A6B5A6B5A6B5A6B5A6B5A6B
      5A6B0F00B556B556B556B556003CB556B556B556000000000000000000000000
      000000000000B556B556B556003CB556B5560F005A6B5A6B5A6B5A6B5A6B5A6B
      0F00B556B556B556B556B556003CB556B556B556B5560F000F00B556B5560F00
      0F00B556B556B556B556B556003CB556B5560F005A6B5A6B5A6B5A6B5A6B5A6B
      5A6B0F00B556B556B556B556003CB556B5560000000000000000000000000000
      000000000000B556B556B556003CB556B5560F005A6B5A6B5A6B5A6B5A6B5A6B
      0F000F000F000F00B556B556003CB556B556B556B556B5560F000F000F000F00
      B556B556B556B556B556B556003CB556B5560F005A6B5A6B5A6B5A6B5A6B5A6B
      5A6B0F00B556B556B556B556003CB556B55600005A6B5A6B5A6B5A6B5A6B5A6B
      5A6B00000000B556B556B556003CB556B5560F005A6B5A6B5A6B5A6B5A6B5A6B
      0F00E07F5A6B0F00B556B556003CB556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556003CB556B5560F005A6B5A6B5A6B5A6B5A6B5A6B
      5A6B0F00B556B556B556B556003CB556B55600005A6B5A6B007C5A6B007C007C
      5A6B00000000B556B556B556003CB556B5560F005A6B5A6B5A6B5A6B5A6B5A6B
      0F005A6BE07F0F00B556B556003CB556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556003CB556B5560F005A6B5A6B5A6B5A6B5A6B5A6B
      5A6B0F00B556B556B556B556003CB556B55600005A6B5A6B007C5A6B007C5A6B
      5A6B00000000B556B556B556003CB556B5560F005A6B5A6B5A6B0F000F000F00
      0F00E07F5A6B0F00B556B556003CB556B556B556B556B5560F000F000F000F00
      0F00B556B556B556B556B556003CB556B5560F000F000F000F000F000F000F00
      0F000F00B556B556B556B556003CB556B55600005A6B007C007C5A6B5A6B007C
      5A6B00000000B556B556B556003CB556B5560F005A6B5A6B5A6B0F005A6B0F00
      E07F5A6BE07F0F00B556B556003CB556B556B556B5560F000F00B556B5560F00
      0F00B556B556B556B556B556003CB556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556003CB556B55600005A6B5A6B007C5A6B007C007C
      5A6B00000000B556B556B556003CB556B5560F005A6B5A6B5A6B0F000F00E07F
      5A6BE07F5A6B0F00B556B556003CB556B556B556B5560F000F00B556B5560F00
      0F00B556B556B556B556B556003CB556B556B556B556B556B556B5560F000F00
      0F000F00B556B556B556B556003CB556B55600005A6B5A6B5A6B5A6B5A6B5A6B
      5A6B00000000B556B556B556003CB556B5560F000F000F000F000F00E07F5A6B
      0F000F000F000F00B556B556003CB556B556B556B556B5560F000F000F000F00
      0F00B556B556B556B556B556003CB556B556B556B556B556B556B5560F005A6B
      5A6B0F00B556B556B556B556003CB556B5560000000000000000000000000000
      000000000000B556B556B556003CB556B556B556B556B5560F00E07F5A6BE07F
      0F00E07F0F00B556B556B556003CB556B556B556B556B556B556B556B5560F00
      0F00B556B556B556B556B556003CB556B556B556B556B556B556B5560F005A6B
      5A6B0F00B556B556B556B556003CB556B5560000007C007C007C007C007C007C
      007C00000000B556B556B556003CB556B556B556B556B5560F005A6BE07F5A6B
      0F000F00B556B556B556B556003CB556B556B556B556B5560F000F000F000F00
      B556B556B556B556B556B556003CB556B556B556B556B556B556B5560F000F00
      0F000F00B556B556B556B556003CB556B5560000000000000000000000000000
      00000000B556B556B556B556003CB556B556B556B556B5560F000F000F000F00
      0F00B556B556B556B556B556003CB556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556B556
      B556B556B556B556B556B556B556B556B5560000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      007C007C00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      007C007C000000000000000000000000000000000000E03DE03D000000000000
      000000000000000000000000E03D000000000000000000000000FF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7F00000000000000000000000000000000F75EE07FF75E
      E07FF75EE07FF75EE07FF75E0000000000000000000000000000000000000000
      00000000000000000000000000000000000000000000E03DE03D000000000000
      000000000000000000000000E03D000000000000000000000000FF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7F0000000000000000000000000000E07F0000F75EE07F
      F75EE07FF75EE07FF75EE07FF75E000000000000000000000000000000000000
      007C007C000000000000000000000000000000000000E03DE03D000000000000
      000000000000000000000000E03D000000000000000000000000FF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7F0000000000000000000000000000E07FE07F0000F75E
      E07FF75EE07FF75EE07FF75EE07FF75E00000000000000000000000000000000
      007C007C000000000000000000000000000000000000E03DE03D000000000000
      000000000000000000000000E03D000000000000000000000000FF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7F0000000000000000000000000000E07FE07FE07F0000
      0000000000000000000000000000000000000000000000000000000000000000
      007C007C000000000000000000000000000000000000E03DE03DE03DE03DE03D
      E03DE03DE03DE03DE03DE03DE03D000000000000000000000000FF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7F0000000000000000000000000000E07FE07FE07FE07F
      E07FE07FE07FE07F000000000000000000000000000000000000000000000000
      007C007C000000000000000000000000000000000000E03DE03D000000000000
      00000000000000000000E03DE03D000000000000000000000000FF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7F0000000000000000000000000000E07FE07FE07FE07F
      E07FE07FE07FE07F000000000000000000000000000000000000000000000000
      007C007C000000000000000000000000000000000000E03D0000000000000000
      000000000000000000000000E03D000000000000000000000000FF7FFF7FFF7F
      FF7FFF7FFF7FFF7FFF7F0000000000000000000000000000E07FE07FE07F0000
      0000000000000000000000000000000000000000000000000000000000000000
      007C007C000000000000000000000000000000000000E03D0000000000000000
      000000000000000000000000E03D000000000000000000000000FF7FFF7FFF7F
      FF7FFF7F00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      007C007C000000000000000000000000000000000000E03D0000000000000000
      000000000000000000000000E03D000000000000000000000000FF7FFF7FFF7F
      FF7FFF7F0000FF7F000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      007C007C000000000000000000000000000000000000E03D0000000000000000
      000000000000000000000000E03D000000000000000000000000FF7FFF7FFF7F
      FF7FFF7F00000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      007C007C000000000000000000000000000000000000E03D0000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      007C007C000000000000000000000000000000000000E03D0000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      000000000000000000000000000000000000424D3E000000000000003E000000
      2800000040000000300000000100010000000000800100000000000000000000
      000000000000000000000000FFFFFF0000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      0000000000000000000000000000000000000000000000000000000000000000
      00000000000000000000000000000000FFFFFFFFFFFFFFFFFFFFFFFFFE7FC001
      E007C007FE7F8031E007C003FFFF8031E007C001FE7F8031E007C000FE7F8001
      E007C000FE7F8001E007C00FFE7F8001E007C00FFE7F8FF1E007C00FFE7F8FF1
      E007E3FFFE7F8FF1E00FFF1FFE7F8FF1E01FFF9FFE7F8FF1E03FFB5FFE7F8FF5
      FFFFFCFFFFFF8001FFFFFFFFFFFFFFFF00000000000000000000000000000000
      000000000000}
  end
  object OpenDialog: TOpenDialog
    Filter = 'Text Files|*.txt'
    Left = 424
    Top = 360
  end
  object SaveDialog: TSaveDialog
    Filter = 'Text Files|*.txt'
    Left = 464
    Top = 352
  end
end
