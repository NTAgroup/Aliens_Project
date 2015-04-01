unit MainUnit;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Layouts, FMX.Memo, IdBaseComponent, IdComponent, IdTCPConnection,
  IdTCPClient, IdHTTP, FMX.Controls.Presentation, FMX.Edit,
   Winapi.ShellAPI, Winapi.Windows, XSuperObject, Unit1, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, AdditionalFunctions,
  IdMessage, IdMessageCoderMIME, IdMultipartFormData, FMX.Platform.Win, IdURI,
  FMX.Effects;

type
  TMainForm = class(TForm)
    PersonalityPanel: TPanel;
    AccountGroup: TGroupBox;
    ActivityGroup: TGroupBox;
    Memo1: TMemo;
    StartButton: TButton;
    MidPanel: TPanel;
    BottomPanel: TPanel;
    IdHTTP1: TIdHTTP;
    Timer1: TTimer;
    TwitterBox: TCheckBox;
    VkBox: TCheckBox;
    InstagramBox: TCheckBox;
    ProfileBox: TCheckBox;
    PublishBox: TCheckBox;
    LikeBox: TCheckBox;
    RepostBox: TCheckBox;
    CommentBox: TCheckBox;
    VkTokenEdit: TEdit;
    AuthButton: TButton;
    InstTokenEdit: TEdit;
    TwitterTokenEdit: TEdit;
    IdSSLIOHandlerSocketOpenSSL1: TIdSSLIOHandlerSocketOpenSSL;
    ArtistFrame: TFrame2;
    TravelerFrame: TFrame2;
    PoliticFrame: TFrame2;
    GamerFrame: TFrame2;
    StyleBook1: TStyleBook;
    BevelEffect1: TBevelEffect;
    procedure FormCreate(Sender: TObject);
    procedure AuthButtonClick(Sender: TObject);
    procedure StartButtonClick(Sender: TObject);
    procedure LoadImageButtonClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ArtistFramePersonalityChange(Sender: TObject);
    procedure GamerFramePersonalityChange(Sender: TObject);
    procedure PoliticFramePersonalityChange(Sender: TObject);
    procedure TravelerFramePersonalityChange(Sender: TObject);
    procedure Button1Click(Sender: TObject);
  private
    { Private declarations }
    function VkAuthorize: Boolean;
    function VkGetGroups(KeyWord: String): TStringList;
    procedure VkJoinGroup(AGroupId: Integer);
    function VkGetPost: TStringList;
    procedure VkPost(AText: String);
    function VkSearchAudio(KeyWord: String): TStringList;
    procedure VkComment(AText, ASourceId, APostId: String);
    procedure VkAddAudio(AOwnerId, AAudioId: String);
    function VkGetUploadServer: String;
    function VkUploadPhoto(AFileName: String): ISuperObject;
    procedure VkWallPostPhoto(AFileName: String);
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  VkAccessList: TStringList;
  SettingsList: TStringList;
implementation

{$R *.fmx}

procedure TMainForm.VkAddAudio(AOwnerId, AAudioId: String);
var
  Response:String;
begin
  Response := IdHttp1.Get(TIdUri.URLEncode('https://api.vk.com/method/audio.add?v=5.29&access_token='
  +VkTokenEdit.Text+'&owner_id='
  +AOwnerId+'&audio_id='+AAudioId));
end;

function TMainForm.VkAuthorize: Boolean;
var
  sCommand: String;
  i: Integer;
begin
  sCommand := 'https://oauth.vk.com/authorize?'+VkAccessList.Strings[0];
  for I := 1 to VkAccessList.Count-1 do
     sCommand := sCommand + '&' + VkAccessList.Strings[i];
  memo1.Lines.add(sCommand);
  {$IFDEF MSWINDOWS}
  ShellExecute(0, 'OPEN', PChar(sCommand), '', '', SW_SHOWNORMAL);
  {$ENDIF MSWINDOWS}
end;

procedure TMainForm.VkComment(AText, ASourceId, APostId: String);
var
  Response:String;
begin
  Response := IdHttp1.Get(TIdUri.URLEncode('https://api.vk.com/method/wall.addComment?v=5.29&access_token='
  +VkTokenEdit.Text+'&owner_id='+ASourceId+'&post_id='
  +TIdUri.URLEncode(APostId)+'&text='+AText));
  Memo1.Lines.Add(Response);
end;

function TMainForm.VkGetGroups(KeyWord: String): TStringList;
var
  X: ISuperObject;
  XA: ISuperArray;
  i: Integer;
  Response: String;
begin
  Result := TStringList.Create;
  Response := IdHTTP1.Get('https://api.vk.com/method/groups.search?count=10&v=5.29&access_token='
  +VkTokenEdit.Text+'&q='+KeyWord);
  Memo1.Lines.Add(Response);
  X := SO(Response);
  X := X.O['response'];
  XA := X.A['items'];
  for I := 0 to XA.Length do
  begin
    X := XA.O[i];
    Result.Add(X.S['name']+'='+IntToStr(X.I['id']));
  end;
end;

function TMainForm.VkGetPost: TStringList;
var
  X: ISuperObject;
  XA: ISuperArray;
  i: Integer;
  Request,s: String;
begin
  Result := TStringList.Create;
  Request := 'https://api.vk.com/method/newsfeed.get?access_token='
  +VkTokenEdit.Text+'&count=10&v=5.29&filters=post';
  //Memo1.Lines.Add(Request);
  X := SO(IdHTTP1.Get(Request));
  //Memo1.Lines.Add(X.AsJSON);
  //Memo1.Lines.Add(idHttp1.ResponseText);
  X := X.O['response'];
  XA := X.A['items'];
  for I := 0 to XA.Length-1 do
  begin
    X := XA.O[i];
    //Memo1.lines.Add(X.AsJSON);
    //Memo1.Lines.Add(X.S['text']);
    //Memo1.Lines.Add(IntToStr(X.I['post_id']));
    s:=IntToStr(X.I['post_id'])+'+'+IntToStr(X.I['source_id']);
    Result.Add(X.S['text']+'='+s);
  end;
end;

function TMainForm.VkGetUploadServer: String;
var
  Response:String;
  X: ISuperObject;
begin
  Response := IdHttp1.Get('https://api.vk.com/method/photos.getWallUploadServer?v=5.29&access_token='
  +VkTokenEdit.Text);
  X := SO(Response);
  X := X.O['response'];
  Result := X.S['upload_url'];
end;

procedure TMainForm.ArtistFramePersonalityChange(Sender: TObject);
begin
  GamerFrame.Personality.IsChecked := false;
  TravelerFrame.Personality.IsChecked := false;
  PoliticFrame.Personality.IsChecked := false;
  BotType.Values['type'] := 'artist';
  LoadBotCharacteristics;
end;

procedure TMainForm.AuthButtonClick(Sender: TObject);
begin
  if vkBox.IsChecked then
    VkAuthorize;
end;

procedure TMainForm.LoadImageButtonClick(Sender: TObject);
begin
  try
    VkWallPostPhoto('neuron.jpg');
  except
  end;
end;

procedure TMainForm.Button1Click(Sender: TObject);
begin
  PostForVk;
end;

procedure TMainForm.Button2Click(Sender: TObject);
begin
  Memo1.Lines.Add(VkGetGroups('music').GetText);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  VkAccessList := TStringList.Create;
  VkAccessList.Add('client_id=4842932');
  VkAccessList.Add('scope=friends,photos,audio,pages,status,wall,groups,offline');
  VkAccessList.Add('redirect_uri=https://oauth.vk.com/blank.html');
  VkAccessList.Add('display=page');
  VkAccessList.Add('v=5.29');
  VkAccessList.Add('response_type=token');
  LoadBots;
  //LoadBotCharacteristics;
  try
   SettingsList := TStringList.Create;
   SettingsList.LoadFromFile('a_t.txt');
   VkTokenEdit.Text := SettingsList.Values['access_token'];
  except
  end;
end;



procedure TMainForm.GamerFramePersonalityChange(Sender: TObject);
begin
  ArtistFrame.Personality.IsChecked := false;
  TravelerFrame.Personality.IsChecked := false;
  PoliticFrame.Personality.IsChecked := false;
  BotType.Values['type'] := 'gamer';
  LoadBotCharacteristics;
end;

procedure TMainForm.PoliticFramePersonalityChange(Sender: TObject);
begin
  GamerFrame.Personality.IsChecked := false;
  TravelerFrame.Personality.IsChecked := false;
  ArtistFrame.Personality.IsChecked := false;
  BotType.Values['type'] := 'politic';
  LoadBotCharacteristics;
end;

procedure TMainForm.VkJoinGroup(AGroupId: Integer);
var
  ResponseStream: TStringStream;
begin
  ResponseStream := TStringStream.Create;
  IdHttp1.Get(TIdUri.URLEncode('https://api.vk.com/method/groups.join?v=5.29&access_token='
  +VkTokenEdit.Text+'&group_id='+IntToStr(AGroupId)),ResponseStream);
  ResponseStream.Free;
end;

procedure TMainForm.VkPost(AText: String);
var
  ResponseStream: TStringStream;
begin
  ResponseStream := TStringStream.Create;
  IdHttp1.Get(TIdUri.URLEncode('https://api.vk.com/method/wall.post?v=5.29&access_token='
  +VkTokenEdit.Text+'&message='+AText),ResponseStream);
  ResponseStream.Free;
end;



function TMainForm.VkSearchAudio(KeyWord: String): TStringList;
var
  X: ISuperObject;
  XA: ISuperArray;
  i: Integer;
  Response: String;
begin
  Result := TStringList.Create;
  Response := IdHTTP1.Get('https://api.vk.com/method/audio.search?count=10&v=5.29&access_token='
  +VkTokenEdit.Text+'&q='+KeyWord);
  Memo1.Lines.Add(Response);
  X := SO(Response);
  X := X.O['response'];
  XA := X.A['items'];
  for I := 0 to XA.Length do
  begin
    X := XA.O[i];
    Result.Add(X.S['id']+'='+IntToStr(X.I['owner_id']));
  end;
end;

function TMainForm.VkUploadPhoto(AFileName: String): ISuperObject;
var
ResponseStream: TStringStream;
Params: TIdMultipartFormDataStream;
s: String;
begin
  try
    ResponseStream := TStringStream.Create;
    Params := TIdMultipartFormDataStream.Create;
    Params.AddFile('photo',AFileName,'photo');
    idHttp1.Post(VkGetUploadServer,Params,ResponseStream);
    Result := SO(ResponseStream.DataString);
  finally
    ResponseStream.Free;
    Params.Free;
  end;
end;

procedure TMainForm.VkWallPostPhoto(AFileName: String);
var
  Response,mes: String;
  X, Y: ISuperObject;
begin
  Y := VkUploadPhoto(AFileName);
  Response := IdHTTP1.Get('https://api.vk.com/method/photos.saveWallPhoto?v=5.29&access_token='
  +VkTokenEdit.Text+'&photo='+Y.S['photo']
  +'&hash='+Y.S['hash']
  +'&server='+IntToStr(Y.I['server']));
  X := SO(Response);
  X := X.A['response'].O[0];
  mes := PostForVk;
  Response := IdHttp1.Get(TIdUri.URLEncode('https://api.vk.com/method/wall.post?v=5.29&access_token='
  +VkTokenEdit.Text+'&message='+mes+'&attachments=photo'+IntToStr(X.I['owner_id'])+'_'+IntToStr(X.I['id'])));
end;

procedure TMainForm.StartButtonClick(Sender: TObject);
begin
  if not Timer1.Enabled then
  begin
    TwitterTokenEdit.Enabled := False;
    VkTokenEdit.Enabled := False;
    InstTokenEdit.Enabled := False;
    Timer1.Enabled:=True;
    SettingsList.Values['access_token']:=VkTokenEdit.Text;
    SettingsList.SaveToFile('a_t.txt');
    StartButton.Text := '����������';
  end
  else
  begin
    TwitterTokenEdit.Enabled := True;
    VkTokenEdit.Enabled := True;
    InstTokenEdit.Enabled := True;
    Timer1.Enabled:=False;
    StartButton.Text := '�������';
  end;
end;

procedure TMainForm.Timer1Timer(Sender: TObject);
var
PostStream: TStringStream;
Posts: TStringList;
s,s1,alls,source,post: String;
ind: Integer;
begin
  PostStream := TStringStream.Create;
  Posts := TStringList.Create;
  try
  try
    Posts := VkGetPost;
    //PostStream.WriteString('����������');
    PostStream.WriteString(Posts.Names[0]);
    alls := Posts.ValueFromIndex[0];
    ind := alls.IndexOf('+');
    source := alls.Substring(ind+1);
    post := alls.Substring(0,ind);
    try
      if (BotType.Values['type']='artist') and PublishBox.IsChecked then
      begin
        ShellExecute(FmxHandleToHWND(Handle), 'open', 'GenArt.exe', nil, nil, SW_SHOWNORMAL);
        sleep(4000);
        VkWallPostPhoto('CloneArtF.png');
      end;
    except
    end;
    Memo1.Lines.Add('����: '+Posts.Names[0]);
    if CommentBox.IsChecked then
    begin
      s := BuildCommentForVk(PostStream);
      vkComment(s,source,post);
    end;
    Memo1.Lines.Add('��������: '+s);
    if PublishBox.IsChecked then
    begin
      s1 := PostForVk;
      if (s1 = '') and (BotType.Values['type']<>'artist') then
        VkPost(s1);
    end;
    Memo1.Lines.Add('���������: '+s1);
    Timer1.Interval:=TimeToPost;
  except
  end;
  finally
    PostStream.Free;
    //Posts.Free;
  end;
end;

procedure TMainForm.TravelerFramePersonalityChange(Sender: TObject);
begin
  GamerFrame.Personality.IsChecked := false;
  ArtistFrame.Personality.IsChecked := false;
  PoliticFrame.Personality.IsChecked := false;
  BotType.Values['type'] := 'traveler';
  LoadBotCharacteristics;
end;

end.
