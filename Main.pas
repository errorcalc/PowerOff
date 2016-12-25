{****************************************************************************************}
{                                       PowerOff                                         }
{                                   ErrorSoft(c) 2016                                    }
{                                                                                        }
{ Utility was written, to check the suitability of the FireMonkey technology to develop- }
{ in general - yes, at the moment, under Windows (and to simulate the interface UWP),    }
{ it is a workable technology.                                                           }
{                                                                                        }
{ This can be useful utilite or some of the sources, such as FontSizeForBox function.    }
{                                                                                        }
{ PowerOff - Very simple application for auto shutdown the computer.                     }
{ It is useful app, if you before sleep like watch videos on                             }
{ YouTube/music/TV shows/movies, but they continue playing all night, causing a headache }
{ in the morning ...                                                                     }
{                                                                                        }
{ This project uses MIT license:                                                         }
{ -------------------------------------------------------------------------------------- }
{ Copyright (c) 2016 errorsoft                                                           }
{ Permission is hereby granted, free of charge, to any person obtaining a copy of this   }
{ software and associated documentation files (the "Software"), to deal in the Software  }
{ without restriction, including without limitation the rights to use, copy, modify,     }
{ merge, publish, distribute, sublicense, and/or sell copies of the Software, and to     }
{ permit persons to whom the Software is furnished to do so, subject to the following    }
{ conditions:                                                                            }
{ The above copyright notice and this permission notice shall be included in all copies  }
{ or substantial portions of the Software.                                               }
{ THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED,    }
{ INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR            }
{ A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT   }
{ HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF   }
{ CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE   }
{ OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                                          }
{****************************************************************************************}
unit Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.TabControl,
  FMX.Controls.Presentation, FMX.StdCtrls, FMX.Layouts, FMX.TextLayout,
  WinApi.Windows, WinApi.ShellAPI, System.Math, FMX.Effects, FMX.Objects,
  FMX.Ani;

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
    Button5: TButton;
    LayoutCustomTime: TLayout;
    CalloutPanel: TCalloutPanel;
    TrackBarCustom: TTrackBar;
    CustomTime: TLabel;
    LayoutCustomButton: TLayout;
    ButtonCustomOk: TButton;
    LayoutCustomTimeInternalRect: TLayout;
    FooterEsLayout: TLayout;
    FooterEs: TLabel;
    FooterEsColorAnimation: TColorAnimation;
    BackButton: TButton;
    Back_Image: TImage;
    procedure ButtonSetClick(Sender: TObject);
    procedure TimerTimer(Sender: TObject);
    procedure DisplayResize(Sender: TObject);
    procedure Button5Resize(Sender: TObject);
    procedure Button5MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X,
      Y: Single);
    procedure TrackBarCustomChange(Sender: TObject);
    procedure ButtonCustomOkClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FooterEsClick(Sender: TObject);
    procedure BackButtonClick(Sender: TObject);
    procedure TrackBarCustomPainting(Sender: TObject; Canvas: TCanvas; const [Ref] ARect: TRectF);
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
  sNotificationBodyRu = '��������! ����� 5 ����� ���������� �������������� ���������� ����������';
  sNotificationBodyEn = 'Warning! After 5 minutes will automatically shutdown the computer';
  sNotificationTitle = 'PowerOff';
  sDefaultDisplayRu = '00� 00� 00�';
  sDefaultDisplayEn = '00h 00m 00s';
  sOffTextRu = '����������...';
  sOffTextEn = 'Power off...';
  sCustomTmeRu = '��������� �����';
  sCustomTmeEn = 'Shutdown in';
  NotificationTime = 60 * 5;// 5 minutes
  NormalDispColor = $FF000000;
  AlarmDispColor = $FFFF0000;

function sNotificationBody: string;
begin
  if IsRu then
    Result := sNotificationBodyRu
  else
    Result := sNotificationBodyEn;
end;

function sDefaultDisplay: string;
begin
  if IsRu then
    Result := sDefaultDisplayRu
  else
    Result := sDefaultDisplayEn;
end;

function sOffText: string;
begin
  if IsRu then
    Result := sOffTextRu
  else
    Result := sOffTextEn;
end;

function sCustomTme: string;
begin
  if IsRu then
    Result := sCustomTmeRu
  else
    Result := sCustomTmeEn;
end;

procedure TMainForm.BackButtonClick(Sender: TObject);
begin
  Timer.Enabled := False;
  TabControl.SetActiveTabWithTransition(TabItemSet, TTabTransition.Slide, TTabTransitionDirection.Reversed);
  Button5Resize(Button5);
end;

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
  if TButton(Sender).IsPressed and not Timer.Enabled then
  begin
    LayoutCustomTime.Position.X := Trunc(
      TButton(Sender).LocalToAbsolute(PointF(0, 0)).X - LayoutCustomTime.Size.Width + TButton(Sender).Width);
    LayoutCustomTime.Position.Y := Trunc(
      TButton(Sender).LocalToAbsolute(PointF(0, 0)).Y - LayoutCustomTime.Size.Height);
  end;
end;

procedure TMainForm.ButtonCustomOkClick(Sender: TObject);
begin
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

procedure TMainForm.FooterEsClick(Sender: TObject);
begin
  ShellExecute(0, 'open', PChar('https://github.com/errorcalc/PowerOff'), nil, nil, 0);
end;

procedure TMainForm.FormCreate(Sender: TObject);
begin
  FooterEsLayout.BringToFront;// for link
  if IsRu then
  begin
    SetTitle.Text := '��������� ��������� �����:';
    Button1.Text := '15 �����';
    Button2.Text := '30 �����';
    Button3.Text := '1 ���';
    Button4.Text := '2 ����';
    Button5.Text := '���������...';
    RunTitle.Text := '�� ���������� ���������� ��������:';
  end;
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
  Display.TextSettings.FontColor := NormalDispColor;
  IsUsedNotification := False;
  OldTime := GetTickCount div 1000 + Time;
  Test;

  TabControl.SetActiveTabWithTransition(TabItemRun, TTabTransition.Slide, TTabTransitionDirection.Normal);
  Timer.Enabled := True;
end;

procedure TMainForm.ShowNotification;
begin
  WinApi.Windows.MessageBeep(MB_ICONINFORMATION);
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

procedure TMainForm.TrackBarCustomPainting(Sender: TObject; Canvas: TCanvas; const [Ref] ARect: TRectF);
begin
  DrawTicks(TTrackBar(Sender), 25, 30, True, TLineKind.Both, 6, 8, $66000000);
end;

end.
