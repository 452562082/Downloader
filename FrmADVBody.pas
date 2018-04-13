unit FrmADVBody;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, GifImg, jpeg, ExtCtrls, pngimage, UnitConfig, EmbeddedWB, shellapi,
  UnitFuc, OleCtrls, SHDocVw_EWB, EwbCore;

type
  TFFrmADVBody = class(TForm)
    ADVBody: TEmbeddedWB;
    EmbeddedWB1: TEmbeddedWB;
    procedure FormCreate(Sender: TObject);
  private
    //ADVBody: TEmbeddedWB;
    procedure ADVBodyNewWindow2(ASender: TObject; var ppDisp: IDispatch; var Cancel: WordBool);
    procedure ADVBodyNewWindow3(ASender: TObject; var ppDisp: IDispatch;
      var Cancel: WordBool; dwFlags: Cardinal; const bstrUrlContext,
      bstrUrl: WideString);
  public
    { Public declarations }
  end;

var
  FFrmADVBody: TFFrmADVBody;

implementation

{$R *.dfm}

uses
  FrmADV;

procedure TFFrmADVBody.FormCreate(Sender: TObject);
var
  gifADV: TGIFImage;
  jpgADV: TJPEGImage;
  FStream : TResourceStream;
begin
  Self.Parent := FFrmADV;
  Self.BorderStyle := bsNone;
  Self.Position := poDesigned;
  Self.SetBounds(1, 36, FrmADVBodyWidth, FrmADVBodyHeight);
  //Self.OnClick := Self.UIOnClick;

  {with TImage.Create(Self) do
  begin
    Parent := Self;
    SetBounds(0,0,FrmADVBodyWidth,FrmADVBodyHeight);
    Cursor:=crHandpoint;
    gifADV := TGIFImage.Create;
    FStream := TResourceStream.Create(hInstance,'ADV_img',RT_RCDATA);
    gifADV.LoadFromStream(FStream);
    Picture.Assign(gifADV);
    TGIFImage(Picture.Graphic).Animate := True;
    gifADV.Free;
    OnClick := UIOnClick;
  end}

  {with TImage.Create(Self) do
  begin
    Parent := Self;
    SetBounds(0,0,FrmADVBodyWidth,FrmADVBodyHeight);
    jpgADV := TJPEGImage.Create;
    FStream := TResourceStream.Create(hInstance,'ADV_img',RT_RCDATA) ;
    jpgADV.LoadFromStream(FStream);
    Picture.Bitmap.Assign(jpgADV);
    Cursor:=crHandpoint;
    OnClick := UIOnClick;
    jpgADV.Free;
  end;}

  if IsHttpUrl(ADVInfo.slide) then
  begin
    ADVBody.Visible := True;
    ADVBody.SetBounds(-51, -52, FrmADVBodyWidth + 51, FrmADVBodyHeight + 52);
    ADVBody.OnNewWindow2 := ADVBodyNewWindow2;
    ADVBody.OnNewWindow3 := ADVBodyNewWindow3;
    ADVBody.Navigate(ADVInfo.slide);
  end;

end;

procedure TFFrmADVBody.ADVBodyNewWindow2(ASender: TObject; var ppDisp: IDispatch; var Cancel: WordBool);
begin
  ppDisp := EmbeddedWB1.Application;
end;

procedure TFFrmADVBody.ADVBodyNewWindow3(ASender: TObject; var ppDisp: IDispatch;
      var Cancel: WordBool; dwFlags: Cardinal; const bstrUrlContext,
      bstrUrl: WideString);
begin
  ShellExecute(Application.Handle, nil, PWideChar(bstrUrl), nil, nil, SW_SHOWNORMAL);
end;

end.
