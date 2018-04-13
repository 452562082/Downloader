unit GR32_Backends_VCL;

interface

{$I GR32.inc}

uses
  SysUtils, Classes, Windows, Graphics, GR32, GR32_Backends, GR32_Containers
  , GR32_Backends_Generic;

type

  TGDIBackend = class(TCustomBackend, IPaintSupport,
    IBitmapContextSupport, IDeviceContextSupport,
    ITextSupport, IFontSupport, ICanvasSupport)
  private
    procedure FontChangedHandler(Sender: TObject);
    procedure CanvasChangedHandler(Sender: TObject);
    procedure CanvasChanged;
    procedure FontChanged;
  protected
    FBitmapInfo: TBitmapInfo;
    FBitmapHandle: HBITMAP;
    FHDC: HDC;
    FFont: TFont;
    FCanvas: TCanvas;
    FFontHandle: HFont;
    FMapHandle: THandle;

    FOnFontChange: TNotifyEvent;
    FOnCanvasChange: TNotifyEvent;

    procedure InitializeSurface(NewWidth, NewHeight: Integer; ClearBuffer: Boolean); override;
    procedure FinalizeSurface; override;

    procedure PrepareFileMapping(NewWidth, NewHeight: Integer); virtual;
  public
    constructor Create; override;
    destructor Destroy; override;

    procedure Changed; override;

    function Empty: Boolean; override;
  public
    
    procedure ImageNeeded;
    procedure CheckPixmap;
    
    function GetBitmapInfo: TBitmapInfo;
    function GetBitmapHandle: THandle;

    property BitmapInfo: TBitmapInfo read GetBitmapInfo;
    property BitmapHandle: THandle read GetBitmapHandle;
    
    function GetHandle: HDC;

    procedure Draw(const DstRect, SrcRect: TRect; hSrc: HDC); overload;
    procedure DrawTo(hDst: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF}; DstX, DstY: Integer); overload;
    procedure DrawTo(hDst: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF}; const DstRect, SrcRect: TRect); overload;

    property Handle: HDC read GetHandle;
    
    procedure Textout(X, Y: Integer; const Text: String); overload;
    procedure Textout(X, Y: Integer; const ClipRect: TRect; const Text: String); overload;
    procedure Textout(var DstRect: TRect; const Flags: Cardinal; const Text: String); overload;
    function  TextExtent(const Text: String): TSize;

    procedure TextoutW(X, Y: Integer; const Text: Widestring); overload;
    procedure TextoutW(X, Y: Integer; const ClipRect: TRect; const Text: Widestring); overload;
    procedure TextoutW(var DstRect: TRect; const Flags: Cardinal; const Text: Widestring); overload;
    function  TextExtentW(const Text: Widestring): TSize;
    
    function GetOnFontChange: TNotifyEvent;
    procedure SetOnFontChange(Handler: TNotifyEvent);
    function GetFont: TFont;
    procedure SetFont(const Font: TFont);

    procedure UpdateFont;
    property Font: TFont read GetFont write SetFont;
    property OnFontChange: TNotifyEvent read FOnFontChange write FOnFontChange;
    
    function GetCanvasChange: TNotifyEvent;
    procedure SetCanvasChange(Handler: TNotifyEvent);
    function GetCanvas: TCanvas;

    procedure DeleteCanvas;
    function CanvasAllocated: Boolean;

    property Canvas: TCanvas read GetCanvas;
    property OnCanvasChange: TNotifyEvent read GetCanvasChange write SetCanvasChange;
  end;

  TGDIMMFBackend = class(TGDIBackend)
  private
    FMapFileHandle: THandle;
    FMapIsTemporary: Boolean;
    FMapFileName: string;
  protected
    procedure PrepareFileMapping(NewWidth, NewHeight: Integer); override;
  public
    constructor Create(Owner: TBitmap32; IsTemporary: Boolean = True; const MapFileName: string = ''); virtual;
    destructor Destroy; override;
  end;

  TGDIMemoryBackend = class(TMemoryBackend, IPaintSupport, IDeviceContextSupport)
  private
    procedure DoPaintRect(ABuffer: TBitmap32; ARect: TRect; ACanvas: TCanvas);

    function GetHandle: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF}; 
  protected
    FBitmapInfo: TBitmapInfo;

    procedure InitializeSurface(NewWidth: Integer; NewHeight: Integer;
      ClearBuffer: Boolean); override;
  public
    constructor Create; override;
    
    procedure ImageNeeded;
    procedure CheckPixmap;
    
    procedure Draw(const DstRect, SrcRect: TRect; hSrc: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF}); overload;
    procedure DrawTo(hDst: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF}; DstX, DstY: Integer); overload;
    procedure DrawTo(hDst: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF}; const DstRect, SrcRect: TRect); overload;
  end;

implementation

var
  StockFont: HFONT;

constructor TGDIBackend.Create;
begin
  inherited;

  FillChar(FBitmapInfo, SizeOf(TBitmapInfo), 0);
  with FBitmapInfo.bmiHeader do
  begin
    biSize := SizeOf(TBitmapInfoHeader);
    biPlanes := 1;
    biBitCount := 32;
    biCompression := BI_RGB;
  end;

  FMapHandle := 0;

  FFont := TFont.Create;
  FFont.OnChange := FontChangedHandler;
  FFont.OwnerCriticalSection := @FLock;
end;

destructor TGDIBackend.Destroy;
begin
  DeleteCanvas;
  FFont.Free;

  inherited;
end;

procedure TGDIBackend.InitializeSurface(NewWidth, NewHeight: Integer; ClearBuffer: Boolean);
begin
  with FBitmapInfo.bmiHeader do
  begin
    biWidth := NewWidth;
    biHeight := -NewHeight;
    biSizeImage := NewWidth * NewHeight * 4;
  end;

  PrepareFileMapping(NewWidth, NewHeight);

  FBitmapHandle := CreateDIBSection(0, FBitmapInfo, DIB_RGB_COLORS, Pointer(FBits), FMapHandle, 0);

  if FBits = nil then
    raise Exception.Create(RCStrCannotAllocateDIBHandle);

  FHDC := CreateCompatibleDC(0);
  if FHDC = 0 then
  begin
    DeleteObject(FBitmapHandle);
    FBitmapHandle := 0;
    FBits := nil;
    raise Exception.Create(RCStrCannotCreateCompatibleDC);
  end;

  if SelectObject(FHDC, FBitmapHandle) = 0 then
  begin
    DeleteDC(FHDC);
    DeleteObject(FBitmapHandle);
    FHDC := 0;
    FBitmapHandle := 0;
    FBits := nil;
    raise Exception.Create(RCStrCannotSelectAnObjectIntoDC);
  end;
end;

procedure TGDIBackend.FinalizeSurface;
begin
  if FHDC <> 0 then DeleteDC(FHDC);
  FHDC := 0;
  if FBitmapHandle <> 0 then DeleteObject(FBitmapHandle);
  FBitmapHandle := 0;

  FBits := nil;
end;

procedure TGDIBackend.DeleteCanvas;
begin
  if Assigned(FCanvas) then
  begin
    FCanvas.Handle := 0;
    FCanvas.Free;
    FCanvas := nil;
  end;
end;

procedure TGDIBackend.PrepareFileMapping(NewWidth, NewHeight: Integer);
begin
  
end;

procedure TGDIBackend.Changed;
begin
  if FCanvas <> nil then FCanvas.Handle := Self.Handle;
  inherited;
end;

procedure TGDIBackend.CanvasChanged;
begin
  if Assigned(FOnCanvasChange) then
    FOnCanvasChange(Self);
end;

procedure TGDIBackend.FontChanged;
begin
  if Assigned(FOnFontChange) then
    FOnFontChange(Self);
end;

function TGDIBackend.TextExtent(const Text: String): TSize;
var
  DC: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF};
  OldFont: HGDIOBJ;
begin
  UpdateFont;
  Result.cX := 0;
  Result.cY := 0;
  if Handle <> 0 then
    Windows.GetTextExtentPoint32(Handle, PChar(Text), Length(Text), Result)
  else
  begin
    StockBitmap.Canvas.Lock;
    try
      DC := StockBitmap.Canvas.Handle;
      OldFont := SelectObject(DC, Font.Handle);
      Windows.GetTextExtentPoint32(DC, PChar(Text), Length(Text), Result);
      SelectObject(DC, OldFont);
    finally
      StockBitmap.Canvas.Unlock;
    end;
  end;
end;

function TGDIBackend.TextExtentW(const Text: Widestring): TSize;
var
  DC: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF};
  OldFont: HGDIOBJ;
begin
  UpdateFont;
  Result.cX := 0;
  Result.cY := 0;

  if Handle <> 0 then
    Windows.GetTextExtentPoint32W(Handle, PWideChar(Text), Length(Text), Result)
  else
  begin
    StockBitmap.Canvas.Lock;
    try
      DC := StockBitmap.Canvas.Handle;
      OldFont := SelectObject(DC, Font.Handle);
      Windows.GetTextExtentPoint32W(DC, PWideChar(Text), Length(Text), Result);
      SelectObject(DC, OldFont);
    finally
      StockBitmap.Canvas.Unlock;
    end;
  end;
end;

procedure TGDIBackend.Textout(X, Y: Integer; const Text: String);
var
  Extent: TSize;
begin
  UpdateFont;

  if not FOwner.MeasuringMode then
  begin
    if FOwner.Clipping then
      ExtTextout(Handle, X, Y, ETO_CLIPPED, @FOwner.ClipRect, PChar(Text), Length(Text), nil)
    else
      ExtTextout(Handle, X, Y, 0, nil, PChar(Text), Length(Text), nil);
  end;

  Extent := TextExtent(Text);
  FOwner.Changed(MakeRect(X, Y, X + Extent.cx + 1, Y + Extent.cy + 1));
end;

procedure TGDIBackend.TextoutW(X, Y: Integer; const Text: Widestring);
var
  Extent: TSize;
begin
  UpdateFont;

  if not FOwner.MeasuringMode then
  begin
    if FOwner.Clipping then
      ExtTextoutW(Handle, X, Y, ETO_CLIPPED, @FOwner.ClipRect, PWideChar(Text), Length(Text), nil)
    else
      ExtTextoutW(Handle, X, Y, 0, nil, PWideChar(Text), Length(Text), nil);
  end;

  Extent := TextExtentW(Text);
  FOwner.Changed(MakeRect(X, Y, X + Extent.cx + 1, Y + Extent.cy + 1));
end;

procedure TGDIBackend.TextoutW(X, Y: Integer; const ClipRect: TRect; const Text: Widestring);
var
  Extent: TSize;
begin
  UpdateFont;

  if not FOwner.MeasuringMode then
    ExtTextoutW(Handle, X, Y, ETO_CLIPPED, @ClipRect, PWideChar(Text), Length(Text), nil);

  Extent := TextExtentW(Text);
  FOwner.Changed(MakeRect(X, Y, X + Extent.cx + 1, Y + Extent.cy + 1));
end;

procedure TGDIBackend.Textout(X, Y: Integer; const ClipRect: TRect; const Text: String);
var
  Extent: TSize;
begin
  UpdateFont;

  if not FOwner.MeasuringMode then
    ExtTextout(Handle, X, Y, ETO_CLIPPED, @ClipRect, PChar(Text), Length(Text), nil);

  Extent := TextExtent(Text);
  FOwner.Changed(MakeRect(X, Y, X + Extent.cx + 1, Y + Extent.cy + 1));
end;

procedure TGDIBackend.TextoutW(var DstRect: TRect; const Flags: Cardinal; const Text: Widestring);
begin
  UpdateFont;

  if not FOwner.MeasuringMode then
    DrawTextW(Handle, PWideChar(Text), Length(Text), DstRect, Flags);

  FOwner.Changed(DstRect);
end;

procedure TGDIBackend.UpdateFont;
begin
  if (FFontHandle = 0) and (Handle <> 0) then
  begin
    SelectObject(Handle, Font.Handle);
    SetTextColor(Handle, ColorToRGB(Font.Color));
    SetBkMode(Handle, Windows.TRANSPARENT);
    FFontHandle := Font.Handle;
  end
  else
  begin
    SelectObject(Handle, FFontHandle);
    SetTextColor(Handle, ColorToRGB(Font.Color));
    SetBkMode(Handle, Windows.TRANSPARENT);
  end;
end;

procedure TGDIBackend.Textout(var DstRect: TRect; const Flags: Cardinal; const Text: String);
begin
  UpdateFont;

  if not FOwner.MeasuringMode then
    DrawText(Handle, PChar(Text), Length(Text), DstRect, Flags);

  FOwner.Changed(DstRect);
end;

procedure TGDIBackend.DrawTo(hDst: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF}; DstX, DstY: Integer);
begin
  StretchDIBits(
    hDst, DstX, DstY, FOwner.Width, FOwner.Height,
    0, 0, FOwner.Width, FOwner.Height, Bits, FBitmapInfo, DIB_RGB_COLORS, SRCCOPY);
end;

procedure TGDIBackend.DrawTo(hDst: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF}; const DstRect, SrcRect: TRect);
begin
  StretchBlt(
    hDst,
    DstRect.Left, DstRect.Top, DstRect.Right - DstRect.Left, DstRect.Bottom - DstRect.Top, Handle,
    SrcRect.Left, SrcRect.Top, SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, SRCCOPY);
end;

function TGDIBackend.GetBitmapHandle: THandle;
begin
  Result := FBitmapHandle;
end;

function TGDIBackend.GetBitmapInfo: TBitmapInfo;
begin
  Result := FBitmapInfo;
end;

function TGDIBackend.GetCanvas: TCanvas;
begin
  if not Assigned(FCanvas) then
  begin
    FCanvas := TCanvas.Create;
    FCanvas.Handle := Handle;
    FCanvas.OnChange := CanvasChangedHandler;
  end;
  Result := FCanvas;
end;

function TGDIBackend.GetCanvasChange: TNotifyEvent;
begin
  Result := FOnCanvasChange;
end;

function TGDIBackend.GetFont: TFont;
begin
  Result := FFont;
end;

function TGDIBackend.GetHandle: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF};
begin
  Result := FHDC;
end;

function TGDIBackend.GetOnFontChange: TNotifyEvent;
begin
  Result := FOnFontChange;
end;

procedure TGDIBackend.SetCanvasChange(Handler: TNotifyEvent);
begin
  FOnCanvasChange := Handler;
end;

procedure TGDIBackend.SetFont(const Font: TFont);
begin
  FFont.Assign(Font);
  FontChanged;
end;

procedure TGDIBackend.SetOnFontChange(Handler: TNotifyEvent);
begin
  FOnFontChange := Handler;
end;

procedure TGDIBackend.Draw(const DstRect, SrcRect: TRect; hSrc: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF});
begin
  if FOwner.Empty then Exit;

  if not FOwner.MeasuringMode then
    StretchBlt(Handle, DstRect.Left, DstRect.Top, DstRect.Right - DstRect.Left,
      DstRect.Bottom - DstRect.Top, hSrc, SrcRect.Left, SrcRect.Top,
      SrcRect.Right - SrcRect.Left, SrcRect.Bottom - SrcRect.Top, SRCCOPY);

  FOwner.Changed(DstRect);
end;

function TGDIBackend.CanvasAllocated: Boolean;
begin
  Result := Assigned(FCanvas);
end;

function TGDIBackend.Empty: Boolean;
begin
  Result := FBitmapHandle = 0;
end;

procedure TGDIBackend.FontChangedHandler(Sender: TObject);
begin
  if FFontHandle <> 0 then
  begin
    if Handle <> 0 then SelectObject(Handle, StockFont);
    FFontHandle := 0;
  end;

  FontChanged;
end;

procedure TGDIBackend.CanvasChangedHandler(Sender: TObject);
begin
  CanvasChanged;
end;

procedure TGDIBackend.ImageNeeded;
begin

end;

procedure TGDIBackend.CheckPixmap;
begin

end;

constructor TGDIMMFBackend.Create(Owner: TBitmap32; IsTemporary: Boolean = True; const MapFileName: string = '');
begin
  FMapFileName := MapFileName;
  FMapIsTemporary := IsTemporary;
  TMMFBackend.InitializeFileMapping(FMapHandle, FMapFileHandle, FMapFileName);
  inherited Create(Owner);
end;

destructor TGDIMMFBackend.Destroy;
begin
  TMMFBackend.DeinitializeFileMapping(FMapHandle, FMapFileHandle, FMapFileName);
  inherited;
end;

procedure TGDIMMFBackend.PrepareFileMapping(NewWidth, NewHeight: Integer);
begin
  TMMFBackend.CreateFileMapping(FMapHandle, FMapFileHandle, FMapFileName, FMapIsTemporary, NewWidth, NewHeight);
end;

constructor TGDIMemoryBackend.Create;
begin
  inherited;
  FillChar(FBitmapInfo, SizeOf(TBitmapInfo), 0);
  with FBitmapInfo.bmiHeader do 
  begin
    biSize := SizeOf(TBitmapInfoHeader);
    biPlanes := 1;
    biBitCount := 32;
    biCompression := BI_RGB;
    biXPelsPerMeter := 96;
    biYPelsPerMeter := 96;
    biClrUsed := 0;
  end;
end;

procedure TGDIMemoryBackend.InitializeSurface(NewWidth, NewHeight: Integer;
  ClearBuffer: Boolean);
begin
  inherited;
  with FBitmapInfo.bmiHeader do 
  begin
    biWidth := NewWidth;
    biHeight := -NewHeight;
  end;
end;

procedure TGDIMemoryBackend.ImageNeeded;
begin

end;

procedure TGDIMemoryBackend.CheckPixmap;
begin

end;

procedure TGDIMemoryBackend.DoPaintRect(ABuffer: TBitmap32;
  ARect: TRect; ACanvas: TCanvas);
var
  Bitmap        : HBITMAP;
  DeviceContext : {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF};
  Buffer        : Pointer;
  OldObject     : HGDIOBJ;
begin
  if SetDIBitsToDevice(ACanvas.Handle, ARect.Left, ARect.Top, ARect.Right -
    ARect.Left, ARect.Bottom - ARect.Top, ARect.Left, ARect.Top, 0,
    ARect.Bottom - ARect.Top, ABuffer.Bits, FBitmapInfo, DIB_RGB_COLORS) = 0 then
  begin
    
    DeviceContext := CreateCompatibleDC(ACanvas.Handle);
    if DeviceContext <> 0 then
    try
      Bitmap := CreateDIBSection(DeviceContext, FBitmapInfo, DIB_RGB_COLORS,
        Buffer, 0, 0);

      if Bitmap <> 0 then 
      begin
        OldObject := SelectObject(DeviceContext, Bitmap);
        try
          Move(ABuffer.Bits^, Buffer^, FBitmapInfo.bmiHeader.biWidth *
            FBitmapInfo.bmiHeader.biHeight * SizeOf(Cardinal));
          BitBlt(ACanvas.Handle, ARect.Left, ARect.Top, ARect.Right -
            ARect.Left, ARect.Bottom - ARect.Top, DeviceContext, 0, 0, SRCCOPY);
        finally
          if OldObject <> 0 then
            SelectObject(DeviceContext, OldObject);
          DeleteObject(Bitmap);
        end;
      end else
        raise Exception.Create('Can''t create compatible DC''');
    finally
      DeleteDC(DeviceContext);
    end;
  end;
end;

procedure TGDIMemoryBackend.Draw(const DstRect, SrcRect: TRect; hSrc: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF});
begin
  if FOwner.Empty then Exit;

  if not FOwner.MeasuringMode then
    raise Exception.Create('Not supported!');

  FOwner.Changed(DstRect);
end;

procedure TGDIMemoryBackend.DrawTo(hDst: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF}; DstX, DstY: Integer);
var
  Bitmap        : HBITMAP;
  DeviceContext : {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF};
  Buffer        : Pointer;
  OldObject     : HGDIOBJ;
begin
  if SetDIBitsToDevice(hDst, DstX, DstY,
    FOwner.Width, FOwner.Height, 0, 0, 0, FOwner.Height, FBits, FBitmapInfo,
    DIB_RGB_COLORS) = 0 then
  begin
    
    DeviceContext := CreateCompatibleDC(hDst);
    if DeviceContext <> 0 then
    try
      Bitmap := CreateDIBSection(DeviceContext, FBitmapInfo, DIB_RGB_COLORS,
        Buffer, 0, 0);

      if Bitmap <> 0 then
      begin
        OldObject := SelectObject(DeviceContext, Bitmap);
        try
          Move(FBits^, Buffer^, FBitmapInfo.bmiHeader.biWidth *
            FBitmapInfo.bmiHeader.biHeight * SizeOf(Cardinal));
          BitBlt(hDst, DstX, DstY, FOwner.Width, FOwner.Height, DeviceContext,
            0, 0, SRCCOPY);
        finally
          if OldObject <> 0 then
            SelectObject(DeviceContext, OldObject);
          DeleteObject(Bitmap);
        end;
      end else
        raise Exception.Create('Can''t create compatible DC''');
    finally
      DeleteDC(DeviceContext);
    end;
  end;
end;

procedure TGDIMemoryBackend.DrawTo(hDst: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF}; 
  const DstRect, SrcRect: TRect);
var
  Bitmap        : HBITMAP;
  DeviceContext : {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF};
  Buffer        : Pointer;
  OldObject     : HGDIOBJ;
begin
  if SetDIBitsToDevice(hDst, DstRect.Left, DstRect.Top,
    DstRect.Right - DstRect.Left, DstRect.Bottom - DstRect.Top, SrcRect.Left,
    SrcRect.Top, 0, SrcRect.Bottom - SrcRect.Top, FBits, FBitmapInfo,
    DIB_RGB_COLORS) = 0 then
  begin
    
    DeviceContext := CreateCompatibleDC(hDst);
    if DeviceContext <> 0 then
    try
      Bitmap := CreateDIBSection(DeviceContext, FBitmapInfo, DIB_RGB_COLORS,
        Buffer, 0, 0);

      if Bitmap <> 0 then
      begin
        OldObject := SelectObject(DeviceContext, Bitmap);
        try
          Move(FBits^, Buffer^, FBitmapInfo.bmiHeader.biWidth *
            FBitmapInfo.bmiHeader.biHeight * SizeOf(Cardinal));
          BitBlt(hDst, DstRect.Left, DstRect.Top, DstRect.Right -
            DstRect.Left, DstRect.Bottom - DstRect.Top, DeviceContext, 0, 0, SRCCOPY);
        finally
          if OldObject <> 0 then
            SelectObject(DeviceContext, OldObject);
          DeleteObject(Bitmap);
        end;
      end else
        raise Exception.Create('Can''t create compatible DC''');
    finally
      DeleteDC(DeviceContext);
    end;
  end;
end;

function TGDIMemoryBackend.GetHandle: {$IFDEF BCB}Cardinal{$ELSE}HDC{$ENDIF};
begin
  Result := 0;
end;

initialization
  StockFont := GetStockObject(SYSTEM_FONT);

finalization

end.
 