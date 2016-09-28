{****************************************************************************************}
{                                       PowerOff                                         }
{                                   ErrorSoft(c) 2016                                    }
{                                                                                        }
{ This is my first public project using FireMonkey technology.                           }
{ This can be useful utilite or some of the sources, such as FontSizeForBox function.    }
{                                                                                        }
{ Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License }
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
    SetTitle: TLabel;
    TabControl: TTabControl;
    TabItemSet: TTabItem;
    GridPanelLayout: TGridPanelLayout;
    Button1: TButton;
    Button2: TButton;
    Button4: TButton;
    Button3: TButton;
    TabItemRun: TTabItem;
    RunTitle: TLabel;
    Display: TLabel;
    Timer: TTimer;
    FooterEs: TLabel;
    NotificationCenter: TNotificationCenter;
    procedure GridPanelLayoutResize(Sender: TObject);
    procedure ButtonSetClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure DisplayResize(Sender: TObject);
  private
    OldTime: DWord;
    IsUsedNotification: Boolean;
    procedure Test;
    function PowerOff: Boolean;
    procedure ShowNotification;
  end;

var
  MainForm: TMainForm;

implementation

{$R *.fmx}

uses
  Utils, Tooltip;

const
  sNotificationBody = 'Внимание! Через 5 минут произойдет автоматиеское выключение компьютера';
  sNotificationTitle = 'PowerOff';
  sDefaultDisplay = '00ч 00м 00с';
  sOffText = 'Выключение...';
  cHour = 'ч';
  cMinute = 'м';
  cSecond = 'с';
  NotificationTime = 60 * 5;// 5 minutes
  NormalDispColor = $FF000000;
  AlarmDispColor = $FFFF0000;

procedure TMainForm.ButtonSetClick(Sender: TObject);
begin
  OldTime := GetTickCount div 1000 + DWord(TControl(Sender).Tag) * 60;
  Test;

  TabControl.SetActiveTabWithTransition(TabItemRun, TTabTransition.Slide, TTabTransitionDirection.Normal);
  Timer.Enabled := True;
end;

procedure TMainForm.DisplayResize(Sender: TObject);
begin
  Display.Font.Size := FontSizeForBox(sDefaultDisplay,
    Display.Font, Display.Width, Display.Height, Display.Height);
end;

procedure TMainForm.GridPanelLayoutResize(Sender: TObject);
//var
//  Width, Height: Integer;
//  Grid: TGridPanelLayout;
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
//var
//  Notification: TNotification;
begin
//  Notification := NotificationCenter.CreateNotification;
//  try
//    Notification.Title := sNotificationTitle;
//    Notification.AlertBody := sNotificationBody;
//    NotificationCenter.PresentNotification(Notification);
//  finally
//    Notification.Free;
//  end;
  System.SysUtils.Beep;
  ShowTooltip(sNotificationBody);
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
      s := s + n.toString + cHour + ' ';
    end;

    if Time >= 60 then
    begin
      n := (Time div 60) mod 60;
      if n <= 9 then
        s := s + '0';
      s := s + n.toString + cMinute + ' ';
    end;

    n := Time mod 60;
    if n <= 9 then
      s := s + '0';
    s := s + n.toString + cSecond + ' ';

    Display.Text := s;
  end;

  if Time <= 0 then
  begin
    Timer.Enabled := False;
    Display.Text := sOffText;
    PowerOff;
  end;

  if not IsUsedNotification and (Time <= NotificationTime) then
  begin
    IsUsedNotification := True;
    Display.TextSettings.FontColor := AlarmDispColor;
    ShowNotification;
  end;
end;

procedure TMainForm.TimerTimer(Sender: TObject);
begin
  Test;
end;

end.
