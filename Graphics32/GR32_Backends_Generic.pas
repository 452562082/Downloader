unit GR32_Backends_Generic;

interface

{$I GR32.inc}

uses
{$IFDEF FPC}
  {$IFDEF Windows}
  Windows,
  {$ENDIF}
{$ELSE}
  Windows,
{$ENDIF}
{$IFDEF USE_GUIDS_IN_MMF}
  ActiveX,
{$ENDIF}
  SysUtils, Classes, GR32, GR32_Backends;

type

  TMemoryBackend = class(TCustomBackend)
  protected
    procedure InitializeSurface(NewWidth, NewHeight: Integer; ClearBuffer: Boolean); override;
    procedure FinalizeSurface; override;
  end;

{$IFDEF Windows}

  TMMFBackend = class(TMemoryBackend)
  private
    FMapHandle: THandle;
    FMapIsTemporary: boolean;
    FMapFileHandle: THandle;
    FMapFileName: string;
  protected
    procedure InitializeSurface(NewWidth, NewHeight: Integer; ClearBuffer: Boolean); override;
    procedure FinalizeSurface; override;
  public
    constructor Create(Owner: TCustomBitmap32; IsTemporary: Boolean = True; const MapFileName: string = ''); virtual;
    destructor Destroy; override;

    class procedure InitializeFileMapping(var MapHandle, MapFileHandle: THandle; var MapFileName: string);
    class procedure DeinitializeFileMapping(MapHandle, MapFileHandle: THandle; const MapFileName: string);
    class procedure CreateFileMapping(var MapHandle, MapFileHandle: THandle; var MapFileName: string; IsTemporary: Boolean; NewWidth, NewHeight: Integer);
  end;

{$ENDIF}

implementation

uses
  GR32_LowLevel;

{$IFDEF Windows}

var
  TempPath: TFileName;

resourcestring
  RCStrFailedToMapFile = 'Failed to map file';
  RCStrFailedToCreateMapFile = 'Failed to create map file (%s)';
  RCStrFailedToMapViewOfFile = 'Failed to map view of file.';

function GetTempPath: TFileName;
var
  PC: PChar;
begin
  PC := StrAlloc(MAX_PATH + 1);
  try
    Windows.GetTempPath(MAX_PATH, PC);
    Result := TFileName(PC);
  finally
    StrDispose(PC);
  end;
end;

{$ENDIF}

procedure TMemoryBackend.InitializeSurface(NewWidth, NewHeight: Integer; ClearBuffer: Boolean);
begin
  GetMem(FBits, NewWidth * NewHeight * 4);
  if ClearBuffer then
    FillLongword(FBits[0], NewWidth * NewHeight, clBlack32);
end;

procedure TMemoryBackend.FinalizeSurface;
begin
  if Assigned(FBits) then
  begin
    FreeMem(FBits);
    FBits := nil;
  end;
end;

{$IFDEF Windows}

constructor TMMFBackend.Create(Owner: TCustomBitmap32; IsTemporary: Boolean = True; const MapFileName: string = '');
begin
  FMapFileName := MapFileName;
  FMapIsTemporary := IsTemporary;
  InitializeFileMapping(FMapHandle, FMapFileHandle, FMapFileName);
  inherited Create(Owner);
end;

destructor TMMFBackend.Destroy;
begin
  DeinitializeFileMapping(FMapHandle, FMapFileHandle, FMapFileName);
  inherited;
end;

procedure TMMFBackend.FinalizeSurface;
begin
  if Assigned(FBits) then
  begin
    UnmapViewOfFile(FBits);
    FBits := nil;
  end;
end;

procedure TMMFBackend.InitializeSurface(NewWidth, NewHeight: Integer; ClearBuffer: Boolean);
begin
  CreateFileMapping(FMapHandle, FMapFileHandle, FMapFileName, FMapIsTemporary, NewWidth, NewHeight);
  FBits := MapViewOfFile(FMapHandle, FILE_MAP_ALL_ACCESS, 0, 0, 0);

  if not Assigned(FBits) then
    raise Exception.Create(RCStrFailedToMapViewOfFile);

  if ClearBuffer then
    FillLongword(FBits[0], NewWidth * NewHeight, clBlack32);
end;

class procedure TMMFBackend.InitializeFileMapping(var MapHandle, MapFileHandle: THandle; var MapFileName: string);
begin
  MapHandle := INVALID_HANDLE_VALUE;
  MapFileHandle := INVALID_HANDLE_VALUE;
  if MapFileName <> '' then
    ForceDirectories(IncludeTrailingPathDelimiter(ExtractFilePath(MapFileName)));
end;

class procedure TMMFBackend.DeinitializeFileMapping(MapHandle, MapFileHandle: THandle; const MapFileName: string);
begin
  if MapFileName <> '' then
  begin
    CloseHandle(MapHandle);
    CloseHandle(MapFileHandle);
    if FileExists(MapFileName) then
      DeleteFile(MapFileName);
  end;
end;

class procedure TMMFBackend.CreateFileMapping(var MapHandle, MapFileHandle: THandle;
  var MapFileName: string; IsTemporary: Boolean; NewWidth, NewHeight: Integer);
var
  Flags: Cardinal;

{$IFDEF USE_GUIDS_IN_MMF}

  function GetTempFileName(const Prefix: string): string;
  var
    GUID: TGUID;
  begin
    repeat
      CoCreateGuid(GUID);
      Result := TempPath + Prefix + GUIDToString(GUID);
    until not FileExists(Result);
  end;

{$ELSE}

  function GetTempFileName(const Prefix: string): string;
  var
    PC: PChar;
  begin
    PC := StrAlloc(MAX_PATH + 1);
    Windows.GetTempFileName(PChar(GetTempPath), PChar(Prefix), 0, PC);
    Result := string(PC);
    StrDispose(PC);
  end;

{$ENDIF}

begin
  
  if MapHandle <> INVALID_HANDLE_VALUE then
  begin
    CloseHandle(MapHandle);
    MapHandle := INVALID_HANDLE_VALUE;
  end;

  if MapFileHandle <> INVALID_HANDLE_VALUE then
  begin
    CloseHandle(MapFileHandle);
    MapHandle := INVALID_HANDLE_VALUE;
  end;
  
  if (MapFileName <> '') or IsTemporary then
  begin
    if MapFileName = '' then
    {$IFDEF HAS_NATIVEINT}
      MapFileName := GetTempFileName(IntToStr(NativeUInt(Self)));
    {$ELSE}
      MapFileName := GetTempFileName(IntToStr(Cardinal(Self)));
    {$ENDIF}
    
    if FileExists(MapFileName) then
      DeleteFile(MapFileName);
    
    if IsTemporary then
      Flags := FILE_ATTRIBUTE_TEMPORARY OR FILE_FLAG_DELETE_ON_CLOSE
    else
      Flags := FILE_ATTRIBUTE_NORMAL;

    MapFileHandle := CreateFile(PChar(MapFileName), GENERIC_READ or GENERIC_WRITE,
      0, nil, CREATE_ALWAYS, Flags, 0);

    if MapFileHandle = INVALID_HANDLE_VALUE then
    begin
      if not IsTemporary then
        raise Exception.CreateFmt(RCStrFailedToCreateMapFile, [MapFileName])
      else
      begin
        
        if FileExists(MapFileName) then
          DeleteFile(MapFileName);
          
        MapFileName := '';
      end;
    end;
  end
  else 
    MapFileHandle := INVALID_HANDLE_VALUE;
  
  MapHandle := Windows.CreateFileMapping(MapFileHandle, nil, PAGE_READWRITE, 0, NewWidth * NewHeight * 4, nil);

  if MapHandle = 0 then
    raise Exception.Create(RCStrFailedToMapFile);
end;

{$ENDIF}

{$IFDEF Windows}
initialization
  TempPath := IncludeTrailingPathDelimiter(GetTempPath);

finalization
  TempPath := '';
{$ENDIF}

end.
 