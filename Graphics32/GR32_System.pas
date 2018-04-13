unit GR32_System;

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

type
  TPerfTimer = class
  private
{$IFDEF UNIX}
  {$IFDEF FPC}
    FStart: Int64;
  {$ENDIF}
{$ENDIF}
{$IFDEF Windows}
    FFrequency, FPerformanceCountStart, FPerformanceCountStop: Int64;
{$ENDIF}
  public
    procedure Start;
    function ReadNanoseconds: string;
    function ReadMilliseconds: string;
    function ReadSeconds: String;
    function ReadValue: Int64;
  end;

function GetTickCount: Cardinal;

function GetProcessorCount: Cardinal;

type
  {$IFNDEF PUREPASCAL}
  
  TCPUInstructionSet = (ciMMX, ciEMMX, ciSSE, ciSSE2, ci3DNow, ci3DNowExt);
  {$ELSE}
  TCPUInstructionSet = (ciDummy);
  {$DEFINE NO_REQUIREMENTS}
  {$ENDIF}

  PCPUFeatures = ^TCPUFeatures;
  TCPUFeatures = set of TCPUInstructionSet;

function HasInstructionSet(const InstructionSet: TCPUInstructionSet): Boolean;
function CPUFeatures: TCPUFeatures;

var
  GlobalPerfTimer: TPerfTimer;

implementation

uses
   Classes, TypInfo;

var
  CPUFeaturesInitialized : Boolean = False;
  CPUFeaturesData: TCPUFeatures;

{$IFDEF UNIX}
{$IFDEF FPC}
function GetTickCount: Cardinal;
var
  t : timeval;
begin
  fpgettimeofday(@t,nil);
   
  Result := (Int64(t.tv_sec) * 1000000) + t.tv_usec;
end;

function TPerfTimer.ReadNanoseconds: string;
var
  t : timeval;
begin
  fpgettimeofday(@t,nil);
   
  Result := IntToStr( ( (Int64(t.tv_sec) * 1000000) + t.tv_usec ) div 1000 );
end;

function TPerfTimer.ReadMilliseconds: string;
var
  t : timeval;
begin
  fpgettimeofday(@t,nil);
   
  Result := IntToStr( ( (Int64(t.tv_sec) * 1000000) + t.tv_usec ) * 1000 );
end;

function TPerfTimer.ReadSeconds: string;
var
  t : timeval;
begin
  fpgettimeofday(@t,nil);
   
  Result := IntToStr( ( (Int64(t.tv_sec) * 1000000) + t.tv_usec ) );
end;

function TPerfTimer.ReadValue: Int64;
var t : timeval;
begin
  fpgettimeofday(@t,nil);
   
  Result := (Int64(t.tv_sec) * 1000000) + t.tv_usec;
  Result := Result div 1000;
end;

procedure TPerfTimer.Start;
var
  t : timeval;
begin
  fpgettimeofday(@t,nil);
   
  FStart := (Int64(t.tv_sec) * 1000000) + t.tv_usec;
end;
{$ENDIF}
{$ENDIF}

{$IFDEF Windows}
function GetTickCount: Cardinal;
begin
  Result := Windows.GetTickCount;
end;

function TPerfTimer.ReadNanoseconds: string;
begin
  QueryPerformanceCounter(FPerformanceCountStop);
  QueryPerformanceFrequency(FFrequency);
  Assert(FFrequency > 0);

  Result := IntToStr(Round(1000000 * (FPerformanceCountStop - FPerformanceCountStart) / FFrequency));
end;

function TPerfTimer.ReadMilliseconds: string;
begin
  QueryPerformanceCounter(FPerformanceCountStop);
  QueryPerformanceFrequency(FFrequency);
  Assert(FFrequency > 0);

  Result := FloatToStrF(1000 * (FPerformanceCountStop - FPerformanceCountStart) / FFrequency, ffFixed, 15, 3);
end;

function TPerfTimer.ReadSeconds: String;
begin
  QueryPerformanceCounter(FPerformanceCountStop);
  QueryPerformanceFrequency(FFrequency);
  Result := FloatToStrF((FPerformanceCountStop - FPerformanceCountStart) / FFrequency, ffFixed, 15, 3);
end;

function TPerfTimer.ReadValue: Int64;
begin
  QueryPerformanceCounter(FPerformanceCountStop);
  QueryPerformanceFrequency(FFrequency);
  Assert(FFrequency > 0);

  Result := Round(1000000 * (FPerformanceCountStop - FPerformanceCountStart) / FFrequency);
end;

procedure TPerfTimer.Start;
begin
  QueryPerformanceCounter(FPerformanceCountStart);
end;
{$ENDIF}

{$IFDEF UNIX}
{$IFDEF FPC}
function GetProcessorCount: Cardinal;
begin
  Result := 1;
end;
{$ENDIF}
{$ENDIF}
{$IFDEF Windows}
function GetProcessorCount: Cardinal;
var
  lpSysInfo: TSystemInfo;
begin
  GetSystemInfo(lpSysInfo);
  Result := lpSysInfo.dwNumberOfProcessors;
end;
{$ENDIF}

{$IFNDEF PUREPASCAL}
const
  CPUISChecks: Array[TCPUInstructionSet] of Cardinal =
    ($800000,  $400000, $2000000, $4000000, $80000000, $40000000);

function CPUID_Available: Boolean;
asm
{$IFDEF TARGET_x64}
        MOV       EDX,False
        PUSHFQ
        POP       RAX
        MOV       ECX,EAX
        XOR       EAX,$00200000
        PUSH      RAX
        POPFQ
        PUSHFQ
        POP       RAX
        XOR       ECX,EAX
        JZ        @1
        MOV       EDX,True
@1:     PUSH      RAX
        POPFQ
        MOV       EAX,EDX
{$ELSE}
        MOV       EDX,False
        PUSHFD
        POP       EAX
        MOV       ECX,EAX
        XOR       EAX,$00200000
        PUSH      EAX
        POPFD
        PUSHFD
        POP       EAX
        XOR       ECX,EAX
        JZ        @1
        MOV       EDX,True
@1:     PUSH      EAX
        POPFD
        MOV       EAX,EDX
{$ENDIF}
end;

function CPU_Signature: Integer;
asm
{$IFDEF TARGET_x64}
        PUSH      RBX
        MOV       EAX,1
        CPUID
        POP       RBX
{$ELSE}
        PUSH      EBX
        MOV       EAX,1
        {$IFDEF FPC}
        CPUID
        {$ELSE}
        DW        $A20F   
        {$ENDIF}
        POP       EBX
{$ENDIF}
end;

function CPU_Features: Integer;
asm
{$IFDEF TARGET_x64}
        PUSH      RBX
        MOV       EAX,1
        CPUID
        POP       RBX
        MOV       EAX,EDX
{$ELSE}
        PUSH      EBX
        MOV       EAX,1
        {$IFDEF FPC}
        CPUID
        {$ELSE}
        DW        $A20F   
        {$ENDIF}
        POP       EBX
        MOV       EAX,EDX
{$ENDIF}
end;

function CPU_ExtensionsAvailable: Boolean;
asm
{$IFDEF TARGET_x64}
        PUSH      RBX
        MOV       @Result, True
        MOV       EAX, $80000000
        CPUID
        CMP       EAX, $80000000
        JBE       @NOEXTENSION
        JMP       @EXIT
        @NOEXTENSION:
        MOV       @Result, False
        @EXIT:
        POP       RBX
{$ELSE}
        PUSH      EBX
        MOV       @Result, True
        MOV       EAX, $80000000
        {$IFDEF FPC}
        CPUID
        {$ELSE}
        DW        $A20F   
        {$ENDIF}
        CMP       EAX, $80000000
        JBE       @NOEXTENSION
        JMP       @EXIT
      @NOEXTENSION:
        MOV       @Result, False
      @EXIT:
        POP       EBX
{$ENDIF}
end;

function CPU_ExtFeatures: Integer;
asm
{$IFDEF TARGET_x64}
        PUSH      RBX
        MOV       EAX, $80000001
        CPUID
        POP       RBX
        MOV       EAX,EDX
{$ELSE}
        PUSH      EBX
        MOV       EAX, $80000001
        {$IFDEF FPC}
        CPUID
        {$ELSE}
        DW        $A20F   
        {$ENDIF}
        POP       EBX
        MOV       EAX,EDX
{$ENDIF}
end;

function HasInstructionSet(const InstructionSet: TCPUInstructionSet): Boolean;

begin
  Result := False;
  if not CPUID_Available then Exit;                   
  if CPU_Signature shr 8 and $0F < 5 then Exit;       

  case InstructionSet of
    ci3DNow, ci3DNowExt:
      {$IFNDEF FPC}
      if not CPU_ExtensionsAvailable or (CPU_ExtFeatures and CPUISChecks[InstructionSet] = 0) then
      {$ENDIF}
        Exit;
    ciEMMX:
      begin
        
        if (CPU_Features and CPUISChecks[ciSSE] = 0) and
          (not CPU_ExtensionsAvailable or (CPU_ExtFeatures and CPUISChecks[ciEMMX] = 0)) then
          Exit;
      end;
  else
    if CPU_Features and CPUISChecks[InstructionSet] = 0 then
      Exit; 
    end;

  Result := True;
end;

{$ELSE}

function HasInstructionSet(const InstructionSet: TCPUInstructionSet): Boolean;
begin
  Result := False;
end;
{$ENDIF}

procedure InitCPUFeaturesData;
var
  I: TCPUInstructionSet;
begin
  if CPUFeaturesInitialized then Exit;

  CPUFeaturesData := [];
  for I := Low(TCPUInstructionSet) to High(TCPUInstructionSet) do
    if HasInstructionSet(I) then CPUFeaturesData := CPUFeaturesData + [I];

  CPUFeaturesInitialized := True;
end;

function CPUFeatures: TCPUFeatures;
begin
  if not CPUFeaturesInitialized then
    InitCPUFeaturesData;
  Result := CPUFeaturesData;
end;

initialization
  InitCPUFeaturesData;
  GlobalPerfTimer := TPerfTimer.Create;

finalization
  GlobalPerfTimer.Free;

end.
 