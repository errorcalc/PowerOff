{****************************************************************************************}
{                                       PowerOff                                         }
{                                   ErrorSoft(c) 2016                                    }
{                                                                                        }
{ This is my first public project using FireMonkey technology.                           }
{ This can be useful utilite or some of the sources, such as FontSizeForBox function.    }
{                                                                                        }
{ Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License }
{                                                                                        }
{****************************************************************************************}
unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.TextLayout,
  WinApi.Windows, WinApi.ShellAPI, System.Math, System.Notification;

type
  TMainForm = class(TForm)
    StyleBook: TStyleBook;
    Label1: TLabel;
    TabControl: TTabControl;
    TabItemSet: TTabItem;
    GridPanelLayout1: TGridPanelLayout;
    Button1: TButton;
    Button2: TButton;
    Button3: TButton;
    Button4: TButton;
    TabItemRun: TTabItem;
    Label2: TLabel;
    Display: TLabel;
    Timer: TTimer;
    Label3: TLabel;
    NotificationCenter: TNotificationCenter;
    procedure GridPanelLayout1Resize(Sender: TObject);
    procedure ButtonSetClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure DisplayResize(Sender: TObject);
  private
    { Private declarations }
    OldTime: DWORD;
    IsUsedNotification: Boolean;
    procedure Test;
    function PowerOff: Boolean;
    procedure ShowNotification;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

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

const
  cMaxFontSize = 512;

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

procedure TMainForm.ButtonSetClick(Sender: TObject);
begin
  OldTime := GetTickCount div 1000 + TControl(Sender).Tag * 60;
  Test;

  TabControl.SetActiveTabWithTransition(TabItemRun, TTabTransition.Slide, TTabTransitionDirection.Normal);
  Timer.Enabled := True;
end;

procedure TMainForm.DisplayResize(Sender: TObject);
begin
  Display.Font.Size := FontSizeForBox('00ч 00м 00с',
    Display.Font, Display.Width, Display.Height, Display.Height);
end;

procedure TMainForm.GridPanelLayout1Resize(Sender: TObject);
var
  Width, Height: Integer;
  Grid: TGridPanelLayout;
begin
//  Grid := TGridPanelLayout(Sender);
//  if Grid.ColumnCollection.Count <> 0 then
//    Width := Trunc(Grid.Width) div Grid.ColumnCollection.Count;
//  if Grid.RowCollection.Count <> 0 then
//    Height := Trunc(Grid.Height) div Grid.RowCollection.Count;
//  Grid.ColumnCollection[Grid.ColumnCollection.Count - 1].Value := Trunc(Grid.Width) - Width * (Grid.ColumnCollection.Count - 1);
//  Grid.RowCollection[Grid.RowCollection.Count - 1].Value := Trunc(Grid.Height) - Height * (Grid.RowCollection.Count - 1);
end;

function TMainForm.PowerOff: Boolean;
var
  TokenHandle: THandle;
  Priv, Prevst: TTokenPrivileges;
  rl: DWORD;
begin
  if OpenProcessToken(GetCurrentProcess, TOKEN_ADJUST_PRIVILEGES or TOKEN_QUERY, TokenHandle) then
  begin
    if LookupPrivilegeValue(nil, 'SeShutdownPrivilege', Priv.Privileges[0].Luid) then
    begin
      Priv.PrivilegeCount := 1;
      Priv.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED;

      AdjustTokenPrivileges(TokenHandle, False, Priv, SizeOf(Prevst), Prevst, rl);
    end;
  end;

  Result := ExitWindowsEx(EWX_SHUTDOWN or EWX_POWEROFF, 0);
end;

procedure TMainForm.ShowNotification;
var
  Notification: TNotification;
begin
  Notification := NotificationCenter.CreateNotification;
  try
    Notification.Title := 'PowerOff';
    Notification.AlertBody := 'Внимание:'#13'Через 5 минут произойдет автоматиеское выключение компьютера';
    NotificationCenter.PresentNotification(Notification);
  finally
    Notification.Free;
  end;
end;

procedure TMainForm.Test;
var
  s: string;
  n: Integer;
  Time: Integer;
begin
  s := '';

  Time := OldTime - GetTickCount div 1000;

  if Time >= 0 then
  begin
    if Time >= 60 * 60 then
    begin
      n := Time div (60 * 60);
      s := s + n.toString + 'ч ';
    end;

    if Time >= 60 then
    begin
      n := (Time div 60) mod 60;
      if n <= 9 then
        s := s + '0';
      s := s + n.toString + 'м ';
    end;

    n := Time mod 60;
    if n <= 9 then
      s := s + '0';
    s := s + n.toString + 'c ';

    Display.Text := s;
  end;

  if Time <= 0 then
  begin
    Timer.Enabled := False;
    Display.Text := 'Выключение...';
    PowerOff;
  end;

  if (Time <= 60 * 5) and not IsUsedNotification then
  begin
    IsUsedNotification := True;
    ShowNotification;
  end;
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
  Test;
end;

end.
