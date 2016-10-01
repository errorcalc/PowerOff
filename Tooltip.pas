{****************************************************************************************}
{                                       PowerOff                                         }
{                                   ErrorSoft(c) 2016                                    }
{                                                                                        }
{ This is my first public project using FireMonkey technology.                           }
{ This can be useful utilite or some of the sources, such as FontSizeForBox function.    }
{                                                                                        }
{ Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International Public License }
{****************************************************************************************}
unit Tooltip;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Controls.Presentation,
  FMX.StdCtrls, FMX.Effects, FMX.Objects, FMX.Ani, FMX.Layouts;

type
  TTooltipForm = class(TForm)
    Rectangle: TRectangle;
    ShadowEffect: TShadowEffect;
    Message: TLabel;
    TimerFree: TTimer;
    AnimationShow: TFloatAnimation;
    AnimationHide: TFloatAnimation;
    Layout: TLayout;
    procedure TimerFreeTimer(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormShow(Sender: TObject);
  private
    FTextMessage: string;
  public
    property TextMessage: string read FTextMessage write FTextMessage;
  end;

procedure ShowTooltip(Message: string);

implementation

{$R *.fmx}

uses
  Utils, System.Math;

procedure ShowTooltip(Message: string);
var
  Form: TTooltipForm;
begin
  Form := TTooltipForm.Create(nil);
  Form.TextMessage := Message;
  Form.Show;
end;

procedure TTooltipForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := TCloseAction.caFree;
end;

procedure TTooltipForm.FormShow(Sender: TObject);
var
  Size: TSize;
begin
  ShadowEffect.Distance := 0;// TShadowEffect.Distance bug fix
  AnimationHide.Delay := (TimerFree.Interval / 1000) - AnimationHide.Duration;
  AnimationHide.Start;

  TimerFree.Enabled := True;

  Message.Text := TextMessage;

  Size := TSize.Create(
    Ceil(CalcTextSize(TextMessage, Message.Font).Width + Rectangle.Margins.Left + Rectangle.Margins.Right + 20),
    Ceil(CalcTextSize('W|', Message.Font).Height + Rectangle.Margins.Top + Rectangle.Margins.Bottom + 20));

  SetBounds(Screen.Width div 2 - Size.Width div 2, Screen.Height div 2 - Size.Height div 2,
    Size.Width, Size.Height);
end;

procedure TTooltipForm.TimerFreeTimer(Sender: TObject);
begin
  Close;
end;

end.
