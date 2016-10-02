unit Utils;

interface

uses
  System.Types, FMX.Types, FMX.Graphics, FMX.TextLayout, System.Math, System.SysUtils;

const
  cMaxFontSize = 512;

function CalcTextSize(Text: string; Font: TFont; Size: Single = 0): TSizeF;
function FontSizeForBox(Text: string; Font: TFont; Width, Height: Single; MaxFontSize: Single = cMaxFontSize): Integer;
function SecondsToString(Seconds: Integer): string;

implementation

const
  cHour = '÷';
  cMinute = 'ì';
  cSecond = 'ñ';

function CalcTextSize(Text: string; Font: TFont; Size: Single = 0): TSizeF;
var
  TextLayout: TTextLayout;
begin
  TextLayout := TTextLayoutManager.DefaultTextLayout.Create;
  try
    TextLayout.BeginUpdate;
    try
      TextLayout.Text := Text;
      TextLayout.MaxSize := TPointF.Create(9999, 9999);
      TextLayout.Font.Assign(Font);
      if not SameValue(0, Size) then
      begin
        TextLayout.Font.Size := Size;
      end;
      TextLayout.WordWrap := False;
      TextLayout.Trimming := TTextTrimming.None;
      TextLayout.HorizontalAlign := TTextAlign.Leading;
      TextLayout.VerticalAlign := TTextAlign.Leading;
    finally
      TextLayout.EndUpdate;
    end;

    Result.Width := TextLayout.Width;
    Result.Height := TextLayout.Height;
  finally
    TextLayout.Free;
  end;
end;

function FontSizeForBox(Text: string; Font: TFont; Width, Height: Single; MaxFontSize: Single = cMaxFontSize): Integer;
var
  Size, Max, Min, MaxIterations: Integer;
  Current: TSizeF;
begin
  Max := Trunc(MaxFontSize);
  Min := 0;

  MaxIterations := 20;
  repeat
    Size := (Max + Min) div 2;

    Current := CalcTextSize(Text, Font, Size);

    if ((Abs(Width - Current.Width) < 1) and (Width >= Current.Width)) and
      ((Abs(Height - Current.Height) < 1) and (Height >= Current.Height)) then
      break
    else
    if (Width < Current.Width) or (Height < Current.Height) then
      Max := Size
    else
      Min := Size;

    Dec(MaxIterations);
  until MaxIterations = 0;

  Result := Size;
end;

function SecondsToString(Seconds: Integer): string;
var
  n: Integer;
begin
  Result := '';

  if Seconds >= 60 * 60 then
  begin
    n := Seconds div (60 * 60);
    Result := Result + n.toString + cHour + ' ';
  end;

  if Seconds >= 60 then
  begin
    n := (Seconds div 60) mod 60;
    if n <= 9 then
      Result := Result + '0';
    Result := Result + n.toString + cMinute + ' ';
  end;

  n := Seconds mod 60;
  if n <= 9 then
    Result := Result + '0';
  Result := Result + n.toString + cSecond + ' ';
end;

end.
