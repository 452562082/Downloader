unit HttpDowner;

interface

uses
  Windows, SysUtils, UnitLoadDll;

const
  
  HttpFtp_PROXY_TO_HTTP = 1; 
  HttpFtp_PROXY_TO_HTTPS = 2; 
  HttpFtp_PROXY_TO_FTP = 4; 
  HttpFtp_PROXY_TO_ALL = 7; 

type
  int = integer;
  
  HttpFtp_FtpTransferType = (FTT_BINARY, 
    FTT_ASCII, 
    FTT_BY_EXT, 
    FTT_NO_SET 
    );

  PHttpFtpGlobalSetting = ^HttpFtpGlobalSetting;

  HttpFtpGlobalSetting = record
    maxSections: int; 
    
    sectionMinSize: int; 
    trafficLimit: int; 

    dwWriteCaceSize: DWORD; 
    iAutoSaveInterval: int; 
    bReserveDiskSpace: BOOL; 

    maxAttempts: int; 
    retriesTime: int; 
    nTimeout: int; 

    bUseDetailLog: BOOL; 
    bHideFileNotComplete: BOOL; 
    bUseServerTime: BOOL; 
    bReWriteExistFile: BOOL; 
    
    bAutoSearchMirror: BOOL; 
    
    mirroServer: int; 
    mirroMinFileSize: int; 
    
    rollBackSize: word; 

    bFtpUsePassiveMode: BOOL; 
    bUseHttp11: BOOL; 
    bUseCookie: BOOL; 

    ftpTransferType: HttpFtp_FtpTransferType;
    
    padding: array [0 .. 2] of AnsiChar; 

    ftpASCIIExt: array [0 .. 255] of AnsiChar; 

    agentStr: array [0 .. 2047] of AnsiChar; 
    additionalExtension: array [0 .. 15] of AnsiChar; 
  end;
  
  HttpFtp_LANG_TYPE = (HttpFtp_LANG_EN, HttpFtp_LANG_CHS);
  
  HttpFtp_RECEIVELOG_CALLBACK = procedure(downloaderID: DWORD;
    lpstrLog: LPCSTR; lpParam: Pointer); stdcall;
  
  PHttpFtpDownloaderParams = ^HttpFtpDownloaderParams;

  HttpFtpDownloaderParams = record
    url: LPCSTR; 
    saveFolder: LPCSTR; 
    fileName: LPCSTR; 
    bAutoName: BOOL; 
  end;
  
  HttpFtp_DOWNLOADER_STATE = (HttpFtp_DLSTATE_NONE, 
    HttpFtp_DLSTATE_DOWNLOADING, 
    HttpFtp_DLSTATE_PAUSE, 
    HttpFtp_DLSTATE_STOPPED, 
    HttpFtp_DLSTATE_FAIL, 
    HttpFtp_DLSTATE_DOWNLOADED 
    );
  
  HttpFtp_ACCESS_TYPE = (HttpFtp_ACCESS_NOPROXY,
    
    HttpFtp_ACCESS_IE_CONFIG, 
    HttpFtp_ACCESS_MANUAL 
    );

  PHTTP_FTP_DOWNLOADER_ADDITIONAL_PARAMS = ^
    HTTP_FTP_DOWNLOADER_ADDITIONAL_PARAMS;

  HTTP_FTP_DOWNLOADER_ADDITIONAL_PARAMS = record
    statusFile: LPCSTR; 
    referer: LPCSTR; 

    authUserName: LPCSTR; 
    authPassword: LPCSTR; 

    maxSections: int; 
    
    sectionMinSize: int; 
    trafficLimit: int; 

    ftpTransferType: HttpFtp_FtpTransferType; 
    padding: array [0 .. 2] of AnsiChar; 

    iFtpUsePassiveMode: int; 
  end;
  
var
  
  HttpFtp_Startup: function(): BOOL;
stdcall = nil;
HttpFtp_Shutdown :
procedure();
stdcall = nil;

HttpFtp_SetSetting :
procedure(s: PHttpFtpGlobalSetting);
stdcall = nil;
HttpFtp_GetSetting :
procedure(s: PHttpFtpGlobalSetting);
stdcall = nil;

HttpFtp_SetMaxTraffic :
procedure(uTrafficLimit: int);
stdcall = nil; 
HttpFtp_SetMaxConns :
procedure(uMaxConns: int);
stdcall = nil; 
HttpFtp_SetMaxConnsPS :
procedure(uMaxConnsPS: int);
stdcall = nil; 

HttpFtp_SetProxy :
function(proxyType: HttpFtp_ACCESS_TYPE;
  
  proxyTo: int; 
  proxyUrl: LPCSTR; 
  userName: LPCSTR; password: LPCSTR): HRESULT;
stdcall = nil;

HttpFtp_SetLogLanguage :
procedure(langType: HttpFtp_LANG_TYPE);
stdcall = nil;

HttpFtp_SetReceiveLogFunc :
procedure(pfn: HttpFtp_RECEIVELOG_CALLBACK; 
  lpParam: Pointer 
  );
stdcall = nil;

HttpFtp_Downloader_Initialize :
function(params: PHttpFtpDownloaderParams;
  
  downloaderID: PInteger; 
  additionalParams: PHTTP_FTP_DOWNLOADER_ADDITIONAL_PARAMS = nil
  
  ): HRESULT;
stdcall = nil;

HttpFtp_Downloader_Load :
function(downloaderID: PInteger;
  
  statusFile: LPCSTR 
  ): HRESULT;
stdcall = nil;

HttpFtp_Downloader_Stop :
function(downloaderID: DWORD; dwMilliseconds: DWORD): HRESULT;
stdcall = nil;

HttpFtp_Downloader_Release :
function(downloaderID: DWORD; iDeleteFiles: int): HRESULT;
stdcall = nil;

HttpFtp_Downloader_Resume :
function(downloaderID: DWORD): HRESULT;
stdcall = nil;

HttpFtp_Downloader_DeleteStatuseFile :
procedure(downloaderID: DWORD);
stdcall = nil;

HttpFtp_Downloader_AddMirrorUrl :
function(downloaderID: DWORD; url: LPCSTR): HRESULT;
stdcall = nil;

HttpFtp_Downloader_GetFileName :
function(downloaderID: DWORD): LPCSTR;
stdcall = nil;

HttpFtp_Downloader_GetUrl :
function(downloaderID: DWORD; bIncludeAuth: BOOL): LPCSTR;
stdcall = nil;

HttpFtp_Downloader_GetSpeed :
function(downloaderID: DWORD): DWORD;
stdcall = nil;

HttpFtp_Downloader_GetLeftTime :
function(downloaderID: DWORD): DWORD;
stdcall = nil;

HttpFtp_Downloader_GetPercentDone :
function(downloaderID: DWORD): single;
stdcall = nil;

HttpFtp_Downloader_GetFileSize :
function(downloaderID: DWORD): UINT64;
stdcall = nil;

HttpFtp_Downloader_GetDownloadedSize :
function(downloaderID: DWORD): UINT64;
stdcall = nil;

HttpFtp_Downloader_GetLeftSize :
function(downloaderID: DWORD): UINT64;
stdcall = nil;

HttpFtp_Downloader_GetDownloadTime :
function(downloaderID: DWORD): DWORD;
stdcall = nil;

HttpFtp_Downloader_GetDownloadRunningTime :
function(downloaderID: DWORD): DWORD;
stdcall = nil;

HttpFtp_Downloader_GetState :
function(downloaderID: DWORD): HttpFtp_DOWNLOADER_STATE;
stdcall = nil;

HttpFtp_Downloader_GetLastError :
function(downloaderID: DWORD): DWORD;
stdcall = nil;

HttpFtp_SetVerInfo :
procedure(cert1: DWORD; cert2: DWORD; cert3: DWORD; cert4: LPCSTR);
stdcall = nil;

function LoadSdkFromFile(const fileName: string): Boolean;
function LoadSdkFromMemory(const dll_data: Pointer;
  dll_size: Cardinal): Boolean;
procedure UnLoadSdk();

implementation

var
  HttpModule: HMODULE = 0;
  HttpMemory: MODULE_HANDLE = nil;

function LoadSdkFromFile(const fileName: string): Boolean;
begin
  Result := False;
  if not FileExists(fileName) then
    Exit;
  if HttpModule = 0 then
    HttpModule := LoadLibrary(PChar(fileName));
  if HttpModule = 0 then
    Exit;
  @HttpFtp_Startup := Windows.GetProcAddress(HttpModule, 'HttpFtp_Startup');
  @HttpFtp_Shutdown := Windows.GetProcAddress(HttpModule, 'HttpFtp_Shutdown');
  @HttpFtp_SetSetting := Windows.GetProcAddress(HttpModule,
    'HttpFtp_SetSetting');
  @HttpFtp_GetSetting := Windows.GetProcAddress(HttpModule,
    'HttpFtp_GetSetting');
  @HttpFtp_SetMaxTraffic := Windows.GetProcAddress(HttpModule,
    'HttpFtp_SetMaxTraffic');
  @HttpFtp_SetMaxConns := Windows.GetProcAddress(HttpModule,
    'HttpFtp_SetMaxConns');
  @HttpFtp_SetMaxConnsPS := Windows.GetProcAddress(HttpModule,
    'HttpFtp_SetMaxConnsPS');
  @HttpFtp_SetProxy := Windows.GetProcAddress(HttpModule, 'HttpFtp_SetProxy');
  @HttpFtp_SetLogLanguage := Windows.GetProcAddress(HttpModule,
    'HttpFtp_SetLogLanguage');
  @HttpFtp_SetReceiveLogFunc := Windows.GetProcAddress(HttpModule,
    'HttpFtp_SetReceiveLogFunc');
  @HttpFtp_Downloader_Initialize := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_Initialize');
  @HttpFtp_Downloader_Load := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_Load');
  @HttpFtp_Downloader_Stop := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_Stop');
  @HttpFtp_Downloader_Release := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_Release');
  @HttpFtp_Downloader_Resume := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_Resume');
  @HttpFtp_Downloader_DeleteStatuseFile := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_DeleteStatuseFile');
  @HttpFtp_Downloader_AddMirrorUrl := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_AddMirrorUrl');
  @HttpFtp_Downloader_GetFileName := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_GetFileName');
  @HttpFtp_Downloader_GetUrl := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_GetUrl');
  @HttpFtp_Downloader_GetSpeed := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_GetSpeed');
  @HttpFtp_Downloader_GetLeftTime := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_GetLeftTime');
  @HttpFtp_Downloader_GetPercentDone := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_GetPercentDone');
  @HttpFtp_Downloader_GetFileSize := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_GetFileSize');
  @HttpFtp_Downloader_GetDownloadedSize := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_GetDownloadedSize');
  @HttpFtp_Downloader_GetLeftSize := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_GetLeftSize');
  @HttpFtp_Downloader_GetDownloadTime := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_GetDownloadTime');
  @HttpFtp_Downloader_GetDownloadRunningTime := Windows.GetProcAddress
    (HttpModule, 'HttpFtp_Downloader_GetDownloadRunningTime');
  @HttpFtp_Downloader_GetState := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_GetState');
  @HttpFtp_Downloader_GetLastError := Windows.GetProcAddress(HttpModule,
    'HttpFtp_Downloader_GetLastError');
  @HttpFtp_SetVerInfo := Windows.GetProcAddress(HttpModule,
    'HttpFtp_SetVerInfo');
  Result := Assigned(@HttpFtp_Startup);
end;

function LoadSdkFromMemory(const dll_data: Pointer;
  dll_size: Cardinal): Boolean;
begin
  Result := False;
  HttpMemory := LoadModuleFromMemory(dll_data, dll_size);
  if HttpMemory = nil then
    Exit;
  @HttpFtp_Startup := GetModuleFunction(HttpMemory, 'HttpFtp_Startup');
  @HttpFtp_Shutdown := GetModuleFunction(HttpMemory, 'HttpFtp_Shutdown');
  @HttpFtp_SetSetting := GetModuleFunction(HttpMemory, 'HttpFtp_SetSetting');
  @HttpFtp_GetSetting := GetModuleFunction(HttpMemory, 'HttpFtp_GetSetting');
  @HttpFtp_SetMaxTraffic := GetModuleFunction(HttpMemory,
    'HttpFtp_SetMaxTraffic');
  @HttpFtp_SetMaxConns := GetModuleFunction(HttpMemory, 'HttpFtp_SetMaxConns');
  @HttpFtp_SetMaxConnsPS := GetModuleFunction(HttpMemory,
    'HttpFtp_SetMaxConnsPS');
  @HttpFtp_SetProxy := GetModuleFunction(HttpMemory, 'HttpFtp_SetProxy');
  @HttpFtp_SetLogLanguage := GetModuleFunction(HttpMemory,
    'HttpFtp_SetLogLanguage');
  @HttpFtp_SetReceiveLogFunc := GetModuleFunction(HttpMemory,
    'HttpFtp_SetReceiveLogFunc');
  @HttpFtp_Downloader_Initialize := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_Initialize');
  @HttpFtp_Downloader_Load := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_Load');
  @HttpFtp_Downloader_Stop := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_Stop');
  @HttpFtp_Downloader_Release := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_Release');
  @HttpFtp_Downloader_Resume := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_Resume');
  @HttpFtp_Downloader_DeleteStatuseFile := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_DeleteStatuseFile');
  @HttpFtp_Downloader_AddMirrorUrl := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_AddMirrorUrl');
  @HttpFtp_Downloader_GetFileName := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_GetFileName');
  @HttpFtp_Downloader_GetUrl := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_GetUrl');
  @HttpFtp_Downloader_GetSpeed := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_GetSpeed');
  @HttpFtp_Downloader_GetLeftTime := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_GetLeftTime');
  @HttpFtp_Downloader_GetPercentDone := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_GetPercentDone');
  @HttpFtp_Downloader_GetFileSize := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_GetFileSize');
  @HttpFtp_Downloader_GetDownloadedSize := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_GetDownloadedSize');
  @HttpFtp_Downloader_GetLeftSize := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_GetLeftSize');
  @HttpFtp_Downloader_GetDownloadTime := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_GetDownloadTime');
  @HttpFtp_Downloader_GetDownloadRunningTime := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_GetDownloadRunningTime');
  @HttpFtp_Downloader_GetState := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_GetState');
  @HttpFtp_Downloader_GetLastError := GetModuleFunction(HttpMemory,
    'HttpFtp_Downloader_GetLastError');
  @HttpFtp_SetVerInfo := GetModuleFunction(HttpMemory, 'HttpFtp_SetVerInfo');
  Result := Assigned(@HttpFtp_Startup);
end;

procedure SetSdkFucNil();
begin
  @HttpFtp_Startup := nil;
  @HttpFtp_Shutdown := nil;
  @HttpFtp_SetSetting := nil;
  @HttpFtp_GetSetting := nil;
  @HttpFtp_SetMaxTraffic := nil;
  @HttpFtp_SetMaxConns := nil;
  @HttpFtp_SetMaxConnsPS := nil;
  @HttpFtp_SetProxy := nil;
  @HttpFtp_SetLogLanguage := nil;
  @HttpFtp_SetReceiveLogFunc := nil;
  @HttpFtp_Downloader_Initialize := nil;
  @HttpFtp_Downloader_Load := nil;
  @HttpFtp_Downloader_Stop := nil;
  @HttpFtp_Downloader_Release := nil;
  @HttpFtp_Downloader_Resume := nil;
  @HttpFtp_Downloader_DeleteStatuseFile := nil;
  @HttpFtp_Downloader_AddMirrorUrl := nil;
  @HttpFtp_Downloader_GetFileName := nil;
  @HttpFtp_Downloader_GetUrl := nil;
  @HttpFtp_Downloader_GetSpeed := nil;
  @HttpFtp_Downloader_GetLeftTime := nil;
  @HttpFtp_Downloader_GetPercentDone := nil;
  @HttpFtp_Downloader_GetFileSize := nil;
  @HttpFtp_Downloader_GetDownloadedSize := nil;
  @HttpFtp_Downloader_GetLeftSize := nil;
  @HttpFtp_Downloader_GetDownloadTime := nil;
  @HttpFtp_Downloader_GetDownloadRunningTime := nil;
  @HttpFtp_Downloader_GetState := nil;
  @HttpFtp_Downloader_GetLastError := nil;
end;

procedure UnLoadSdk();
begin
  if HttpModule <> 0 then
  begin
    FreeLibrary(HttpModule);
    HttpModule := 0;
  end;
  if (HttpMemory <> nil) then
  begin
    UnloadModule(HttpMemory);
    HttpMemory := nil;
  end;
  SetSdkFucNil();
end;

end.
 