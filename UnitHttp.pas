unit UnitHttp;

interface

uses
  windows, SysUtils;

const
  DHttp_Library = 'HttpFtp.dll';
  // 以下是只有在 HttpFtp_ACCESS_MANUAL 时有效
  HttpFtp_PROXY_TO_HTTP = 1; // 仅对Http方式的下载使用代理
  HttpFtp_PROXY_TO_HTTPS = 2; // 仅对Https方式的下载使用代理
  HttpFtp_PROXY_TO_FTP = 4; // 仅对Ftp下载使用代理设置
  HttpFtp_PROXY_TO_ALL = 7; // (HttpFtp_PROXY_TO_HTTP | HttpFtp_PROXY_TO_HTTPS | HttpFtp_PROXY_TO_FTP);  //对所有下载均使用代理

type
  int = integer;

  // FTP传输时的几种方式设置
  HttpFtp_FtpTransferType = (FTT_BINARY, // 二进制模式
    FTT_ASCII, // ASCII方式
    FTT_BY_EXT, // 根据文件后缀名选择下载模式（仅ftpASCIIExt里面的这些文件使用ASCII模式，其它使用二进制）
    FTT_NO_SET // 不做设置，如果是单独的任务中传入这个参数，代表默认使用全局的设置；如果是全局中则会默认使用ByEXT方式
    );

  // =============================================================
  // 程序整体性质的绝大部分配置选项都在下面这个结构体中
  // 需要修改时可以直接修改要改变的某一项即可
  // =============================================================

  PHttpFtpGlobalSetting = ^HttpFtpGlobalSetting;

  HttpFtpGlobalSetting = record
    maxSections: int; // 最多分段数（将一个文件可以分为多块下载，每块启动一个线程），默认12。下载完成一块后，如果剩余的数据量还足以分为sectionMinSize以上
    // 大小的一块，则该线程自动从未下完的数据里面分一块出来下载，始终保持这么多分块。直到剩余的数据没有了，或者不足sectionMinSize大小了。
    sectionMinSize: int; // 最小的分段大小，单位是字节数。 参考maxSections的说明
    trafficLimit: int; // 速度限制

    dwWriteCaceSize: DWORD; // 写缓存大小（字节）
    iAutoSaveInterval: int; // 自动保存缓存进入磁盘的时间间隔(毫秒)
    bReserveDiskSpace: BOOL; // 下载时为要下载的文件预分配磁盘

    maxAttempts: int; // 连接出错后最多重试次数，默认20次
    retriesTime: int; // 连接出错后重试的间隔时间（秒）
    nTimeout: int; // 连接超时（秒）

    bUseDetailLog: BOOL; // 使用最详细的日志信息（有一些调试信息），默认只使用基本信息
    bHideFileNotComplete: BOOL; // 对未下载完成的文件是否设置隐藏属性，默认不隐藏
    bUseServerTime: BOOL; // 下载完成后是否将文件设置为服务器上该文件的时间，默认使用下载时的时间
    bReWriteExistFile: BOOL; // 如果下载目录下已经有相同文件名的文件，是否替换该文件重新下载。使用断点续传状态文件的时候，则不受该参数限制
    // 断点续传模式下会继续下载未完成的数据。该参数是对刚创建的下载有效。默认是直接替换。如果该参数是FALSE，有同名
    // 文件时，会自动建一个其它名字的文件（比如name(1)这种）

    // 镜像加速功能的设置：可以自动找其它服务器上是否有相同文件，同时从多个搜索到的服务器下载
    bAutoSearchMirror: BOOL; // 是否自动通过镜像服务器搜索其它服务上有无该文件，以便加速；默认不使用
    // 去镜像服务器查找也需要一些时间，如果不是热门文件可能找不到，所以根据情况选择使用
    mirroServer: int; // 使用哪一个镜像服务器 0：FileSearching.com； 1： FindFiles.com。默认是0
    mirroMinFileSize: int; // 文件如果少于mirroMinFileSize则不使用镜像加速，默认是1M以内不使用镜像加速

    // 下载协议相关设置
    rollBackSize: word; // 连接中断后启用回滚机制时，回滚的数据长度（字节）

    bFtpUsePassiveMode: BOOL; // FTP使用被动传送模式
    bUseHttp11: BOOL; // Http协议使用Http1.1
    bUseCookie: BOOL; // Http使用Cookie

    ftpTransferType: HttpFtp_FtpTransferType;
    // FTP传输模式（二进制、ASCII、根据扩展名），默认是根据扩展名
    padding: array [0 .. 2] of AnsiChar; // 对齐字节,没有实际意义，用于字节对齐，只是为了调用

    ftpASCIIExt: array [0 .. 255] of AnsiChar; // FTT_BY_EXT模式下有效，对这些扩展名的文件ftp传输时使用ASCII模式，默认是："txt htm html shtml"，默认中间有一个空格隔开,其它使用二进制模式

    agentStr: array [0 .. 2047] of AnsiChar; // userAgent 字符串
    additionalExtension: array [0 .. 15] of AnsiChar; // 未下载完成时使用的后缀扩展名，默认不使用后缀
  end;

  // ========================================================================================
  // 如果需要详细日志，可以通过下面这个设置需要什么语言的下载日志，目前只有英文和中文可选，默认是中文
  // ========================================================================================
  HttpFtp_LANG_TYPE = (HttpFtp_LANG_EN, HttpFtp_LANG_CHS);

  // ========================================================================================
  // 用于设置获取详细日志，这个是回调函数，每当有一个信息出来，会立即通过该函数通知
  // ========================================================================================
  HttpFtp_RECEIVELOG_CALLBACK = procedure(downloaderID: DWORD;
    lpstrLog: LPCSTR; lpParam: Pointer); stdcall;


  // ***************************  以下是对某一个下载任务的一些类型 ********************************

  // ========================================================================================
  // 一个任务项的一些启动的基本参数
  // ========================================================================================
  PHttpFtpDownloaderParams = ^HttpFtpDownloaderParams;

  HttpFtpDownloaderParams = record
    url: LPCSTR; // 要下载的网址（http或者ftp）
    saveFolder: LPCSTR; // 保存到哪个文件夹
    fileName: LPCSTR; // 文件名：如果bAutoName为FALSE，则使用该文件名；如果bAutoName为TRUE，那么再自动重命名失败时使用这个fileName
    bAutoName: BOOL; // 是否自动重命名，默认是TRUE
  end;

  // ========================================================================================
  // 下载任务的一些状态
  // ========================================================================================
  HttpFtp_DOWNLOADER_STATE = (HttpFtp_DLSTATE_NONE, // 已启动
    HttpFtp_DLSTATE_DOWNLOADING, // 下载中
    HttpFtp_DLSTATE_PAUSE, // 暂停
    HttpFtp_DLSTATE_STOPPED, // 停止
    HttpFtp_DLSTATE_FAIL, // 失败
    HttpFtp_DLSTATE_DOWNLOADED // 已完成
    );

  // ========================================================================================
  // 以下是代理相关的一些设置
  // ========================================================================================

  // 上网的几种方式：不需代理、使用IE中的代理设置、使用自定义的代理设置
  HttpFtp_ACCESS_TYPE = (HttpFtp_ACCESS_NOPROXY,
    // 不使用代理：设置这一项时，proxyUserName等参数不起作用
    HttpFtp_ACCESS_IE_CONFIG, // 使用IE的代理设置：这一项时后面的几个参数不起作用
    HttpFtp_ACCESS_MANUAL // 人工指定：只有这一项才需要用到后面的proxyUserName等其他参数
    );

  // ========================================================================================
  // 一个任务项的一些高级设置参数
  // ========================================================================================

  PHTTP_FTP_DOWNLOADER_ADDITIONAL_PARAMS = ^
    HTTP_FTP_DOWNLOADER_ADDITIONAL_PARAMS;

  HTTP_FTP_DOWNLOADER_ADDITIONAL_PARAMS = record
    statusFile: LPCSTR; // 用于断点续传（下次继续上次的下载）的状态文件
    referer: LPCSTR; // http协议中的refer，有些网站不允许从非自己网站以外的地方下载（防盗链），可以考虑使用refer来灵活处理

    authUserName: LPCSTR; // 该地址需要身份验证（用户名）
    authPassword: LPCSTR; // 该地址需要身份验证（密码）

    maxSections: int; // 最多分段数（将一个文件可以分为多块下载，每块启动一个线程），默认12。下载完成一块后，如果剩余的数据量还足以分为sectionMinSize以上
    // 大小的一块，则该线程自动从未下完的数据里面分一块出来下载，始终保持这么多分块。直到剩余的数据没有了，或者不足sectionMinSize大小了。
    // 默认是0，代表使用全局的设置
    sectionMinSize: int; // 最小的分段大小，单位是字节数。 参考maxSections的说明。默认是0，代表使用全局的设置，该任务不单独设置
    trafficLimit: int; // 速度限制。默认是0，代表使用全局的设置

    ftpTransferType: HttpFtp_FtpTransferType; // FTP传输模式（二进制、ASCII、根据扩展名、不设置），默认是不设置--使用全局中的设置
    padding: array [0 .. 2] of AnsiChar; // 对齐字节,没有实际意义，用于字节对齐，只是为了调用

    iFtpUsePassiveMode: int; // FTP使用的传送模式，1代表使用被动模式，0代表不使用被动，默认是-1，代表使用全局的
  end;


  // ***************************  以下是内核整体相关的接口 ********************************

  // ======================================================================================
  // 启动和关闭内核接口，分别必须作为第一个和最后一个调用的HttpFtp内核接口
  // ======================================================================================
function HttpFtp_Startup(): BOOL; stdcall;
procedure HttpFtp_Shutdown(); stdcall;

// ======================================================================================
// 设置HttpFtp内核的各项配置，可参考HttpFtpGlobalSetting的说明
// ======================================================================================
// 设置时是一起设置，如果你只想改动配置总的某一项，请先调用HttpFtp_GetSetting获得当前设置
// 然后在当前配置的基础上修改。（示例程序中有说明）
procedure HttpFtp_SetSetting(s: PHttpFtpGlobalSetting); stdcall;
procedure HttpFtp_GetSetting(s: PHttpFtpGlobalSetting); stdcall;

// 限制整体速度的几个接口
procedure HttpFtp_SetMaxTraffic(uTrafficLimit: int); stdcall; // 整个内核最大速度
procedure HttpFtp_SetMaxConns(uMaxConns: int); stdcall; // 最多建立连接数
procedure HttpFtp_SetMaxConnsPS(uMaxConnsPS: int); stdcall; // 单个服务器最多同时多少个连接

// ======================================================================================
// 设置HttpFtp内核的代理
// ======================================================================================
function HttpFtp_SetProxy(proxyType: HttpFtp_ACCESS_TYPE;
  // 设置使用IE默认代理设置、不使用代理、还是手工设置代理，默认不使用代理

  // 以下几个参数只在proxyType为HttpFtp_ACCESS_MANUAL时（手工设置模式）有效
  proxyTo: int; // 将代理设置给哪些下载使用，参考HttpFtpLib_PROXY_TO_HTTP这些
  proxyUrl: LPCSTR; // 代理服务器地址（包括端口），比如：http://198.20.31.85:8080
  userName: LPCSTR; password: LPCSTR): HRESULT; stdcall;

// ======================================================================================
// 设置HttpFtp内核输出的下载信息是什么语言的，目前只有英文和中文可选，默认中文
// ======================================================================================
procedure HttpFtp_SetLogLanguage(langType: HttpFtp_LANG_TYPE); stdcall;
// 单个服务器最多同时多少个连接

// ======================================================================================
// 设置接收HttpFtp内核输出的下载信息的回调函数，如果不需要下载信息可以不设置该函数
// ======================================================================================
procedure HttpFtp_SetReceiveLogFunc(pfn: HttpFtp_RECEIVELOG_CALLBACK; // 回调函数
  lpParam: Pointer // 传入一个记录的上下文（可选），如果传入，回调时会原封不动传回给调用者
  ); stdcall;

// ***************************  以下是单个下载相关的接口 ********************************

// ======================================================================================
// 开始一个下载任务
// ======================================================================================
function HttpFtp_Downloader_Initialize(params: PHttpFtpDownloaderParams;
  // 启动下载的参数（有网址和保存目录）
  downloaderID: PInteger; // 返回一个下载任务的唯一标号，以便以后对这个任务进行操作（获取下载进度等）
  additionalParams: PHTTP_FTP_DOWNLOADER_ADDITIONAL_PARAMS = nil
  // 高级参数，比如设置refer等
  ): HRESULT; stdcall;

// ======================================================================================
// 载入上次的一个下载任务（断点续传）：
// 如果任务上次已经下载了一部分，继续下载，需要指定上次下载时保存的续传文件（状态文件）的路径。
// 则使用这个函数（断点续传），所有的配置和上次下载时一致
// ======================================================================================
function HttpFtp_Downloader_Load(downloaderID: PInteger;
  // 返回一个下载任务的唯一标号，以便以后对这个任务进行操作（获取下载进度等）
  statusFile: LPCSTR // 状态文件的路径（用于断点续传），只有有这个文件才能续传，否则就是新下载
  ): HRESULT; stdcall;

// ------------  以下是几个常用操作函数
// ======================================================================================
// 停止下载任务，任务ID（downloaderID）仍然有效，可以获取文件大小、下载完成情况等
// dwMilliseconds: 最长等待时间，如果为0，表示立即返回，INFINITE，表示等到所有操作真正停止（各个线程）
// 0: 成功停止   1：正在停止，但尚未完成  其它返回值：是windows返回值，代表出错
// ======================================================================================
function HttpFtp_Downloader_Stop(downloaderID: DWORD;
  dwMilliseconds: DWORD): HRESULT; stdcall;

// ======================================================================================
// 移除下载任务，任务ID（downloaderID）将不再有效，所有资源都释放
// iDeleteFiles：0代表不删除文件，只是停止； 1代表只删除状态文件；2代表全部删除
// ======================================================================================
function HttpFtp_Downloader_Release(downloaderID: DWORD;
  iDeleteFiles: int): HRESULT; stdcall;

// ======================================================================================
// 继续一个下载任务，对于Stop或者Pause后的任务，都可以调用该函数继续下载
// ======================================================================================
function HttpFtp_Downloader_Resume(downloaderID: DWORD): HRESULT; stdcall;

// 删除续传文件（状态文件）的接口，调用后，本任务将不再生成续传文件（一般用于文件下载完成后，不再需要断点续传时）
procedure HttpFtp_Downloader_DeleteStatuseFile(downloaderID: DWORD); stdcall;

// ======================================================================================
// 对一个任务增加镜像地址（一个文件可以同时从多个服务器下载）
// ======================================================================================
function HttpFtp_Downloader_AddMirrorUrl(downloaderID: DWORD;
  url: LPCSTR): HRESULT; stdcall;


// ======================================================================================
// 以下是几个常用的获取信息的函数
// ======================================================================================

// 获取下载的文件的名字（如果是自动命名的文件，在获取到文件名之前可能是空的）
function HttpFtp_Downloader_GetFileName(downloaderID: DWORD): LPCSTR; stdcall;

// 获取下载任务对应的网址,bIncludeAuth代表是否包括用户名和密码信息
function HttpFtp_Downloader_GetUrl(downloaderID: DWORD;
  bIncludeAuth: BOOL): LPCSTR; stdcall;

// 获取下载速度（字节/秒）
function HttpFtp_Downloader_GetSpeed(downloaderID: DWORD): DWORD; stdcall;
// 获取剩余时间
function HttpFtp_Downloader_GetLeftTime(downloaderID: DWORD): DWORD; stdcall;
// 获取当前下载进度
function HttpFtp_Downloader_GetPercentDone(downloaderID: DWORD): single;
  stdcall;
// 获取文件总大小（字节）
function HttpFtp_Downloader_GetFileSize(downloaderID: DWORD): UINT64; stdcall;
// 获取已下载的数据量（字节）
function HttpFtp_Downloader_GetDownloadedSize(downloaderID: DWORD): UINT64;
  stdcall;
// 获取剩余的大小（字节）
function HttpFtp_Downloader_GetLeftSize(downloaderID: DWORD): UINT64; stdcall;
// 获取下载用时：从任务进入下载开始（不包括下载之前初始化一些环境的时间），到下载停止或完成所用时间（ms单位）。
// 记录完成-下载开始的时间段
function HttpFtp_Downloader_GetDownloadTime(downloaderID: DWORD): DWORD;
  stdcall;
// 获取运行用时：从任务进入下载开始（不包括下载之前初始化一些环境的时间），到当前的时间（单位：ms）。
function HttpFtp_Downloader_GetDownloadRunningTime(downloaderID: DWORD): DWORD;
  stdcall;

// 获取任务的状态：下载中、暂停、已完成等
function HttpFtp_Downloader_GetState(downloaderID: DWORD)
  : HttpFtp_DOWNLOADER_STATE; stdcall;
// 出错后可以调用查看错误信息
function HttpFtp_Downloader_GetLastError(downloaderID: DWORD): DWORD; stdcall;

// 正版验证相关的接口
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
