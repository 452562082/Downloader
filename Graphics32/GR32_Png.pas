unit GR32_PNG;

interface

{$I GR32.inc}
{$I GR32_PngCompilerSwitches.inc}

uses
  Classes, Graphics, SysUtils, GR32, GR32_PortableNetworkGraphic;

type
  TProgressEvent = procedure(Sender: TObject; Percent: Single) of object;

  TPortableNetworkGraphic32 = class(TPortableNetworkGraphic)
  private
    FProgressEvent: TProgressEvent;
    procedure AssignPropertiesFromBitmap32(Bitmap32: TCustomBitmap32);
  protected
    function GR32Scanline(Bitmap: TObject; Y: Integer): Pointer; virtual;
    function GR32ScanlineProgress(Bitmap: TObject; Y: Integer): Pointer;
      virtual;
  public
    procedure AssignTo(Dest: TPersistent); override;
    procedure Assign(Source: TPersistent); override;

    procedure DrawToBitmap32(Bitmap32: TCustomBitmap32); virtual;

    property Progress: TProgressEvent read FProgressEvent write FProgressEvent;
  end;

implementation

resourcestring
  RCStrUnsupportedFormat = 'Unsupported Format';
  RCStrDataIncomplete = 'Data not complete';

type
  TCustomPngNonInterlacedDecoder = class(TCustomPngDecoder)
  protected
    FBytesPerRow: Integer;
    FRowByteSize: Integer;
    procedure TransferData(Source: Pointer; Destination: PColor32); virtual;
      abstract;
  public
    constructor Create(Stream: TStream; Header: TChunkPngImageHeader;
      Gamma: TChunkPngGamma = nil; Palette: TChunkPngPalette = nil); override;
    destructor Destroy; override;

    procedure DecodeToScanline(Bitmap: TObject;
      ScanLineCallback: TScanLineCallback); override;
  end;

  TPngNonInterlacedGrayscale1bitDecoder = class(TCustomPngNonInterlacedDecoder)
  protected
    procedure TransferData(Source: Pointer; Destination: PColor32); override;
  end;

  TPngNonInterlacedGrayscale2bitDecoder = class(TCustomPngNonInterlacedDecoder)
  protected
    procedure TransferData(Source: Pointer; Destination: PColor32); override;
  end;

  TPngNonInterlacedGrayscale4bitDecoder = class(TCustomPngNonInterlacedDecoder)
  protected
    procedure TransferData(Source: Pointer; Destination: PColor32); override;
  end;

  TPngNonInterlacedGrayscale8bitDecoder = class(TCustomPngNonInterlacedDecoder)
  protected
    procedure TransferData(Source: Pointer; Destination: PColor32); override;
  end;

  TPngNonInterlacedGrayscale16bitDecoder = class(TCustomPngNonInterlacedDecoder)
  protected
    procedure TransferData(Source: Pointer; Destination: PColor32); override;
  end;

  TPngNonInterlacedTrueColor8bitDecoder = class(TCustomPngNonInterlacedDecoder)
  protected
    procedure TransferData(Source: Pointer; Destination: PColor32); override;
  end;

  TPngNonInterlacedTrueColor16bitDecoder = class(TCustomPngNonInterlacedDecoder)
  protected
    procedure TransferData(Source: Pointer; Destination: PColor32); override;
  end;

  TPngNonInterlacedPaletteDecoder = class(TCustomPngNonInterlacedDecoder)
  protected
    procedure TransferData(Source: Pointer; Destination: PColor32); override;
  end;

  TPngNonInterlacedPalette8bitDecoder = class(TCustomPngNonInterlacedDecoder)
  protected
    procedure TransferData(Source: Pointer; Destination: PColor32); override;
  end;

  TPngNonInterlacedGrayscaleAlpha8bitDecoder = class
    (TCustomPngNonInterlacedDecoder)
  protected
    procedure TransferData(Source: Pointer; Destination: PColor32); override;
  end;

  TPngNonInterlacedGrayscaleAlpha16bitDecoder = class
    (TCustomPngNonInterlacedDecoder)
  protected
    procedure TransferData(Source: Pointer; Destination: PColor32); override;
  end;

  TPngNonInterlacedTrueColorAlpha8bitDecoder = class
    (TCustomPngNonInterlacedDecoder)
  protected
    procedure TransferData(Source: Pointer; Destination: PColor32); override;
  end;

  TPngNonInterlacedTrueColorAlpha16bitDecoder = class
    (TCustomPngNonInterlacedDecoder)
  protected
    procedure TransferData(Source: Pointer; Destination: PColor32); override;
  end;

  TCustomPngAdam7Decoder = class(TCustomPngDecoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); virtual; abstract;
  public
    constructor Create(Stream: TStream; Header: TChunkPngImageHeader;
      Gamma: TChunkPngGamma = nil; Palette: TChunkPngPalette = nil); override;
    destructor Destroy; override;
    procedure DecodeToScanline(Bitmap: TObject;
      ScanLineCallback: TScanLineCallback); override;
  end;

  TPngAdam7Grayscale1bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TPngAdam7Grayscale2bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TPngAdam7Grayscale4bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TPngAdam7Grayscale8bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TPngAdam7Grayscale16bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TPngAdam7TrueColor8bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TPngAdam7TrueColor16bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TPngAdam7Palette1bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TPngAdam7Palette2bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TPngAdam7Palette4bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TPngAdam7Palette8bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TPngAdam7GrayscaleAlpha8bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TPngAdam7GrayscaleAlpha16bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TPngAdam7TrueColorAlpha8bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TPngAdam7TrueColorAlpha16bitDecoder = class(TCustomPngAdam7Decoder)
  protected
    procedure TransferData(const Pass: Byte; Source: Pointer;
      Destination: PColor32); override;
  end;

  TCustomPngNonInterlacedEncoder = class(TCustomPngEncoder)
  protected
    FBytesPerRow: Integer;
    FRowByteSize: Integer;
    function ColorInPalette(Color: TColor32): Integer; virtual;
    procedure TransferData(Source: PColor32; Destination: Pointer); virtual;
      abstract;
  public
    constructor Create(Stream: TStream; Header: TChunkPngImageHeader;
      Gamma: TChunkPngGamma = nil; Palette: TChunkPngPalette = nil); override;
    destructor Destroy; override;
    procedure EncodeFromScanline(Bitmap: TObject;
      ScanLineCallback: TScanLineCallback); override;
  end;

  TPngNonInterlacedGrayscale1bitEncoder = class(TCustomPngNonInterlacedEncoder)
  protected
    procedure TransferData(Source: PColor32; Destination: Pointer); override;
  end;

  TPngNonInterlacedGrayscale2bitEncoder = class(TCustomPngNonInterlacedEncoder)
  protected
    procedure TransferData(Source: PColor32; Destination: Pointer); override;
  end;

  TPngNonInterlacedGrayscale4bitEncoder = class(TCustomPngNonInterlacedEncoder)
  protected
    procedure TransferData(Source: PColor32; Destination: Pointer); override;
  end;

  TPngNonInterlacedGrayscale8bitEncoder = class(TCustomPngNonInterlacedEncoder)
  protected
    procedure TransferData(Source: PColor32; Destination: Pointer); override;
  end;

  TPngNonInterlacedTrueColor8bitEncoder = class(TCustomPngNonInterlacedEncoder)
  protected
    procedure TransferData(Source: PColor32; Destination: Pointer); override;
  end;

  TPngNonInterlacedPalette1bitEncoder = class(TCustomPngNonInterlacedEncoder)
  protected
    procedure TransferData(Source: PColor32; Destination: Pointer); override;
  end;

  TPngNonInterlacedPalette2bitEncoder = class(TCustomPngNonInterlacedEncoder)
  protected
    procedure TransferData(Source: PColor32; Destination: Pointer); override;
  end;

  TPngNonInterlacedPalette4bitEncoder = class(TCustomPngNonInterlacedEncoder)
  protected
    procedure TransferData(Source: PColor32; Destination: Pointer); override;
  end;

  TPngNonInterlacedPalette8bitEncoder = class(TCustomPngNonInterlacedEncoder)
  protected
    procedure TransferData(Source: PColor32; Destination: Pointer); override;
  end;

  TPngNonInterlacedGrayscaleAlpha8bitEncoder = class
    (TCustomPngNonInterlacedEncoder)
  protected
    procedure TransferData(Source: PColor32; Destination: Pointer); override;
  end;

  TPngNonInterlacedTrueColorAlpha8bitEncoder = class
    (TCustomPngNonInterlacedEncoder)
  protected
    procedure TransferData(Source: PColor32; Destination: Pointer); override;
  end;

  TPalette24 = array of TRGB24;

function TPortableNetworkGraphic32.GR32Scanline(Bitmap: TObject;
  Y: Integer): Pointer;
begin
  if Bitmap is TBitmap32 then
    Result := TBitmap32(Bitmap).ScanLine[Y]
  else
    Result := nil;
end;

function TPortableNetworkGraphic32.GR32ScanlineProgress(Bitmap: TObject;
  Y: Integer): Pointer;
begin
  Result := GR32Scanline(Bitmap, Y);
  if FImageHeader.Height > 0 then
    FProgressEvent(Self, 100 * Y / FImageHeader.Height)
  else
    FProgressEvent(Self, 100);
end;

procedure TPortableNetworkGraphic32.DrawToBitmap32(Bitmap32: TCustomBitmap32);
var
  DecoderClass: TCustomPngDecoderClass;
  DataStream: TMemoryStream;
begin
  DataStream := TMemoryStream.Create;
  try
    
    DecompressImageDataToStream(DataStream);
    
    DataStream.Seek(0, soFromBeginning);

    case ImageHeader.InterlaceMethod of
      imNone:
        case ImageHeader.ColorType of
          ctGrayscale:
            case ImageHeader.BitDepth of
              1:
                DecoderClass := TPngNonInterlacedGrayscale1bitDecoder;
              2:
                DecoderClass := TPngNonInterlacedGrayscale2bitDecoder;
              4:
                DecoderClass := TPngNonInterlacedGrayscale4bitDecoder;
              8:
                DecoderClass := TPngNonInterlacedGrayscale8bitDecoder;
              16:
                DecoderClass := TPngNonInterlacedGrayscale16bitDecoder;
            else
              raise EPngError.Create(RCStrUnsupportedFormat);
            end;
          ctTrueColor:
            case ImageHeader.BitDepth of
              8:
                DecoderClass := TPngNonInterlacedTrueColor8bitDecoder;
              16:
                DecoderClass := TPngNonInterlacedTrueColor16bitDecoder;
            else
              raise EPngError.Create(RCStrUnsupportedFormat);
            end;
          ctIndexedColor:
            case ImageHeader.BitDepth of
              1, 2, 4:
                DecoderClass := TPngNonInterlacedPaletteDecoder;
              8:
                DecoderClass := TPngNonInterlacedPalette8bitDecoder;
            else
              raise EPngError.Create(RCStrUnsupportedFormat);
            end;
          ctGrayscaleAlpha:
            case ImageHeader.BitDepth of
              8:
                DecoderClass := TPngNonInterlacedGrayscaleAlpha8bitDecoder;
              16:
                DecoderClass := TPngNonInterlacedGrayscaleAlpha16bitDecoder;
            else
              raise EPngError.Create(RCStrUnsupportedFormat);
            end;
          ctTrueColorAlpha:
            case ImageHeader.BitDepth of
              8:
                DecoderClass := TPngNonInterlacedTrueColorAlpha8bitDecoder;
              16:
                DecoderClass := TPngNonInterlacedTrueColorAlpha16bitDecoder;
            else
              raise EPngError.Create(RCStrUnsupportedFormat);
            end;
        else
          raise EPngError.Create(RCStrUnsupportedFormat);
        end;
      imAdam7:
        case ImageHeader.ColorType of
          ctGrayscale:
            case ImageHeader.BitDepth of
              1:
                DecoderClass := TPngAdam7Grayscale1bitDecoder;
              2:
                DecoderClass := TPngAdam7Grayscale2bitDecoder;
              4:
                DecoderClass := TPngAdam7Grayscale4bitDecoder;
              8:
                DecoderClass := TPngAdam7Grayscale8bitDecoder;
              16:
                DecoderClass := TPngAdam7Grayscale16bitDecoder;
            else
              raise EPngError.Create(RCStrUnsupportedFormat);
            end;
          ctTrueColor:
            case ImageHeader.BitDepth of
              8:
                DecoderClass := TPngAdam7TrueColor8bitDecoder;
              16:
                DecoderClass := TPngAdam7TrueColor16bitDecoder;
            else
              raise EPngError.Create(RCStrUnsupportedFormat);
            end;
          ctIndexedColor:
            case ImageHeader.BitDepth of
              1:
                DecoderClass := TPngAdam7Palette1bitDecoder;
              2:
                DecoderClass := TPngAdam7Palette2bitDecoder;
              4:
                DecoderClass := TPngAdam7Palette4bitDecoder;
              8:
                DecoderClass := TPngAdam7Palette8bitDecoder;
            else
              raise EPngError.Create(RCStrUnsupportedFormat);
            end;
          ctGrayscaleAlpha:
            case ImageHeader.BitDepth of
              8:
                DecoderClass := TPngAdam7GrayscaleAlpha8bitDecoder;
              16:
                DecoderClass := TPngAdam7GrayscaleAlpha16bitDecoder;
            else
              raise EPngError.Create(RCStrUnsupportedFormat);
            end;
          ctTrueColorAlpha:
            case ImageHeader.BitDepth of
              8:
                DecoderClass := TPngAdam7TrueColorAlpha8bitDecoder;
              16:
                DecoderClass := TPngAdam7TrueColorAlpha16bitDecoder;
            else
              raise EPngError.Create(RCStrUnsupportedFormat);
            end;
        else
          raise EPngError.Create(RCStrUnsupportedFormat);
        end;
    else
      raise EPngError.Create(RCStrUnsupportedFormat);
    end;

    with DecoderClass.Create(DataStream, FImageHeader, FGammaChunk,
      FPaletteChunk) do
      try
        if Assigned(FProgressEvent) then
          DecodeToScanline(Bitmap32, GR32ScanlineProgress)
        else
          DecodeToScanline(Bitmap32, GR32Scanline);
      finally
        Free;
      end;
  finally
    FreeAndNil(DataStream);
  end;
end;

function ColorIndexInPalette(Color: TColor32; Palette: TPalette24): Integer;
begin
  for Result := 0 to Length(Palette) - 1 do
    if (TColor32Entry(Color).R = Palette[Result].R) and
      (TColor32Entry(Color).G = Palette[Result].G) and
      (TColor32Entry(Color).B = Palette[Result].B) then
      Exit;
  Result := -1;
end;

procedure TPortableNetworkGraphic32.AssignPropertiesFromBitmap32
  (Bitmap32: TCustomBitmap32);
var
  Index: Integer;
  IsAlpha: Boolean;
  IsGrayScale: Boolean;
  IsPalette: Boolean;
  Color: TColor32;
  TempPalette: TPalette24;
  TempAlpha: Byte;
begin
  with Bitmap32 do
  begin
    
    ImageHeader.Width := Width;
    ImageHeader.Height := Height;
    ImageHeader.CompressionMethod := 0;
    ImageHeader.InterlaceMethod := imNone;
    
    SetLength(TempPalette, 0);
    IsGrayScale := True;
    IsPalette := True;
    IsAlpha := False;
    TempAlpha := 0;
    
    for Index := 0 to Width * Height - 1 do
    begin
      Color := Bits[Index];
      
      if Length(TempPalette) = 0 then
      begin
        IsAlpha := TColor32Entry(Color).A < 255;
        
        if IsAlpha then
          TempAlpha := TColor32Entry(Color).A;

        SetLength(TempPalette, 1);
        TempPalette[0].R := TColor32Entry(Color).R;
        TempPalette[0].G := TColor32Entry(Color).G;
        TempPalette[0].B := TColor32Entry(Color).B;
        IsGrayScale := (TColor32Entry(Color).R = TColor32Entry(Color).G) and
          (TColor32Entry(Color).B = TColor32Entry(Color).G);
      end
      else
      begin
        
        if (TColor32Entry(Color).A < 255) then
        begin
          if IsAlpha then
            if IsPalette and (TempAlpha <> TColor32Entry(Color).A) then
              IsPalette := False
            else
            else
              TempAlpha := TColor32Entry(Color).A;

          IsAlpha := True;
        end;
        if ColorIndexInPalette(Color, TempPalette) < 0 then
        begin
          if IsPalette then
            if (Length(TempPalette) < 256) then
            begin
              SetLength(TempPalette, Length(TempPalette) + 1);
              TempPalette[Length(TempPalette) - 1].R := TColor32Entry(Color).R;
              TempPalette[Length(TempPalette) - 1].G := TColor32Entry(Color).G;
              TempPalette[Length(TempPalette) - 1].B := TColor32Entry(Color).B;
              if IsGrayScale and not
                ((TColor32Entry(Color).R = TColor32Entry(Color).G) and
                  (TColor32Entry(Color).B = TColor32Entry(Color).G)) then
                IsGrayScale := False;
            end
            else
              IsPalette := False
            else if not((TColor32Entry(Color).R = TColor32Entry(Color).G) and
                (TColor32Entry(Color).B = TColor32Entry(Color).G)) then
              IsGrayScale := False;
        end;
      end;

      if IsAlpha and (not IsPalette) and (not IsGrayScale) then
        Break;
    end;
    
    with ImageHeader do
      if IsGrayScale then
        if IsAlpha then
        begin
          ColorType := ctGrayscaleAlpha;
          BitDepth := 8;
        end
        else
        begin
          ColorType := ctIndexedColor; 
          if Length(TempPalette) <= 2 then
            BitDepth := 1
          else if Length(TempPalette) <= 4 then
            BitDepth := 2
          else if Length(TempPalette) <= 16 then
            BitDepth := 4
          else
            BitDepth := 8;
        end
        else if IsPalette then
        begin
          ColorType := ctIndexedColor;
          if Length(TempPalette) <= 2 then
            BitDepth := 1
          else if Length(TempPalette) <= 4 then
            BitDepth := 2
          else if Length(TempPalette) <= 16 then
            BitDepth := 4
          else
            BitDepth := 8;
        end
        else if IsAlpha then
        begin
          ColorType := ctTrueColorAlpha;
          BitDepth := 8;
        end
        else
        begin
          ColorType := ctTrueColor;
          BitDepth := 8;
        end;
    
    if ImageHeader.HasPalette then
    begin
      Assert(Length(TempPalette) <= 256);

      if not Assigned(FPaletteChunk) then
        FPaletteChunk := TChunkPngPalette.Create(ImageHeader);

      FPaletteChunk.Count := Length(TempPalette);
      for Index := 0 to Length(TempPalette) - 1 do
        FPaletteChunk.PaletteEntry[Index] := TempPalette[Index];
    end;
{$IFDEF StoreGamma}
    
    if not Assigned(FGammaChunk) then
      FGammaChunk := TChunkPngGamma.Create(ImageHeader);
    FGammaChunk.GammaAsSingle := 1;
{$ELSE}
    
    if Assigned(FGammaChunk) then
      FreeAndNil(FGammaChunk);
{$ENDIF}
  end;
end;

procedure TPortableNetworkGraphic32.Assign(Source: TPersistent);
var
  EncoderClass: TCustomPngEncoderClass;
  DataStream: TMemoryStream;
begin
  if Source is TCustomBitmap32 then
    with TCustomBitmap32(Source) do
    begin
      
      AssignPropertiesFromBitmap32(TCustomBitmap32(Source));

      case ImageHeader.ColorType of
        ctGrayscale:
          case ImageHeader.BitDepth of
            1:
              EncoderClass := TPngNonInterlacedGrayscale1bitEncoder;
            2:
              EncoderClass := TPngNonInterlacedGrayscale2bitEncoder;
            4:
              EncoderClass := TPngNonInterlacedGrayscale4bitEncoder;
            8:
              EncoderClass := TPngNonInterlacedGrayscale8bitEncoder;
          else
            raise EPngError.Create(RCStrUnsupportedFormat);
          end;
        ctTrueColor:
          EncoderClass := TPngNonInterlacedTrueColor8bitEncoder;
        ctIndexedColor:
          case ImageHeader.BitDepth of
            1:
              EncoderClass := TPngNonInterlacedPalette1bitEncoder;
            2:
              EncoderClass := TPngNonInterlacedPalette2bitEncoder;
            4:
              EncoderClass := TPngNonInterlacedPalette4bitEncoder;
            8:
              EncoderClass := TPngNonInterlacedPalette8bitEncoder;
          else
            raise EPngError.Create(RCStrUnsupportedFormat);
          end;
        ctGrayscaleAlpha:
          EncoderClass := TPngNonInterlacedGrayscaleAlpha8bitEncoder;
        ctTrueColorAlpha:
          EncoderClass := TPngNonInterlacedTrueColorAlpha8bitEncoder;
      else
        raise EPngError.Create(RCStrUnsupportedFormat);
      end;

      DataStream := TMemoryStream.Create;
      with DataStream do
        try
          with EncoderClass.Create(DataStream, FImageHeader, FGammaChunk,
            FPaletteChunk) do
            try
              if Assigned(FProgressEvent) then
                EncodeFromScanline(TCustomBitmap32(Source),
                  GR32ScanlineProgress)
              else
                EncodeFromScanline(TCustomBitmap32(Source), GR32Scanline);
            finally
              Free;
            end;
          
          DataStream.Seek(0, soFromBeginning);
          
          CompressImageDataFromStream(DataStream);
        finally
          FreeAndNil(DataStream);
        end;
    end
    else
      inherited;
end;

procedure TPortableNetworkGraphic32.AssignTo(Dest: TPersistent);
begin
  if Dest is TCustomBitmap32 then
  begin
    TCustomBitmap32(Dest).SetSize(ImageHeader.Width, ImageHeader.Height);
    DrawToBitmap32(TCustomBitmap32(Dest));
  end
  else
    inherited;
end;

const
  CRowStart: array [0 .. 6] of Integer = (0, 0, 4, 0, 2, 0, 1);
  CColumnStart: array [0 .. 6] of Integer = (0, 4, 0, 2, 0, 1, 0);
  CRowIncrement: array [0 .. 6] of Integer = (8, 8, 8, 4, 4, 2, 2);
  CColumnIncrement: array [0 .. 6] of Integer = (8, 8, 4, 4, 2, 2, 1);
  CGrayScaleTable1Bit: array [0 .. 1] of Byte = (0, $FF);
  CGrayScaleTable2Bit: array [0 .. 3] of Byte = (0, $55, $AA, $FF);
  CGrayScaleTable4Bit: array [0 .. 15] of Byte = (0, $11, $22, $33, $44, $55,
    $66, $77, $88, $99, $AA, $BB, $CC, $DD, $EE, $FF);

constructor TCustomPngNonInterlacedDecoder.Create(Stream: TStream;
  Header: TChunkPngImageHeader; Gamma: TChunkPngGamma = nil;
  Palette: TChunkPngPalette = nil);
begin
  inherited;
  FBytesPerRow := FHeader.BytesPerRow;
  FRowByteSize := FBytesPerRow + 1;
  GetMem(FRowBuffer[0], FRowByteSize);
  GetMem(FRowBuffer[1], FRowByteSize);
end;

destructor TCustomPngNonInterlacedDecoder.Destroy;
begin
  Dispose(FRowBuffer[0]);
  Dispose(FRowBuffer[1]);
  inherited;
end;

procedure TCustomPngNonInterlacedDecoder.DecodeToScanline(Bitmap: TObject;
  ScanLineCallback: TScanLineCallback);
var
  Index: Integer;
  CurrentRow: Integer;
  PixelByteSize: Integer;
  UsedFilters: TAvailableAdaptiveFilterMethods;
begin
  
  CurrentRow := 0;
  UsedFilters := [];
  PixelByteSize := FHeader.PixelByteSize;

  FillChar(FRowBuffer[1 - CurrentRow]^[0], FRowByteSize, 0);

  for Index := 0 to FHeader.Height - 1 do
  begin
    
    if FStream.Read(FRowBuffer[CurrentRow][0], FRowByteSize)
      <> FRowByteSize then
      raise EPngError.Create(RCStrDataIncomplete);
    
    DecodeFilterRow(TAdaptiveFilterMethod(FRowBuffer[CurrentRow]^[0]),
      FRowBuffer[CurrentRow], FRowBuffer[1 - CurrentRow], FBytesPerRow,
      PixelByteSize);
    
    case TAdaptiveFilterMethod(FRowBuffer[CurrentRow]) of
      afmSub:
        UsedFilters := UsedFilters + [aafmSub];
      afmUp:
        UsedFilters := UsedFilters + [aafmUp];
      afmAverage:
        UsedFilters := UsedFilters + [aafmAverage];
      afmPaeth:
        UsedFilters := UsedFilters + [aafmPaeth];
    end;
    
    TransferData(@FRowBuffer[CurrentRow][1], ScanLineCallback(Bitmap, Index));
    
    CurrentRow := 1 - CurrentRow;
  end;
  FHeader.AdaptiveFilterMethods := UsedFilters;
end;

procedure TPngNonInterlacedGrayscale1bitDecoder.TransferData(Source: Pointer;
  Destination: PColor32);
var
  Index: Integer;
  Src: PByte absolute Source;
  BitIndex: Byte;
begin
  BitIndex := 8;

  for Index := 0 to FHeader.Width - 1 do
  begin
    Dec(BitIndex);
    PColor32Entry(Destination)^.R := FMappingTable
      [CGrayScaleTable1Bit[(Src^ shr BitIndex) and $1]];
    PColor32Entry(Destination)^.G := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.B := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.A := 255;
    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Src);
    end;
    Inc(Destination);
  end;
end;

procedure TPngNonInterlacedGrayscale2bitDecoder.TransferData(Source: Pointer;
  Destination: PColor32);
var
  Index: Integer;
  Src: PByte absolute Source;
  BitIndex: Byte;
begin
  BitIndex := 8;

  for Index := 0 to FHeader.Width - 1 do
  begin
    Dec(BitIndex, 2);
    PColor32Entry(Destination)^.R := FMappingTable
      [CGrayScaleTable2Bit[(Src^ shr BitIndex) and $3]];
    PColor32Entry(Destination)^.G := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.B := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.A := 255;
    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Src);
    end;
    Inc(Destination);
  end;
end;

procedure TPngNonInterlacedGrayscale4bitDecoder.TransferData(Source: Pointer;
  Destination: PColor32);
var
  Index: Integer;
  Src: PByte absolute Source;
  BitIndex: Byte;
begin
  BitIndex := 8;

  for Index := 0 to FHeader.Width - 1 do
  begin
    Dec(BitIndex, 4);
    PColor32Entry(Destination)^.R := FMappingTable
      [CGrayScaleTable4Bit[(Src^ shr BitIndex) and $F]];
    PColor32Entry(Destination)^.G := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.B := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.A := 255;
    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Src);
    end;
    Inc(Destination);
  end;
end;

procedure TPngNonInterlacedGrayscale8bitDecoder.TransferData(Source: Pointer;
  Destination: PColor32);
var
  Index: Integer;
  Src: PByte absolute Source;
begin
  for Index := 0 to FHeader.Width - 1 do
  begin
    PColor32Entry(Destination)^.R := FMappingTable[Src^];
    Inc(Src);
    PColor32Entry(Destination)^.G := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.B := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.A := 255;
    Inc(Destination);
  end;
end;

procedure TPngNonInterlacedGrayscale16bitDecoder.TransferData(Source: Pointer;
  Destination: PColor32);
var
  Index: Integer;
  Src: PWord absolute Source;
begin
  for Index := 0 to FHeader.Width - 1 do
  begin
    PColor32Entry(Destination)^.R := FMappingTable[Src^ and $FF];
    Inc(Src);
    PColor32Entry(Destination)^.G := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.B := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.A := 255;
    Inc(Destination);
  end;
end;

procedure TPngNonInterlacedTrueColor8bitDecoder.TransferData(Source: Pointer;
  Destination: PColor32);
var
  Index: Integer;
  Src: PRGB24 absolute Source;
begin
  for Index := 0 to FHeader.Width - 1 do
  begin
    PColor32Entry(Destination)^.R := FMappingTable[Src^.R];
    PColor32Entry(Destination)^.G := FMappingTable[Src^.G];
    PColor32Entry(Destination)^.B := FMappingTable[Src^.B];
    PColor32Entry(Destination)^.A := 255;
    Inc(Src);
    Inc(Destination);
  end;
end;

procedure TPngNonInterlacedTrueColor16bitDecoder.TransferData(Source: Pointer;
  Destination: PColor32);
var
  Index: Integer;
  Src: PRGB24Word absolute Source;
begin
  for Index := 0 to FHeader.Width - 1 do
  begin
    PColor32Entry(Destination)^.R := FMappingTable[Src^.R and $FF];
    PColor32Entry(Destination)^.G := FMappingTable[Src^.G and $FF];
    PColor32Entry(Destination)^.B := FMappingTable[Src^.B and $FF];
    PColor32Entry(Destination)^.A := 255;
    Inc(Src);
    Inc(Destination);
  end;
end;

procedure TPngNonInterlacedPaletteDecoder.TransferData(Source: Pointer;
  Destination: PColor32);
var
  Index: Integer;
  Src: PByte absolute Source;
  Palette: PRGB24Array;
  Color: TRGB24;
  BitIndex: Byte;
  BitMask: Byte;
  BitDepth: Byte;
begin
  BitIndex := 8;
  BitDepth := FHeader.BitDepth;
  BitMask := (1 shl BitDepth) - 1;
  Palette := PRGB24Array(FMappingTable);

  for Index := 0 to FHeader.Width - 1 do
  begin
    Dec(BitIndex, BitDepth);
    Color := Palette[(Src^ shr BitIndex) and BitMask];
    PColor32Entry(Destination)^.R := Color.R;
    PColor32Entry(Destination)^.G := Color.G;
    PColor32Entry(Destination)^.B := Color.B;
    PColor32Entry(Destination)^.A := 255;
    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Src);
    end;
    Inc(Destination);
  end;
end;

procedure TPngNonInterlacedPalette8bitDecoder.TransferData(Source: Pointer;
  Destination: PColor32);
var
  Index: Integer;
  Src: PByte absolute Source;
  Palette: PRGB24Array;
begin
  Palette := PRGB24Array(FMappingTable);
  for Index := 0 to FHeader.Width - 1 do
  begin
    PColor32Entry(Destination)^.R := Palette[Src^].R;
    PColor32Entry(Destination)^.G := Palette[Src^].G;
    PColor32Entry(Destination)^.B := Palette[Src^].B;
    PColor32Entry(Destination)^.A := 255;
    Inc(Src);
    Inc(Destination);
  end;
end;

procedure TPngNonInterlacedGrayscaleAlpha8bitDecoder.TransferData
  (Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  Src: PByte absolute Source;
begin
  for Index := 0 to FHeader.Width - 1 do
  begin
    PColor32Entry(Destination)^.R := FMappingTable[Src^];
    Inc(Src);
    PColor32Entry(Destination)^.G := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.B := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.A := Src^;
    Inc(Src);
    Inc(Destination);
  end;
end;

procedure TPngNonInterlacedGrayscaleAlpha16bitDecoder.TransferData
  (Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  Src: PWord absolute Source;
begin
  for Index := 0 to FHeader.Width - 1 do
  begin
    PColor32Entry(Destination)^.R := FMappingTable[Src^ and $FF];
    Inc(Src);
    PColor32Entry(Destination)^.G := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.B := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.A := Src^ and $FF;
    Inc(Src);
    Inc(Destination);
  end;
end;

procedure TPngNonInterlacedTrueColorAlpha8bitDecoder.TransferData
  (Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  Src: PRGB32 absolute Source;
begin
  for Index := 0 to FHeader.Width - 1 do
  begin
    PColor32Entry(Destination)^.R := FMappingTable[Src^.R];
    PColor32Entry(Destination)^.G := FMappingTable[Src^.G];
    PColor32Entry(Destination)^.B := FMappingTable[Src^.B];
    PColor32Entry(Destination)^.A := Src^.A;
    Inc(Src);
    Inc(Destination);
  end;
end;

procedure TPngNonInterlacedTrueColorAlpha16bitDecoder.TransferData
  (Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  Src: PRGB32Word absolute Source;
begin
  for Index := 0 to FHeader.Width - 1 do
  begin
    PColor32Entry(Destination)^.R := FMappingTable[Src^.R and $FF];
    PColor32Entry(Destination)^.G := FMappingTable[Src^.G and $FF];
    PColor32Entry(Destination)^.B := FMappingTable[Src^.B and $FF];
    PColor32Entry(Destination)^.A := Src^.A and $FF;
    Inc(Src);
    Inc(Destination);
  end;
end;

constructor TCustomPngAdam7Decoder.Create(Stream: TStream;
  Header: TChunkPngImageHeader; Gamma: TChunkPngGamma = nil;
  Palette: TChunkPngPalette = nil);
begin
  inherited;
  
  GetMem(FRowBuffer[0], FHeader.BytesPerRow + 1);
  GetMem(FRowBuffer[1], FHeader.BytesPerRow + 1);
end;

destructor TCustomPngAdam7Decoder.Destroy;
begin
  Dispose(FRowBuffer[0]);
  Dispose(FRowBuffer[1]);
  inherited;
end;

procedure TCustomPngAdam7Decoder.DecodeToScanline(Bitmap: TObject;
  ScanLineCallback: TScanLineCallback);
var
  CurrentRow: Integer;
  RowByteSize: Integer;
  PixelPerRow: Integer;
  PixelByteSize: Integer;
  CurrentPass: Integer;
  PassRow: Integer;
  UsedFilters: TAvailableAdaptiveFilterMethods;
begin
  
  CurrentRow := 0;
  RowByteSize := 0;
  UsedFilters := [];
  PixelByteSize := FHeader.PixelByteSize;
  
  for CurrentPass := 0 to 6 do
  begin
    
    PixelPerRow := (FHeader.Width - CColumnStart[CurrentPass] + CColumnIncrement
        [CurrentPass] - 1) div CColumnIncrement[CurrentPass];

    with FHeader do
      case ColorType of
        ctGrayscale, ctIndexedColor:
          RowByteSize := (PixelPerRow * BitDepth + 7) div 8;
        ctTrueColor:
          RowByteSize := (PixelPerRow * BitDepth * 3) div 8;
        ctGrayscaleAlpha:
          RowByteSize := (PixelPerRow * BitDepth * 2) div 8;
        ctTrueColorAlpha:
          RowByteSize := (PixelPerRow * BitDepth * 4) div 8;
      else
        Continue;
      end;

    PassRow := CRowStart[CurrentPass];
    
    FillChar(FRowBuffer[1 - CurrentRow]^[0], RowByteSize, 0);
    
    while PassRow < FHeader.Height do
    begin
      
      if FStream.Read(FRowBuffer[CurrentRow][0], RowByteSize + 1) <>
        (RowByteSize + 1) then
        raise EPngError.Create(RCStrDataIncomplete);

      DecodeFilterRow(TAdaptiveFilterMethod(FRowBuffer[CurrentRow]^[0]),
        FRowBuffer[CurrentRow], FRowBuffer[1 - CurrentRow], RowByteSize,
        PixelByteSize);
      
      case TAdaptiveFilterMethod(FRowBuffer[CurrentRow]) of
        afmSub:
          UsedFilters := UsedFilters + [aafmSub];
        afmUp:
          UsedFilters := UsedFilters + [aafmUp];
        afmAverage:
          UsedFilters := UsedFilters + [aafmAverage];
        afmPaeth:
          UsedFilters := UsedFilters + [aafmPaeth];
      end;
      
      TransferData(CurrentPass, @FRowBuffer[CurrentRow][1],
        ScanLineCallback(Bitmap, PassRow));
      
      Inc(PassRow, CRowIncrement[CurrentPass]);
      CurrentRow := 1 - CurrentRow;
    end;
  end;
  FHeader.AdaptiveFilterMethods := UsedFilters;
end;

procedure TPngAdam7Grayscale1bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  BitIndex: Integer;
  Src: PByte absolute Source;
begin
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  BitIndex := 8;
  repeat
    Dec(BitIndex);
    PColor32Entry(Destination)^.R := FMappingTable
      [CGrayScaleTable1Bit[(Src^ shr BitIndex) and $1]];
    PColor32Entry(Destination)^.G := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.B := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.A := 255;

    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Src);
    end;

    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

procedure TPngAdam7Grayscale2bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  BitIndex: Integer;
  Src: PByte absolute Source;
begin
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  BitIndex := 8;
  repeat
    Dec(BitIndex, 2);
    PColor32Entry(Destination)^.R := FMappingTable
      [CGrayScaleTable2Bit[((Src^ shr BitIndex) and $3)]];
    PColor32Entry(Destination)^.G := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.B := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.A := 255;

    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Src);
    end;

    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

procedure TPngAdam7Grayscale4bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  BitIndex: Integer;
  Src: PByte absolute Source;
begin
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  BitIndex := 8;
  repeat
    Dec(BitIndex, 4);
    PColor32Entry(Destination)^.R := FMappingTable
      [CGrayScaleTable4Bit[((Src^ shr BitIndex) and $F)]];
    PColor32Entry(Destination)^.G := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.B := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.A := 255;

    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Src);
    end;

    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

procedure TPngAdam7Grayscale8bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  Src: PByte absolute Source;
begin
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  repeat
    PColor32Entry(Destination)^.R := FMappingTable[Src^];
    Inc(Src);
    PColor32Entry(Destination)^.G := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.B := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.A := 255;

    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

procedure TPngAdam7Grayscale16bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  Src: PWord absolute Source;
begin
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  repeat
    PColor32Entry(Destination)^.R := FMappingTable[Src^ and $FF];
    Inc(Src);
    PColor32Entry(Destination)^.G := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.B := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.A := 255;

    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

procedure TPngAdam7TrueColor8bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  Src: PRGB24 absolute Source;
begin
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  repeat
    PColor32Entry(Destination)^.R := FMappingTable[Src^.R];
    PColor32Entry(Destination)^.G := FMappingTable[Src^.G];
    PColor32Entry(Destination)^.B := FMappingTable[Src^.B];
    PColor32Entry(Destination)^.A := 255;

    Inc(Src);
    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

procedure TPngAdam7TrueColor16bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  Src: PRGB24Word absolute Source;
begin
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  repeat
    PColor32Entry(Destination)^.R := FMappingTable[Src^.R and $FF];
    PColor32Entry(Destination)^.G := FMappingTable[Src^.G and $FF];
    PColor32Entry(Destination)^.B := FMappingTable[Src^.B and $FF];
    PColor32Entry(Destination)^.A := 255;

    Inc(Src);
    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

procedure TPngAdam7Palette1bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  BitIndex: Integer;
  Src: PByte absolute Source;
  Palette: PRGB24Array;
  Color: TRGB24;
begin
  BitIndex := 8;
  Palette := PRGB24Array(FMappingTable);
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  repeat
    Dec(BitIndex);
    Color := Palette[(Src^ shr BitIndex) and $1];
    PColor32Entry(Destination)^.R := Color.R;
    PColor32Entry(Destination)^.G := Color.G;
    PColor32Entry(Destination)^.B := Color.B;
    PColor32Entry(Destination)^.A := 255;

    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Src);
    end;
    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

procedure TPngAdam7Palette2bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  BitIndex: Integer;
  Src: PByte absolute Source;
  Palette: PRGB24Array;
  Color: TRGB24;
begin
  BitIndex := 8;
  Palette := PRGB24Array(FMappingTable);
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  repeat
    Dec(BitIndex, 2);
    Color := Palette[(Src^ shr BitIndex) and $3];
    PColor32Entry(Destination)^.R := Color.R;
    PColor32Entry(Destination)^.G := Color.G;
    PColor32Entry(Destination)^.B := Color.B;
    PColor32Entry(Destination)^.A := 255;

    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Src);
    end;
    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

procedure TPngAdam7Palette4bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  BitIndex: Integer;
  Src: PByte absolute Source;
  Palette: PRGB24Array;
  Color: TRGB24;
begin
  BitIndex := 8;
  Palette := PRGB24Array(FMappingTable);
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  repeat
    Dec(BitIndex, 4);
    Color := Palette[(Src^ shr BitIndex) and $F];
    PColor32Entry(Destination)^.R := Color.R;
    PColor32Entry(Destination)^.G := Color.G;
    PColor32Entry(Destination)^.B := Color.B;
    PColor32Entry(Destination)^.A := 255;

    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Src);
    end;
    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

procedure TPngAdam7Palette8bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  Src: PByte absolute Source;
  Palette: PRGB24Array;
begin
  Palette := PRGB24Array(FMappingTable);
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  repeat
    PColor32Entry(Destination)^.R := Palette[Src^].R;
    PColor32Entry(Destination)^.G := Palette[Src^].G;
    PColor32Entry(Destination)^.B := Palette[Src^].B;
    PColor32Entry(Destination)^.A := 255;

    Inc(Src);
    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

procedure TPngAdam7GrayscaleAlpha8bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  Src: PByte absolute Source;
begin
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  repeat
    PColor32Entry(Destination)^.R := FMappingTable[Src^];
    Inc(Src);
    PColor32Entry(Destination)^.G := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.B := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.A := Src^;
    Inc(Src);

    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

procedure TPngAdam7GrayscaleAlpha16bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  Src: PWord absolute Source;
begin
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  repeat
    PColor32Entry(Destination)^.R := FMappingTable[Src^ and $FF];
    Inc(Src);
    PColor32Entry(Destination)^.G := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.B := PColor32Entry(Destination)^.R;
    PColor32Entry(Destination)^.A := Src^ and $FF;
    Inc(Src);

    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

procedure TPngAdam7TrueColorAlpha8bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  SrcPtr: PRGB32 absolute Source;
begin
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  repeat
    PColor32Entry(Destination)^.R := FMappingTable[SrcPtr^.R];
    PColor32Entry(Destination)^.G := FMappingTable[SrcPtr^.G];
    PColor32Entry(Destination)^.B := FMappingTable[SrcPtr^.B];
    PColor32Entry(Destination)^.A := SrcPtr^.A;

    Inc(SrcPtr);
    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

procedure TPngAdam7TrueColorAlpha16bitDecoder.TransferData(const Pass: Byte;
  Source: Pointer; Destination: PColor32);
var
  Index: Integer;
  SrcPtr: PRGB32Word absolute Source;
begin
  Index := CColumnStart[Pass];
  Inc(Destination, Index);
  repeat
    PColor32Entry(Destination)^.R := FMappingTable[SrcPtr^.R and $FF];
    PColor32Entry(Destination)^.G := FMappingTable[SrcPtr^.G and $FF];
    PColor32Entry(Destination)^.B := FMappingTable[SrcPtr^.B and $FF];
    PColor32Entry(Destination)^.A := SrcPtr^.A and $FF;

    Inc(SrcPtr);
    Inc(Destination, CColumnIncrement[Pass]);
    Inc(Index, CColumnIncrement[Pass]);
  until Index >= FHeader.Width;
end;

constructor TCustomPngNonInterlacedEncoder.Create(Stream: TStream;
  Header: TChunkPngImageHeader; Gamma: TChunkPngGamma;
  Palette: TChunkPngPalette);
begin
  inherited;
  FBytesPerRow := FHeader.BytesPerRow;
  FRowByteSize := FBytesPerRow + 1;
  GetMem(FRowBuffer[0], FRowByteSize);
  GetMem(FRowBuffer[1], FRowByteSize);
end;

destructor TCustomPngNonInterlacedEncoder.Destroy;
begin
  Dispose(FRowBuffer[0]);
  Dispose(FRowBuffer[1]);
  inherited;
end;

function TCustomPngNonInterlacedEncoder.ColorInPalette(Color: TColor32)
  : Integer;
var
  Color24: TRGB24;
begin
  for Result := 0 to FPalette.Count - 1 do
  begin
    Color24 := FPalette.PaletteEntry[Result];
    if (TColor32Entry(Color).R = Color24.R) and
      (TColor32Entry(Color).G = Color24.G) and
      (TColor32Entry(Color).B = Color24.B) then
      Exit;
  end;
  Result := -1;
end;

procedure TCustomPngNonInterlacedEncoder.EncodeFromScanline(Bitmap: TObject;
  ScanLineCallback: TScanLineCallback);
var
  Index: Integer;
  CurrentRow: Integer;
  OutputRow: PByteArray;
  TempBuffer: PByteArray;
begin
  
  CurrentRow := 0;
  FillChar(FRowBuffer[1 - CurrentRow]^[0], FRowByteSize, 0);
  
  if FHeader.ColorType <> ctIndexedColor then
  begin
    Assert(FRowByteSize = FBytesPerRow + 1);
    GetMem(OutputRow, FRowByteSize);
    GetMem(TempBuffer, FRowByteSize);
    try
      for Index := 0 to FHeader.Height - 1 do
      begin
        
        TransferData(ScanLineCallback(Bitmap, Index),
          @FRowBuffer[CurrentRow][1]);
        
        EncodeFilterRow(FRowBuffer[CurrentRow], FRowBuffer[1 - CurrentRow],
          OutputRow, TempBuffer, FBytesPerRow, FHeader.PixelByteSize);
        Assert(OutputRow[0] in [0 .. 4]);
        
        FStream.Write(OutputRow[0], FRowByteSize);
        
        CurrentRow := 1 - CurrentRow;
      end;
    finally
      Dispose(OutputRow);
      Dispose(TempBuffer);
    end;
  end
  else
    for Index := 0 to FHeader.Height - 1 do
    begin
      
      TransferData(ScanLineCallback(Bitmap, Index), @FRowBuffer[CurrentRow][1]);
      
      FRowBuffer[CurrentRow][0] := 0;
      
      FStream.Write(FRowBuffer[CurrentRow][0], FRowByteSize);
      
      CurrentRow := 1 - CurrentRow;
    end;
end;

procedure TPngNonInterlacedGrayscale1bitEncoder.TransferData(Source: PColor32;
  Destination: Pointer);
var
  Index: Integer;
  Dest: PByte absolute Destination;
  BitIndex: Byte;
begin
  BitIndex := 8;

  for Index := 0 to FHeader.Width - 1 do
  begin
    Dec(BitIndex);
    Dest^ := (Dest^ and not($1 shl BitIndex)) or
      (((PColor32Entry(Source)^.R shr 7) and $1) shl BitIndex);

    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Dest);
    end;
    Inc(Source);
  end;
end;

procedure TPngNonInterlacedGrayscale2bitEncoder.TransferData(Source: PColor32;
  Destination: Pointer);
var
  Index: Integer;
  Dest: PByte absolute Destination;
  BitIndex: Byte;
begin
  BitIndex := 8;

  for Index := 0 to FHeader.Width - 1 do
  begin
    Dec(BitIndex, 2);
    Dest^ := (Dest^ and not($3 shl BitIndex)) or
      (((PColor32Entry(Source)^.R shr 6) and $3) shl BitIndex);

    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Dest);
    end;
    Inc(Source);
  end;
end;

procedure TPngNonInterlacedGrayscale4bitEncoder.TransferData(Source: PColor32;
  Destination: Pointer);
var
  Index: Integer;
  Dest: PByte absolute Destination;
  BitIndex: Byte;
begin
  BitIndex := 8;

  for Index := 0 to FHeader.Width - 1 do
  begin
    Dec(BitIndex, 4);
    Dest^ := (Dest^ and not($F shl BitIndex)) or
      (((PColor32Entry(Source)^.R shr 4) and $F) shl BitIndex);

    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Dest);
    end;
    Inc(Source);
  end;
end;

procedure TPngNonInterlacedGrayscale8bitEncoder.TransferData(Source: PColor32;
  Destination: Pointer);
var
  Index: Integer;
  Dest: PByte absolute Destination;
begin
  for Index := 0 to FHeader.Width - 1 do
  begin
    Dest^ := PColor32Entry(Source)^.R;
    Inc(Source);
    Inc(Dest);
  end;
end;

procedure TPngNonInterlacedTrueColor8bitEncoder.TransferData(Source: PColor32;
  Destination: Pointer);
var
  Index: Integer;
  Dest: PRGB24 absolute Destination;
begin
  for Index := 0 to FHeader.Width - 1 do
  begin
    Dest^.R := PColor32Entry(Source)^.R;
    Dest^.G := PColor32Entry(Source)^.G;
    Dest^.B := PColor32Entry(Source)^.B;
    Inc(Source);
    Inc(Dest);
  end;
end;

procedure TPngNonInterlacedPalette1bitEncoder.TransferData(Source: PColor32;
  Destination: Pointer);
var
  Index: Integer;
  Dest: PByte absolute Destination;
  BitIndex: Byte;
begin
  BitIndex := 8;

  for Index := 0 to FHeader.Width - 1 do
  begin
    Dec(BitIndex);
    Dest^ := (Dest^ and not($1 shl BitIndex)) or
      ((ColorInPalette(Source^) and $1) shl BitIndex);

    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Dest);
    end;
    Inc(Source);
  end;
end;

procedure TPngNonInterlacedPalette2bitEncoder.TransferData(Source: PColor32;
  Destination: Pointer);
var
  Index: Integer;
  Dest: PByte absolute Destination;
  BitIndex: Byte;
begin
  BitIndex := 8;

  for Index := 0 to FHeader.Width - 1 do
  begin
    Dec(BitIndex, 2);
    Dest^ := (Dest^ and not($3 shl BitIndex)) or
      ((ColorInPalette(Source^) and $3) shl BitIndex);

    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Dest);
    end;
    Inc(Source);
  end;
end;

procedure TPngNonInterlacedPalette4bitEncoder.TransferData(Source: PColor32;
  Destination: Pointer);
var
  Index: Integer;
  Dest: PByte absolute Destination;
  BitIndex: Byte;
begin
  BitIndex := 8;

  for Index := 0 to FHeader.Width - 1 do
  begin
    Dec(BitIndex, 4);
    Dest^ := (Dest^ and not($F shl BitIndex)) or
      ((ColorInPalette(Source^) and $F) shl BitIndex);

    if BitIndex = 0 then
    begin
      BitIndex := 8;
      Inc(Dest);
    end;
    Inc(Source);
  end;
end;

procedure TPngNonInterlacedPalette8bitEncoder.TransferData(Source: PColor32;
  Destination: Pointer);
var
  Index: Integer;
  Dest: PByte absolute Destination;
begin
  for Index := 0 to FHeader.Width - 1 do
  begin
    Dest^ := ColorInPalette(Source^);
    Inc(Source);
    Inc(Dest);
  end;
end;

procedure TPngNonInterlacedGrayscaleAlpha8bitEncoder.TransferData
  (Source: PColor32; Destination: Pointer);
var
  Index: Integer;
  Dest: PByte absolute Destination;
begin
  for Index := 0 to FHeader.Width - 1 do
  begin
    Dest^ := PColor32Entry(Source)^.R;
    Inc(Dest);
    Dest^ := PColor32Entry(Source)^.A;
    Inc(Dest);
    Inc(Source);
  end;
end;

procedure TPngNonInterlacedTrueColorAlpha8bitEncoder.TransferData
  (Source: PColor32; Destination: Pointer);
var
  Index: Integer;
  Dest: PRGB32 absolute Destination;
begin
  for Index := 0 to FHeader.Width - 1 do
  begin
    Dest^.R := PColor32Entry(Source)^.R;
    Dest^.G := PColor32Entry(Source)^.G;
    Dest^.B := PColor32Entry(Source)^.B;
    Dest^.A := PColor32Entry(Source)^.A;
    Inc(Dest);
    Inc(Source);
  end;
end;

end.
 