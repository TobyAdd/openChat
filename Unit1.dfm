object Main: TMain
  Left = 192
  Top = 125
  BorderIcons = [biSystemMenu, biMinimize]
  BorderStyle = bsSingle
  Caption = 'openChat'
  ClientHeight = 394
  ClientWidth = 790
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
  object UpdateChatBtn: TButton
    Left = 184
    Top = 8
    Width = 89
    Height = 25
    Caption = 'Update chat'
    TabOrder = 0
    OnClick = UpdateChatBtnClick
  end
  object Button1: TButton
    Left = 706
    Top = 360
    Width = 75
    Height = 25
    Caption = 'About'
    TabOrder = 1
    OnClick = Button1Click
  end
  object CheckBox1: TCheckBox
    Left = 280
    Top = 12
    Width = 97
    Height = 17
    Caption = 'Auto update'
    TabOrder = 2
    OnClick = CheckBox1Click
  end
  object RoomsGB: TGroupBox
    Left = 8
    Top = 88
    Width = 161
    Height = 185
    Caption = 'Rooms'
    TabOrder = 3
    object RoomsLB: TListBox
      Left = 8
      Top = 24
      Width = 145
      Height = 121
      ItemHeight = 13
      TabOrder = 0
      OnClick = RoomsLBClick
    end
    object UpdateRoomsBtn: TButton
      Left = 8
      Top = 152
      Width = 65
      Height = 25
      Caption = 'Update'
      TabOrder = 1
      OnClick = UpdateRoomsBtnClick
    end
    object Button3: TButton
      Left = 80
      Top = 152
      Width = 73
      Height = 25
      Caption = 'Create room'
      TabOrder = 2
      OnClick = Button3Click
    end
  end
  object CurrentRoomGB: TGroupBox
    Left = 176
    Top = 40
    Width = 433
    Height = 345
    Caption = 'Current room'
    TabOrder = 4
    object Label2: TLabel
      Left = 8
      Top = 292
      Width = 46
      Height = 13
      Caption = 'Message:'
    end
    object SendBtn: TButton
      Left = 350
      Top = 305
      Width = 75
      Height = 25
      Caption = 'Send'
      TabOrder = 0
      OnClick = SendBtnClick
    end
    object TextEdt: TEdit
      Left = 8
      Top = 308
      Width = 257
      Height = 21
      TabOrder = 1
      OnKeyDown = TextEdtKeyDown
    end
    object Button2: TButton
      Left = 272
      Top = 304
      Width = 75
      Height = 25
      Caption = 'Image'
      TabOrder = 2
      OnClick = Button2Click
    end
    object WebBrowser1: TWebBrowser
      Left = 8
      Top = 16
      Width = 417
      Height = 265
      TabOrder = 3
      ControlData = {
        4C000000192B0000631B00000000000000000000000000000000000000000000
        000000004C000000000000000000000001000000E0D057007335CF11AE690800
        2B2E126208000000000000004C0000000114020000000000C000000000000046
        8000000000000000000000000000000000000000000000000000000000000000
        00000000000000000100000000000000000000000000000000000000}
    end
  end
  object AuthGB: TGroupBox
    Left = 616
    Top = 40
    Width = 169
    Height = 169
    Caption = 'Auth / Register'
    TabOrder = 5
    object Label1: TLabel
      Left = 8
      Top = 20
      Width = 25
      Height = 13
      Caption = 'Nick:'
    end
    object Label3: TLabel
      Left = 8
      Top = 68
      Width = 49
      Height = 13
      Caption = 'Password:'
    end
    object Label4: TLabel
      Left = 8
      Top = 144
      Width = 77
      Height = 13
      Caption = 'User not logined'
    end
    object NickEdt: TEdit
      Left = 8
      Top = 36
      Width = 153
      Height = 21
      TabOrder = 0
    end
    object PassEdt: TEdit
      Left = 8
      Top = 84
      Width = 153
      Height = 21
      PasswordChar = '*'
      TabOrder = 1
    end
    object EnterBtn: TButton
      Left = 8
      Top = 112
      Width = 75
      Height = 25
      Caption = 'Enter'
      TabOrder = 2
      OnClick = EnterBtnClick
    end
    object Button4: TButton
      Left = 88
      Top = 112
      Width = 75
      Height = 25
      Caption = 'Register'
      TabOrder = 3
      OnClick = Button4Click
    end
  end
  object GroupBox1: TGroupBox
    Left = 8
    Top = 8
    Width = 161
    Height = 73
    Caption = 'Room type'
    TabOrder = 6
    object CommonRoomsRB: TRadioButton
      Left = 8
      Top = 24
      Width = 113
      Height = 17
      Caption = 'Common rooms'
      Checked = True
      TabOrder = 0
      TabStop = True
    end
    object HiddenRoomsRB: TRadioButton
      Left = 8
      Top = 48
      Width = 113
      Height = 17
      Caption = 'Hidden rooms'
      TabOrder = 1
    end
  end
  object GroupBox2: TGroupBox
    Left = 8
    Top = 280
    Width = 161
    Height = 105
    Caption = 'Hidden room'
    TabOrder = 7
    object Label5: TLabel
      Left = 8
      Top = 56
      Width = 21
      Height = 13
      Caption = 'Key:'
    end
    object CreateHiddenRoomBtn: TButton
      Left = 8
      Top = 24
      Width = 145
      Height = 25
      Caption = 'Create hidden room'
      TabOrder = 0
      OnClick = CreateHiddenRoomBtnClick
    end
    object HiddenRoomKeyEdt: TEdit
      Left = 8
      Top = 72
      Width = 145
      Height = 21
      TabOrder = 1
    end
  end
  object UpdateTimer: TTimer
    Enabled = False
    OnTimer = UpdateTimerTimer
    Left = 448
    Top = 8
  end
  object OpenDialog: TOpenDialog
    Filter = 'bmp, jpg, jpeg, png, gif|*.bmp;*.jpg;*.jpeg;*.gif;'
    Left = 416
    Top = 8
  end
  object IdHTTP: TIdHTTP
    IOHandler = IdSSLIOHandlerSocket1
    MaxLineAction = maException
    ReadTimeout = 0
    AllowCookies = True
    HandleRedirects = True
    ProxyParams.BasicAuthentication = False
    ProxyParams.ProxyPort = 0
    Request.ContentLength = -1
    Request.ContentRangeEnd = 0
    Request.ContentRangeStart = 0
    Request.ContentType = 'text/html'
    Request.Accept = 'text/html, */*'
    Request.BasicAuthentication = False
    Request.UserAgent = 'Mozilla/3.0 (compatible; Indy Library)'
    HTTPOptions = [hoForceEncodeParams]
    Left = 680
    Top = 248
  end
  object IdSSLIOHandlerSocket1: TIdSSLIOHandlerSocket
    SSLOptions.Method = sslvTLSv1
    SSLOptions.Mode = sslmUnassigned
    SSLOptions.VerifyMode = []
    SSLOptions.VerifyDepth = 0
    Left = 648
    Top = 248
  end
end
