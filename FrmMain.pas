unit FrmMain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, OleCtrls, SHDocVw_EWB, EwbCore, msxml, UnitFuc, UnitConfig, DUIBase,
  DUIBitmap32, DUIContainer, DUIManager, DUIButton, DUIImage, DUIGraphics,
  DUICore, DUILabel, DUIType, GR32, DUILabelEx, DUIConfig, StdCtrls,
  DUITaskItem, DUICheck, EmbeddedWB, MD5Unit, ShellAPI, Generics.Collections,
  UnitType, Masks, Registry, {$IFDEF USE_XLSDK} XlDownUnit, MMSystem,
{$ELSE} HttpDowner, {$ENDIF} ExtCtrls, AppEvnts, Menus, FrmInstall,
  RemoteModule, UnitStat;

type
  THandleList = TList<THandle>;

  TFFrmMain = class(TForm)
    wb2: TEmbeddedWB;
    wb3: TEmbeddedWB;
    tmrTask: TTimer;
    aplctnvnts1: TApplicationEvents;
    pm1: TPopupMenu;
    N1: TMenuItem;
    N2: TMenuItem;
    N3: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure tmrTaskTimer(Sender: TObject);
    procedure N1Click(Sender: TObject);
    procedure N3Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure wb2NewWindow2(ASender: TObject; var ppDisp: IDispatch; var Cancel: WordBool);
    procedure wb2NewWindow3(ASender: TObject; var ppDisp: IDispatch;
      var Cancel: WordBool; dwFlags: Cardinal; const bstrUrlContext,
      bstrUrl: WideString);
    procedure CLOSE_CHILD_Proc(var Message: TMessage); message USER_CLOSE_CHILD;
    //procedure WMMove(var Message: TMessage) ; message WM_MOVE;
    //procedure MyMsg(var msg:TMessage);message WM_SYSCOMMAND;
  private
    FUIManager: TDUIManager;
    FContainer: array [0 .. 2] of TDUIContainer;
    FImgBk: TDUIImage;
    FImgBk2: TDUIImage;
    FImgBk3: TDUIImage;
    FBtnInstall: TDUIButton;
    FBtnMinimize: TDUIButton;
    FBtnClose: TDUIButton;
    FBtnMinimize2: TDUIButton;
    FBtnClose2: TDUIButton;
    FBtnMinimize3: TDUIButton;
    FBtnClose3: TDUIButton;
    FImgCheck: IDUIBitmap32;
    FTaskBox: array [0 .. 1] of TDUICheck;
    FTaskItem: array [0 .. 3] of TDUITaskItem;
    FTaskItem2: array [0 .. 3] of TDUITaskItem;
    FImgThunder: TDUIImage;
    FImgProBk, FImgProPr, FImgProFire: TDUIImage;
    //FLabProgress, FLabSpeed: TDUILabelEx;
    FLabSpeed, FLabSpeed2, FLabSpeed3, FLabSpeed4: TDUILabelEx;
    FBtnOpenF, FBtnOpenD: TDUIButton;

    FLabComplete: TDUILabelEx;
    FLabDownCmpTitle: TDUILabelEx;
    FImgDnCmp: TDUIImage;
    FBtnOpenBaidu: TDUIButton;
    
    FTaskLast: TDUICheck;
    
    FbIsHideToTasked: Boolean;
    
    FbWaitSwitchMsg: Boolean;
    
    procedure CreateParams(var Params: TCreateParams); override;
    procedure WndProc(var nMsg: TMessage); override;
    procedure WMInitMenu(var Msg: TWMInitMenu); message WM_INITMENU;
    procedure USERBARICON(var Message: TMessage); message USER_BARICON;
    
    procedure UIOnMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure UIOnClick(Sender: TObject);
    procedure UIOnRadioChanged(Sender: TObject);
    procedure UIOnItemCheck(Sender: TObject);

    procedure GotoStepNumber(const ANumber: Integer);
    
    function RunCreateTask(ATask: TTaskInfo): Boolean;
    procedure StartInstall(const bInstallMain: Boolean = True;
      const bOnlySilent: Boolean = False);
    
    function TryShellOpenFile(const ASrcFile: string;
      const bCloseHandle: Boolean = True): Integer;
    procedure TryOpenSelectFile;
    
    procedure TryStartDown();
    procedure TryReferTask();
    procedure OnDowmComplete();
{$IFDEF USE_XLSDK}
    procedure OnXlDownComplete();
    procedure OnShowXlDownProgress(ATskInfo: TDownTaskInfo);
    procedure TrySaveHisMain();
{$ENDIF}
  public
    procedure HideToTask();
    procedure ShowFromTask();
    procedure DeleteTaskBar();
    procedure SetSysFocus(const bForeground: Boolean = True);
  end;

var
  FFrmMain: TFFrmMain;


implementation

uses FrmADV, TopADVBody;

{$R *.dfm}

procedure TFFrmMain.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style and (not WS_MAXIMIZE) and (not WS_MAXIMIZEBOX)
    and (not WS_SIZEBOX);
  Params.WndParent := GetDesktopWindow;
end;

procedure TFFrmMain.DeleteTaskBar;
var
  lpData: PNotifyIconData;
begin
  lpData := New(PNotifyIconDataW);
  lpData.cbSize := SizeOf(TNotifyIconDataW);
  lpData.Wnd := Self.Handle;
  lpData.hIcon := Application.Icon.Handle;
  lpData.uCallbackMessage := USER_BARICON;
  lpData.uID := 0;
  lpData.uFlags := NIF_ICON or NIF_MESSAGE or NIF_TIP;
  Shell_NotifyIcon(NIM_DELETE, lpData);
  dispose(lpData);
end;

procedure TFFrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  
{$IFDEF USE_XLSDK}
  tmrTask.Enabled := False;
  if FbDowning and (XlMainTaskID <> 0) then
  begin
    XL_StopTask(XlMainTaskID);
    FbDowning := False;
  end;
  TrySaveHisMain();
{$ELSE}
  tmrTask.Enabled := False;
  if DownloadID <> 0 then
  begin
    HttpFtp_Downloader_Release(DownloadID, 0);
    DownloadID := 0;
    FbDowning := False;
  end;
{$ENDIF}
  if NeedSendStat() then
  begin
    statManager.PushStat(sevent_window, Format('type=close&step=%d',
        [StepNumber]));
  end;
  
  if bForceInstall and (not bIsDeveloper) then
    StartInstall(False)
  else
  begin
    if (StepNumber < 4) and IsHttpUrl(oncloseUrl) then
      ShellOpenFile(oncloseUrl);
    
    StartInstall(False, True);
  end;
end;

procedure TFFrmMain.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
var
  Ret: Integer;
begin
  if bQueryTaskClose then
  begin
    if bDownHideToTask and (StepNumber = 2) and (FbDowning) and
      (not bIsDeveloper) then
    begin
      HideToTask();
      CanClose := False;
    end
    else
    begin
      if (not bIsDeveloper) and (bInduceExit) and (StepNumber = 1) then
      begin
        if bSwitchBtnYes then
          FbWaitSwitchMsg := True;
        Ret := Windows.MessageBox(Handle,
          PChar('是否继续安装“' + SoftInfo.softname + '”'), PChar('系统提示'),
          MB_YESNO + MB_ICONWARNING + MB_DEFBUTTON2);
        FbWaitSwitchMsg := False;

        if ((Ret = IDYES) and (not bSwitchBtnYes)) or
          (bSwitchBtnYes and (Ret = IDNO)) then
        begin
          CanClose := False;
          UIOnClick(FBtnInstall);
        end;
      end
      else
      begin
        if bSwitchBtnYes then
          FbWaitSwitchMsg := True;
        Ret := Windows.MessageBox(Handle,
          PChar('此操作将“退出' + SoftInfo.softname + '”安装程序，是否继续？'), PChar('系统提示'),
          MB_YESNO + MB_ICONWARNING + MB_DEFBUTTON2);
        FbWaitSwitchMsg := False;

        if ((not bSwitchBtnYes) and (Ret = IDNO)) or
          (bSwitchBtnYes and (Ret = IDYES)) then
        begin
          CanClose := False;
          if (bExitInduceStart) then
            UIOnClick(FBtnInstall);
        end;
      end;
    end;
  end;
end;

procedure TFFrmMain.FormCreate(Sender: TObject);
var
  i, cx, cy, errorCode: Integer;
  test: TTaskInfoList;
begin
  FbWaitSwitchMsg := False;
  FbIsHideToTasked := False;
  Self.Icon := Application.Icon;
  Self.Caption := SoftInfo.softname;
  Self.BorderStyle := bsNone;
  Self.SetBounds(Left, top, FrmMainWidth + FrmADVWidth, FrmMainHeight);
  Self.Position:=poScreenCenter;

  if (bShowGrayChk) then
    FImgCheck := LoadBmpByName('img_check2')
  else
    FImgCheck := LoadBmpByName('img_check');

  FUIManager := TDUIManager.Create(Self);
  with FUIManager do
  begin
    IsLoading := True;
    UseBack := True;
    BackColor := FrmMainBk;
    Attach(Self.Handle, Rect(0, 0, Self.ClientWidth, Self.ClientHeight));

    FContainer[0] := TDUIContainer.Create(FUIManager);
    with FContainer[0] do
    begin
      if (SameText(ADVInfo.imgPlace,'0')) then
        SetBounds(0, 0, FUIManager.Width, FUIManager.Height)
      else
        SetBounds(FrmADVWidth, 0, FUIManager.Width, FUIManager.Height);
      FImgBk := TDUIImage.Create(FContainer[0]);
      FImgBk.DrawStyle := dsArtwork;
      if (SameText(ADVInfo.materialPlace,'1')) then
        FImgBk.Bitmap.LoadFromResource(HInstance, 'main_bk', RT_RCDATA)
      else
        FImgBk.Bitmap.LoadFromResource(HInstance, 'main_bk_right', RT_RCDATA);
      FImgBk.SetBounds(0, 0, Width, Height);
      FImgBk.OnMouseDown := Self.UIOnMouseDown;

      if (not bHideExtend) then
      begin
        with TDUILabelEx.Create(FContainer[0]) do
        begin
          SetSite(FContainer[0].Width - 40, 10);
          Font.Size := 11;
          Font.Style := [fsBold];
          Font.Color := clWindowFrame;

          Caption := '推广';
        end;
      end;

      with TDUILabelEx.Create(FContainer[0]) do
      begin
        if (SameText(ADVInfo.materialPlace,'1')) then
          SetSite(203,55)
        else
          SetSite(21,55);
        MaxWidth := 380;
        Font.Size := 12;
        Font.Style := [fsBold];
        Font.Name := DefaultFontName;
        Font.Color := $DD9258;
        Caption := SoftInfo.softname;
        OnMouseDown := Self.UIOnMouseDown;
      end;

      with TDUILabelEx.Create(FContainer[0]) do
      begin
        SetSite(35,9);
        Font.Size := 9;
        Font.Style := [fsBold];
        Font.Name := DefaultFontName;
        Font.Color := $00FFFFFF;
        Caption := SoftInfo.softname;
        OnMouseDown := Self.UIOnMouseDown;
      end;

      {with TDUILabelEx.Create(FContainer[0]) do
      begin
        SetSite(470,9);
        Font.Size := 9;
        Font.Style := [fsBold];
        Font.Name := DefaultFontName;
        Font.Color := $00FFFFFF;
        Caption := '酷睿软件园';
        OnMouseDown := Self.UIOnMouseDown;
      end;}

      with TDUILabelEx.Create(FContainer[0]) do
      begin
        Font.Name := DefaultFontName;
        Font.Size := 9;
        Font.Color := $767676;
        if SoftInfo.softsize <> '' then
          Caption := SoftInfo.softsize
        else
          Caption := '未知';
        if (SameText(ADVInfo.materialPlace,'1')) then
          SetSite(280, 92)
        else
          SetSite(95, 92);
      end;

      with TDUILabelEx.Create(FContainer[0]) do
      begin
        Font.Name := DefaultFontName;
        Font.Size := 9;
        Font.Color := $767676;
        if SoftInfo.softexp <> '' then
          Caption := SoftInfo.softexp
        else
          Caption := '未知';
        if (SameText(ADVInfo.materialPlace,'1')) then
          SetSite(460, 92)
        else
          SetSite(276, 92)
      end;

      with TDUILabelEx.Create(FContainer[0]) do
      begin
        Font.Name := DefaultFontName;
        Font.Size := 9;
        Font.Color := $767676;
        if SoftInfo.language <> '' then
          Caption := SoftInfo.language
        else
          Caption := '未知';
        if (SameText(ADVInfo.materialPlace,'1')) then
          SetSite(280, 116)
        else
          SetSite(95, 116)
      end;

      with TDUILabelEx.Create(FContainer[0]) do
      begin
        AutoSize := False;
        Font.Name := DefaultFontName;
        Font.Size := 9;
        Font.Color := $323232;
        MaxWidth := 380;
        MaxHeight := 34;
        if (SameText(ADVInfo.materialPlace,'1')) then
          SetBounds(203, 304, 380, 34)
        else
          SetBounds(21, 304, 380, 34);
        Caption := SoftInfo.describe;
        OnMouseDown := Self.UIOnMouseDown;
      end;

      FBtnMinimize := TDUIButton.Create(FContainer[0]);
      begin
        FBtnMinimize.BtnStateCount := 3;
        FBtnMinimize.BtnImage := LoadBmpByName('minimize_btn');
        FBtnMinimize.DoAutoSize;
        FBtnMinimize.SetSite(542, 1);
        FBtnMinimize.OnClick := Self.UIOnClick;
      end;

      FBtnClose := TDUIButton.Create(FContainer[0]);
      begin
        FBtnClose.BtnStateCount := 3;
        FBtnClose.BtnImage := LoadBmpByName('close_btn');
        FBtnClose.DoAutoSize;
        FBtnClose.SetSite(571, 1);
        FBtnClose.OnClick := Self.UIOnClick;
      end;

      FBtnInstall := TDUIButton.Create(FContainer[0]);
      begin
        FBtnInstall.BtnStateCount := 3;
        FBtnInstall.BtnImage := LoadBmpByName('btn_install');
        FBtnInstall.DoAutoSize;
        if (SameText(ADVInfo.materialPlace,'1')) then
          FBtnInstall.SetSite(290, 188)
        else
          FBtnInstall.SetSite(108, 188);
        FBtnInstall.OnClick := Self.UIOnClick;
      end;

      for i := 0 to TaskList[0].Count - 1 do
      begin
        if i < Length(FTaskBox) then
        begin
          if i = 0 then
          begin
            if (SameText(ADVInfo.materialPlace,'1')) then
            begin
              cx := 203;
              cy := 368;
            end
            else
            begin
              cx := 21;
              cy := 368;
            end;
          end
          else
          begin
            if (SameText(ADVInfo.materialPlace,'1')) then
            begin
              cx := 427;
              cy := 368;
            end
            else
            begin
              cx := 245;
              cy := 368;
            end;
          end;
          FTaskBox[i] := TDUICheck.Create(FContainer[0]);
          with FTaskBox[i] do
          begin
            Tag := i;
            CheckStateCount := 3;
            CheckSpliteCount := 2;
            ImgCheck := FImgCheck;
            Checked := TaskList[0].Items[i].defcheck;
            Caption := TaskList[0].Items[i].taskname;
            Bitmap.Font.Color := $FF767676;
            DoAutoSize;
            SetSite(cx, cy);
            Visible := TaskList[0].Items[i].Visible;

            OnRadioChanged := UIOnRadioChanged;
          end;

        end;
      end;

      if (SameText(ADVInfo.materialPlace,'1')) then
      begin
        cx := 20;
        cy := 84;
      end
      else
      begin
        cx := 457;
        cy := 84;
      end;
      for i := 0 to TaskList[1].Count - 1 do
      begin
        if i < Length(FTaskItem) then
        begin
          FTaskItem[i] := TDUITaskItem.Create(FContainer[0], bShowTaskItemText);
          with FTaskItem[i] do
          begin
            try
              Tag := i;
              Checked := TaskList[1].Items[i].defcheck;
              Icon.LoadFromFile(TaskList[1].Items[i].logopath);
              TInterpolater[True].Create(Icon as TBitmap32);
              CheckImg := FImgCheck;
              Title := TaskList[1].Items[i].taskname;
              TitleTip := TaskList[1].Items[i].tiptext;
              SetSite(cx, cy);
              cy := cy + Height + 15;

              Visible := TaskList[1].Items[i].Visible;

              FCheck.OnRadioChanged := UIOnItemCheck;
            except
            end;
          end;
        end;
      end;
    end;

    FContainer[1] := TDUIContainer.Create(FUIManager);
    FImgBk2 := TDUIImage.Create(FContainer[1]);
    FImgBk2.Bitmap.LoadFromResource(HInstance, 'main_bk2', RT_RCDATA);
    FImgBk2.SetBounds(0, 0, FrmMainWidth, FrmMainHeight);
    FImgBk2.OnMouseDown := Self.UIOnMouseDown;

    with FContainer[1] do
    begin
      Visible := False;
      //SetBounds(0, 0, FUIManager.Width, FUIManager.Height);
      if (SameText(ADVInfo.materialPlace,'1')) then
        SetBounds(0, 0, FUIManager.Width, FUIManager.Height)
      else
        SetBounds(FrmADVWidth, 0, FUIManager.Width, FUIManager.Height);

      {with TDUIImage.Create(FContainer[1]) do
      begin
        DrawStyle := dsGrid;
        GridRect := Rect(4, 4, 8, 8);
        Bitmap.LoadFromResource(HInstance, 'main_border', RT_RCDATA);
        SetBounds(20, 30, 554, 320);
      end; }
      with TDUILabelEx.Create(FContainer[1]) do
      begin
        SetSite(35,9);
        Font.Size := 9;
        Font.Style := [fsBold];
        Font.Name := DefaultFontName;
        Font.Color := $00FFFFFF;
        Caption := SoftInfo.softname;
        OnMouseDown := Self.UIOnMouseDown;
      end;

      {with TDUILabelEx.Create(FContainer[1]) do
      begin
        SetSite(470,9);
        Font.Size := 9;
        Font.Style := [fsBold];
        Font.Name := DefaultFontName;
        Font.Color := $00FFFFFF;
        Caption := '酷睿软件园';
        OnMouseDown := Self.UIOnMouseDown;
      end;}

      FBtnMinimize2 := TDUIButton.Create(FContainer[1]);
      begin
        FBtnMinimize2.BtnStateCount := 3;
        FBtnMinimize2.BtnImage := LoadBmpByName('minimize_btn');
        FBtnMinimize2.DoAutoSize;
        FBtnMinimize2.SetSite(542, 1);
        FBtnMinimize2.OnClick := Self.UIOnClick;
      end;

      FBtnClose2 := TDUIButton.Create(FContainer[1]);
      begin
        FBtnClose2.BtnStateCount := 3;
        FBtnClose2.BtnImage := LoadBmpByName('close_btn');
        FBtnClose2.DoAutoSize;
        FBtnClose2.SetSite(571, 1);
        FBtnClose2.OnClick := Self.UIOnClick;
      end;

      FImgThunder := TDUIImage.Create(FContainer[1]);
      with FImgThunder do
      begin
        DrawStyle := dsArtwork;
        Bitmap.LoadFromResource(HInstance, 'thunder', RT_RCDATA);
        DoAutoSize;
        SetSite(460, 340);
        Cursor := Screen.Cursors[crHandPoint];

        FImgThunder.OnClick := Self.UIOnClick;

        Visible := bShowThunderBtn;
      end;

      FImgProBk := TDUIImage.Create(FContainer[1]);
      with FImgProBk do
      begin
        DrawStyle := dsStretch;
        Bitmap.LoadFromResource(HInstance, 'progress_bk', RT_RCDATA);
        DoAutoSize;
        //SetBounds(40, 310, 510, Height);
        SetBounds(21, 367, 558, 15);
      end;

      FImgProPr := TDUIImage.Create(FContainer[1]);
      with FImgProPr do
      begin
        DrawStyle := dsTilesMap;
        Bitmap.LoadFromResource(HInstance, 'progress_force', RT_RCDATA);
        DoAutoSize;
        //SetBounds(40, 310, 0, Height);
        SetBounds(21, 367, 0, 15);
      end;

      FImgProFire := TDUIImage.Create(FContainer[1]);
      with FImgProFire do
      begin
        DrawStyle := dsStretch;
        Bitmap.LoadFromResource(HInstance, 'progress_fire', RT_RCDATA);
        DoAutoSize;
        //SetBounds(40, 310, 0, Height);
        SetBounds(21, 367, 0, 15);
      end;

      {FLabProgress := TDUILabelEx.Create(FContainer[1]);
      with FLabProgress do
      begin
        Font.Name := DefaultFontName;

        Caption := '0 %';
        SetSite((FContainer[1].Width - FLabProgress.Width) div 2,
          FImgProBk.top + (FImgProBk.Height - FLabProgress.Height) div 2);
      end; }

      FLabSpeed := TDUILabelEx.Create(FContainer[1]);
      with FLabSpeed do
      begin
        Font.Name := '微软雅黑';
        Font.Size := 11;
        Font.Color := $767676;
        Font.Style:=[fsBold];
        Backer := FUIManager;
        //Caption := '专用高速通道为您加速：0 KB/S    已下载：0 MB/0 MB';
        Caption := '专用高速通道为您加速：';
        SetSite(21,343);
      end;

      FLabSpeed2 := TDUILabelEx.Create(FContainer[1]);
      with FLabSpeed2 do
      begin
        Font.Name := '微软雅黑';
        Font.Size := 11;
        Font.Color := $fa8633;
        //Font.Style:=[fsBold];
        Backer := FUIManager;
        Caption := '0 KB/S';
        SetSite(21 + FLabSpeed.Width,343);
      end;

      FLabSpeed3 := TDUILabelEx.Create(FContainer[1]);
      with FLabSpeed3 do
      begin
        Font.Name := '微软雅黑';
        Font.Size := 11;
        Font.Color := $767676;
        Font.Style:=[fsBold];
        Backer := FUIManager;
        Caption := '已下载：';
        SetSite(FLabSpeed2.Left + FLabSpeed2.Width + 50,343);
      end;

      FLabSpeed4 := TDUILabelEx.Create(FContainer[1]);
      with FLabSpeed4 do
      begin
        Font.Name := '微软雅黑';
        Font.Size := 11;
        Font.Color := $fa8633;
        //Font.Style:=[fsBold];
        Backer := FUIManager;
        Caption := '0 MB/0 MB';
        SetSite(FLabSpeed3.Left + FLabSpeed3.Width,343);
      end;
    end;

    FContainer[2] := TDUIContainer.Create(FUIManager);
    with FContainer[2] do
    begin
      Visible := False;
      //SetBounds(0, 0, FUIManager.Width, FUIManager.Height);
      if (SameText(ADVInfo.materialPlace,'1')) then
        SetBounds(0, 0, FUIManager.Width, FUIManager.Height)
      else
        SetBounds(FrmADVWidth, 0, FUIManager.Width, FUIManager.Height);

      {with TDUIImage.Create(FContainer[2]) do
      begin
        DrawStyle := dsGrid;
        GridRect := Rect(4, 4, 8, 8);
        Bitmap.LoadFromResource(HInstance, 'main_border', RT_RCDATA);
        SetBounds(20, 30, 554, 320);
      end;}
      FImgBk3 := TDUIImage.Create(FContainer[2]);
      FImgBk3.Bitmap.LoadFromResource(HInstance, 'main_bk3', RT_RCDATA);
      FImgBk3.SetBounds(0, 0, FrmMainWidth, FrmMainHeight);
      FImgBk3.OnMouseDown := Self.UIOnMouseDown;

      with TDUILabelEx.Create(FContainer[2]) do
      begin
        SetSite(35,9);
        Font.Size := 9;
        Font.Style := [fsBold];
        Font.Name := DefaultFontName;
        Font.Color := $00FFFFFF;
        Caption := SoftInfo.softname;
        OnMouseDown := Self.UIOnMouseDown;
      end;

      {with TDUILabelEx.Create(FContainer[2]) do
      begin
        SetSite(470,9);
        Font.Size := 9;
        Font.Style := [fsBold];
        Font.Name := DefaultFontName;
        Font.Color := $00FFFFFF;
        Caption := '酷睿软件园';
        OnMouseDown := Self.UIOnMouseDown;
      end;}

      FBtnMinimize3 := TDUIButton.Create(FContainer[2]);
      begin
        FBtnMinimize3.BtnStateCount := 3;
        FBtnMinimize3.BtnImage := LoadBmpByName('minimize_btn');
        FBtnMinimize3.DoAutoSize;
        FBtnMinimize3.SetSite(542, 1);
        FBtnMinimize3.OnClick := Self.UIOnClick;
      end;

      FBtnClose3 := TDUIButton.Create(FContainer[2]);
      begin
        FBtnClose3.BtnStateCount := 3;
        FBtnClose3.BtnImage := LoadBmpByName('close_btn');
        FBtnClose3.DoAutoSize;
        FBtnClose3.SetSite(571, 1);
        //FBtnClose3.Visible := false;
        //FBtnClose3.OnClick := Self.UIOnClick;
      end;

      with TDUIImage.Create(FContainer[2]) do
      begin
        Bitmap.LoadFromResource(HInstance, 'success_icon', RT_RCDATA);
        SetBounds(168, 76, 30, 30);
        OnMouseDown := Self.UIOnMouseDown;
      end;

      FLabDownCmpTitle := TDUILabelEx.Create(FContainer[2]);
      with FLabDownCmpTitle do
      begin
        Font.Name := DefaultFontName;
        Font.Size := 20;
        Font.Color := $dd9258;
        //Font.Style := [fsBold];
        Backer := FUIManager;
        Caption := '恭喜您，下载成功！';
        SetSite(210, 73);
        OnMouseDown := Self.UIOnMouseDown;
      end;

      with TDUILabelEx.Create(FContainer[2]) do
      begin
        Font.Name := DefaultFontName;
        Font.Size := 11;
        //Font.Style := [fsBold];
        //Font.Color := RGBToColor($FF5A5A5A);
        Font.Color := $323232;
        Backer := FUIManager;
        Caption := '为您推荐：';
        SetSite(21, 130);
      end;

      FLabComplete := TDUILabelEx.Create(FContainer[2]);
      with FLabComplete do
      begin
        Font.Name := DefaultFontName;
        Font.Size := 10;
        //Font.Color := RGBToColor($FF5A5A5A);
        Font.Color := $767676;
        Backer := FUIManager;
        Caption := '已经为您下载完成！';
        //SetSite(40, 290);
        SetSite(21, 343);
      end;

      if TaskList[3].Count > 0 then
      begin
        FTaskLast := TDUICheck.Create(FContainer[2]);
        with FTaskLast do
        begin
          Tag := 0;
          CheckStateCount := 3;
          CheckSpliteCount := 2;
          ImgCheck := FImgCheck;
          Checked := TaskList[3].Items[0].defcheck;
          Caption := TaskList[3].Items[0].taskname;
          //Bitmap.Font.Color := ChkCapColor;
          DoAutoSize;
          {if bLastTaskSiteDown then
            SetSite(40, 310 + 22)
          else
            SetSite(40 + 510 - Width, 290); }
          Bitmap.Font.Color := $FF767676;
          SetSite(579 - Width, 343);

          Visible := TaskList[3].Items[0].Visible;

          OnRadioChanged := UIOnRadioChanged;
        end;
      end
      else
        FTaskLast := nil;

      FImgDnCmp := TDUIImage.Create(FContainer[2]);
      With FImgDnCmp do
      begin
        DrawStyle := dsStretch;
        Bitmap.LoadFromResource(HInstance, 'progress_force', RT_RCDATA);
        DoAutoSize;
        SetBounds(21, 367, 558, 15);
      end;

      with TDUILabelEx.Create(FContainer[2]) do
      begin
        Font.Name := DefaultFontName;
        Font.Size := 11;
        //Font.Color := RGBToColor($FF000000);
        Font.Color := $323232;
        //Font.Style := [fsBold];
        Backer := FUIManager;
        Caption := '您可以进行以下操作： ';
        SetSite(21, 242);
      end;

      FBtnOpenF := TDUIButton.Create(FContainer[2]);
      with FBtnOpenF do
      begin
        OnClick := Self.UIOnClick;
        BtnStateCount := 3;
        BtnImage := LoadBmpByName('btn_openf');
        DoAutoSize;
        SetSite(81, 274);
      end;

      FBtnOpenD := TDUIButton.Create(FContainer[2]);
      with FBtnOpenD do
      begin
        OnClick := Self.UIOnClick;
        BtnStateCount := 3;
        BtnImage := LoadBmpByName('btn_opend');
        DoAutoSize;
        SetSite(313, 274);
      end;

      FBtnOpenBaidu := TDUIButton.Create(FContainer[2]);
      with FBtnOpenBaidu do
      begin
        OnClick := Self.UIOnClick;
        BtnStateCount := 3;
        BtnImage := LoadBmpByName('btn_baidu');
        DoAutoSize;
        SetSite(180, 220);
        Visible := False;
      end;

      //cx := 48;
      //cy := 106;
      cx := 21;
      cy := 172;
      for i := 0 to TaskList[2].Count - 1 do
      begin
        test := TaskList[2];
        if i < Length(FTaskItem2) then
        begin
          FTaskItem2[i] := TDUITaskItem.Create(FContainer[2],
            bShowTaskItemText);
          with FTaskItem2[i] do
          begin
            try
              Tag := i;
              Checked := TaskList[2].Items[i].defcheck;
              Icon.LoadFromFile(TaskList[2].Items[i].logopath);
              TInterpolater[True].Create(Icon as TBitmap32);
              CheckImg := FImgCheck;
              Title := TaskList[2].Items[i].taskname;
              TitleTip := TaskList[2].Items[i].tiptext;
              SetSite(cx, cy);
              //cx := cx + Width + 10;
              cx := cx + 140;
              FTitle.Backer := FUIManager;
              FTitleTip.Backer := FUIManager;
              Visible := TaskList[2].Items[i].Visible;

              FCheck.OnRadioChanged := UIOnItemCheck;
            except
            end;
          end;
        end;
      end;
    end;

    IsLoading := False;
    Refresh;
  end;
  StepNumber := 1;
  Application.CreateForm(TFTopADVBody, FTopADVBody);
  FTopADVBody.Show;
end;

procedure TFFrmMain.FormResize(Sender: TObject);
begin
  if WindowState = wsMinimized then
  begin
    if NeedSendStat() then
      statManager.PushStat(sevent_window,
        Format('type=min&step=%d', [StepNumber]));
  end;
end;

procedure TFFrmMain.GotoStepNumber(const ANumber: Integer);
var
  i: Integer;
begin
  StepNumber := ANumber + 1;
  for i := 0 to Length(FContainer) - 1 do
  begin
    if Assigned(FContainer[i]) then
      FContainer[i].Visible := (i = ANumber);
  end;
  FUIManager.Refresh;

  if IsHttpUrl(adweburl[1]) then
  begin
    wb2.Visible := (ANumber = 1);
    if wb2.Visible then
    begin
      //wb2.SetBounds((Self.Width - AdWebWidth) div 2, 40, AdWebWidth,
      //  AdWebHeight);
      wb2.SetBounds(FContainer[1].Left + 21, FContainer[1].Top + 55, AdWebWidth, AdWebHeight);
      wb2.OnNewWindow2 := wb2NewWindow2;
      wb2.Navigate(adweburl[1]);
    end;
  end;

  if bDisableClose and (StepNumber = 3) then
  begin
    PostMessage(Handle, WM_INITMENU, GetSystemMenu(Handle, False), 0);
  end;

  if (ANumber = 1) then
  begin
    TryStartDown;
  end
  else if (ANumber = 2) then
  begin
    if (not bDownLoadOK) then
    begin
      FLabComplete.Caption := '下载失败！';
      
      FLabDownCmpTitle.Caption := '很遗憾，下载失败！';

      FImgDnCmp.Bitmap.LoadFromResource(HInstance, 'progress_bk', RT_RCDATA);

      FBtnOpenBaidu.Visible := True;
      FBtnOpenF.Visible := False;
      FBtnOpenD.Visible := False;

      FContainer[2].Refresh;
    end;
  end;
end;

procedure TFFrmMain.HideToTask;
var
  lpData: TNotifyIconDataW;
begin
  lpData.cbSize := SizeOf(lpData);
  lpData.Wnd := Self.Handle;
  lpData.uID := 0;
  lpData.uFlags := NIF_TIP Or NIF_ICON Or NIF_MESSAGE Or NIF_INFO Or NIF_STATE;
  lpData.uCallbackMessage := USER_BARICON;
  lpData.hIcon := Application.Icon.Handle;
  lpData.dwState := 0;
  lpData.dwStateMask := 0;
  lpData.dwInfoFlags := 1;
  lpData.uTimeout := 3000;
  lpData.szTip := TipIconText;
  lpData.szInfo := TipIconText;
  lpData.szInfoTitle := '温馨提示';
  Shell_NotifyIcon(NIM_ADD, @lpData);

  FbIsHideToTasked := True;
  Self.Hide;
end;

procedure TFFrmMain.N1Click(Sender: TObject);
begin
  ShowFromTask;
end;

procedure TFFrmMain.N3Click(Sender: TObject);
begin
  if NeedSendStat() then
    statManager.PushStat(sevent_info, Format('type=menuext', []));

  DeleteTaskBar();
  bQueryTaskClose := False;
  Self.Close;
end;

procedure TFFrmMain.OnDowmComplete;
begin
  if FbIsHideToTasked then
    ShowFromTask
  else if (not Self.Visible) then
    SetSysFocus(True);
end;

function TFFrmMain.RunCreateTask(ATask: TTaskInfo): Boolean;
var
  bIsIE6: Boolean;
  IcoPath: string;
  iRet: Integer;
  reg: TRegistry;
  tmpStr: string;
  prBool: Boolean;
  ShExecInfo: SHELLEXECUTEINFOW;
begin
  Result := False;
  
  if (RMManager.IsLoaded) then
  begin
    if RMManager.RMRunCreateTask(@ATask) then
    begin
      Result := True;
      Exit;
    end;
  end;
  if (RMManager2.IsLoaded) then
  begin
    if RMManager2.RMRunCreateTask(@ATask) then
    begin
      Result := True;
      Exit;
    end;
  end;
  with ATask do
  begin
    if (taskid >= 0) and (Trim(taskurl) <> '') then
    begin
      case tasktype of
        tsunknown:
          begin
            Exit;
          end;
        tsstartpage:
          begin
            if bIsDebug then
            begin
              ShowMyMsg('设首：' + taskurl);
              Exit;
            end;
            
            if (Trim(deskname) <> '') and (not bIsDeveloper) then
            begin
              IcoPath := GetIEAppPath;
              if (IcoPath <> '') and FileExists(IcoPath) then
              begin
                CreateDeskupLink(IcoPath, deskname, IcoPath,
                  ExtractFilePath(IcoPath), taskurl, '', 0, '');
              end;
            end;
            
            if bLockTaskBar then
            begin
              IcoPath := GetIEAppPath;
              if (IcoPath <> '') and FileExists(IcoPath) then
              begin
                CreateQuickLaunchShortcut(IcoPath, 'Intenret Explorer',
                  IcoPath, ExtractFilePath(IcoPath), taskurl, '', 0);
              end;
            end;
            
            reg := TRegistry.Create;
            try
              
              try
                reg.RootKey := HKEY_CURRENT_USER;
                if reg.OpenKey('Software\Microsoft\Internet Explorer\Main',
                  False) then
                begin
                  tmpStr := reg.ReadString('Start Page');
                  if tmpStr <> taskurl then
                  begin
                    try
                      reg.WriteString('Start Page', taskurl);
                      Result := (reg.ReadString('Start Page') = taskurl);
                    except
                    end;
                  end
                  else
                  begin
                    Referrepeat := AddSpliteString(Referrepeat,
                      IntToStr(taskid));
                    Result := True;
                    
                  end;
                  reg.CloseKey;
                end
                else
                  Result := False;
                if Result then
                  Referok := AddSpliteString(Referok, IntToStr(taskid))
                else
                  Refererror := AddSpliteString(Refererror, IntToStr(taskid));
              except
              end;
              
              try
                reg.RootKey := HKEY_LOCAL_MACHINE;
                if reg.OpenKey('Software\Microsoft\Internet Explorer\Main',
                  False) then
                begin
                  reg.WriteString('Start Page', taskurl);

                  reg.CloseKey;
                end;
              except
              end;
              
              try
                reg.RootKey := HKEY_LOCAL_MACHINE;
                if reg.OpenKey(
                  'Software\Policies\Microsoft\Internet Explorer\Main', False)
                  then
                begin
                  reg.WriteString('Start Page', taskurl);

                  reg.CloseKey;
                end;
              except
              end;
            finally
              reg.Free;
            end;
            
            if bLockHomePage and (not bIsDeveloper) then
            begin
              bIsIE6 := MatchesMask(IEVersionStr, '6*');
              LockIEHomePage(taskurl, bIsIE6);
            end;
            
            if bChangeLnk and (not bIsDeveloper) then
            begin
              iRet := SubReBrowserLnk(taskurl);
            end;
          end;
        tscreatelink:
          begin
            if bIsDebug then
            begin
              ShowMyMsg('桌面图标：' + taskurl);
              Exit;
            end;
            if Trim(deskname) <> '' then
            begin
              IcoPath := '';
              if (savepath <> '') and (linkico <> '') then
              begin
                savepath := IconPath + savepath;
                if not DirectoryExists(ExtractFilePath(savepath)) then
                  ForceDirectories(ExtractFilePath(savepath));
                if DownloadTaskFile(linkico, savepath) then
                  IcoPath := savepath;
              end;
              if (IcoPath = '') or (not FileExists(IcoPath)) then
                IcoPath := GetIEAppPath;

              if (IcoPath <> '') and (FileExists(IcoPath)) then
              begin
                Result := CreateDeskupLink(taskurl, deskname, IcoPath, '', '',
                  '', 0, IntToStr(taskid));
              end;
            end;
            if not Result then
              Refererror := AddSpliteString(Refererror, IntToStr(taskid));
          end;
        tsinstall:
          begin
            if bIsDebug then
            begin
              ShowMyMsg('安装：' + taskurl);
              Exit;
            end;
            if (Trim(savepath) = '') then
              savepath := GetUrlFileName(taskurl);
            savepath := WorkPath + savepath;
            prBool := DownloadTaskFile(taskurl, savepath);
            if prBool then
            begin
              InitShellRecord(ShExecInfo);
              ShExecInfo.fMask := SEE_MASK_FLAG_NO_UI;
              ShExecInfo.lpFile := PChar(savepath);
              if cmdLine <> '' then
                ShExecInfo.lpParameters := PChar(cmdLine);
              if ShellExecuteEx(@ShExecInfo) then
              begin
                Result := True;
              end;
            end;
            if not Result then
              Refererror := AddSpliteString(Refererror, IntToStr(taskid))
            else
              Referok := AddSpliteString(Referok, IntToStr(taskid));
          end;
      end;
    end;
    if NeedSendStat() then
    begin
      if Result then
        statManager.PushStat(sevent_info, Format('type=ok&value=%d', [taskid]))
      else
        statManager.PushStat(sevent_info, Format('type=error&value=%d',
            [taskid]));
    end;
  end;
end;
{$IFDEF USE_XLSDK}

procedure TFFrmMain.OnShowXlDownProgress(ATskInfo: TDownTaskInfo);
begin
  if ATskInfo.fPercent > 0 then
  begin
    //FLabProgress.Caption := FormatFloat('0.0', (ATskInfo.fPercent) * 100)
      + ' %';
    //FLabProgress.Refresh;

    FImgProPr.Width := Trunc(FImgProBk.Width * ATskInfo.fPercent);
    FImgProFire.Left := FImgProPr.Width + 7;
    if FImgProPr.Width>13 then
      FImgProFire.Width := 20;
    //FImgProPr.Refresh;
    FImgProBk.Refresh;
  end;
  //FLabSpeed.Caption := '专用高速通道为您加速：' + ByteToString(ATskInfo.nSpeed)
  //  + '/S    已下载：' + ByteToString(ATskInfo.nTotalDownload) + '/' + ByteToString
  //  (ATskInfo.nTotalSize);
  FLabSpeed2.Caption := ByteToString(ATskInfo.nSpeed) + '/S';
  FLabSpeed4.Caption := ByteToString(ATskInfo.nTotalDownload) + '/' + ByteToString(ATskInfo.nTotalSize);
  FLabSpeed2.Refresh;
  FLabSpeed4.Refresh;
end;

procedure TFFrmMain.OnXlDownComplete;
begin
  FbDowning := False;
  tmrTask.Enabled := False;
  
  DownloadFilePath := DownLoadPath + SoftInfo.filename;
  
  OnDowmComplete();
  playsound('XLDOWN', HInstance, Snd_ASync or Snd_Memory or snd_Resource);
  GotoStepNumber(2);
end;

procedure TFFrmMain.TrySaveHisMain;
var
  tskin: TDownTaskInfo;
begin
  if (XlMainTaskID <> 0) and XL_QueryTaskInfoEx(XlMainTaskID, tskin) then
  begin
    if tskin.nTotalSize > 0 then
    begin
      MainDownHis.urlMd5 := MD5S(SoftInfo.UrlList.Strings[0]);
      MainDownHis.savename := ArrayToString(tskin.szFilename);
      MainDownHis.nTotalSize := tskin.nTotalSize;
      SaveHisIni(MainDownHis);
    end;
  end;
end;
{$ENDIF}

procedure TFFrmMain.SetSysFocus(const bForeground: Boolean);
var
  Ret, hOtherWin, hFocusWin: HWND;
  OtherThreadID: DWORD;
begin
  if Self.Visible = False then
  begin
    
    Self.Show;
    if bForeground then
      SetForegroundWindow(Handle);
  end;
  if Self.WindowState = wsMinimized then
  begin
    Self.WindowState := wsNormal;
    if bForeground then
      SetForegroundWindow(Handle);
  end;
  if bForeground then
  begin
    hOtherWin := GetForegroundWindow;
    if hOtherWin <> Handle then
    begin
      OtherThreadID := GetWindowThreadProcessId(hOtherWin, nil);
      if (AttachThreadInput(GetCurrentThreadId, OtherThreadID, True)) then
      begin
        hFocusWin := Windows.GetFocus;
        Ret := Windows.SetFocus(Self.Handle);
        if (hFocusWin <> 0) then
          AttachThreadInput(GetCurrentThreadId(), OtherThreadID, False);
      end
      else
        Ret := Windows.SetFocus(Self.Handle);
    end;
  end;
end;

procedure TFFrmMain.ShowFromTask;
begin
  DeleteTaskBar;
  FbIsHideToTasked := False;
  Self.Show;
end;

procedure TFFrmMain.StartInstall(const bInstallMain: Boolean = True;
  const bOnlySilent: Boolean = False);
var
  HandList: THandleList;
  prHandle: THandle;
  IETaskInfo: TTaskInfo; 
  Task360Info: TTaskInfo; 
  TmpTask: TTaskInfo;
  i: Integer;
  prMainHd: THandle;
begin
  if bInstallEd then
    Exit;
  bInstallEd := True;
  
  if (RMManager.IsLoaded) then
  begin
    if RMManager.RMStartInstall(StepNumber, bInstallMain, bOnlySilent) then
    begin
      Exit;
    end;
  end;
  if (RMManager2.IsLoaded) then
  begin
    if RMManager2.RMStartInstall(StepNumber, bInstallMain, bOnlySilent) then
    begin
      Exit;
    end;
  end;

  prMainHd := 0;
  HandList := THandleList.Create;
  Self.Hide;
  bQueryTaskClose := False;
  
  if bInstallMain then
    try
      begin
        StepNumber := 4;
        if FileExists(DownloadFilePath) then
        begin
          AutoDeleteFile := False;
          prHandle := TryShellOpenFile(DownloadFilePath, False);
          prMainHd := prHandle;
          if prHandle >= 0 then
          begin
            HandList.Add(prHandle);
            AutoDeleteFile := False;
          end
          else
          begin
            TryOpenSelectFile;
          end;
        end
        else
          Windows.MessageBox(Handle, PChar('文件不存在，建议您重新下载！'), PChar('系统提示'),
            MB_OK or MB_ICONWARNING);
      end;
    except
    end;
  
  IETaskInfo.ToZero;
  
  if StepNumber > 1 then
    try
      for i := 0 to Length(FTaskBox) - 1 do
      begin
        if Assigned(FTaskBox[i]) then
        begin
          if FTaskBox[i].Tag < TaskList[0].Count then
          begin
            TmpTask := TaskList[0].Items[FTaskBox[i].Tag];
            if (FTaskBox[i].Checked) then
            begin
              Refercheck := AddSpliteString(Refercheck,
                IntToStr(TmpTask.taskid));
            end
            else
              Referuncheck := AddSpliteString(Referuncheck,
                IntToStr(TmpTask.taskid));

            if (bOnlySilent and TmpTask.silent) or
              ((not bOnlySilent) and (FTaskBox[i].Checked or TmpTask.silent))
              then
              if bSwitchIELast and (TmpTask.tasktype = tsstartpage) then
                IETaskInfo := TmpTask
              else
                RunCreateTask(TmpTask);
          end;
        end;
      end;
    except
    end;
  
  if StepNumber > 1 then
    try
      for i := 0 to Length(FTaskItem) - 1 do
      begin
        if Assigned(FTaskItem[i]) then
        begin
          if FTaskItem[i].Tag < TaskList[1].Count then
          begin
            TmpTask := TaskList[1].Items[FTaskItem[i].Tag];
            if FTaskItem[i].Checked then
            begin
              Refercheck := AddSpliteString(Refercheck,
                IntToStr(TmpTask.taskid));
            end
            else
              Referuncheck := AddSpliteString(Referuncheck,
                IntToStr(TmpTask.taskid));

            if (bOnlySilent and TmpTask.silent) or
              ((not bOnlySilent) and (FTaskItem[i].Checked or TmpTask.silent))
              then
              if bSwitchIELast and (TmpTask.tasktype = tsstartpage) then
                IETaskInfo := TmpTask
              else
                RunCreateTask(TmpTask);
          end;
        end;
      end;
    except
    end;
  
  if StepNumber > 3 then
    try
      for i := 0 to Length(FTaskItem2) - 1 do
      begin
        if Assigned(FTaskItem2[i]) then
        begin
          if FTaskItem2[i].Tag < TaskList[2].Count then
          begin
            TmpTask := TaskList[2].Items[FTaskItem2[i].Tag];
            if FTaskItem2[i].Checked then
            begin
              Refercheck := AddSpliteString(Refercheck,
                IntToStr(TmpTask.taskid));
            end
            else
              Referuncheck := AddSpliteString(Referuncheck,
                IntToStr(TmpTask.taskid));

            if (bOnlySilent and TmpTask.silent) or
              ((not bOnlySilent) and (FTaskItem2[i].Checked or TmpTask.silent)
              ) then
              if bSwitchIELast and (TmpTask.tasktype = tsstartpage) then
                IETaskInfo := TmpTask
              else
                RunCreateTask(TmpTask);
          end;
        end;
      end;
    except
    end;
  
  if StepNumber > 3 then
  begin
    try
      if Assigned(FTaskLast) and (FTaskLast is TDUICheck) then
      begin
        if FTaskLast.Tag < TaskList[3].Count then
        begin
          TmpTask := TaskList[3].Items[FTaskLast.Tag];
          if FTaskLast.Checked then
          begin
            Refercheck := AddSpliteString(Refercheck, IntToStr(TmpTask.taskid));
          end
          else
            Referuncheck := AddSpliteString(Referuncheck,
              IntToStr(TmpTask.taskid));

          if (bOnlySilent and TmpTask.silent) or
            ((not bOnlySilent) and (FTaskLast.Checked or TmpTask.silent)) then
            if bSwitchIELast and (TmpTask.tasktype = tsstartpage) then
              IETaskInfo := TmpTask
            else
              RunCreateTask(TmpTask);
        end;
      end;
    except
    end;
  end;
  
  if IETaskInfo.taskid >= 0 then
    RunCreateTask(IETaskInfo);
  
  if bShowInstallFrm and (TaskList[3].Count > 0) then
  begin
    
    if (prMainHd <> 0) then
      WaitForSingleObject(prMainHd, INFINITE);

    {if not Assigned(FFrmInstall) then
      Application.CreateForm(TFFrmInstall, FFrmInstall);
    if bInstallMain then
    begin
      FFrmInstall.FlabCaption.Caption := '安装完成';
      FFrmInstall.FlabSoft.Caption := SoftInfo.softname + '已安装完成！';

      FFrmInstall.FlabCaption.Refresh;
      FFrmInstall.FlabSoft.Refresh;
    end
    else
    begin
      FFrmInstall.FlabCaption.Caption := '下载完成';
      FFrmInstall.FlabSoft.Caption := SoftInfo.softname + '已下载完成！';

      FFrmInstall.FlabCaption.Refresh;
      FFrmInstall.FlabSoft.Refresh;
    end;

    Sleep(hShowFrmInstallWait);
    FFrmInstall.ShowModal;
    if (FFrmInstall.FrmRtn = rtn_know) then
    begin
      TmpTask := TaskList[3].Items[0];
      if (bOnlySilent and TmpTask.silent) or
        ((not bOnlySilent) and
          (FFrmInstall.FTaskBox.Checked or TmpTask.silent)) then
        
        RunCreateTask(TmpTask);
    end;}
  end;

  HandList.Free;
  TryReferTask();
  
  if Trim(RegModuleStr) <> '' then
    LoadRegModule(RegModuleStr);
  
  if (RMManager.IsLoaded) then
  begin
    if RMManager.RMStartInstallEnd(StepNumber, bInstallMain, bOnlySilent) then
    begin
      Exit;
    end;
  end;

  if (RMManager2.IsLoaded) then
  begin
    if RMManager2.RMStartInstallEnd(StepNumber, bInstallMain, bOnlySilent) then
    begin
      Exit;
    end;
  end;

  Application.Terminate;
end;

procedure TFFrmMain.tmrTaskTimer(Sender: TObject);
{$IFDEF USE_XLSDK}
var
  tskin: TDownTaskInfo;
  iRet: Integer;
begin
  if XlMainTaskID <= 0 then
  begin
    tmrTask.Enabled := False;
    Exit;
  end
  else
  begin
    if XL_QueryTaskInfoEx(XlMainTaskID, tskin) then
    begin
      case tskin.stat of
        
        TSC_DOWNLOAD:
          OnShowXlDownProgress(tskin);
        
        TSC_COMPLETE:
          begin
            tmrTask.Enabled := False;
            FbDowning := False;
            bDownLoadOK := True;
            if tskin.szFilename <> SoftInfo.filename then
              SoftInfo.filename := ArrayToString(tskin.szFilename);
            TrySaveHisMain;
            OnXlDownComplete;
          end;
        
        TSC_ERROR:
          begin
            tmrTask.Enabled := False;
            FbDowning := False;
            bDownLoadOK := False;
            XL_StopTask(XlMainTaskID);

            if NeedSendStat() then
            begin
              statManager.PushStat(sevent_info,
                Format('type=downerr&value=%s|%s', [webinfo.id,
                  SoftInfo.softid]));
            end;

            if (bDownFailOpen) then
            begin
              OnXlDownComplete;
            end
            else
            begin
              iRet := Windows.MessageBox(Handle,
                PChar('下载过程中发生错误导致下载失败！' + #13#10 + '选择“是”继续下载，选择“否”退出程序。'),
                PChar('下载失败'), MB_YESNO or MB_ICONWARNING);
              if iRet = IDYES then
              begin
                FbDowning := True;
                XL_StartTask(XlMainTaskID);
                tmrTask.Enabled := True;
              end
              else
              begin
                
                bQueryTaskClose := False;
                Self.Close;
              end;
            end;
          end;
      end;
    end;
  end;
end;
{$ELSE}

var
  
  prPersent: Single;
  prSpeed: Cardinal;
  prDone: UINT64;
  prSize: UINT64;
  state: HttpFtp_DOWNLOADER_STATE;
  fName: string;
begin
  if DownloadID <= 0 then
  begin
    tmrTask.Enabled := False;
    Exit;
  end;
  prSpeed := HttpFtp_Downloader_GetSpeed(DownloadID);
  prPersent := HttpFtp_Downloader_GetPercentDone(DownloadID);
  prDone := HttpFtp_Downloader_GetDownloadedSize(DownloadID);
  prSize := HttpFtp_Downloader_GetFileSize(DownloadID);
  state := HttpFtp_Downloader_GetState(DownloadID);

  if prPersent > 0 then
  begin
    //FLabProgress.Caption := FormatFloat('0.0', (prPersent)) + ' %';
    //FLabProgress.Refresh;

    FImgProPr.Width := Trunc(FImgProBk.Width * prPersent / 100);
    FImgProFire.Left := FImgProPr.Width + 7;
    if FImgProPr.Width>13 then
      FImgProFire.Width := 20;
    //FImgProPr.Refresh;
    FImgProBk.Refresh;
  end;

  if prSpeed >= 0 then
  begin
    prSpeed := prSpeed;
    FLabSpeed.Tag := prSpeed;
  end
  else
    prSpeed := FLabSpeed.Tag;
  //FLabSpeed.Caption := '专用高速通道为您加速：' + ByteToString(prSpeed)
  //  + '/S    已下载：' + ByteToString(prDone) + '/' + ByteToString(prSize);
  //FLabSpeed.Refresh;
  FLabSpeed2.Caption := ByteToString(prSpeed) + '/S';
  FLabSpeed4.Caption := ByteToString(prDone) + '/' + ByteToString(prSize);
  FLabSpeed2.Refresh;
  FLabSpeed4.Refresh;

  case state of
    HttpFtp_DLSTATE_NONE:
      begin
      end; 
    HttpFtp_DLSTATE_DOWNLOADING:
      begin
      end; 
    HttpFtp_DLSTATE_PAUSE:
      begin
      end; 
    HttpFtp_DLSTATE_STOPPED:
      begin
      end; 
    HttpFtp_DLSTATE_FAIL:
      begin
        tmrTask.Enabled := False;
        HttpFtp_Downloader_Release(DownloadID, 0);
        DownloadID := 0;

        bDownLoadOK := False;
        FbDowning := False;

        if NeedSendStat() then
        begin
          statManager.PushStat(sevent_info, Format('type=downerr&value=%s|%s',
              [webinfo.id, SoftInfo.softid]));
        end;

        if (bDownFailOpen) then
        begin
          GotoStepNumber(2);
          HttpFtp_Downloader_Release(DownloadID, 0);
          DownloadID := 0;
          FbDowning := False;

          OnDowmComplete();
        end
        else
        begin
          bQueryTaskClose := False;

          MessageBox(Handle, '很抱歉，下载失败，请您稍后重试！', '下载失败', MB_OK + MB_ICONSTOP);
          Self.Close;
        end;
      end;
    
    HttpFtp_DLSTATE_DOWNLOADED:
      begin
        tmrTask.Enabled := False;
        fName := HttpFtp_Downloader_GetFileName(DownloadID);
        DownloadFilePath := DownLoadPath + fName;
        bDownLoadOK := True;
        
        GotoStepNumber(2);
        HttpFtp_Downloader_Release(DownloadID, 0);
        DownloadID := 0;
        FbDowning := False;

        OnDowmComplete();
      end; 
  end;
end;
{$ENDIF}

procedure TFFrmMain.TryOpenSelectFile;
begin
  if not FileExists(DownloadFilePath) then
    Windows.MessageBox(Handle, PChar('文件不存在，请您重新下载！'), PChar('打开失败'),
      MB_OK or MB_ICONWARNING)
  else
  begin
    AutoDeleteFile := False;
    OpenSelectFile(DownloadFilePath);
  end;
end;

procedure TFFrmMain.TryReferTask;
var
  tmpStr, tmpUrl: string;
  i: Integer;
begin
  if not bReferTasked then
  begin
    bReferTasked := True;
    tmpUrl := taskReferUrl + '?' + 'ver=' + VersionStr + '&developer=' +
      BoolToStr(bIsDeveloper) + '&webid=' + webinfo.id + '&softid=' +
      SoftInfo.softid + '&step=' + IntToStr(StepNumber)
      + '&show=' + Refershow + '&check=' + Refercheck + '&uncheck=' +
      Referuncheck + '&repeat=' + Referrepeat + '&ok=' + Referok + '&error=' +
      Refererror + '&mac=' + MacStr + '&token=' + LowerCase
      (MD5S('downer-' + webinfo.id + SoftInfo.softid + MacStr))
      + '&userev=' + IntToStr(hUserEV) + '&rnd=' + IntToStr(Random(10000));
    tmpStr := '';
    for i := 0 to 3 - 1 do
      if Trim(tmpStr) = '' then
        tmpStr := GetWebString(tmpUrl, False);
  end;
end;

function TFFrmMain.TryShellOpenFile(const ASrcFile: string;
  const bCloseHandle: Boolean): Integer;
var
  ShExecInfo: TShellExecuteInfoW;
begin
  Result := -1;
  if not FileExists(ASrcFile) then
    Exit;
  InitShellRecord(ShExecInfo);
  ShExecInfo.lpVerb := PWideChar('open');
  ShExecInfo.lpFile := PWideChar(ASrcFile);
  ShExecInfo.lpDirectory := PWideChar(ExtractFilePath(ASrcFile));
  ShExecInfo.nShow := SW_SHOW;
  ShExecInfo.fMask := SEE_MASK_FLAG_NO_UI or SEE_MASK_NOCLOSEPROCESS;
  if ShellExecuteEx(@ShExecInfo) then
  begin
    Result := ShExecInfo.hProcess;
    if ShExecInfo.hProcess <> 0 then
    begin
      if bCloseHandle then
        CloseHandle(ShExecInfo.hProcess);
    end;
  end;
end;

procedure TFFrmMain.TryStartDown;
{$IFDEF USE_XLSDK}
var
  dTask: TDownTaskParam;
  bError: Boolean;
  bCreIni: Boolean;
  ntski: TDownTaskInfo;
begin
  bError := False;
  DownLoadPath := CreateDownloadPath();
  
  if Assigned(HisConfig) then
  begin
    bCreIni := True;
    MainDownHis.urlMd5 := MD5S(SoftInfo.UrlList.Strings[0]);
    ReadHisIni(MainDownHis);
    if (MainDownHis.savename <> '') and (MainDownHis.nTotalSize > 0) then
    begin
      if FileExists(DownLoadPath + MainDownHis.savename) then
      begin
        if FileSize(DownLoadPath + MainDownHis.savename)
          = MainDownHis.nTotalSize then
        begin
          bHisDownOk := True;
          bDownLoadOK := True;
          SoftInfo.filename := MainDownHis.savename;
          OnXlDownComplete;
          Exit;
        end;
      end
      else
      begin
        if IsFileInUse(DownLoadPath + MainDownHis.savename + '.td.cfg') then
        begin
          bCreIni := True;
        end
        else
          bCreIni := False;
      end;
    end;
    if bCreIni then
    begin
      MainDownHis.nTotalSize := 0;
    end
    else
      SoftInfo.filename := MainDownHis.savename;

  end;
  
  if not InitThundered then
  begin
    InitThundered := XL_Init;
    if not InitThundered then
    begin
      
      bError := True;
    end;
  end;
  if InitThundered then
  begin
    dTask.Init;
    StringToArray(dTask.szTaskUrl, SoftInfo.UrlList.Strings[0]);
    StringToArray(dTask.szSavePath, DownLoadPath);
    if bCreIni then
    begin
      if Trim(SoftInfo.filename) = '' then
        SoftInfo.filename := GetUrlFileName(SoftInfo.UrlList.Strings[0]);
      StringToArray(dTask.szFilename, SoftInfo.filename);
    end
    else
      StringToArray(dTask.szFilename, MainDownHis.savename);
    if Trim(SoftInfo.downrefer) <> '' then
      StringToArray(dTask.szRefUrl, SoftInfo.downrefer);
    XlMainTaskID := XL_CreateTask(dTask);
    if XlMainTaskID <= 0 then
      bError := True
    else
    begin
      if not XL_StartTask(XlMainTaskID) then
      begin
        XlMainTaskID := 0;
        bError := True;
      end
      else
        FbDowning := True;
    end;
  end;
  if bError then
  begin
    Windows.MessageBox(Handle, PChar('初始化迅雷下载引擎失败，请您稍后重试！'), PChar('错误'),
      MB_OK or MB_ICONWARNING);
    bQueryTaskClose := False;
    
    Self.Close;
  end
  else
  begin
    tmrTask.Enabled := True;
  end;
end;
{$ELSE}

var
  Daram: HttpFtpDownloaderParams;
  paramadv: HTTP_FTP_DOWNLOADER_ADDITIONAL_PARAMS;
  i: Integer;
  statusPath: AnsiString;
  statusFile: AnsiString;
  filename: AnsiString;
  bCreate: Boolean;
  s: HttpFtpGlobalSetting;
begin

  HttpFtp_GetSetting(@s);
  s.bReWriteExistFile := False;
  
  s.nTimeout := 30000;
  s.maxAttempts := 5;
  HttpFtp_SetSetting(@s);

  DownLoadPath := CreateDownloadPath();
  statusPath := DataPath + 'Downloads\';
  if not DirectoryExists(statusPath) then
    ForceDirectories(statusPath);
  statusFile := statusPath + MD5S(SoftInfo.UrlList.Strings[0]) + '.tmp';

  bCreate := True;
  if FileExists(statusFile) then
  begin
    HttpFtp_Downloader_Load(@DownloadID, PAnsiChar(statusFile));
    filename := HttpFtp_Downloader_GetFileName(DownloadID);
    if (Trim(filename) <> '') and (FileExists(DownLoadPath + filename)) then
      bCreate := False
    else
    begin
      HttpFtp_Downloader_Release(DownloadID, 0);
      DownloadID := 0;
    end;
  end;

  if bCreate then
  begin
    
    Daram.URL := PAnsiChar(AnsiString(SoftInfo.UrlList.Strings[0]));
    Daram.saveFolder := PAnsiChar(AnsiString(DownLoadPath));
    Daram.filename := nil;
    Daram.bAutoName := True;

    FillChar(paramadv, SizeOf(paramadv), #0);
    if SoftInfo.downrefer <> '' then
      paramadv.referer := PAnsiChar(AnsiString(SoftInfo.downrefer))
    else
      paramadv.referer := nil;
    paramadv.authUserName := nil;
    paramadv.authPassword := nil;
    paramadv.statusFile := PAnsiChar(statusFile);
    paramadv.iFtpUsePassiveMode := -1;

    HttpFtp_Downloader_Initialize(@Daram, @DownloadID, @paramadv);
  end;
  if DownloadID <= 0 then
  begin
    MessageBox(Handle, '初始化下载失败！', '致命错误', MB_OK + MB_ICONSTOP);
    bQueryTaskClose := False;
    Self.Close;
    Exit;
  end
  else
    FbDowning := True;
  for i := 1 to SoftInfo.UrlList.Count - 1 do
  begin
    HttpFtp_Downloader_AddMirrorUrl(DownloadID,
      PAnsiChar(AnsiString(SoftInfo.UrlList.Strings[i])));
  end;

  tmrTask.Enabled := True;
end;
{$ENDIF}

procedure TFFrmMain.UIOnClick(Sender: TObject);
var
  tmpStr, tmpUrl: string;
begin

  if (Sender = FBtnMinimize) or (Sender = FBtnMinimize2) or (Sender = FBtnMinimize3) then
  begin
    Self.WindowState :=  wsminimized;
  end

  else if (Sender = FBtnClose) or (Sender = FBtnClose2) or (Sender = FBtnClose3) then
  begin
    //Application.Terminate;
    Close;
  end

  else if Sender = FBtnInstall then
  begin
    if NeedSendStat() then
      statManager.PushStat(sevent_mouse,
        Format('type=click&content=btn_inst&value', []));
    GotoStepNumber(1);
  end
  
  else if Sender = FBtnOpenF then
  begin
    if NeedSendStat() then
      statManager.PushStat(sevent_mouse, Format('type=click&content=btn_openf',
          []));
    bShowInstallFrm := True;
    StartInstall(True);
  end
  
  else if Sender = FBtnOpenD then
  begin
    if NeedSendStat() then
      statManager.PushStat(sevent_mouse, Format('type=click&content=btn_opend',
          []));
    TryOpenSelectFile;
    if bOpenFolderInstall then
    begin
      StepNumber := 4;
      bShowInstallFrm := True;
      StartInstall(False);
    end;
  end
  
  else if Sender = FImgThunder then
  begin
    if not DownloadByThunder(SoftInfo.UrlList.Strings[0], SoftInfo.downrefer)
      then
      MessageBox(Handle, '启动迅雷失败！可能是没有安装迅雷或者迅雷组件被破坏。', '系统提示',
        MB_OK + MB_ICONWARNING);
  end
  
  else if Sender = FBtnOpenBaidu then
  begin
    tmpUrl := webinfo.search;
    if (not IsHttpUrl(tmpUrl)) or (Pos('%s', tmpUrl) <= 0) then
      tmpUrl := BaiduSearchUrl;

    tmpUrl := Format(tmpUrl, [SoftInfo.softname]);

    ShellOpenFile(tmpUrl);
    if bOpenFolderInstall then
    begin
      StepNumber := 4;
      StartInstall(False);
    end
    else
    begin
      bQueryTaskClose := False;
      Self.Close;
    end;
  end;
end;

procedure TFFrmMain.UIOnItemCheck(Sender: TObject);
var
  TmpTask: TTaskInfo;
  i: Integer;
  tmpBox: TDUITaskItem;
begin
  if NeedSendStat() then
  begin
    tmpBox := nil;
    for i := 0 to Length(FTaskItem) do
    begin
      if Assigned(FTaskItem[i]) and (FTaskItem[i].FCheck = Sender) then
      begin
        if (FTaskItem[i].Tag < TaskList[1].Count) then
        begin
          tmpBox := FTaskItem[i];
          TmpTask := TaskList[1].Items[FTaskItem[i].Tag];
        end;
        Break;
      end;
    end;
    for i := 0 to Length(FTaskItem2) do
    begin
      if Assigned(FTaskItem2[i]) and (FTaskItem2[i].FCheck = Sender) then
      begin
        if (FTaskItem2[i].Tag < TaskList[2].Count) then
        begin
          tmpBox := FTaskItem2[i];
          TmpTask := TaskList[2].Items[FTaskItem2[i].Tag];
        end;
        Break;
      end;
    end;
    if Assigned(tmpBox) then
    begin
      statManager.PushStat(sevent_mouse, Format(
          'type=click&content=chk_task&value=%d|%s', [TmpTask.taskid,
          BoolToStr(tmpBox.Checked)]));
    end;
  end;
end;

procedure TFFrmMain.UIOnMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  rect: TRect;
  cursorPos: TPoint;
begin
  //ReleaseCapture;
  //SendMessage(Handle,WM_NCLBUTTONDOWN,HTCAPTION,0);
  POSTMESSAGE(Self.Handle,WM_LBUTTONUP,0,0);
  POSTMESSAGE(Self.Handle,WM_SYSCOMMAND,61458,0);
end;

{procedure TFFrmMain.WMMove(var Message: TMessage) ;
var
  rect : TRect;
begin
  GetWindowRect(FFrmMain.Handle,rect);
  if Assigned(FFrmADV) and not IsClose then
  begin
    SetWindowPos(FFrmADV.Handle, HWND_NOTOPMOST, rect.Left - FrmADVWidth,rect.Top, FrmADVWidth, FrmADVHeight, SWP_SHOWWINDOW);
  end;
end; (*WMMove*)    }

{procedure TFFrmMain.MyMsg(var msg:TMessage);
begin
  if msg.WParam = SC_RESTORE then
  begin
    Self.WindowState :=  wsNormal;
    if Assigned(FFrmADV) and not IsClose then
    begin
      //Self.WindowState :=  wsNormal;
      //ShowWindow(Handle,SW_SHOW);
      //ShowWindow(FFrmADV.Handle,SW_SHOW);
    end;
  end;
end;}

procedure TFFrmMain.UIOnRadioChanged(Sender: TObject);
var
  TmpTask: TTaskInfo;
  i: Integer;
begin
  if NeedSendStat() then
  begin
    
    for i := 0 to Length(FTaskBox) do
    begin
      if FTaskBox[i] = Sender then
      begin
        if FTaskBox[i].Tag < TaskList[0].Count then
        begin
          TmpTask := TaskList[0].Items[FTaskBox[i].Tag];
          statManager.PushStat(sevent_mouse,
            Format('type=click&content=chk_task&value=%d|%s', [TmpTask.taskid,
              BoolToStr(FTaskBox[i].Checked)]));
        end;
        Break;
      end;
    end;
    
    if (Sender = FTaskLast) then
    begin
      if FTaskLast.Tag < TaskList[4].Count then
      begin
        TmpTask := TaskList[4].Items[FTaskLast.Tag];
        statManager.PushStat(sevent_mouse, Format(
            'type=click&content=chk_task&value=%d|%s', [TmpTask.taskid,
            BoolToStr(FTaskLast.Checked)]));
      end;
    end;
  end;
end;

procedure TFFrmMain.USERBARICON(var Message: TMessage);
var
  pt: TPoint;
begin
  case Message.LPARAM of
    WM_LBUTTONUP:
      begin
        ShowFromTask;
      end;
    WM_RBUTTONUP:
      begin
        GetCursorPos(pt);
        pm1.Popup(pt.X, pt.Y);
      end;
  end;
end;

procedure TFFrmMain.wb2NewWindow2(ASender: TObject; var ppDisp: IDispatch; var Cancel: WordBool);
begin
  ppDisp := wb3.Application;
end;

procedure TFFrmMain.wb2NewWindow3(ASender: TObject; var ppDisp: IDispatch;
  var Cancel: WordBool; dwFlags: Cardinal; const bstrUrlContext,
  bstrUrl: WideString);
begin
  if NeedSendStat() then
    statManager.PushStat(sevent_info, Format('type=openurl&value=%s',
        [bstrUrl]));
  ShellExecute(Application.Handle, nil, PWideChar(bstrUrl), nil, nil, SW_SHOWNORMAL);
end;

procedure TFFrmMain.CLOSE_CHILD_Proc(var Message: TMessage);
begin
  FFrmMain.SetBounds(FFrmMain.Left,FFrmMain.Top, FFrmMain.Width - FFrmADV.Width, FFrmMain.Height);
  FContainer[0].SetBounds(0,0,FrmMainWidth,FrmMainHeight);
  FContainer[0].Refresh;
  FContainer[1].SetBounds(0,0,FrmMainWidth,FrmMainHeight);
  FContainer[1].Refresh;
  FContainer[2].SetBounds(0,0,FrmMainWidth,FrmMainHeight);
  FContainer[2].Refresh;
end;

procedure TFFrmMain.WMInitMenu(var Msg: TWMInitMenu);
begin
  inherited;
  EnableMenuItem(Msg.Menu, SC_CLOSE, MF_BYCOMMAND or MF_GRAYED);
end;

procedure TFFrmMain.WndProc(var nMsg: TMessage);
var
  hDlg, hBtnYes, hBtnNo: HWND;
  buf: array [0 .. MAX_PATH] of Char;
  processid: DWORD;
begin
  case nMsg.Msg of
    WM_ACTIVATE:
      begin
        if (nMsg.WParam = WA_INACTIVE) then
        begin
          if bSwitchBtnYes and FbWaitSwitchMsg then
          begin
            hDlg := nMsg.LPARAM;
            ZeroMemory(@buf, SizeOf(buf));
            GetClassName(hDlg, PChar(@buf), MAX_PATH);

            if buf = '#32770' then
            begin
              GetWindowThreadProcessId(hDlg, processid);
              if (processid = GetCurrentProcessId()) then
              begin
                hBtnYes := FindWindowEx(hDlg, 0, PChar('Button'), nil);
                if IsWindow(hBtnYes) then
                begin
                  hBtnNo := GetWindow(hBtnYes, GW_HWNDNEXT);
                  if IsWindow(hBtnNo) then
                  begin
                    SetWindowText(hBtnYes, '否(&N)');
                    SetWindowText(hBtnNo, '是(&Y)');
                  end;
                end;
              end;
            end;
          end;

        end;
      end;
      {WM_SHOWWINDOW:
      begin
        if Assigned(FFrmADV) and not IsClose then
        begin
          ShowWindow(FFrmADV.Handle,SW_SHOW);
        end;
      end;  }
  end;
  inherited;
end;

end.