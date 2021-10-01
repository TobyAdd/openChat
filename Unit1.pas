unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, WinInet, StdCtrls, ShellAPI, ExtCtrls, IdIOHandler,
  IdIOHandlerSocket, IdSSLOpenSSL, IdBaseComponent, IdComponent,
  IdTCPConnection, IdTCPClient, IdHTTP, IdMultipartFormData, OleCtrls,
  SHDocVw, MD5, ClipBrd;

type
  TMain = class(TForm)
    UpdateChatBtn: TButton;
    Button1: TButton;
    CheckBox1: TCheckBox;
    RoomsGB: TGroupBox;
    RoomsLB: TListBox;
    UpdateRoomsBtn: TButton;
    CurrentRoomGB: TGroupBox;
    SendBtn: TButton;
    TextEdt: TEdit;
    Label2: TLabel;
    AuthGB: TGroupBox;
    Label1: TLabel;
    NickEdt: TEdit;
    PassEdt: TEdit;
    Label3: TLabel;
    EnterBtn: TButton;
    Button4: TButton;
    Button3: TButton;
    UpdateTimer: TTimer;
    Label4: TLabel;
    Button2: TButton;
    OpenDialog: TOpenDialog;
    IdHTTP: TIdHTTP;
    IdSSLIOHandlerSocket1: TIdSSLIOHandlerSocket;
    WebBrowser1: TWebBrowser;
    GroupBox1: TGroupBox;
    CommonRoomsRB: TRadioButton;
    HiddenRoomsRB: TRadioButton;
    GroupBox2: TGroupBox;
    CreateHiddenRoomBtn: TButton;
    Label5: TLabel;
    HiddenRoomKeyEdt: TEdit;
    procedure SendBtnClick(Sender: TObject);
    procedure TextEdtKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure UpdateChatBtnClick(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure UpdateRoomsBtnClick(Sender: TObject);
    procedure Button3Click(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure UpdateTimerTimer(Sender: TObject);
    procedure RoomsLBClick(Sender: TObject);
    procedure EnterBtnClick(Sender: TObject);
    procedure Button4Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure WebViewWrite(Str: string);
    procedure CreateHiddenRoomBtnClick(Sender: TObject);
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  Main: TMain;

const
  ChatHost = 'http://localhost';
  RoomsFolder = 'rooms';
  IMGUrKey='d00000000000000';

implementation

{$R *.dfm}

function HTTPCheck(const URL: string): boolean;
var
  hSession, hUrl: HINTERNET;
  dwIndex, dwCodeLen, dwFlags: DWORD;
  dwCode: array [1..20] of Char;
begin
  Result:=false;
  hSession:=InternetOpen('Mozilla/4.0 (MSIE 6.0; Windows NT 5.1)', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(hSession) then begin

    if Copy(LowerCase(URL), 1, 8) = 'https://' then
      dwFlags:=INTERNET_FLAG_SECURE
    else
      dwFlags:=INTERNET_FLAG_RELOAD;

    hUrl:=InternetOpenURL(hSession, PChar(URL), nil, 0, dwFlags, 0);
    if Assigned(hUrl) then begin
      dwIndex:=0;
      dwCodeLen:=10;
      if HttpQueryInfo(hUrl, HTTP_QUERY_STATUS_CODE, @dwCode, dwCodeLen, dwIndex) then
        Result:=(PChar(@dwCode) = IntToStr(HTTP_STATUS_OK)) or (PChar(@dwCode) = IntToStr(HTTP_STATUS_REDIRECT));
      InternetCloseHandle(hUrl);
    end;

    InternetCloseHandle(hSession);
  end;
end;

function HTTPGet(URL: string): string;
var
  hSession, hUrl: HINTERNET;
  Buffer: array [1..8192] of Byte;
  dwFlags, BufferLen: DWORD;
  StrStream: TStringStream;
begin
  Result:='';
  hSession:=InternetOpen('Mozilla/4.0 (MSIE 6.0; Windows NT 5.1)', INTERNET_OPEN_TYPE_PRECONFIG, nil, nil, 0);
  if Assigned(hSession) then begin

    if Copy(LowerCase(URL), 1, 8) = 'https://' then
      dwFlags:=INTERNET_FLAG_SECURE
    else
      dwFlags:=INTERNET_FLAG_RELOAD;

    hUrl:=InternetOpenUrl(hSession, PChar(URL), nil, 0, dwFlags or INTERNET_FLAG_RESYNCHRONIZE, 0);
    if Assigned(hUrl) then begin
      StrStream:=TStringStream.Create('');
      try
        repeat
          FillChar(Buffer, SizeOf(Buffer), 0);
          BufferLen:=0;
          if InternetReadFile(hURL, @Buffer, SizeOf(Buffer), BufferLen) then
            StrStream.WriteBuffer(Buffer, BufferLen)
          else
            Break;
          Application.ProcessMessages;
        until BufferLen = 0;
        Result:=StrStream.DataString;
      except
        Result:='';
      end;
      StrStream.Free;

      InternetCloseHandle(hUrl);
    end;

    InternetCloseHandle(hSession);
  end;
end;

function DigitToHex(Digit: Integer): Char;
  begin
    case Digit of
      0..9: Result := Chr(Digit + Ord('0'));
      10..15: Result := Chr(Digit - 10 + Ord('A'));
    else
      Result := '0';
  end;
end; // DigitToHex

function URLEncode(const S: string): string;
var
  i, idx, len: Integer;
begin
  len := 0;
  for i := 1 to Length(S) do
    if ((S[i] >= '0') and (S[i] <= '9')) or
      ((S[i] >= 'A') and (S[i] <= 'Z')) or
      ((S[i] >= 'a') and (S[i] <= 'z')) or (S[i] = ' ') or
      (S[i] = '_') or (S[i] = '*') or (S[i] = '-') or (S[i] = '.') then
      len := len + 1
    else
      len := len + 3;
  SetLength(Result, len);
  idx := 1;
  for i := 1 to Length(S) do
    if S[i] = ' ' then begin
      Result[idx] := '+';
      idx := idx + 1;
    end else
      if ((S[i] >= '0') and (S[i] <= '9')) or
        ((S[i] >= 'A') and (S[i] <= 'Z')) or
        ((S[i] >= 'a') and (S[i] <= 'z')) or
        (S[i] = '_') or (S[i] = '*') or (S[i] = '-') or (S[i] = '.') then begin
          Result[idx] := S[i];
          idx := idx + 1;
        end
        else
        begin
          Result[idx] := '%';
          Result[idx + 1] := DigitToHex(Ord(S[i]) div 16);
          Result[idx + 2] := DigitToHex(Ord(S[i]) mod 16);
          idx := idx + 3;
        end;
end;

procedure TMain.SendBtnClick(Sender: TObject);
begin
  if (CommonRoomsRB.Checked) and (RoomsLB.ItemIndex = -1) then begin
    ShowMessage('Select any room');
    Exit;
  end;
  if (HiddenRoomsRB.Checked) and (Trim(HiddenRoomKeyEdt.Text) = '') then begin
    ShowMessage('Enter hidden key');
    Exit;
  end;
  if Label4.Caption <> 'Password correct' then begin
    ShowMessage('Need auth');
    Exit;
  end;

  if CommonRoomsRB.Checked then
    HTTPGet(ChatHost + '/chatapi.php?n=' + URLEncode(NickEdt.Text) + '&p=' + URLEncode(PassEdt.Text) + '&r=' + URLEncode(RoomsLB.Items.Strings[RoomsLB.ItemIndex]) + '&t=' + URLEncode(AnsiToUTF8(TextEdt.Text)))
  else
    HTTPGet(ChatHost + '/chatapi.php?n=' + URLEncode(NickEdt.Text) + '&p=' + URLEncode(PassEdt.Text) + '&h=' + URLEncode(HiddenRoomKeyEdt.Text) + '&t=' + URLEncode(AnsiToUTF8(TextEdt.Text)));

  TextEdt.Clear;
  UpdateChatBtn.Click;
end;

procedure TMain.TextEdtKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = 13 then
    SendBtn.Click;
end;

procedure TMain.UpdateChatBtnClick(Sender: TObject);
begin
  if CommonRoomsRB.Checked then begin
    if RoomsLB.ItemIndex = -1 then begin
      ShowMessage('Select any room');
      Exit;
    end;

    WebViewWrite(HTTPGet(ChatHost + '/' + RoomsFolder + '/' + RoomsLB.Items.Strings[RoomsLB.ItemIndex] + '.txt'));
  end else begin     //if (HiddenRoomsRB.Checked)
    if (Trim(HiddenRoomKeyEdt.Text) = '') then begin
      ShowMessage('Enter hidden key');
      Exit;
    end;

    WebViewWrite(HTTPGet(ChatHost + '/chatapi.php?a=read&h=' + URLEncode(HiddenRoomKeyEdt.Text)));
  end;
end;

procedure TMain.Button1Click(Sender: TObject);
begin
  ShellAbout(Main.Handle, PChar(Caption), 'Author ...', Application.Icon.Handle);
end;

procedure TMain.FormCreate(Sender: TObject);
begin
  Application.Title:=Caption;
  IdHttp.Request.CustomHeaders.Add('Authorization:Client-ID ' + IMGUrKey);
  WebBrowser1.Navigate('about:blank');
end;

procedure TMain.UpdateRoomsBtnClick(Sender: TObject);
begin
  RoomsLB.Items.Text:=HTTPGet(ChatHost + '/chatapi.php?a=rooms');
end;

procedure TMain.Button3Click(Sender: TObject);
var
  Str: string; i: integer; Found: bool;
begin
  Found:=false;
  if InputQuery(Caption, 'Enter room name', Str) then
    for i:=1 to Length(Str) do
      if not (Str[i] in ['A'..'Z', 'a'..'z', '0'..'9', ' ']) then begin
        Found:=true;
        Break;
      end;


  if Found then
    ShowMessage('Use only Latin')
  else begin
    HTTPGet(ChatHost + '/chatapi.php?a=create&r=' + URLEncode(Str));
    UpdateRoomsBtn.Click;
  end;
end;

procedure TMain.CheckBox1Click(Sender: TObject);
begin
  UpdateTimer.Enabled:=CheckBox1.Checked;
end;

procedure TMain.UpdateTimerTimer(Sender: TObject);
begin
  if CommonRoomsRB.Checked then begin
    if RoomsLB.ItemIndex <> -1 then
      WebViewWrite(HTTPGet(ChatHost + '/' + RoomsFolder + '/' + RoomsLB.Items.Strings[RoomsLB.ItemIndex] + '.txt'));
  end else begin
    if Trim(HiddenRoomKeyEdt.Text) <> '' then
      WebViewWrite(HTTPGet(ChatHost + '/chatapi.php?a=read&h=' + URLEncode(HiddenRoomKeyEdt.Text)));
  end;
end;

procedure TMain.RoomsLBClick(Sender: TObject);
begin
  WebViewWrite(HTTPGet(ChatHost + '/' + RoomsFolder + '/' + RoomsLB.Items.Strings[RoomsLB.ItemIndex] + '.txt'));
end;

procedure TMain.EnterBtnClick(Sender: TObject);
var
  Status: string;
begin
  if Trim(NickEdt.Text) = '' then begin ShowMessage('Enter login'); Exit; end;
  if Trim(PassEdt.Text) = '' then begin ShowMessage('Enter pass'); Exit; end;
  Status:=HTTPGet(ChatHost + '/chatapi.php?a=auth&n=' + URLEncode(Trim(NickEdt.Text)) + '&p=' + URLEncode(Trim(PassEdt.Text)));
  ShowMessage(Status);
  Label4.Caption:=Status;
  if Status = 'Password correct' then begin
    Caption:='openChat - ' + NickEdt.Text;
    UpdateRoomsBtn.Click;
  end;
end;

procedure TMain.Button4Click(Sender: TObject);
var
  Status: string;
begin
  if Trim(NickEdt.Text) = '' then begin ShowMessage('Enter login'); Exit; end;
  if Trim(PassEdt.Text) = '' then begin ShowMessage('Enter pass'); Exit; end;
  Status:=HTTPGet(ChatHost + '/chatapi.php?a=reg&n=' + URLEncode(Trim(NickEdt.Text)) + '&p=' + URLEncode(Trim(PassEdt.Text)));
  ShowMessage(Status);
end;

procedure TMain.Button2Click(Sender: TObject);
var
  Source: string;
  FormData: TIdMultiPartFormDataStream;
begin
  if not OpenDialog.Execute then Exit;
  FormData:=TIdMultiPartFormDataStream.Create;
  FormData.AddFile('image', OpenDialog.FileName, '');
  IdHTTP.Request.ContentType:='Content-Type: application/octet-stream';
  try
    Source:=IdHTTP.Post('https://api.imgur.com/3/image.xml', FormData);
  except
  end;
  if IdHTTP.ResponseCode = 200 then begin
    Delete(Source, 1, Pos('<link>', Source) + 5);
    Delete(Source, Pos('<', Source), Length(Source) - Pos('<', Source) + 1);
    ShowMessage('Uploaded');
    TextEdt.Text:='<br><img src="' + Source + '" />';
    SendBtn.Click;
  end else
    ShowMessage('Fail upload');
  FormData.Free;
end;

procedure TMain.WebViewWrite(Str: string);
begin
  Str:=StringReplace(Str, #13#10, '<br>', [rfReplaceAll]);
  Str:=StringReplace(Str, '&lt;', '<', [rfReplaceAll]);
  Str:=StringReplace(Str, '&gt;', '>', [rfReplaceAll]);
  Str:=StringReplace(Str, '&quot;', '"', [rfReplaceAll]);
  WebBrowser1.Refresh;
  WebBrowser1.OleObject.Document.Write('<html><body>' + UTF8ToAnsi(Str) + ' </body></html>');
end;

procedure TMain.CreateHiddenRoomBtnClick(Sender: TObject);
var
  Str: string; i: integer; Found: bool;
begin
  Str:=MD5DigestToStr(MD5String(DateToStr(Date) + ' ' + TimeToStr(Time)));
  ClipBoard.AsText:=Str;
  HiddenRoomKeyEdt.Text:=Str;
  ShowMessage('Key copied to the clipboard');
  HTTPGet(ChatHost + '/chatapi.php?a=hidden&r=' + URLEncode(Str));
  UpdateRoomsBtn.Click;
end;

end.
