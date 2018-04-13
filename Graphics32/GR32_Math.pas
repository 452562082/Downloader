unit GR32_Math;

interface

{$I GR32.inc}

uses GR32;

function FixedFloor(A: TFixed): Integer;
function FixedCeil(A: TFixed): Integer;
function FixedMul(A, B: TFixed): TFixed;
function FixedDiv(A, B: TFixed): TFixed;
function OneOver(Value: TFixed): TFixed;
function FixedRound(A: TFixed): Integer;
function FixedSqr(Value: TFixed): TFixed;
function FixedSqrtLP(Value: TFixed): TFixed;      
function FixedSqrtHP(Value: TFixed): TFixed;      

function FixedCombine(W, X, Y: TFixed): TFixed;

procedure SinCos(const Theta: TFloat; out Sin, Cos: TFloat); overload;
procedure SinCos(const Theta, Radius: Single; out Sin, Cos: Single); overload;
function Hypot(const X, Y: TFloat): TFloat; overload;
function Hypot(const X, Y: Integer): Integer; overload;
function FastSqrt(const Value: TFloat): TFloat;
function FastSqrtBab1(const Value: TFloat): TFloat;
function FastSqrtBab2(const Value: TFloat): TFloat;
function FastInvSqrt(const Value: Single): Single; {$IFDEF INLININGSUPPORTED} inline; {$ENDIF} overload;

function MulDiv(Multiplicand, Multiplier, Divisor: Integer): Integer;

function IsPowerOf2(Value: Integer): Boolean; {$IFDEF INLININGSUPPORTED} inline; {$ENDIF}

function PrevPowerOf2(Value: Integer): Integer;

function NextPowerOf2(Value: Integer): Integer;

function Average(A, B: Integer): Integer;

function Sign(Value: Integer): Integer;

function FloatMod(x, y: Double): Double; {$IFDEF INLININGSUPPORTED} inline; {$ENDIF}

implementation

uses
  Math;

{$IFDEF PUREPASCAL}
const
  FixedOneS: Single = 65536;
{$ENDIF}

function FixedFloor(A: TFixed): Integer;
{$IFDEF PUREPASCAL}
begin
  Result := A div FIXEDONE;
{$ELSE}
asm
{$IFDEF TARGET_x86}
        SAR     EAX, 16
{$ENDIF}
{$IFDEF TARGET_x64}
        MOV     EAX, ECX
        SAR     EAX, 16
{$ENDIF}
{$ENDIF}
end;

function FixedCeil(A: TFixed): Integer;
{$IFDEF PUREPASCAL}
begin
  Result := (A + $FFFF) div FIXEDONE;
{$ELSE}
asm
{$IFDEF TARGET_x86}
        ADD     EAX, $0000FFFF
        SAR     EAX, 16
{$ENDIF}
{$IFDEF TARGET_x64}
        MOV     EAX, ECX
        ADD     EAX, $0000FFFF
        SAR     EAX, 16
{$ENDIF}
{$ENDIF}
end;

function FixedRound(A: TFixed): Integer;
{$IFDEF PUREPASCAL}
begin
  Result := (A + $7FFF) div FIXEDONE;
{$ELSE}
asm
{$IFDEF TARGET_x86}
        ADD     EAX, $00007FFF
        SAR     EAX, 16
{$ENDIF}
{$IFDEF TARGET_x64}
        MOV     EAX, ECX
        ADD     EAX, $00007FFF
        SAR     EAX, 16
{$ENDIF}
{$ENDIF}
end;

function FixedMul(A, B: TFixed): TFixed;
{$IFDEF PUREPASCAL}
begin
  Result := Round(A * FixedToFloat * B);
{$ELSE}
asm
{$IFDEF TARGET_x86}
        IMUL    EDX
        SHRD    EAX, EDX, 16
{$ENDIF}
{$IFDEF TARGET_x64}
        MOV     EAX, ECX
        IMUL    EDX
        SHRD    EAX, EDX, 16
{$ENDIF}
{$ENDIF}
end;

function FixedDiv(A, B: TFixed): TFixed;
{$IFDEF PUREPASCAL}
begin
  Result := Round(A / B * FixedOne);
{$ELSE}
asm
{$IFDEF TARGET_x86}
        MOV     ECX, B
        CDQ
        SHLD    EDX, EAX, 16
        SHL     EAX, 16
        IDIV    ECX
{$ENDIF}
{$IFDEF TARGET_x64}
        MOV     EAX, ECX
        MOV     ECX, EDX
        CDQ
        SHLD    EDX, EAX, 16
        SHL     EAX, 16
        IDIV    ECX
{$ENDIF}
{$ENDIF}
end;

function OneOver(Value: TFixed): TFixed;
{$IFDEF PUREPASCAL}
const
  Dividend: Single = 4294967296; 
begin
  Result := Round(Dividend / Value);
{$ELSE}
asm
{$IFDEF TARGET_x86}
        MOV     ECX, Value
        XOR     EAX, EAX
        MOV     EDX, 1
        IDIV    ECX
{$ENDIF}
{$IFDEF TARGET_x64}
        XOR     EAX, EAX
        MOV     EDX, 1
        IDIV    ECX
{$ENDIF}
{$ENDIF}
end;

function FixedSqr(Value: TFixed): TFixed;
{$IFDEF PUREPASCAL}
begin
  Result := Round(Value * FixedToFloat * Value);
{$ELSE}
asm
{$IFDEF TARGET_x86}
        IMUL    EAX
        SHRD    EAX, EDX, 16
{$ENDIF}
{$IFDEF TARGET_x64}
        MOV     EAX, Value
        IMUL    EAX
        SHRD    EAX, EDX, 16
{$ENDIF}
{$ENDIF}
end;

function FixedSqrtLP(Value: TFixed): TFixed;
{$IFDEF PUREPASCAL}
begin
  Result := Round(Sqrt(Value * FixedOneS));
{$ELSE}
asm
{$IFDEF TARGET_x86}
        PUSH    EBX
        MOV     ECX, EAX
        XOR     EAX, EAX
        MOV     EBX, $40000000
@SqrtLP1:
        MOV     EDX, ECX
        SUB     EDX, EBX
        JL      @SqrtLP2
        SUB     EDX, EAX
        JL      @SqrtLP2
        MOV     ECX,EDX
        SHR     EAX, 1
        OR      EAX, EBX
        SHR     EBX, 2
        JNZ     @SqrtLP1
        SHL     EAX, 8
        JMP     @SqrtLP3
@SqrtLP2:
        SHR     EAX, 1
        SHR     EBX, 2
        JNZ     @SqrtLP1
        SHL     EAX, 8
@SqrtLP3:
        POP     EBX
{$ENDIF}
{$IFDEF TARGET_x64}
        PUSH    RBX
        XOR     EAX, EAX
        MOV     EBX, $40000000
@SqrtLP1:
        MOV     EDX, ECX
        SUB     EDX, EBX
        JL      @SqrtLP2
        SUB     EDX, EAX
        JL      @SqrtLP2
        MOV     ECX,EDX
        SHR     EAX, 1
        OR      EAX, EBX
        SHR     EBX, 2
        JNZ     @SqrtLP1
        SHL     EAX, 8
        JMP     @SqrtLP3
@SqrtLP2:
        SHR     EAX, 1
        SHR     EBX, 2
        JNZ     @SqrtLP1
        SHL     EAX, 8
@SqrtLP3:
        POP     RBX
{$ENDIF}
{$ENDIF}
end;

function FixedSqrtHP(Value: TFixed): TFixed;
{$IFDEF PUREPASCAL}
begin
  Result := Round(Sqrt(Value * FixedOneS));
{$ELSE}
asm
{$IFDEF TARGET_x86}
        PUSH    EBX
        MOV     ECX, EAX
        XOR     EAX, EAX
        MOV     EBX, $40000000
@SqrtHP1:
        MOV     EDX, ECX
        SUB     EDX, EBX
        jb      @SqrtHP2
        SUB     EDX, EAX
        jb      @SqrtHP2
        MOV     ECX,EDX
        SHR     EAX, 1
        OR      EAX, EBX
        SHR     EBX, 2
        JNZ     @SqrtHP1
        JZ      @SqrtHP5
@SqrtHP2:
        SHR     EAX, 1
        SHR     EBX, 2
        JNZ     @SqrtHP1
@SqrtHP5:
        MOV     EBX, $00004000
        SHL     EAX, 16
        SHL     ECX, 16
@SqrtHP3:
        MOV     EDX, ECX
        SUB     EDX, EBX
        jb      @SqrtHP4
        SUB     EDX, EAX
        jb      @SqrtHP4
        MOV     ECX, EDX
        SHR     EAX, 1
        OR      EAX, EBX
        SHR     EBX, 2
        JNZ     @SqrtHP3
        JMP     @SqrtHP6
@SqrtHP4:
        SHR     EAX, 1
        SHR     EBX, 2
        JNZ     @SqrtHP3
@SqrtHP6:
        POP     EBX
{$ENDIF}
{$IFDEF TARGET_x64}
        PUSH    RBX
        XOR     EAX, EAX
        MOV     EBX, $40000000
@SqrtHP1:
        MOV     EDX, ECX
        SUB     EDX, EBX
        jb      @SqrtHP2
        SUB     EDX, EAX
        jb      @SqrtHP2
        MOV     ECX,EDX
        SHR     EAX, 1
        OR      EAX, EBX
        SHR     EBX, 2
        JNZ     @SqrtHP1
        JZ      @SqrtHP5
@SqrtHP2:
        SHR     EAX, 1
        SHR     EBX, 2
        JNZ     @SqrtHP1
@SqrtHP5:
        MOV     EBX, $00004000
        SHL     EAX, 16
        SHL     ECX, 16
@SqrtHP3:
        MOV     EDX, ECX
        SUB     EDX, EBX
        jb      @SqrtHP4
        SUB     EDX, EAX
        jb      @SqrtHP4
        MOV     ECX, EDX
        SHR     EAX, 1
        OR      EAX, EBX
        SHR     EBX, 2
        JNZ     @SqrtHP3
        JMP     @SqrtHP6
@SqrtHP4:
        SHR     EAX, 1
        SHR     EBX, 2
        JNZ     @SqrtHP3
@SqrtHP6:
        POP     RBX
{$ENDIF}
{$ENDIF}
end;

function FixedCombine(W, X, Y: TFixed): TFixed;

{$IFDEF PUREPASCAL}
begin
  Result := Round(Y + (X - Y) * FixedToFloat * W);
{$ELSE}
asm
{$IFDEF TARGET_x86}
        SUB     EDX, ECX
        IMUL    EDX
        SHRD    EAX, EDX, 16
        ADD     EAX, ECX
{$ENDIF}
{$IFDEF TARGET_x64}
        MOV     EAX, ECX
        SUB     EDX, R8D
        IMUL    EDX
        SHRD    EAX, EDX, 16
        ADD     EAX, R8D
{$ENDIF}
{$ENDIF}
end;

procedure SinCos(const Theta: TFloat; out Sin, Cos: TFloat);
{$IFDEF NATIVE_SINCOS}
var
  S, C: Extended;
begin
  Math.SinCos(Theta, S, C);
  Sin := S;
  Cos := C;
{$ELSE}
{$IFDEF TARGET_x64}
var
  Temp: DWord = 0;
{$ENDIF}
asm
{$IFDEF TARGET_x86}
        FLD     Theta
        FSINCOS
        FSTP    DWORD PTR [EDX] 
        FSTP    DWORD PTR [EAX] 
{$ENDIF}
{$IFDEF TARGET_x64}
        MOVD    Temp, Theta
        FLD     Temp
        FSINCOS
        FSTP    [Sin] 
        FSTP    [Cos] 
{$ENDIF}
{$ENDIF}
end;

procedure SinCos(const Theta, Radius: TFloat; out Sin, Cos: TFloat);
{$IFDEF NATIVE_SINCOS}
var
  S, C: Extended;
begin
  Math.SinCos(Theta, S, C);
  Sin := S * Radius;
  Cos := C * Radius;
{$ELSE}
asm
{$IFDEF TARGET_x86}
        FLD     Theta
        FSINCOS
        FMUL    Radius
        FSTP    DWORD PTR [EDX] 
        FMUL    Radius
        FSTP    DWORD PTR [EAX] 
{$ENDIF}
{$IFDEF TARGET_x64}
        MOVD    Temp, Theta
        FLD     Temp
        MOVD    Temp, Radius
        FSINCOS
        FMUL    Temp
        FSTP    [Cos]
        FMUL    Temp
        FSTP    [Sin]
{$ENDIF}
{$ENDIF}
end;

function Hypot(const X, Y: TFloat): TFloat;
{$IFDEF PUREPASCAL}
begin
  Result := Sqrt(Sqr(X) + Sqr(Y));
{$ELSE}
asm
{$IFDEF TARGET_x86}
        FLD     X
        FMUL    ST,ST
        FLD     Y
        FMUL    ST,ST
        FADDP   ST(1),ST
        FSQRT
        FWAIT
{$ENDIF}
{$IFDEF TARGET_x64}
        MULSS   XMM0, XMM0
        MULSS   XMM1, XMM1
        ADDSS   XMM0, XMM1
        SQRTSS  XMM0, XMM0
{$ENDIF}
{$ENDIF}
end;

function Hypot(const X, Y: Integer): Integer;

begin
  Result := Round(Math.Hypot(X, Y));

end;

function FastSqrt(const Value: TFloat): TFloat;

{$IFDEF PUREPASCAL}
var
  I: Integer absolute Value;
  J: Integer absolute Result;
begin
  J := (I - $3F800000) div 2 + $3F800000;
{$ELSE}
asm
{$IFDEF TARGET_x86}
        MOV     EAX, DWORD PTR Value
        SUB     EAX, $3F800000
        SAR     EAX, 1
        ADD     EAX, $3F800000
        MOV     DWORD PTR [ESP - 4], EAX
        FLD     DWORD PTR [ESP - 4]
{$ENDIF}
{$IFDEF TARGET_x64}
        SQRTSS  XMM0, XMM0
{$ENDIF}
{$ENDIF}
end;

function FastSqrtBab1(const Value: TFloat): TFloat;

const
  CHalf : TFloat = 0.5;
{$IFDEF PUREPASCAL}
var
  I: Integer absolute Value;
  J: Integer absolute Result;
begin
  J := (I - $3F800000) div 2 + $3F800000;
  Result := CHalf * (Result + Value / Result);
{$ELSE}
asm
{$IFDEF TARGET_x86}
        MOV     EAX, Value
        SUB     EAX, $3F800000
        SAR     EAX, 1
        ADD     EAX, $3F800000
        MOV     DWORD PTR [ESP - 4], EAX
        FLD     Value
        FDIV    DWORD PTR [ESP - 4]
        FADD    DWORD PTR [ESP - 4]
        FMUL    CHalf
{$ENDIF}
{$IFDEF TARGET_x64}
        SQRTSS  XMM0, XMM0
{$ENDIF}
{$ENDIF}
end;

function FastSqrtBab2(const Value: TFloat): TFloat;

{$IFDEF PUREPASCAL}
const
  CQuarter : TFloat = 0.25;
var
  J: Integer absolute Result;
begin
 Result := Value;
 J := ((J - (1 shl 23)) shr 1) + (1 shl 29);
 Result := Result + Value / Result;
 Result := CQuarter * Result + Value / Result;
{$ELSE}
const
  CHalf : TFloat = 0.5;
asm
{$IFDEF TARGET_x86}
        MOV     EAX, Value
        SUB     EAX, $3F800000
        SAR     EAX, 1
        ADD     EAX, $3F800000
        MOV     DWORD PTR [ESP - 4], EAX
        FLD     Value
        FDIV    DWORD PTR [ESP - 4]
        FADD    DWORD PTR [ESP - 4]
        FMUL    CHalf
{$ENDIF}
{$IFDEF TARGET_x64}
        MOVD    EAX, Value
        SUB     EAX, $3F800000
        SAR     EAX, 1
        ADD     EAX, $3F800000
        MOVD    XMM1, EAX
        DIVSS   XMM0, XMM1
        ADDSS   XMM0, XMM1
        MOVD    XMM1, CHalf
        MULSS   XMM0, XMM1
{$ENDIF}
{$ENDIF}
end;

function FastInvSqrt(const Value: Single): Single;
var
  IntCst : Cardinal absolute result;
begin
  Result := Value;
  IntCst := ($BE6EB50C - IntCst) shr 1;
  Result := 0.5 * Result * (3 - Value * Sqr(Result));
end;

function MulDiv(Multiplicand, Multiplier, Divisor: Integer): Integer;
{$IFDEF PUREPASCAL}
begin
  Result := Int64(Multiplicand) * Int64(Multiplier) div Divisor;
{$ELSE}
asm
{$IFDEF TARGET_x86}
        PUSH    EBX             
        PUSH    ESI             

        MOV     EBX, EAX        
        XOR     EBX, EDX        
        XOR     EBX, ECX        

        OR      EAX, EAX        
        JNS     @m1Ok           
        NEG     EAX
@m1Ok:
        OR      EDX, EDX
        JNS     @m2Ok
        NEG     EDX
@m2Ok:
        OR      ECX, ECX
        JNS     @DivOk
        NEG     ECX
@DivOK:
        MUL     EDX             

        MOV     ESI, EDX        
        SHL     ESI, 1          
        CMP     ESI, ECX        
        JAE     @Overfl         

        DIV     ECX             

        SUB     ECX, EDX        
        CMP     ECX, EDX        
        JA      @NoAdd          
        INC     EAX             
@NoAdd:
        OR      EBX, EDX        
        JNS     @Exit           
        NEG     EAX             
        JMP     @Exit
@Overfl:
        OR      EAX, -1         
                                
@Exit:
        POP     ESI             
        POP     EBX             
{$ENDIF}
{$IFDEF TARGET_x64}
        MOV     EAX, ECX        
        XOR     ECX, EDX        
        XOR     ECX, R8D        

        OR      EAX, EAX        
        JNS     @m1Ok           
        NEG     EAX
@m1Ok:
        OR      EDX, EDX
        JNS     @m2Ok
        NEG     EDX
@m2Ok:
        OR      R8D, R8D
        JNS     @DivOk
        NEG     R8D
@DivOK:
        MUL     EDX             

        MOV     R9D, EDX        
        SHL     R9D, 1          
        CMP     R9D, R8D        
        JAE     @Overfl         

        DIV     R8D             

        SUB     R8D, EDX        
        CMP     R8D, EDX        
        JA      @NoAdd          
        INC     EAX             
@NoAdd:
        OR      ECX, EDX        
        JNS     @Exit           
        NEG     EAX             
        JMP     @Exit
@Overfl:
        OR      EAX, -1         
                                
@Exit:
{$ENDIF}
{$ENDIF}
end;

function IsPowerOf2(Value: Integer): Boolean;

begin
  Result := Value and (Value - 1) = 0;
end;

function PrevPowerOf2(Value: Integer): Integer;

{$IFDEF PUREPASCAL}
begin
  Result := 1;
  while Value shr 1 > 0 do
    Result := Result shl 1;
{$ELSE}
asm
{$IFDEF TARGET_x86}
        BSR     ECX, EAX
        SHR     EAX, CL
        SHL     EAX, CL
{$ENDIF}
{$IFDEF TARGET_x64}
        MOV     EAX, Value
        BSR     ECX, EAX
        SHR     EAX, CL
        SHL     EAX, CL
{$ENDIF}
{$ENDIF}
end;

function NextPowerOf2(Value: Integer): Integer;

{$IFDEF PUREPASCAL}
begin
  Result := 2;
  while Value shr 1 > 0 do 
    Result := Result shl 1;
{$ELSE}
asm
{$IFDEF TARGET_x86}
        DEC     EAX
        JLE     @1
        BSR     ECX, EAX
        MOV     EAX, 2
        SHL     EAX, CL
        RET
@1:
        MOV     EAX, 1
{$ENDIF}
{$IFDEF TARGET_x64}
        MOV     EAX, Value
        DEC     EAX
        JLE     @1
        BSR     ECX, EAX
        MOV     EAX, 2
        SHL     EAX, CL
        RET
@1:
        MOV     EAX, 1
{$ENDIF}
{$ENDIF}
end;

function Average(A, B: Integer): Integer;

{$IFDEF PUREPASCAL}
begin
  Result := (A and B) + (A xor B) div 2;
{$ELSE}
asm
{$IFDEF TARGET_x86}
        MOV     ECX, EDX
        XOR     EDX, EAX
        SAR     EDX, 1
        AND     EAX, ECX
        ADD     EAX, EDX
{$ENDIF}
{$IFDEF TARGET_x64}
        MOV     EAX, A
        MOV     ECX, EDX
        XOR     EDX, EAX
        SAR     EDX, 1
        AND     EAX, ECX
        ADD     EAX, EDX
{$ENDIF}
{$ENDIF}
end;

function Sign(Value: Integer): Integer;
{$IFDEF PUREPASCAL}
begin
  
  Result := (- Value) shr 31 - (Value shr 31);
{$ELSE}
asm
{$IFDEF TARGET_x64}
        MOV     EAX, Value
{$ENDIF}
        CDQ
        NEG     EAX
        ADC     EDX, EDX
        MOV     EAX, EDX
{$ENDIF}
end;

function FloatMod(x, y: Double): Double;
begin
  if (y = 0) then
    Result := X
  else
    Result := x - y * Floor(x / y);
end;

end.
 