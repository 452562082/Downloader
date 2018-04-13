unit UnitLoadDll;

interface

uses
  Windows, Classes, SysUtils, Math;

const
  IMAGE_REL_BASED_ABSOLUTE = 0;
  IMAGE_REL_BASED_HIGH = 1;
  IMAGE_REL_BASED_LOW = 2;
  IMAGE_REL_BASED_HIGHLOW = 3;
  IMAGE_REL_BASED_HIGHADJ = 4;
  IMAGE_REL_BASED_MIPS_JMPADDR = 5;
  IMAGE_REL_BASED_SECTION = 6;
  IMAGE_REL_BASED_REL32 = 7;
  IMAGE_REL_BASED_MIPS_JMPADDR16 = 9;
  IMAGE_REL_BASED_IA64_IMM64 = 9;
  IMAGE_REL_BASED_DIR64 = 10;
  IMAGE_REL_BASED_HIGH3ADJ = 11;
  IMAGE_ORDINAL_FLAG64 = UINT64($8000000000000000);
  IMAGE_ORDINAL_FLAG32 = LongWord($80000000);
  IMAGE_ORDINAL_FLAG =
{$IFDEF WIN64} IMAGE_ORDINAL_FLAG64 {$ELSE} IMAGE_ORDINAL_FLAG32 {$ENDIF};
  MARCHINECODE =
{$IFDEF WIN64} IMAGE_FILE_MACHINE_AMD64 {$ELSE} IMAGE_FILE_MACHINE_I386
{$ENDIF};

type
  LPVOID = Pointer;
  DWORD_PTR = DWORD;
  PDWORD_PTR = ^DWORD_PTR;
  PVoid = Pointer;

  DLLMAIN = function(image_base: DWORD_PTR; reason: DWORD;
    reserved: LPVOID): BOOL; stdcall;
  LPDLLMAIN = DLLMAIN;

  size_t = Cardinal;
  int = Integer;
  PHMODULE = ^HMODULE;
  unsigned = DWORD;

  LOAD_DLL_INFO = packed record
    size: size_t;
    flags: int;
    image_base: DWORD_PTR;
    mem_block: Pointer;
    dll_main: LPDLLMAIN;
    export_dir_rva: DWORD;
    loaded_import_modules_array: PHMODULE;
    num_import_modules: unsigned;
  end;

  PLOAD_DLL_INFO = ^LOAD_DLL_INFO;

  _LOAD_DLL_READPROC = function(buff: PVoid; position: size_t; size: size_t;
    param: PVoid): BOOL; cdecl;
  LOAD_DLL_READPROC = _LOAD_DLL_READPROC;

  ELoadDLLResult = Integer;

const
  ELoadDLLResult_OK = 0;
  
  ELoadDLLResult_ReadProcError = 1;
  
  ELoadDLLResult_InvalidImage = 2;
  
  ELoadDLLResult_MemoryAllocationError = 3;
  
  ELoadDLLResult_RelocationError = 4;
  
  ELoadDLLResult_BadRelocationTable = 5;
  
  ELoadDLLResult_ImportModuleError = 6;
  
  ELoadDLLResult_ImportFunctionError = 6;
  
  ELoadDLLResult_ImportTableError = 7;
  
  ELoadDLLResult_BoundImportDirectoriesNotSupported = 8;
  
  ELoadDLLResult_ErrorSettingMemoryProtection = 9;
  
  ELoadDLLResult_DllMainCallError = 10;
  ELoadDLLResult_DLLFileNotFound = 11;
  
  ELoadDLLResult_WrongFunctionParameters = -2;
  ELoadDLLResult_UnknownError = -1;

type
  ELoadDLLFlag = DWORD;

const
  
  ELoadDLLFlag_NoEntryCall = $01;
  
  ELoadDLLFlag_NoHeaders = $02;

type
  PIMAGE_SECTION_HEADER = ^IMAGE_SECTION_HEADER;
  PIMAGE_DOS_HEADER = ^IMAGE_DOS_HEADER;
  PIMAGE_NT_HEADERS = ^IMAGE_NT_HEADERS;

  LOAD_DLL_CONTEXT = packed record
    dos_hdr: IMAGE_DOS_HEADER;
    hdr: IMAGE_NT_HEADERS;
    sect: PIMAGE_SECTION_HEADER;
    file_offset_section_headers: size_t;
    size_section_headers: size_t;

    image_base: DWORD_PTR;
    image: PVoid;

    loaded_import_modules_array: PHMODULE;
    num_import_modules: unsigned;
    import_modules_array_capacity: unsigned;

    dll_main: LPDLLMAIN;
  end;

  PLOAD_DLL_CONTEXT = ^LOAD_DLL_CONTEXT;

  MODULE_HANDLE = PLOAD_DLL_INFO;

  LOAD_DLL_FROM_MEMORY_STRUCT = packed record
    dll_data: PVoid;
    dll_size: size_t;
  end;

  PLOAD_DLL_FROM_MEMORY_STRUCT = ^LOAD_DLL_FROM_MEMORY_STRUCT;

  IMAGE_BASE_RELOCATION = packed record
    VirtualAddress: DWORD;
    SizeOfBlock: DWORD;
  end;

  PIMAGE_BASE_RELOCATION = ^IMAGE_BASE_RELOCATION;
  PIMAGE_EXPORT_DIRECTORY = ^IMAGE_EXPORT_DIRECTORY;
  
function LoadModuleFromMemory(const dll_data: Pointer;
  dll_size: size_t): MODULE_HANDLE;
function GetModuleFunction(handle: MODULE_HANDLE;
  const func_name: PAnsiChar): Pointer; overload;
function GetModuleFunction(handle: MODULE_HANDLE;
  const func_name: string): Pointer; overload;
function UnloadModule(handle: MODULE_HANDLE): Boolean;

implementation

function m_read_proc(read_proc: LOAD_DLL_READPROC; buff: PVoid;
  position: size_t; size: size_t; param: PVoid): ELoadDLLResult; cdecl;
begin
  Result := ELoadDLLResult_UnknownError;
  try
    if not(read_proc(buff, position, size, param)) then
      Result := ELoadDLLResult_ReadProcError
    else
      Result := ELoadDLLResult_OK;
  except
    Result := ELoadDLLResult_ReadProcError;
  end;
end;

function LoadDLLFromMemoryCallback(buff: PVoid; position: size_t; size: size_t;
  param: PLOAD_DLL_FROM_MEMORY_STRUCT): BOOL; cdecl;
begin
  if (size = 0) then
  begin
    Result := True;
    Exit;
  end;
  if ((position + size) > param^.dll_size) then
  begin
    Result := False;
    Exit;
  end;
  CopyMemory(buff, Pointer(DWORD(param^.dll_data) + position), size);
  Result := True;
end;

function LoadDLL_LoadHeaders(ctx: PLOAD_DLL_CONTEXT;
  read_proc: LOAD_DLL_READPROC; read_proc_param: PVoid): ELoadDLLResult; cdecl;
begin
  
  Result := m_read_proc(read_proc, @ctx^.dos_hdr, 0, SizeOf(ctx^.dos_hdr),
    read_proc_param);
  if Result <> ELoadDLLResult_OK then
    Exit;
  if (ctx^.dos_hdr.e_magic <> IMAGE_DOS_SIGNATURE) or
    (ctx^.dos_hdr._lfanew = 0) then
  begin
    Result := ELoadDLLResult_InvalidImage;
    Exit;
  end;
  
  Result := m_read_proc(read_proc, @ctx^.hdr, ctx^.dos_hdr._lfanew,
    SizeOf(ctx^.hdr), read_proc_param);
  if Result <> ELoadDLLResult_OK then
    Exit;
  if (ctx^.hdr.Signature <> IMAGE_NT_SIGNATURE) or
    (ctx^.hdr.OptionalHeader.Magic <> IMAGE_NT_OPTIONAL_HDR_MAGIC) or
    (ctx^.hdr.FileHeader.NumberOfSections = 0) then
  begin
    Result := ELoadDLLResult_InvalidImage;
    Exit;
  end;

  ctx^.size_section_headers := ctx^.hdr.FileHeader.NumberOfSections * SizeOf
    (IMAGE_SECTION_HEADER);
  GetMem(ctx^.sect, ctx^.size_section_headers);
  if not Assigned(ctx^.sect) then
  begin
    Result := ELoadDLLResult_MemoryAllocationError;
    Exit;
  end;
  ctx^.file_offset_section_headers := ctx^.dos_hdr._lfanew + SizeOf(DWORD)
    + SizeOf(IMAGE_FILE_HEADER) + ctx^.hdr.FileHeader.SizeOfOptionalHeader;

  Result := m_read_proc(read_proc, ctx^.sect, ctx^.file_offset_section_headers,
    ctx^.size_section_headers, read_proc_param);
end;

function LoadDLL_AllocateMemory(ctx: PLOAD_DLL_CONTEXT;
  flags: int): ELoadDLLResult; cdecl;
var
  rva_low, rva_high, i: DWORD;
  s: PIMAGE_SECTION_HEADER;
begin
  if (flags and ELoadDLLFlag_NoHeaders) <> 0 then
    rva_low := $FFFFFFFF
  else
    rva_low := 0;
  rva_high := 0;
  s := ctx^.sect;
  for i := 0 to ctx^.hdr.FileHeader.NumberOfSections - 1 do
  begin
    if (s^.Misc.VirtualSize = 0) then
    begin
      inc(s);
      Continue;
    end;
    if (s^.VirtualAddress < rva_low) then
      rva_low := s^.VirtualAddress;
    if ((s^.VirtualAddress + s^.Misc.VirtualSize) > rva_high) then
      rva_high := s^.VirtualAddress + s^.Misc.VirtualSize;
    inc(s);
  end;

  ctx^.image := VirtualAlloc
    (Pointer(ctx^.hdr.OptionalHeader.ImageBase + rva_low),
    rva_high - rva_low, MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
  ctx^.image_base := ctx^.hdr.OptionalHeader.ImageBase;

  if not Assigned(ctx^.image) then
  begin
    if (ctx^.hdr.FileHeader.Characteristics and IMAGE_FILE_RELOCS_STRIPPED)
      <> 0 then
    begin
      Result := ELoadDLLResult_RelocationError;
      Exit;
    end;
    ctx^.image := VirtualAlloc(nil, rva_high - rva_low,
      MEM_COMMIT or MEM_RESERVE, PAGE_EXECUTE_READWRITE);
    ctx^.image_base := DWORD_PTR(ctx^.image) - rva_low;
  end;

  if not Assigned(ctx^.image) then
    Result := ELoadDLLResult_MemoryAllocationError
  else
    Result := ELoadDLLResult_OK;
end;

function LoadDLL_LoadSections(ctx: PLOAD_DLL_CONTEXT;
  read_proc: LOAD_DLL_READPROC; read_proc_param: PVoid;
  flags: int): ELoadDLLResult; cdecl;
var
  section_size, i: DWORD;
  s: PIMAGE_SECTION_HEADER;
begin

  if (flags and ELoadDLLFlag_NoHeaders) = 0 then
  begin
    Result := m_read_proc(read_proc, Pointer(ctx^.image_base), 0,
      ctx^.file_offset_section_headers + ctx^.size_section_headers,
      read_proc_param);
    if Result <> ELoadDLLResult_OK then
      Exit;
  end;

  s := ctx^.sect;
  for i := 0 to ctx^.hdr.FileHeader.NumberOfSections - 1 do
  begin
    section_size := min(s^.Misc.VirtualSize, s^.SizeOfRawData);
    if (section_size <> 0) then
    begin
      Result := m_read_proc(read_proc,
        Pointer(s^.VirtualAddress + ctx^.image_base), s^.PointerToRawData,
        section_size, read_proc_param);
      if Result <> ELoadDLLResult_OK then
        Exit;
    end;
    inc(s);
  end;

  Result := ELoadDLLResult_OK;
end;

function LoadDLL_PerformRelocation(ctx: PLOAD_DLL_CONTEXT): ELoadDLLResult;
  cdecl;
var
  num_items, i, j: DWORD;
  diff: DWORD_PTR;
  pwrd: PDWORD_PTR;
  r, rt: PIMAGE_BASE_RELOCATION;
  r_end: PIMAGE_BASE_RELOCATION;
  reloc_item: PWORD;
begin

  if (ctx^.image_base = ctx^.hdr.OptionalHeader.ImageBase) then
  begin
    Result := ELoadDLLResult_OK;
    Exit;
  end;
  if (ctx^.hdr.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_BASERELOC]
      .VirtualAddress = 0) or (ctx^.hdr.OptionalHeader.DataDirectory
      [IMAGE_DIRECTORY_ENTRY_BASERELOC].size = 0) then
  begin
    Result := ELoadDLLResult_RelocationError;
    Exit;
  end;
  try
    diff := ctx^.image_base - ctx^.hdr.OptionalHeader.ImageBase;
    r := PIMAGE_BASE_RELOCATION
      (ctx^.image_base + ctx^.hdr.OptionalHeader.DataDirectory
        [IMAGE_DIRECTORY_ENTRY_BASERELOC].VirtualAddress);
    r_end := PIMAGE_BASE_RELOCATION
      (DWORD_PTR(r) + ctx^.hdr.OptionalHeader.DataDirectory
        [IMAGE_DIRECTORY_ENTRY_BASERELOC].size - SizeOf(IMAGE_BASE_RELOCATION)
      );
    while (DWORD(r) < DWORD(r_end)) do
    begin
      rt := r;
      inc(rt);
      reloc_item := PWORD(rt);
      num_items := (r^.SizeOfBlock - SizeOf(IMAGE_BASE_RELOCATION)) div SizeOf
        (WORD);

      for i := 0 to num_items - 1 do
      begin
        case (reloc_item^ shr 12) of
          IMAGE_REL_BASED_ABSOLUTE:
            ;
          IMAGE_REL_BASED_HIGHLOW:
            begin
              pwrd := PDWORD_PTR(ctx^.image_base + r^.VirtualAddress +
                  (reloc_item^ and $FFF));
              pwrd^ := pwrd^ + diff;
            end;
        else
          begin
            Result := ELoadDLLResult_BadRelocationTable;
            Exit;
          end;
        end;
        inc(reloc_item);
      end;
      r := PIMAGE_BASE_RELOCATION(DWORD_PTR(r) + r^.SizeOfBlock);
    end;
  except
    Result := ELoadDLLResult_BadRelocationTable;
    Exit;
  end;
  Result := ELoadDLLResult_OK;
end;

function LoadDLL_ResolveImports(ctx: PLOAD_DLL_CONTEXT): ELoadDLLResult; cdecl;
var
  import_desc: PIMAGE_IMPORT_DESCRIPTOR;
  hDLL: HMODULE;
  src_iat: PDWORD_PTR;
  dest_iat: PDWORD_PTR;
  new_module_array, tmpmod: PHMODULE;
begin
  if (ctx^.hdr.OptionalHeader.DataDirectory[IMAGE_DIRECTORY_ENTRY_IMPORT]
      .VirtualAddress = 0) or (ctx^.hdr.OptionalHeader.DataDirectory
      [IMAGE_DIRECTORY_ENTRY_IMPORT].size = 0) then
  begin
    Result := ELoadDLLResult_OK;
    Exit;
  end;
  import_desc := PIMAGE_IMPORT_DESCRIPTOR
    (ctx^.image_base + ctx^.hdr.OptionalHeader.DataDirectory
      [IMAGE_DIRECTORY_ENTRY_IMPORT].VirtualAddress);
  while (import_desc^.Name <> 0) do
  begin
    hDLL := LoadLibraryA(Pointer(ctx^.image_base + import_desc^.Name));
    if (hDLL = 0) then
    begin
      Result := ELoadDLLResult_ImportModuleError;
      Exit;
    end;
    if (ctx^.num_import_modules >= ctx^.import_modules_array_capacity) then
    begin
      if ctx^.import_modules_array_capacity <> 0 then
        ctx^.import_modules_array_capacity :=
          ctx^.import_modules_array_capacity * 2
      else
        ctx^.import_modules_array_capacity := 16;
      
      GetMem(new_module_array, SizeOf(HMODULE)
          * ctx^.import_modules_array_capacity);
      if not Assigned(new_module_array) then
      begin
        Result := ELoadDLLResult_MemoryAllocationError;
        Exit;
      end;
      if (ctx^.num_import_modules <> 0) then
        CopyMemory(new_module_array, ctx^.loaded_import_modules_array,
          SizeOf(HMODULE) * ctx^.num_import_modules);
      FreeMem(ctx^.loaded_import_modules_array);
      ctx^.loaded_import_modules_array := new_module_array;
    end;
    
    tmpmod := new_module_array;
    inc(tmpmod, ctx^.num_import_modules);
    tmpmod^ := hDLL;
    ctx^.num_import_modules := ctx^.num_import_modules + 1;

    dest_iat := PDWORD_PTR(ctx^.image_base + import_desc^.FirstThunk);
    src_iat := dest_iat;
    if (import_desc^.TimeDateStamp <> 0) then
    begin
      if (import_desc^.OriginalFirstThunk = 0) then
      begin
        Result := ELoadDLLResult_BoundImportDirectoriesNotSupported;
        Exit;
      end;
      src_iat := PDWORD_PTR(ctx^.image_base + import_desc^.OriginalFirstThunk);
    end;

    while (src_iat^ <> 0) do
    begin
      if (src_iat^ and IMAGE_ORDINAL_FLAG) <> 0 then
        dest_iat^ := DWORD_PTR(GetProcAddress(hDLL,
            PAnsiChar(Pointer(src_iat^ and $FFFF))))
      else
        dest_iat^ := DWORD_PTR(GetProcAddress(hDLL,
            PAnsiChar(Pointer(ctx^.image_base + src_iat^ + 2))));
      if (dest_iat^ = 0) then
      begin
        Result := ELoadDLLResult_ImportFunctionError;
        Exit;
      end;
      inc(src_iat);
      inc(dest_iat);
    end;

    inc(import_desc);
  end;
  Result := ELoadDLLResult_OK;
end;

function LoadDLL_SetSectionMemoryProtection(ctx: PLOAD_DLL_CONTEXT)
  : ELoadDLLResult; cdecl;
var
  s: PIMAGE_SECTION_HEADER;
  protection, i: DWORD;
begin
  s := ctx^.sect;
  for i := 0 to ctx^.hdr.FileHeader.NumberOfSections - 1 do
  begin
    if (s^.Characteristics and IMAGE_SCN_CNT_CODE) <> 0 then
      s^.Characteristics := s^.Characteristics or IMAGE_SCN_MEM_EXECUTE or
        IMAGE_SCN_MEM_READ;
    case (DWORD(s^.Characteristics) shr (32 - 3)) of
      1:
        protection := PAGE_EXECUTE;
      0, 2:
        protection := PAGE_READONLY;
      3:
        protection := PAGE_EXECUTE_READ;
      4, 6:
        protection := PAGE_READWRITE;
      
    else
      begin
        protection := PAGE_EXECUTE_READWRITE;
      end;
    end;

    if not VirtualProtect(Pointer(ctx^.image_base + s^.VirtualAddress),
      s^.Misc.VirtualSize, protection, @protection) then
    begin
      Result := ELoadDLLResult_ErrorSettingMemoryProtection;
      Exit;
    end;

    inc(s);
  end;
  Result := ELoadDLLResult_OK;
end;

function LoadDLL_CallDLLEntryPoint(ctx: PLOAD_DLL_CONTEXT;
  flags: int): ELoadDLLResult; cdecl;
begin
  if (flags and ELoadDLLFlag_NoEntryCall) <> 0 then
  begin
    Result := ELoadDLLResult_OK;
    Exit;
  end;
  if (ctx^.hdr.OptionalHeader.AddressOfEntryPoint) <> 0 then
  begin
    ctx^.dll_main := LPDLLMAIN
      (ctx^.hdr.OptionalHeader.AddressOfEntryPoint + ctx^.image_base);
    try
      
      if not(ctx^.dll_main(0, DLL_PROCESS_ATTACH, nil)) then
      begin
        Result := ELoadDLLResult_DllMainCallError;
        Exit;
      end;
    except
      Result := ELoadDLLResult_DllMainCallError;
      Exit;
    end;
  end;

  Result := ELoadDLLResult_OK;
end;

function LoadDll(read_proc: LOAD_DLL_READPROC; read_proc_param: PVoid;
  flags: int; info: PLOAD_DLL_INFO): ELoadDLLResult; cdecl;
var
  ctx: LOAD_DLL_CONTEXT;
  res: ELoadDLLResult;
  finished_successfully: BOOL;
  i: unsigned;
  tpM: PHMODULE;
begin
  finished_successfully := False;
  if not Assigned(read_proc) then
  begin
    Result := ELoadDLLResult_WrongFunctionParameters;
    Exit;
  end;
  ctx.sect := nil;
  ctx.loaded_import_modules_array := nil;
  ctx.import_modules_array_capacity := 0;
  ctx.num_import_modules := 0;
  ctx.dll_main := nil;

  try
    try
      Result := LoadDLL_LoadHeaders(@ctx, read_proc, read_proc_param);
      if Result <> ELoadDLLResult_OK then
        Exit;
      Result := LoadDLL_AllocateMemory(@ctx, flags);
      if Result <> ELoadDLLResult_OK then
        Exit;
      try
        Result := LoadDLL_LoadSections(@ctx, read_proc, read_proc_param, flags);
        if Result <> ELoadDLLResult_OK then
          Exit;
        Result := LoadDLL_PerformRelocation(@ctx);
        if Result <> ELoadDLLResult_OK then
          Exit;
        Result := LoadDLL_ResolveImports(@ctx);
        if Result <> ELoadDLLResult_OK then
          Exit;
        Result := LoadDLL_SetSectionMemoryProtection(@ctx);
        if Result <> ELoadDLLResult_OK then
          Exit;
        Result := LoadDLL_CallDLLEntryPoint(@ctx, flags);
        if Result <> ELoadDLLResult_OK then
          Exit;
        if Assigned(info) then
        begin
          try
            info^.size := SizeOf(info^);
            info^.flags := flags;
            info^.image_base := ctx.image_base;
            info^.mem_block := ctx.image;
            info^.dll_main := ctx.dll_main;
            info^.export_dir_rva := ctx.hdr.OptionalHeader.DataDirectory
              [IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress;
            info^.loaded_import_modules_array :=
              ctx.loaded_import_modules_array;
            info^.num_import_modules := ctx.num_import_modules;
          except
            Result := ELoadDLLResult_WrongFunctionParameters;
            Exit;
          end;
        end;
        finished_successfully := True;
        Result := ELoadDLLResult_OK;
        Exit;
      finally
        if not finished_successfully then
          VirtualFree(ctx.image, 0, MEM_RELEASE);
        if ((not finished_successfully) or (not Assigned(info))) then
        begin
          if Assigned(ctx.loaded_import_modules_array) then
          begin
            for i := 0 to ctx.num_import_modules - 1 do
            begin
              
              tpM := ctx.loaded_import_modules_array;
              inc(tpM, i);
              FreeLibrary(tpM^);
            end;
            Dispose(ctx.loaded_import_modules_array);
          end;
        end;
      end;
    finally
      if Assigned(ctx.sect) then
        Dispose(ctx.sect);
    end;
  except
    Result := ELoadDLLResult_UnknownError;
  end;

end;

function LoadDLLFromMemory(const dll_data: PVoid; dll_size: size_t; flags: int;
  info: PLOAD_DLL_INFO): ELoadDLLResult; cdecl;
var
  ldfms: LOAD_DLL_FROM_MEMORY_STRUCT;
begin
  ldfms.dll_data := dll_data;
  ldfms.dll_size := dll_size;
  Result := LoadDll(LOAD_DLL_READPROC(@LoadDLLFromMemoryCallback), @ldfms,
    flags, info);
end;

function UnloadDLL(info: PLOAD_DLL_INFO): BOOL;
var
  i: unsigned;
  pm: PHMODULE;
begin
  Result := False;
  try
    if (not Assigned(info)) or (info^.size <> SizeOf(info^)) or
      (info^.image_base = 0) or (not Assigned(info^.mem_block)) then
      Exit;
    if Assigned(info^.loaded_import_modules_array) then
    begin
      for i := 0 to info^.num_import_modules - 1 do
      begin
        pm := info^.loaded_import_modules_array;
        inc(pm, i);
        FreeLibrary(pm^);
      end;
      Dispose(info^.loaded_import_modules_array);
    end;
    if ((info^.flags and ELoadDLLFlag_NoEntryCall) = 0) and
      (Assigned(info^.dll_main)) then
      try
        
        Result := info^.dll_main(0, DLL_PROCESS_DETACH, nil);
      except
        Result := False;
      end;
    VirtualFree(info^.mem_block, 0, MEM_RELEASE);
  except
    Result := False;
  end;
end;

function MyGetProcAddress_ExportDir(export_dir_rva: DWORD;
  image_base: DWORD_PTR; const func_name: PByte): FARPROC; cdecl;
var
  exp: PIMAGE_EXPORT_DIRECTORY;
  ord: DWORD_PTR;
  i: DWORD;
  pd: PDWORD;
  pw: PWORD;
  Ordinals: ^PWORD;
begin
  Result := nil;
  if (export_dir_rva = 0) then
    Exit;
  exp := PIMAGE_EXPORT_DIRECTORY(image_base + export_dir_rva);
  ord := DWORD_PTR(func_name);
  try
    if (ord < $10000) then
    begin
      
      if ord < exp^.Base then
        Exit;
      ord := ord - exp^.Base
    end
    else
    begin
      
      for i := 0 to exp^.NumberOfNames - 1 do
      begin
        pd := PDWORD(DWORD_PTR(exp^.AddressOfNames) + image_base);
        inc(pd, i);
        if lstrcmpA(PAnsiChar(DWORD(pd^) + image_base), PAnsiChar(func_name))
          = 0 then
        begin
          pw := PWORD(DWORD(exp^.AddressOfNameOrdinals) + image_base);
          inc(pw, i);
          ord := pw^;
          Break;
        end;
      end;
    end;
    if (ord >= exp^.NumberOfFunctions) then
      Exit;

    pd := PDWORD(DWORD(exp^.AddressOfFunctions) + image_base);
    inc(pd, ord);
    Result := FARPROC(pd^ + image_base);
  except
  end;
end;

function myGetProcAddress_LoadDLLInfo(info: PLOAD_DLL_INFO;
  const func_name: PByte): FARPROC; cdecl;
begin
  Result := MyGetProcAddress_ExportDir(info^.export_dir_rva, info^.image_base,
    func_name);
end;

function MyGetProcAddress(module: HMODULE; const func_name: PByte): FARPROC;
var
  hdr: PIMAGE_NT_HEADERS;
begin
  Result := nil;
  try
    if PIMAGE_DOS_HEADER(module)^.e_magic <> IMAGE_DOS_SIGNATURE then
      Exit;
    hdr := PIMAGE_NT_HEADERS(DWORD_PTR(module) + PIMAGE_DOS_HEADER(module)
        ^._lfanew);
    if (hdr^.Signature <> IMAGE_NT_SIGNATURE) or
      (hdr^.OptionalHeader.Magic <> IMAGE_NT_OPTIONAL_HDR_MAGIC) then
      Exit;
    Result := MyGetProcAddress_ExportDir(hdr^.OptionalHeader.DataDirectory
        [IMAGE_DIRECTORY_ENTRY_EXPORT].VirtualAddress, DWORD_PTR(module),
      func_name);
  except
  end;
end;

function LoadModuleFromMemory(const dll_data: Pointer;
  dll_size: size_t): MODULE_HANDLE;
var
  p: PLOAD_DLL_INFO;
  res: DWORD;
begin
  New(p);
  res := LoadDLLFromMemory(dll_data, dll_size, 0, p);
  if (res <> ELoadDLLResult_OK) then
  begin
    Dispose(p);
    Result := nil;
  end
  else
    Result := p;
end;

function GetModuleFunction(handle: MODULE_HANDLE;
  const func_name: PAnsiChar): Pointer; overload;
begin
  Result := myGetProcAddress_LoadDLLInfo(handle, PByte(func_name));
end;

function GetModuleFunction(handle: MODULE_HANDLE;
  const func_name: string): Pointer; overload;
begin
  Result := myGetProcAddress_LoadDLLInfo(handle, PByte(AnsiString(func_name)));
end;

function UnloadModule(handle: MODULE_HANDLE): Boolean;
begin
  if Assigned(handle) then
  begin
    Result := UnloadDLL(handle);
    Dispose(handle);
  end
  else
    Result := False;
end;

end.
 