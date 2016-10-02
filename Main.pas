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
  WinApi.Windows, WinApi.ShellAPI, System.Math, System.Notification, FMX.Effects, FMX.Objects;

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
    Button5: TSpeedButton;
    LayoutCustomTime: TLayout;
    CalloutPanel: TCalloutPanel;
    TrackBarCustom: TTrackBar;
    CustomTime: TLabel;
    LayoutCustomButton: TLayout;
    ButtonCustomOk: TButton;
    LayoutCustomTimeInternalRect: TLayout;
    procedure GridPanelLayoutResize(Sender: TObject);
    procedure ButtonSetClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure DisplayResize(Sender: TObject);
    procedure Button5Resize(Sender: TObject);
    procedure Button5MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Single);
    procedure TrackBarCustomChange(Sender: TObject);
    procedure ButtonCustomOkClick(Sender: TObject);
  private
    OldTime: DWord;
    IsUsedNotification: Boolean;
    procedure Test;
    procedure SetTime(Time: Integer);
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
  sNotificationBody = 'Внимание! Через 5 минут произойдет автоматическое выключение компьютера';
  sNotificationTitle = 'PowerOff';
  sDefaultDisplay = '00ч 00м 00с';
  sOffText = 'Выключение...';
  sCustomTme = 'Отключить через';
  NotificationTime = 60 * 5;// 5 minutes
  NormalDispColor = $FF000000;
  AlarmDispColor = $FFFF0000;

procedure TMainForm.Button5MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
  Y: Single);
begin
  Button1.Enabled := not Button5.IsPressed;
  Button2.Enabled := not Button5.IsPressed;
  Button3.Enabled := not Button5.IsPressed;
  Button4.Enabled := not Button5.IsPressed;

  TrackBarCustomChange(TrackBarCustom);

  LayoutCustomTime.Position.X := Trunc(
    TButton(Sender).LocalToAbsolute(PointF(0, 0)).X - LayoutCustomTime.Size.Width + TButton(Sender).Width);
  LayoutCustomTime.Position.Y := Trunc(
    TButton(Sender).LocalToAbsolute(PointF(0, 0)).Y - LayoutCustomTime.Size.Height);
  LayoutCustomTime.Visible := Button5.IsPressed;
end;

procedure TMainForm.Button5Resize(Sender: TObject);
begin
  if Button5.IsPressed then
  begin
    LayoutCustomTime.Position.X := Trunc(
      TButton(Sender).LocalToAbsolute(PointF(0, 0)).X - LayoutCustomTime.Size.Width + TButton(Sender).Width);
    LayoutCustomTime.Position.Y := Trunc(
      TButton(Sender).LocalToAbsolute(PointF(0, 0)).Y - LayoutCustomTime.Size.Height);
  end;
end;

procedure TMainForm.ButtonCustomOkClick(Sender: TObject);
begin
  Button1.Enabled := True;
  Button2.Enabled := True;
  Button3.Enabled := True;
  Button4.Enabled := True;
  SetTime(Trunc(TrackBarCustom.Value) * 60);
end;

procedure TMainForm.ButtonSetClick(Sender: TObject);
begin
  SetTime(DWord(TControl(Sender).Tag) * 60);
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

procedure TMainForm.SetTime(Time: Integer);
begin
  OldTime := GetTickCount div 1000 + Time;
  Test;

  TabControl.SetActiveTabWithTransition(TabItemRun, TTabTransition.Slide, TTabTransitionDirection.Normal);
  Timer.Enabled := True;
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
  WInApi.Windows.MessageBeep(MB_ICONINFORMATION);
  ShowTooltip(sNotificationBody);
end;

procedure TMainForm.Test;
var
  Time: Integer;
begin
  Time := OldTime - GetTickCount div 1000;

  if Time >= 0 then
    Display.Text := SecondsToString(Time);

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

procedure TMainForm.TrackBarCustomChange(Sender: TObject);
begin
  CustomTime.Text := sCustomTme + ': ' + SecondsToString(Trunc(TTrackBar(Sender).Value) * 60);
end;

end.
