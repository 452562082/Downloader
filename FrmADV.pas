unit FrmADV;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, UnitConfig, DUIBase, DUIBitmap32, DUIContainer, DUIManager,
  DUIButton, DUIImage, DUIGraphics, DUICore, DUILabel, DUIType, UnitFuc,
  DUILabelEx, DUIConfig, DUICheck, UnitStat, UnitType, GifImg, jpeg, ExtCtrls,
  pngimage, StdCtrls;

type
  TFFrmADV = class(TForm)
    procedure FormCreate(Sender: TObject);
    //procedure WMMove(var Message: TMessage) ; message WM_MOVE;
  private
    FUIManager: TDUIManager;
    FImgTopBk: TDUIImage;
    FImgBottomBk: TImage;
    FBtnClose: TDUIButton;
    //FImgADV: TGIFImage;
    //FImgBk: TImage;
    FImgADV: TImage;
    //FImgADV: TJPEGImage;
  public

  private
    procedure UIOnClick(Sender: TObject);
    //procedure UIOnMouseDown(Sender: TObject; Button: TMouseButton;
  //Shift: TShiftState; X, Y: Integer);
  end;

var
  FFrmADV: TFFrmADV;
  //IsClose: Boolean;

implementation

{$R *.dfm}

uses
  FrmMain, FrmADVBody;

procedure TFFrmADV.FormCreate(Sender: TObject);
begin
  Self.BorderStyle := bsNone;
  Self.Parent := FFrmMain;
  Self.Position := poDesigned;
  if (SameText(ADVInfo.imgPlace,'1')) then
    Self.SetBounds(0, 0, FrmADVWidth, FrmADVHeight)
  else
    Self.SetBounds(FrmMainWidth, 0, FrmADVWidth, FrmADVHeight);

  FUIManager := TDUIManager.Create(Self);
  with FUIManager do
  begin
    IsLoading := True;

    Attach(Self.Handle, Rect(0, 0, Self.Width, Self.Height));

    FImgTopBk := TDUIImage.Create(FUIManager);
    if (SameText(ADVInfo.imgPlace,'1')) then
      FImgTopBk.Bitmap.LoadFromResource(HInstance, 'ADV_bk_left', RT_RCDATA)
    else
      FImgTopBk.Bitmap.LoadFromResource(HInstance, 'ADV_bk_right', RT_RCDATA);
    FImgTopBk.SetBounds(0, 0, 141, 400);
    //FImgBk.OnMouseDown := Self.UIOnMouseDown;

    FBtnClose := TDUIButton.Create(FUIManager);
    begin
      FBtnClose.BtnStateCount := 3;
      FBtnClose.BtnImage := LoadBmpByName('ADV_close');
      //ImgBk.Bitmap.LoadFromResource(HInstance, 'ADV_close', RT_RCDATA);
      FBtnClose.DoAutoSize;
      FBtnClose.SetSite(112, 1);
      FBtnClose.OnClick := Self.UIOnClick;
      if (SameText(ADVInfo.adStatus,'0')) then
        FBtnClose.Visible := true
      else
        FBtnClose.Visible := false
    end;

    Refresh;
    Application.CreateForm(TFFrmADVBody, FFrmADVBody);
    FFrmADVBody.Show;
  end;
end;

procedure TFFrmADV.UIOnClick(Sender: TObject);
begin
  if Sender = FBtnClose then
  begin
    Close;
    SendMessage(FFrmMain.Handle,USER_CLOSE_CHILD,0,0);
  end
end;

{procedure TFFrmADV.UIOnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  ReleaseCapture;
  SendMessage(Handle,WM_NCLBUTTONDOWN,HTCAPTION,0);
end;

procedure TFFrmADV.WMMove(var Message: TMessage) ;
var
  rect : TRect;
begin
  GetWindowRect(FFrmADV.Handle,rect);
  if Assigned(FFrmMain) then
  begin
    SetWindowPos(FFrmMain.Handle, HWND_NOTOPMOST, rect.Right,rect.Top, FrmMainWidth, FrmMainHeight, SWP_SHOWWINDOW);
  end;
end; (*WMMove*)  }

end.
