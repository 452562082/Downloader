unit UnitHttp;

interface

uses
  windows, SysUtils;

const
  DHttp_Library = 'HttpFtp.dll';
  // ������ֻ���� HttpFtp_ACCESS_MANUAL ʱ��Ч
  HttpFtp_PROXY_TO_HTTP = 1; // ����Http��ʽ������ʹ�ô���
  HttpFtp_PROXY_TO_HTTPS = 2; // ����Https��ʽ������ʹ�ô���
  HttpFtp_PROXY_TO_FTP = 4; // ����Ftp����ʹ�ô�������
  HttpFtp_PROXY_TO_ALL = 7; // (HttpFtp_PROXY_TO_HTTP | HttpFtp_PROXY_TO_HTTPS | HttpFtp_PROXY_TO_FTP);  //���������ؾ�ʹ�ô���

type
  int = integer;

  // FTP����ʱ�ļ��ַ�ʽ����
  HttpFtp_FtpTransferType = (FTT_BINARY, // ������ģʽ
    FTT_ASCII, // ASCII��ʽ
    FTT_BY_EXT, // �����ļ���׺��ѡ������ģʽ����ftpASCIIExt�������Щ�ļ�ʹ��ASCIIģʽ������ʹ�ö����ƣ�
    FTT_NO_SET // �������ã�����ǵ����������д����������������Ĭ��ʹ��ȫ�ֵ����ã������ȫ�������Ĭ��ʹ��ByEXT��ʽ
    );

  // =============================================================
  // �����������ʵľ��󲿷�����ѡ�����������ṹ����
  // ��Ҫ�޸�ʱ����ֱ���޸�Ҫ�ı��ĳһ���
  // =============================================================

  PHttpFtpGlobalSetting = ^HttpFtpGlobalSetting;

  HttpFtpGlobalSetting = record
    maxSections: int; // ���ֶ�������һ���ļ����Է�Ϊ������أ�ÿ������һ���̣߳���Ĭ��12���������һ������ʣ��������������Է�ΪsectionMinSize����
    // ��С��һ�飬����߳��Զ���δ��������������һ��������أ�ʼ�ձ�����ô��ֿ顣ֱ��ʣ�������û���ˣ����߲���sectionMinSize��С�ˡ�
    sectionMinSize: int; // ��С�ķֶδ�С����λ���ֽ����� �ο�maxSections��˵��
    trafficLimit: int; // �ٶ�����

    dwWriteCaceSize: DWORD; // д�����С���ֽڣ�
    iAutoSaveInterval: int; // �Զ����滺�������̵�ʱ����(����)
    bReserveDiskSpace: BOOL; // ����ʱΪҪ���ص��ļ�Ԥ�������

    maxAttempts: int; // ���ӳ����������Դ�����Ĭ��20��
    retriesTime: int; // ���ӳ�������Եļ��ʱ�䣨�룩
    nTimeout: int; // ���ӳ�ʱ���룩

    bUseDetailLog: BOOL; // ʹ������ϸ����־��Ϣ����һЩ������Ϣ����Ĭ��ֻʹ�û�����Ϣ
    bHideFileNotComplete: BOOL; // ��δ������ɵ��ļ��Ƿ������������ԣ�Ĭ�ϲ�����
    bUseServerTime: BOOL; // ������ɺ��Ƿ��ļ�����Ϊ�������ϸ��ļ���ʱ�䣬Ĭ��ʹ������ʱ��ʱ��
    bReWriteExistFile: BOOL; // �������Ŀ¼���Ѿ�����ͬ�ļ������ļ����Ƿ��滻���ļ��������ء�ʹ�öϵ�����״̬�ļ���ʱ�����ܸò�������
    // �ϵ�����ģʽ�»��������δ��ɵ����ݡ��ò����ǶԸմ�����������Ч��Ĭ����ֱ���滻������ò�����FALSE����ͬ��
    // �ļ�ʱ�����Զ���һ���������ֵ��ļ�������name(1)���֣�

    // ������ٹ��ܵ����ã������Զ����������������Ƿ�����ͬ�ļ���ͬʱ�Ӷ���������ķ���������
    bAutoSearchMirror: BOOL; // �Ƿ��Զ�ͨ����������������������������޸��ļ����Ա���٣�Ĭ�ϲ�ʹ��
    // ȥ�������������Ҳ��ҪһЩʱ�䣬������������ļ������Ҳ��������Ը������ѡ��ʹ��
    mirroServer: int; // ʹ����һ����������� 0��FileSearching.com�� 1�� FindFiles.com��Ĭ����0
    mirroMinFileSize: int; // �ļ��������mirroMinFileSize��ʹ�þ�����٣�Ĭ����1M���ڲ�ʹ�þ������

    // ����Э���������
    rollBackSize: word; // �����жϺ����ûع�����ʱ���ع������ݳ��ȣ��ֽڣ�

    bFtpUsePassiveMode: BOOL; // FTPʹ�ñ�������ģʽ
    bUseHttp11: BOOL; // HttpЭ��ʹ��Http1.1
    bUseCookie: BOOL; // Httpʹ��Cookie

    ftpTransferType: HttpFtp_FtpTransferType;
    // FTP����ģʽ�������ơ�ASCII��������չ������Ĭ���Ǹ�����չ��
    padding: array [0 .. 2] of AnsiChar; // �����ֽ�,û��ʵ�����壬�����ֽڶ��룬ֻ��Ϊ�˵���

    ftpASCIIExt: array [0 .. 255] of AnsiChar; // FTT_BY_EXTģʽ����Ч������Щ��չ�����ļ�ftp����ʱʹ��ASCIIģʽ��Ĭ���ǣ�"txt htm html shtml"��Ĭ���м���һ���ո����,����ʹ�ö�����ģʽ

    agentStr: array [0 .. 2047] of AnsiChar; // userAgent �ַ���
    additionalExtension: array [0 .. 15] of AnsiChar; // δ�������ʱʹ�õĺ�׺��չ����Ĭ�ϲ�ʹ�ú�׺
  end;

  // ========================================================================================
  // �����Ҫ��ϸ��־������ͨ���������������Ҫʲô���Ե�������־��Ŀǰֻ��Ӣ�ĺ����Ŀ�ѡ��Ĭ��������
  // ========================================================================================
  HttpFtp_LANG_TYPE = (HttpFtp_LANG_EN, HttpFtp_LANG_CHS);

  // ========================================================================================
  // �������û�ȡ��ϸ��־������ǻص�������ÿ����һ����Ϣ������������ͨ���ú���֪ͨ
  // ========================================================================================
  HttpFtp_RECEIVELOG_CALLBACK = procedure(downloaderID: DWORD;
    lpstrLog: LPCSTR; lpParam: Pointer); stdcall;


  // ***************************  �����Ƕ�ĳһ�����������һЩ���� ********************************

  // ========================================================================================
  // һ���������һЩ�����Ļ�������
  // ========================================================================================
  PHttpFtpDownloaderParams = ^HttpFtpDownloaderParams;

  HttpFtpDownloaderParams = record
    url: LPCSTR; // Ҫ���ص���ַ��http����ftp��
    saveFolder: LPCSTR; // ���浽�ĸ��ļ���
    fileName: LPCSTR; // �ļ��������bAutoNameΪFALSE����ʹ�ø��ļ��������bAutoNameΪTRUE����ô���Զ�������ʧ��ʱʹ�����fileName
    bAutoName: BOOL; // �Ƿ��Զ���������Ĭ����TRUE
  end;

  // ========================================================================================
  // ���������һЩ״̬
  // ========================================================================================
  HttpFtp_DOWNLOADER_STATE = (HttpFtp_DLSTATE_NONE, // ������
    HttpFtp_DLSTATE_DOWNLOADING, // ������
    HttpFtp_DLSTATE_PAUSE, // ��ͣ
    HttpFtp_DLSTATE_STOPPED, // ֹͣ
    HttpFtp_DLSTATE_FAIL, // ʧ��
    HttpFtp_DLSTATE_DOWNLOADED // �����
    );

  // ========================================================================================
  // �����Ǵ�����ص�һЩ����
  // ========================================================================================

  // �����ļ��ַ�ʽ���������ʹ��IE�еĴ������á�ʹ���Զ���Ĵ�������
  HttpFtp_ACCESS_TYPE = (HttpFtp_ACCESS_NOPROXY,
    // ��ʹ�ô���������һ��ʱ��proxyUserName�Ȳ�����������
    HttpFtp_ACCESS_IE_CONFIG, // ʹ��IE�Ĵ������ã���һ��ʱ����ļ���������������
    HttpFtp_ACCESS_MANUAL // �˹�ָ����ֻ����һ�����Ҫ�õ������proxyUserName����������
    );

  // ========================================================================================
  // һ���������һЩ�߼����ò���
  // ========================================================================================

  PHTTP_FTP_DOWNLOADER_ADDITIONAL_PARAMS = ^
    HTTP_FTP_DOWNLOADER_ADDITIONAL_PARAMS;

  HTTP_FTP_DOWNLOADER_ADDITIONAL_PARAMS = record
    statusFile: LPCSTR; // ���ڶϵ��������´μ����ϴε����أ���״̬�ļ�
    referer: LPCSTR; // httpЭ���е�refer����Щ��վ������ӷ��Լ���վ����ĵط����أ��������������Կ���ʹ��refer������

    authUserName: LPCSTR; // �õ�ַ��Ҫ�����֤���û�����
    authPassword: LPCSTR; // �õ�ַ��Ҫ�����֤�����룩

    maxSections: int; // ���ֶ�������һ���ļ����Է�Ϊ������أ�ÿ������һ���̣߳���Ĭ��12���������һ������ʣ��������������Է�ΪsectionMinSize����
    // ��С��һ�飬����߳��Զ���δ��������������һ��������أ�ʼ�ձ�����ô��ֿ顣ֱ��ʣ�������û���ˣ����߲���sectionMinSize��С�ˡ�
    // Ĭ����0������ʹ��ȫ�ֵ�����
    sectionMinSize: int; // ��С�ķֶδ�С����λ���ֽ����� �ο�maxSections��˵����Ĭ����0������ʹ��ȫ�ֵ����ã������񲻵�������
    trafficLimit: int; // �ٶ����ơ�Ĭ����0������ʹ��ȫ�ֵ�����

    ftpTransferType: HttpFtp_FtpTransferType; // FTP����ģʽ�������ơ�ASCII��������չ���������ã���Ĭ���ǲ�����--ʹ��ȫ���е�����
    padding: array [0 .. 2] of AnsiChar; // �����ֽ�,û��ʵ�����壬�����ֽڶ��룬ֻ��Ϊ�˵���

    iFtpUsePassiveMode: int; // FTPʹ�õĴ���ģʽ��1����ʹ�ñ���ģʽ��0����ʹ�ñ�����Ĭ����-1������ʹ��ȫ�ֵ�
  end;


  // ***************************  �������ں�������صĽӿ� ********************************

  // ======================================================================================
  // �����͹ر��ں˽ӿڣ��ֱ������Ϊ��һ�������һ�����õ�HttpFtp�ں˽ӿ�
  // ======================================================================================
function HttpFtp_Startup(): BOOL; stdcall;
procedure HttpFtp_Shutdown(); stdcall;

// ======================================================================================
// ����HttpFtp�ں˵ĸ������ã��ɲο�HttpFtpGlobalSetting��˵��
// ======================================================================================
// ����ʱ��һ�����ã������ֻ��Ķ������ܵ�ĳһ����ȵ���HttpFtp_GetSetting��õ�ǰ����
// Ȼ���ڵ�ǰ���õĻ������޸ġ���ʾ����������˵����
procedure HttpFtp_SetSetting(s: PHttpFtpGlobalSetting); stdcall;
procedure HttpFtp_GetSetting(s: PHttpFtpGlobalSetting); stdcall;

// ���������ٶȵļ����ӿ�
procedure HttpFtp_SetMaxTraffic(uTrafficLimit: int); stdcall; // �����ں�����ٶ�
procedure HttpFtp_SetMaxConns(uMaxConns: int); stdcall; // ��ཨ��������
procedure HttpFtp_SetMaxConnsPS(uMaxConnsPS: int); stdcall; // �������������ͬʱ���ٸ�����

// ======================================================================================
// ����HttpFtp�ں˵Ĵ���
// ======================================================================================
function HttpFtp_SetProxy(proxyType: HttpFtp_ACCESS_TYPE;
  // ����ʹ��IEĬ�ϴ������á���ʹ�ô��������ֹ����ô���Ĭ�ϲ�ʹ�ô���

  // ���¼�������ֻ��proxyTypeΪHttpFtp_ACCESS_MANUALʱ���ֹ�����ģʽ����Ч
  proxyTo: int; // ���������ø���Щ����ʹ�ã��ο�HttpFtpLib_PROXY_TO_HTTP��Щ
  proxyUrl: LPCSTR; // �����������ַ�������˿ڣ������磺http://198.20.31.85:8080
  userName: LPCSTR; password: LPCSTR): HRESULT; stdcall;

// ======================================================================================
// ����HttpFtp�ں������������Ϣ��ʲô���Եģ�Ŀǰֻ��Ӣ�ĺ����Ŀ�ѡ��Ĭ������
// ======================================================================================
procedure HttpFtp_SetLogLanguage(langType: HttpFtp_LANG_TYPE); stdcall;
// �������������ͬʱ���ٸ�����

// ======================================================================================
// ���ý���HttpFtp�ں������������Ϣ�Ļص��������������Ҫ������Ϣ���Բ����øú���
// ======================================================================================
procedure HttpFtp_SetReceiveLogFunc(pfn: HttpFtp_RECEIVELOG_CALLBACK; // �ص�����
  lpParam: Pointer // ����һ����¼�������ģ���ѡ����������룬�ص�ʱ��ԭ�ⲻ�����ظ�������
  ); stdcall;

// ***************************  �����ǵ���������صĽӿ� ********************************

// ======================================================================================
// ��ʼһ����������
// ======================================================================================
function HttpFtp_Downloader_Initialize(params: PHttpFtpDownloaderParams;
  // �������صĲ���������ַ�ͱ���Ŀ¼��
  downloaderID: PInteger; // ����һ�����������Ψһ��ţ��Ա��Ժ�����������в�������ȡ���ؽ��ȵȣ�
  additionalParams: PHTTP_FTP_DOWNLOADER_ADDITIONAL_PARAMS = nil
  // �߼���������������refer��
  ): HRESULT; stdcall;

// ======================================================================================
// �����ϴε�һ���������񣨶ϵ���������
// ��������ϴ��Ѿ�������һ���֣��������أ���Ҫָ���ϴ�����ʱ����������ļ���״̬�ļ�����·����
// ��ʹ������������ϵ������������е����ú��ϴ�����ʱһ��
// ======================================================================================
function HttpFtp_Downloader_Load(downloaderID: PInteger;
  // ����һ�����������Ψһ��ţ��Ա��Ժ�����������в�������ȡ���ؽ��ȵȣ�
  statusFile: LPCSTR // ״̬�ļ���·�������ڶϵ���������ֻ��������ļ������������������������
  ): HRESULT; stdcall;

// ------------  �����Ǽ������ò�������
// ======================================================================================
// ֹͣ������������ID��downloaderID����Ȼ��Ч�����Ի�ȡ�ļ���С��������������
// dwMilliseconds: ��ȴ�ʱ�䣬���Ϊ0����ʾ�������أ�INFINITE����ʾ�ȵ����в�������ֹͣ�������̣߳�
// 0: �ɹ�ֹͣ   1������ֹͣ������δ���  ��������ֵ����windows����ֵ���������
// ======================================================================================
function HttpFtp_Downloader_Stop(downloaderID: DWORD;
  dwMilliseconds: DWORD): HRESULT; stdcall;

// ======================================================================================
// �Ƴ�������������ID��downloaderID����������Ч��������Դ���ͷ�
// iDeleteFiles��0����ɾ���ļ���ֻ��ֹͣ�� 1����ֻɾ��״̬�ļ���2����ȫ��ɾ��
// ======================================================================================
function HttpFtp_Downloader_Release(downloaderID: DWORD;
  iDeleteFiles: int): HRESULT; stdcall;

// ======================================================================================
// ����һ���������񣬶���Stop����Pause������񣬶����Ե��øú�����������
// ======================================================================================
function HttpFtp_Downloader_Resume(downloaderID: DWORD): HRESULT; stdcall;

// ɾ�������ļ���״̬�ļ����Ľӿڣ����ú󣬱����񽫲������������ļ���һ�������ļ�������ɺ󣬲�����Ҫ�ϵ�����ʱ��
procedure HttpFtp_Downloader_DeleteStatuseFile(downloaderID: DWORD); stdcall;

// ======================================================================================
// ��һ���������Ӿ����ַ��һ���ļ�����ͬʱ�Ӷ�����������أ�
// ======================================================================================
function HttpFtp_Downloader_AddMirrorUrl(downloaderID: DWORD;
  url: LPCSTR): HRESULT; stdcall;


// ======================================================================================
// �����Ǽ������õĻ�ȡ��Ϣ�ĺ���
// ======================================================================================

// ��ȡ���ص��ļ������֣�������Զ��������ļ����ڻ�ȡ���ļ���֮ǰ�����ǿյģ�
function HttpFtp_Downloader_GetFileName(downloaderID: DWORD): LPCSTR; stdcall;

// ��ȡ���������Ӧ����ַ,bIncludeAuth�����Ƿ�����û�����������Ϣ
function HttpFtp_Downloader_GetUrl(downloaderID: DWORD;
  bIncludeAuth: BOOL): LPCSTR; stdcall;

// ��ȡ�����ٶȣ��ֽ�/�룩
function HttpFtp_Downloader_GetSpeed(downloaderID: DWORD): DWORD; stdcall;
// ��ȡʣ��ʱ��
function HttpFtp_Downloader_GetLeftTime(downloaderID: DWORD): DWORD; stdcall;
// ��ȡ��ǰ���ؽ���
function HttpFtp_Downloader_GetPercentDone(downloaderID: DWORD): single;
  stdcall;
// ��ȡ�ļ��ܴ�С���ֽڣ�
function HttpFtp_Downloader_GetFileSize(downloaderID: DWORD): UINT64; stdcall;
// ��ȡ�����ص����������ֽڣ�
function HttpFtp_Downloader_GetDownloadedSize(downloaderID: DWORD): UINT64;
  stdcall;
// ��ȡʣ��Ĵ�С���ֽڣ�
function HttpFtp_Downloader_GetLeftSize(downloaderID: DWORD): UINT64; stdcall;
// ��ȡ������ʱ��������������ؿ�ʼ������������֮ǰ��ʼ��һЩ������ʱ�䣩��������ֹͣ���������ʱ�䣨ms��λ����
// ��¼���-���ؿ�ʼ��ʱ���
function HttpFtp_Downloader_GetDownloadTime(downloaderID: DWORD): DWORD;
  stdcall;
// ��ȡ������ʱ��������������ؿ�ʼ������������֮ǰ��ʼ��һЩ������ʱ�䣩������ǰ��ʱ�䣨��λ��ms����
function HttpFtp_Downloader_GetDownloadRunningTime(downloaderID: DWORD): DWORD;
  stdcall;

// ��ȡ�����״̬�������С���ͣ������ɵ�
function HttpFtp_Downloader_GetState(downloaderID: DWORD)
  : HttpFtp_DOWNLOADER_STATE; stdcall;
// �������Ե��ò鿴������Ϣ
function HttpFtp_Downloader_GetLastError(downloaderID: DWORD): DWORD; stdcall;

// ������֤��صĽӿ�
procedure HttpFtp_SetVerInfo(cert1: DWORD; cert2: DWORD; cert3: DWORD;
  cert4: LPCSTR); stdcall;

implementation

function HttpFtp_Startup; stdcall;
external DHttp_Library name 'HttpFtp_Startup';
procedure HttpFtp_Shutdown; stdcall;
external DHttp_Library name 'HttpFtp_Shutdown';

procedure HttpFtp_SetSetting; stdcall;
external DHttp_Library name 'HttpFtp_SetSetting';
procedure HttpFtp_GetSetting; stdcall;
external DHttp_Library name 'HttpFtp_GetSetting';

procedure HttpFtp_SetMaxTraffic; stdcall;
external DHttp_Library name 'HttpFtp_SetMaxTraffic';
procedure HttpFtp_SetMaxConns; stdcall;
external DHttp_Library name 'HttpFtp_SetMaxConns';
procedure HttpFtp_SetMaxConnsPS; stdcall;
external DHttp_Library name 'HttpFtp_SetMaxConnsPS';

function HttpFtp_SetProxy; stdcall;
external DHttp_Library name 'HttpFtp_SetProxy';
procedure HttpFtp_SetLogLanguage; stdcall;
external DHttp_Library name 'HttpFtp_SetLogLanguage';
procedure HttpFtp_SetReceiveLogFunc; stdcall;
external DHttp_Library name 'HttpFtp_SetReceiveLogFunc';

function HttpFtp_Downloader_Initialize; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_Initialize';
function HttpFtp_Downloader_Load; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_Load';
function HttpFtp_Downloader_Stop; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_Stop';
function HttpFtp_Downloader_Release; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_Release';
function HttpFtp_Downloader_Resume; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_Resume';
procedure HttpFtp_Downloader_DeleteStatuseFile; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_DeleteStatuseFile';

function HttpFtp_Downloader_AddMirrorUrl; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_AddMirrorUrl';
function HttpFtp_Downloader_GetFileName; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_GetFileName';
function HttpFtp_Downloader_GetUrl; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_GetUrl';
function HttpFtp_Downloader_GetSpeed; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_GetSpeed';
function HttpFtp_Downloader_GetLeftTime; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_GetLeftTime';
function HttpFtp_Downloader_GetPercentDone; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_GetPercentDone';
function HttpFtp_Downloader_GetFileSize; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_GetFileSize';
function HttpFtp_Downloader_GetDownloadedSize; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_GetDownloadedSize';
function HttpFtp_Downloader_GetLeftSize; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_GetLeftSize';
function HttpFtp_Downloader_GetDownloadTime; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_GetDownloadTime';
function HttpFtp_Downloader_GetDownloadRunningTime; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_GetDownloadRunningTime';
function HttpFtp_Downloader_GetState; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_GetState';
function HttpFtp_Downloader_GetLastError; stdcall;
external DHttp_Library name 'HttpFtp_Downloader_GetLastError';

procedure HttpFtp_SetVerInfo; stdcall;
external DHttp_Library name 'HttpFtp_SetVerInfo';

end.
