unit GR32_LowLevel;

interface

{$I GR32.inc}

{$IFDEF PUREPASCAL}
  {$DEFINE USENATIVECODE}
  {$DEFINE USEMOVE}
{$ENDIF}
{$IFDEF USEINLINING}
  {$DEFINE USENATIVECODE}
{$ENDIF}

uses
  Graphics, GR32, GR32_Math, GR32_System, GR32_Bindings;

function Clamp(const Value: Integer): Integer; overload; {$IFDEF USEINLINING} inline; {$ENDIF}

var
  FillLongword: procedure(var X; Count: Cardinal; Value: Longword);

procedure FillWord(var X; Count: Cardinal; Value: Longword);

{$IFDEF USEMOVE}
procedure MoveLongword(const Source; var Dest; Count: Integer); {$IFDEF USEINLINING} inline; {$ENDIF}
{$ELSE}
procedure MoveLongword(const Source; var Dest; Count: Integer);
{$ENDIF}
procedure MoveWord(const Source; var Dest; Count: Integer);

function StackAlloc(Size: Integer): Pointer; register;

procedure StackFree(P: Pointer); register;

procedure Swap(var A, B: Pointer); overload;{$IFDEF USEINLINING} inline; {$ENDIF}
procedure Swap(var A, B: Integer); overload;{$IFDEF USEINLINING} inline; {$ENDIF}
procedure Swap(var A, B: TFixed); overload;{$IFDEF USEINLINING} inline; {$ENDIF}
procedure Swap(var A, B: TColor32); overload;{$IFDEF USEINLINING} inline; {$ENDIF}

procedure TestSwap(var A, B: Integer); overload;{$IFDEF USEINLINING} inline; {$ENDIF}
procedure TestSwap(var A, B: TFixed); overload;{$IFDEF USEINLINING} inline; {$ENDIF}

function TestClip(var A, B: Integer; const Size: Integer): Boolean; overload;
function TestClip(var A, B: Integer; const Start, Stop: Integer): Boolean; overload;

function Constrain(const Value, Lo, Hi: Integer): Integer; {$IFDEF USEINLINING} inline; {$ENDIF} overload;
function Constrain(const Value, Lo, Hi: Single): Single; {$IFDEF USEINLINING} inline; {$ENDIF} overload;

function SwapConstrain(const Value: Integer; Constrain1, Constrain2: Integer): Integer;

function Min(const A, B, C: Integer): Integer; overload; {$IFDEF USEINLINING} inline; {$ENDIF}
function Max(const A, B, C: Integer): Integer; overload; {$IFDEF USEINLINING} inline; {$ENDIF}

function Clamp(Value, Max: Integer): Integer; overload; {$IFDEF USEINLINING} inline; {$ENDIF}

function Clamp(Value, Min, Max: Integer): Integer; overload; {$IFDEF USEINLINING} inline; {$ENDIF}

function Wrap(Value, Max: Integer): Integer; overload;

function Wrap(Value, Min, Max: Integer): Integer; overload;

function Wrap(Value, Max: Single): Single; overload; {$IFDEF USEINLINING} inline; {$ENDIF} overload;

function WrapPow2(Value, Max: Integer): Integer; {$IFDEF USEINLINING} inline; {$ENDIF} overload;
function WrapPow2(Value, Min, Max: Integer): Integer; {$IFDEF USEINLINING} inline; {$ENDIF} overload;

function Mirror(Value, Max: Integer): Integer; overload;

function Mirror(Value, Min, Max: Integer): Integer; overload;

function MirrorPow2(Value, Max: Integer): Integer; {$IFDEF USEINLINING} inline; {$ENDIF} overload;
function MirrorPow2(Value, Min, Max: Integer): Integer; {$IFDEF USEINLINING} inline; {$ENDIF} overload;

function GetOptimalWrap(Max: Integer): TWrapProc; {$IFDEF USEINLINING} inline; {$ENDIF} overload;
function GetOptimalWrap(Min, Max: Integer): TWrapProcEx; {$IFDEF USEINLINING} inline; {$ENDIF} overload;
function GetOptimalMirror(Max: Integer): TWrapProc; {$IFDEF USEINLINING} inline; {$ENDIF} overload;
function GetOptimalMirror(Min, Max: Integer): TWrapProcEx; {$IFDEF USEINLINING} inline; {$ENDIF} overload;

function GetWrapProc(WrapMode: TWrapMode): TWrapProc; overload;
function GetWrapProc(WrapMode: TWrapMode; Max: Integer): TWrapProc; overload;
function GetWrapProcEx(WrapMode: TWrapMode): TWrapProcEx; overload;
function GetWrapProcEx(WrapMode: TWrapMode; Min, Max: Integer): TWrapProcEx; overload;

const
  WRAP_PROCS: array[TWrapMode] of TWrapProc = (Clamp, Wrap, Mirror);
  WRAP_PROCS_EX: array[TWrapMode] of TWrapProcEx = (Clamp, Wrap, Mirror);

function Div255(Value: Cardinal): Cardinal; {$IFDEF USEINLINING} inline; {$ENDIF}

function SAR_4(Value: Integer): Integer;
function SAR_8(Value: Integer): Integer;
function SAR_9(Value: Integer): Integer;
function SAR_11(Value: Integer): Integer;
function SAR_12(Value: Integer): Integer;
function SAR_13(Value: Integer): Integer;
function SAR_14(Value: Integer): Integer;
function SAR_15(Value: Integer): Integer;
function SAR_16(Value: Integer): Integer;

function ColorSwap(WinColor: TColor): TColor32;

implementation

{$IFDEF FPC}
uses
  SysUtils;
{$ENDIF}

{$R-}{$Q-}  

function Clamp(const Value: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
 if Value > 255 then Result := 255
  else if Value < 0 then Result := 0
  else Result := Value;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        
        MOV     EAX,ECX
{$ENDIF}
        TEST    EAX,$FFFFFF00
        JNZ     @1
        RET
@1:     JS      @2
        MOV     EAX,$FF
        RET
@2:     XOR     EAX,EAX
{$ENDIF}
end;

procedure FillLongword_Pas(var X; Count: Cardinal; Value: Longword);
var
  I: Integer;
  P: PIntegerArray;
begin
  P := PIntegerArray(@X);
  for I := Count - 1 downto 0 do
    P[I] := Integer(Value);
end;

{$IFNDEF PUREPASCAL}
procedure FillLongword_ASM(var X; Count: Cardinal; Value: Longword);
asm
{$IFDEF TARGET_x86}
        
        PUSH    EDI

        MOV     EDI,EAX  
        MOV     EAX,ECX
        MOV     ECX,EDX

        REP     STOSD    
@Exit:
        POP     EDI
{$ENDIF}
{$IFDEF TARGET_x64}
        
        PUSH    RDI

        MOV     RDI,RCX  
        MOV     RAX,R8   
        MOV     ECX,EDX  
        TEST    ECX,ECX
        JS      @Exit

        REP     STOSD    
@Exit:
        POP     RDI
{$ENDIF}
end;

procedure FillLongword_MMX(var X; Count: Cardinal; Value: Longword);
asm
{$IFDEF TARGET_x86}
        
        TEST       EDX, EDX   
        JZ         @Exit      

        PUSH       EDI
        MOV        EDI, EAX
        MOV        EAX, EDX

        SHR        EAX, 1
        SHL        EAX, 1
        SUB        EAX, EDX
        JE         @QLoopIni

        MOV        [EDI], ECX
        ADD        EDI, 4
        DEC        EDX
        JZ         @ExitPOP
    @QLoopIni:
        MOVD       MM1, ECX
        PUNPCKLDQ  MM1, MM1
        SHR        EDX, 1
    @QLoop:
        MOVQ       [EDI], MM1
        ADD        EDI, 8
        DEC        EDX
        JNZ        @QLoop
        EMMS
    @ExitPOP:
        POP        EDI
    @Exit:
{$ENDIF}
{$IFDEF TARGET_x64}
        
        TEST       RDX, RDX   
        JZ         @Exit      
        MOV        RAX, RCX   

        PUSH       RDI        
        MOV        R9, RDX    
        MOV        RDI, RDX   

        SHR        RDI, 1     
        SHL        RDI, 1     
        SUB        R9, RDI    
        JE         @QLoopIni

        MOV        [RAX], R8D 
        ADD        RAX, 4     
        DEC        RDX        
        JZ         @ExitPOP   
@QLoopIni:
        MOVD       MM0, R8D   
        PUNPCKLDQ  MM0, MM0   
        SHR        RDX, 1     
@QLoop:
        MOVQ       QWORD PTR [RAX], MM0 
        ADD        RAX, 8     
        DEC        RDX        
        JNZ        @QLoop
        EMMS
@ExitPOP:
        POP        RDI
@Exit:
{$ENDIF}
end;

procedure FillLongword_SSE2(var X; Count: Integer; Value: Longword);
asm
{$IFDEF TARGET_x86}

        TEST       EDX, EDX        
        JZ         @Exit           

        PUSH       EDI             
        MOV        EDI, EAX        

        CMP        EDX, 32
        JL         @SmallLoop

        AND        EAX, 3          
        TEST       EAX, EAX        
        JNZ        @SmallLoop      

        MOV        EAX, EDI
        SHR        EAX, 2          
        AND        EAX, 3          
        ADD        EAX,-4
        NEG        EAX             
        JZ         @SetupMain
        SUB        EDX, EAX        

@AligningLoop:
        MOV        [EDI], ECX
        ADD        EDI, 4
        DEC        EAX
        JNZ        @AligningLoop

@SetupMain:
        MOV        EAX, EDX        
        SHR        EAX, 2
        SHL        EAX, 2
        SUB        EDX, EAX        
        SHR        EAX, 2

        MOVD       XMM0, ECX
        PUNPCKLDQ  XMM0, XMM0
        PUNPCKLDQ  XMM0, XMM0
@SSE2Loop:
        MOVDQA     [EDI], XMM0
        ADD        EDI, 16
        DEC        EAX
        JNZ        @SSE2Loop

@SmallLoop:
        MOV        EAX,ECX
        MOV        ECX,EDX

        REP        STOSD           

@ExitPOP:
        POP        EDI

@Exit:
{$ENDIF}

{$IFDEF TARGET_x64}
        
        TEST       EDX,EDX    
        JZ         @Exit      
        MOV        RAX, RCX   

        PUSH       RDI        
        MOV        R9, RDX    
        MOV        RDI, RDX   

        SHR        RDI, 1     
        SHL        RDI, 1     
        SUB        R9, RDI    
        JE         @QLoopIni

        MOV        [RAX], R8D 
        ADD        RAX, 4     
        DEC        RDX        
        JZ         @ExitPOP   
@QLoopIni:
        MOVD       XMM0, R8D  
        PUNPCKLDQ  XMM0, XMM0 
        SHR        RDX, 1     
@QLoop:
        MOVQ       QWORD PTR [RAX], XMM0 
        ADD        RAX, 8     
        DEC        RDX        
        JNZ        @QLoop
        EMMS
@ExitPOP:
        POP        RDI
@Exit:
{$ENDIF}
end;
{$ENDIF}

procedure FillWord(var X; Count: Cardinal; Value: LongWord);
{$IFDEF USENATIVECODE}
var
  I: Integer;
  P: PWordArray;
begin
  P := PWordArray(@X);
  for I := Count - 1 downto 0 do
    P[I] := Value;
{$ELSE}
asm
{$IFDEF TARGET_x86}
        
        PUSH    EDI

        MOV     EDI,EAX  
        MOV     EAX,ECX
        MOV     ECX,EDX
        TEST    ECX,ECX
        JZ      @exit

        REP     STOSW    
@exit:
        POP     EDI
{$ENDIF}

{$IFDEF TARGET_x64}
        
        PUSH    RDI

        MOV     RDI,RCX  
        MOV     EAX,R8D
        MOV     ECX,EDX
        TEST    ECX,ECX
        JZ      @exit

        REP     STOSW    
@exit:
        POP     RDI
{$ENDIF}
{$ENDIF}
end;

procedure MoveLongword(const Source; var Dest; Count: Integer);
{$IFDEF USEMOVE}
begin
  Move(Source, Dest, Count shl 2);
{$ELSE}
asm
{$IFDEF TARGET_x86}
        
        PUSH    ESI
        PUSH    EDI

        MOV     ESI,EAX
        MOV     EDI,EDX
        CMP     EDI,ESI
        JE      @exit

        REP     MOVSD
@exit:
        POP     EDI
        POP     ESI
{$ENDIF}

{$IFDEF TARGET_x64}
        
        PUSH    RSI
        PUSH    RDI

        MOV     RSI,RCX
        MOV     RDI,RDX
        MOV     RCX,R8
        CMP     RDI,RSI
        JE      @exit

        REP     MOVSD
@exit:
        POP     RDI
        POP     RSI
{$ENDIF}
{$ENDIF}
end;

procedure MoveWord(const Source; var Dest; Count: Integer);
{$IFDEF USEMOVE}
begin
  Move(Source, Dest, Count shl 1);
{$ELSE}
asm
{$IFDEF TARGET_x86}
        
        PUSH    ESI
        PUSH    EDI

        MOV     ESI,EAX
        MOV     EDI,EDX
        MOV     EAX,ECX
        CMP     EDI,ESI
        JE      @exit

        REP     MOVSW
@exit:
        POP     EDI
        POP     ESI
{$ENDIF}

{$IFDEF TARGET_x64}
        
        PUSH    RSI
        PUSH    RDI

        MOV     RSI,RCX
        MOV     RDI,RDX
        MOV     RAX,R8
        CMP     RDI,RSI
        JE      @exit

        REP     MOVSW
@exit:
        POP     RDI
        POP     RSI
{$ENDIF}
{$ENDIF}
end;

procedure Swap(var A, B: Pointer);
var
  T: Pointer;
begin
  T := A;
  A := B;
  B := T;
end;

procedure Swap(var A, B: Integer);
var
  T: Integer;
begin
  T := A;
  A := B;
  B := T;
end;

procedure Swap(var A, B: TFixed);
var
  T: TFixed;
begin
  T := A;
  A := B;
  B := T;
end;

procedure Swap(var A, B: TColor32);
var
  T: TColor32;
begin
  T := A;
  A := B;
  B := T;
end;

procedure TestSwap(var A, B: Integer);
var
  T: Integer;
begin
  if B < A then
  begin
    T := A;
    A := B;
    B := T;
  end;
end;

procedure TestSwap(var A, B: TFixed);
var
  T: TFixed;
begin
  if B < A then
  begin
    T := A;
    A := B;
    B := T;
  end;
end;

function TestClip(var A, B: Integer; const Size: Integer): Boolean;
begin
  TestSwap(A, B); 
  if A < 0 then
    A := 0;
  if B >= Size then 
    B := Size - 1;
  Result := B >= A;
end;

function TestClip(var A, B: Integer; const Start, Stop: Integer): Boolean;
begin
  TestSwap(A, B); 
  if A < Start then 
    A := Start;
  if B >= Stop then 
    B := Stop - 1;
  Result := B >= A;
end;

function Constrain(const Value, Lo, Hi: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  if Value < Lo then
    Result := Lo
  else if Value > Hi then
    Result := Hi
  else
    Result := Value;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV       EAX,ECX
        MOV       ECX,R8D
{$ENDIF}
        CMP       EDX,EAX
        CMOVG     EAX,EDX
        CMP       ECX,EAX
        CMOVL     EAX,ECX
{$ENDIF}
end;

function Constrain(const Value, Lo, Hi: Single): Single; overload;
begin
  if Value < Lo then Result := Lo
  else if Value > Hi then Result := Hi
  else Result := Value;
end;

function SwapConstrain(const Value: Integer; Constrain1, Constrain2: Integer): Integer;
begin
  TestSwap(Constrain1, Constrain2);
  if Value < Constrain1 then Result := Constrain1
  else if Value > Constrain2 then Result := Constrain2
  else Result := Value;
end;

function Max(const A, B, C: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  if A > B then
    Result := A
  else
    Result := B;

  if C > Result then
    Result := C;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV       RAX,RCX
        MOV       RCX,R8
{$ENDIF}
        CMP       EDX,EAX
        CMOVG     EAX,EDX
        CMP       ECX,EAX
        CMOVG     EAX,ECX
{$ENDIF}
end;

function Min(const A, B, C: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  if A < B then
    Result := A
  else
    Result := B;

  if C < Result then
    Result := C;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV       RAX,RCX
        MOV       RCX,R8
{$ENDIF}
        CMP       EDX,EAX
        CMOVL     EAX,EDX
        CMP       ECX,EAX
        CMOVL     EAX,ECX
{$ENDIF}
end;

function Clamp(Value, Max: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  if Value > Max then 
    Result := Max
  else if Value < 0 then 
    Result := 0
  else
    Result := Value;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV     EAX,ECX
        MOV     ECX,R8D
{$ENDIF}
        CMP     EAX,EDX
        JG      @Above
        TEST    EAX,EAX
        JL      @Below
        RET
@Above:
        MOV     EAX,EDX
        RET
@Below:
        MOV     EAX,0
        RET
{$ENDIF}
end;

function Clamp(Value, Min, Max: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  if Value > Max then 
    Result := Max
  else if Value < Min then
    Result := Min
  else 
    Result := Value;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV     EAX,ECX
        MOV     ECX,R8D
{$ENDIF}
        CMP     EDX,EAX
        CMOVG   EAX,EDX
        CMP     ECX,EAX
        CMOVL   EAX,ECX
{$ENDIF}
end;

function Wrap(Value, Max: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  if Value < 0 then
    Result := Max + (Value - Max) mod (Max + 1)
  else
    Result := (Value) mod (Max + 1);
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV     EAX,ECX
        MOV     ECX,R8D
        LEA     ECX,[RDX+1]
{$ELSE}
        LEA     ECX,[EDX+1]
{$ENDIF}
        CDQ
        IDIV    ECX
        MOV     EAX,EDX
        TEST    EAX,EAX
        JNL     @Exit
        ADD     EAX,ECX
@Exit:
{$ENDIF}
end;

function Wrap(Value, Min, Max: Integer): Integer;
begin
  if Value < Min then
    Result := Max + (Value - Max) mod (Max - Min + 1)
  else
    Result := Min + (Value - Min) mod (Max - Min + 1);
end;

function Wrap(Value, Max: Single): Single;
begin
{$IFDEF USEFLOATMOD}
  Result := FloatMod(Value, Max);
{$ELSE}
  Result := Value;
  while Result >= Max do Result := Result - Max;
  while Result < 0 do Result := Result + Max;
{$ENDIF}
end;

function DivMod(Dividend, Divisor: Integer; out Remainder: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  Remainder := Dividend mod Divisor;
  Result := Dividend div Divisor;
{$ELSE}
asm
{$IFDEF TARGET_x86}
        PUSH      EBX
        MOV       EBX,EDX
        CDQ
        IDIV      EBX
        MOV       [ECX],EDX
        POP       EBX
{$ENDIF}
{$IFDEF TARGET_x64}
        PUSH      RBX
        MOV       EAX,ECX
        MOV       ECX,R8D
        MOV       EBX,EDX
        CDQ
        IDIV      EBX
        MOV       [RCX],EDX
        POP       RBX
{$ENDIF}
{$ENDIF}
end;

function Mirror(Value, Max: Integer): Integer;
{$IFDEF USENATIVECODE}
var
  DivResult: Integer;
begin
  if Value < 0 then
  begin
    DivResult := DivMod(Value - Max, Max + 1, Result);
    Inc(Result, Max);
  end
  else
    DivResult := DivMod(Value, Max + 1, Result);

  if Odd(DivResult) then
    Result := Max - Result;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV       EAX,ECX
        MOV       ECX,R8D
{$ENDIF}
        TEST      EAX,EAX
        JNL       @@1
        NEG       EAX
@@1:
        MOV       ECX,EDX
        CDQ
        IDIV      ECX
        TEST      EAX,1
        MOV       EAX,EDX
        JZ        @Exit
        NEG       EAX
        ADD       EAX,ECX
@Exit:
{$ENDIF}
end;

function Mirror(Value, Min, Max: Integer): Integer;
var
  DivResult: Integer;
begin
  if Value < Min then
  begin
    DivResult := DivMod(Value - Max, Max - Min + 1, Result);
    Inc(Result, Max);
  end
  else
  begin
    DivResult := DivMod(Value - Min, Max - Min + 1, Result);
    Inc(Result, Min);
  end;
  if Odd(DivResult) then Result := Max+Min-Result;
end;

function WrapPow2(Value, Max: Integer): Integer; overload;
begin
  Result := Value and Max;
end;

function WrapPow2(Value, Min, Max: Integer): Integer; overload;
begin
  Result := (Value - Min) and (Max - Min) + Min;
end;

function MirrorPow2(Value, Max: Integer): Integer; overload;
begin
  if Value and (Max + 1) = 0 then
    Result := Value and Max
  else
    Result := Max - Value and Max;
end;

function MirrorPow2(Value, Min, Max: Integer): Integer; overload;
begin
  Value := Value - Min;
  Result := Max - Min;

  if Value and (Result + 1) = 0 then
    Result := Min + Value and Result
  else
    Result := Max - Value and Result;
end;

function GetOptimalWrap(Max: Integer): TWrapProc; overload;
begin
  if (Max >= 0) and IsPowerOf2(Max + 1) then
    Result := WrapPow2
  else
    Result := Wrap;
end;

function GetOptimalWrap(Min, Max: Integer): TWrapProcEx; overload;
begin
  if (Min >= 0) and (Max >= Min) and IsPowerOf2(Max - Min + 1) then
    Result := WrapPow2
  else
    Result := Wrap;
end;

function GetOptimalMirror(Max: Integer): TWrapProc; overload;
begin
  if (Max >= 0) and IsPowerOf2(Max + 1) then
    Result := MirrorPow2
  else
    Result := Mirror;
end;

function GetOptimalMirror(Min, Max: Integer): TWrapProcEx; overload;
begin
  if (Min >= 0) and (Max >= Min) and IsPowerOf2(Max - Min + 1) then
    Result := MirrorPow2
  else
    Result := Mirror;
end;

function GetWrapProc(WrapMode: TWrapMode): TWrapProc; overload;
begin
  case WrapMode of
    wmRepeat:
      Result := Wrap;
    wmMirror:
      Result := Mirror;
    else 
      Result := Clamp;
  end;
end;

function GetWrapProc(WrapMode: TWrapMode; Max: Integer): TWrapProc; overload;
begin
  case WrapMode of
    wmRepeat:
      Result := GetOptimalWrap(Max);
    wmMirror:
      Result := GetOptimalMirror(Max);
    else 
      Result := Clamp;
  end;
end;

function GetWrapProcEx(WrapMode: TWrapMode): TWrapProcEx; overload;
begin
  case WrapMode of
    wmRepeat:
      Result := Wrap;
    wmMirror:
      Result := Mirror;
    else 
      Result := Clamp;
  end;
end;

function GetWrapProcEx(WrapMode: TWrapMode; Min, Max: Integer): TWrapProcEx; overload;
begin
  case WrapMode of
    wmRepeat:
      Result := GetOptimalWrap(Min, Max);
    wmMirror:
      Result := GetOptimalMirror(Min, Max);
    else 
      Result := Clamp;
  end;
end;

function Div255(Value: Cardinal): Cardinal;
begin
  Result := (Value * $8081) shr 23;
end;

function SAR_4(Value: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  Result := Value div 16;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV       EAX,ECX
{$ENDIF}
        SAR       EAX,4
{$ENDIF}
end;

function SAR_8(Value: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  Result := Value div 256;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV       EAX,ECX
{$ENDIF}
        SAR       EAX,8
{$ENDIF}
end;

function SAR_9(Value: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  Result := Value div 512;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV       EAX,ECX
{$ENDIF}
        SAR       EAX,9
{$ENDIF}
end;

function SAR_11(Value: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  Result := Value div 2048;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV       EAX,ECX
{$ENDIF}
        SAR       EAX,11
{$ENDIF}
end;

function SAR_12(Value: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  Result := Value div 4096;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV       EAX,ECX
{$ENDIF}
        SAR       EAX,12
{$ENDIF}
end;

function SAR_13(Value: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  Result := Value div 8192;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV       EAX,ECX
{$ENDIF}
        SAR       EAX,13
{$ENDIF}
end;

function SAR_14(Value: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  Result := Value div 16384;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV       EAX,ECX
{$ENDIF}
        SAR       EAX,14
{$ENDIF}
end;

function SAR_15(Value: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  Result := Value div 32768;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV       EAX,ECX
{$ENDIF}
        SAR       EAX,15
{$ENDIF}
end;

function SAR_16(Value: Integer): Integer;
{$IFDEF USENATIVECODE}
begin
  Result := Value div 65536;
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV       EAX,ECX
{$ENDIF}
        SAR       EAX,16
{$ENDIF}
end;

function ColorSwap(WinColor: TColor): TColor32;
{$IFDEF USENATIVECODE}
var
  WCEn: TColor32Entry absolute WinColor;
  REn : TColor32Entry absolute Result;
begin
  Result := WCEn.ARGB;
  REn.A := $FF;
  REn.R := WCEn.B;
  REn.B := WCEn.R;
{$ELSE}
asm

{$IFDEF TARGET_x64}
        MOV       EAX,ECX
{$ENDIF}
        BSWAP     EAX
        MOV       AL, $FF
        ROR       EAX,8
{$ENDIF}
end;

{$IFDEF PUREPASCAL}
function StackAlloc(Size: Integer): Pointer;
begin
  GetMem(Result, Size);
end;

procedure StackFree(P: Pointer);
begin
  FreeMem(P);
end;
{$ELSE}

function StackAlloc(Size: Integer): Pointer; register;
asm
{$IFDEF TARGET_x86}
        POP       ECX          
        MOV       EDX, ESP
        ADD       EAX, 3
        AND       EAX, not 3   
        CMP       EAX, 4092
        JLE       @@2
@@1:
        SUB       ESP, 4092
        PUSH      EAX          
        SUB       EAX, 4096
        JNS       @@1
        ADD       EAX, 4096
@@2:
        SUB       ESP, EAX
        MOV       EAX, ESP     
        PUSH      EDX          
        MOV       EDX, ESP
        SUB       EDX, 4
        PUSH      EDX          
        PUSH      ECX          
{$ENDIF}
{$IFDEF TARGET_x64}
        MOV       RAX, RCX
        POP       R8           
        MOV       RDX, RSP     
        ADD       ECX, 15
        AND       ECX, NOT 15  
        CMP       ECX, 4092
        JLE       @@2
@@1:
        SUB       RSP, 4092
        PUSH      RCX          
        SUB       ECX, 4096
        JNS       @@1
        ADD       ECX, 4096
@@2:
        SUB       RSP, RCX
        MOV       RAX, RSP     
        PUSH      RDX          
        MOV       RDX, RSP
        SUB       RDX, 8
        PUSH      RDX          
{$ENDIF}
end;

procedure StackFree(P: Pointer); register;
asm
{$IFDEF TARGET_x86}
        POP       ECX                     
        MOV       EDX, DWORD PTR [ESP]
        SUB       EAX, 8
        CMP       EDX, ESP                
        JNE       @Exit
        CMP       EDX, EAX                
        JNE       @Exit
        MOV       ESP, DWORD PTR [ESP+4]  
@Exit:
        PUSH      ECX                     
{$ENDIF}
{$IFDEF TARGET_x64}
        POP       R8                       
        MOV       RDX, QWORD PTR [RSP]
        SUB       RCX, 16
        CMP       RDX, RSP                 
        JNE       @Exit
        CMP       RDX, RCX                 
        JNE       @Exit
        MOV       RSP, QWORD PTR [RSP + 8] 
 @Exit:
        PUSH      R8                       
{$ENDIF}
end;
{$ENDIF}

const
  FID_FILLLONGWORD = 0;

var
  Registry: TFunctionRegistry;

procedure RegisterBindings;
begin
  Registry := NewRegistry('GR32_LowLevel bindings');
  Registry.RegisterBinding(FID_FILLLONGWORD, @@FillLongWord);

  Registry.Add(FID_FILLLONGWORD, @FillLongWord_Pas, []);
  {$IFNDEF PUREPASCAL}
  Registry.Add(FID_FILLLONGWORD, @FillLongWord_ASM, []);
  Registry.Add(FID_FILLLONGWORD, @FillLongWord_MMX, [ciMMX]);
  Registry.Add(FID_FILLLONGWORD, @FillLongword_SSE2, [ciSSE2]);
  {$ENDIF}

  Registry.RebindAll;
end;

initialization
  RegisterBindings;

end.
 