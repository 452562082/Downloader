unit GR32_XPThemes;

interface

{$I GR32.inc}

uses
{$IFDEF FPC}
  LCLIntf, LCLType,
  {$IFDEF Windows}
    Windows,
  {$ENDIF}
  {$IFDEF UNIX}
    Unix, BaseUnix,
  {$ENDIF}
{$ELSE}
  Windows,
{$ENDIF}
  SysUtils;

{$IFDEF Windows}

var
  USE_THEMES: Boolean = False;
  SCROLLBAR_THEME: THandle = 0;
  GLOBALS_THEME: THandle = 0;

const
  THEMEMGR_VERSION                     = 1;
  WM_THEMECHANGED                      = $031A;
  
  SBP_ARROWBTN                         = 1;
  SBP_THUMBBTNHORZ                     = 2;
  SBP_THUMBBTNVERT                     = 3;
  SBP_LOWERTRACKHORZ                   = 4;
  SBP_UPPERTRACKHORZ                   = 5;
  SBP_LOWERTRACKVERT                   = 6;
  SBP_UPPERTRACKVERT                   = 7;
  SBP_GRIPPERHORZ                      = 8;
  SBP_GRIPPERVERT                      = 9;
  SBP_SIZEBOX                          = 10;
  
  ABS_UPNORMAL                         = 1;
  ABS_UPHOT                            = 2;
  ABS_UPPRESSED                        = 3;
  ABS_UPDISABLED                       = 4;
  ABS_DOWNNORMAL                       = 5;
  ABS_DOWNHOT                          = 6;
  ABS_DOWNPRESSED                      = 7;
  ABS_DOWNDISABLED                     = 8;
  ABS_LEFTNORMAL                       = 9;
  ABS_LEFTHOT                          = 10;
  ABS_LEFTPRESSED                      = 11;
  ABS_LEFTDISABLED                     = 12;
  ABS_RIGHTNORMAL                      = 13;
  ABS_RIGHTHOT                         = 14;
  ABS_RIGHTPRESSED                     = 15;
  ABS_RIGHTDISABLED                    = 16;
  
  SCRBS_NORMAL                         = 1;
  SCRBS_HOT                            = 2;
  SCRBS_PRESSED                        = 3;
  SCRBS_DISABLED                       = 4;
  
  SZB_RIGHTALIGN                       = 1;
  SZB_LEFTALIGN                        = 2;

type
  HIMAGELIST = THandle;
  HTHEME = THandle;
  _MARGINS = record
    cxLeftWidth: Integer;      
    cxRightWidth: Integer;     
    cyTopHeight: Integer;      
    cyBottomHeight: Integer;   
  end;
  MARGINS = _MARGINS;
  PMARGINS = ^MARGINS;
  TMargins = MARGINS;

var
  OpenThemeData: function(hwnd: HWND; pszClassList: LPCWSTR): HTHEME; stdcall;
  CloseThemeData: function(hTheme: HTHEME): HRESULT; stdcall;
  DrawThemeBackground: function(hTheme: HTHEME; hdc: HDC; iPartId, iStateId: Integer;
    const Rect: TRect; pClipRect: PRect): HRESULT; stdcall;
  DrawThemeEdge: function(hTheme: HTHEME; hdc: HDC; iPartId, iStateId: Integer; const pDestRect: TRect; uEdge,
    uFlags: UINT; pContentRect: PRECT): HRESULT; stdcall;
  GetThemeColor: function(hTheme: HTHEME; iPartId, iStateId, iPropId: Integer; var pColor: COLORREF): HRESULT; stdcall;
  GetThemeMetric: function(hTheme: HTHEME; hdc: HDC; iPartId, iStateId, iPropId: Integer;
    var piVal: Integer): HRESULT; stdcall;
  GetThemeMargins: function(hTheme: HTHEME; hdc: HDC; iPartId, iStateId, iPropId: Integer; prc: PRECT;
    var pMargins: MARGINS): HRESULT; stdcall;
  SetWindowTheme: function(hwnd: HWND; pszSubAppName: LPCWSTR; pszSubIdList: LPCWSTR): HRESULT; stdcall;
  IsThemeActive: function: BOOL; stdcall;
  IsAppThemed: function: BOOL; stdcall;
  EnableTheming: function(fEnable: BOOL): HRESULT; stdcall;

{$ENDIF}

implementation

{$IFDEF Windows}

uses
  Messages, Classes;

const
  UXTHEME_DLL = 'uxtheme.dll';

var
  DllHandle: THandle;

procedure FreeXPThemes;
begin
  if DllHandle <> 0 then
  begin
    if not IsLibrary then
      FreeLibrary(DllHandle);
      
    DllHandle := 0;
    OpenThemeData := nil;
    CloseThemeData := nil;
    DrawThemeBackground := nil;
    DrawThemeEdge := nil;
    GetThemeColor := nil;
    GetThemeMetric := nil;
    GetThemeMargins := nil;
    SetWindowTheme := nil;
    IsThemeActive := nil;
    IsAppThemed := nil;
    EnableTheming := nil;
  end;
end;

function InitXPThemes: Boolean;
begin
  if DllHandle = 0 then
  begin
    DllHandle := LoadLibrary(UXTHEME_DLL);
    if DllHandle > 0 then
    begin
      OpenThemeData := GetProcAddress(DllHandle, 'OpenThemeData');
      CloseThemeData := GetProcAddress(DllHandle, 'CloseThemeData');
      DrawThemeBackground := GetProcAddress(DllHandle, 'DrawThemeBackground');
      DrawThemeEdge := GetProcAddress(DllHandle, 'DrawThemeEdge');
      GetThemeColor := GetProcAddress(DllHandle, 'GetThemeColor');
      GetThemeMetric := GetProcAddress(DllHandle, 'GetThemeMetric');
      GetThemeMargins := GetProcAddress(DllHandle, 'GetThemeMargins');
      SetWindowTheme := GetProcAddress(DllHandle, 'SetWindowTheme');
      IsThemeActive := GetProcAddress(DllHandle, 'IsThemeActive');
      IsAppThemed := GetProcAddress(DllHandle, 'IsAppThemed');
      EnableTheming := GetProcAddress(DllHandle, 'EnableTheming');
      if (@OpenThemeData = nil) or (@CloseThemeData = nil) or (@IsThemeActive = nil) or
        (@IsAppThemed = nil) or (@EnableTheming = nil) then FreeXPThemes;
    end;
  end;
  Result := DllHandle > 0;
end;

function UseXPThemes: Boolean;
begin
  Result := (DllHandle > 0) and IsAppThemed and IsThemeActive;
end;

type
  TThemeNexus = class
  private
    FWindowHandle: HWND;
  protected
    procedure WndProc(var Message: TMessage);
    procedure OpenVisualStyles;
    procedure CloseVisualStyles;
  public
    constructor Create;
    destructor Destroy; override;
  end;

{$IFDEF SUPPORT_XPTHEMES}
{$IFDEF XPTHEMES}
var
  ThemeNexus: TThemeNexus;
{$ENDIF}
{$ENDIF}

constructor TThemeNexus.Create;
begin
  FWindowHandle := Classes.AllocateHWnd(WndProc);
  OpenVisualStyles;
end;

destructor TThemeNexus.Destroy;
begin
  CloseVisualStyles;
  Classes.DeallocateHWnd(FWindowHandle);
  inherited;
end;

procedure TThemeNexus.OpenVisualStyles;
begin
  USE_THEMES := False;
  if InitXPThemes then
  begin
    USE_THEMES := UseXPThemes;
    if USE_THEMES then
    begin
      SCROLLBAR_THEME := OpenThemeData(FWindowHandle, 'SCROLLBAR');
      GLOBALS_THEME := OpenThemeData(FWindowHandle, 'GLOBALS');
    end;
  end;
end;

procedure TThemeNexus.CloseVisualStyles;
begin
  if not IsLibrary and UseXPThemes then
  begin
    if SCROLLBAR_THEME <> 0 then
    begin
      CloseThemeData(SCROLLBAR_THEME);
      SCROLLBAR_THEME := 0;
    end;
    if GLOBALS_THEME <> 0 then
    begin
      CloseThemeData(GLOBALS_THEME);
      GLOBALS_THEME := 0;
    end;
  end;
  FreeXPThemes;
end;

procedure TThemeNexus.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    WM_THEMECHANGED:
      begin
        CloseVisualStyles;
        OpenVisualStyles;
      end;
  end;
  with Message do Result := DefWindowProc(FWindowHandle, Msg, wParam, lParam);
end;

{$IFDEF SUPPORT_XPTHEMES}
{$IFDEF XPTHEMES}
initialization
  ThemeNexus := TThemeNexus.Create;

finalization
  ThemeNexus.Free;
{$ENDIF}
{$ENDIF}

{$ENDIF}

end.
 