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
    procedure RectangleClick(Sender: TObject);
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

procedure TTooltipForm.RectangleClick(Sender: TObject);
begin
  Close;
end;

procedure TTooltipForm.TimerFreeTimer(Sender: TObject);
begin
  Close;
end;

end.
