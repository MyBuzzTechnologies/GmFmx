{******************************************************************************}
{                                                                              }
{  TSegmentButtons                                                             }
{                                                                              }
{  Description: Animated segment button control                                }
{                                                                              }
{  Author:      Graham Murt                                                    }
{                                                                              }
{  Copyright (c) 2025 Graham Murt. All rights reserved.                        }
{                                                                              }
{  License: MIT                                                                }
{                                                                              }
{  Permission is hereby granted, free of charge, to any person obtaining a     }
{  copy of this software and associated documentation files (the "Software"),  }
{  to deal in the Software without restriction, including without limitation   }
{  the rights to use, copy, modify, merge, publish, distribute, sublicense,    }
{  and/or sell copies of the Software, and to permit persons to whom the       }
{  Software is furnished to do so, subject to the following conditions:        }
{                                                                              }
{  The above copyright notice and this permission notice shall be included     }
{  in all copies or substantial portions of the Software.                      }
{                                                                              }
{  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS     }
{  OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF                  }
{  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.      }
{  IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY        }
{  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,        }
{  TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE           }
{  SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                      }
{                                                                              }
{******************************************************************************}

unit SegmentButtons;

interface

uses FMX.Layouts, FMX.Objects, FMX.Controls, FMX.StdCtrls, Classes, FMX.Types, Generics.Collections, System.UITypes;

type
  TSelectSegmentEvent = procedure(Sender: TObject; ASegmentIndex: integer) of object;

  [ComponentPlatformsAttribute(
    pidAllPlatforms
    )]
  TSegmentButtons = class(TPaintBox)
  private
    FButtonWidth: single;
    FSegments: TStrings;
    FItemIndex: integer;
    FThumbPos: single;
    FOnSelectSegment: TSelectSegmentEvent;
    FCornerRadius: Single;
    FBackStrokeColor: TAlphaColor;
    FThumbColor: TAlphaColor;
    FBackFillColor: TAlphaColor;
    FThumbTextColor: TAlphaColor;
    FBackTextColor: TAlphaColor;
    FXInset: Single;
    FYInset: Single;
    procedure SetSegments(const Value: TStrings);
    procedure SetItemIndex(Value: integer);

    procedure SetThumbPos(const Value: single);
  protected
    procedure Paint; override;
    procedure Click; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ThumbPos: single read FThumbPos write SetThumbPos;
  published
    property Segments: TStrings read FSegments write SetSegments;
    property ItemIndex: integer read FItemIndex write SetItemIndex default -1;
    property OnSelectSegment: TSelectSegmentEvent read FOnSelectSegment write FOnSelectSegment;
    property CornerRadius: Single read FCornerRadius write FCornerRadius;
    property BackFillColor: TAlphaColor read FBackFillColor write FBackFillColor;
    property BackStrokeColor: TAlphaColor read FBackStrokeColor write FBackStrokeColor;
    property BackTextColor: TAlphaColor read FBackTextColor write FBackTextColor;
    property ThumbColor: TAlphaColor read FThumbColor write FThumbColor;
    property ThumbTextColor: TAlphaColor read FThumbTextColor write FThumbTextColor;
    property XInset: Single read FXInset write FXInset;
    property YInset: Single read FYInset write FYInset;
  end;

  procedure Register;

implementation

uses FMX.Graphics, FMX.Ani, System.Types, System.UIConsts, Math;


procedure Register;
begin
  RegisterComponents('GmFmx', [TSegmentButtons]);
end;

{ TSegmentButtons }

procedure TSegmentButtons.Click;
begin
  inherited;
end;

constructor TSegmentButtons.Create(AOwner: TComponent);
begin
  inherited;
  FSegments := TStringList.Create;
  FThumbPos := 0;
  FItemIndex := -1;
  FCornerRadius := 16;
  FXInset:=8;
  FYInset:=8;
  FBackStrokeColor:=claGainsboro;
  FBackFillColor:=claGainsboro;
  FThumbColor:=claWhite;
  FThumbTextColor:=claBlack;
  FBackTextColor:=claBlack;
  Width := 200;
  Height := 56;
  SetAcceptsControls(False);
end;

destructor TSegmentButtons.Destroy;
begin
  FSegments.Free;
  inherited;
end;

procedure TSegmentButtons.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Single);
var
  AIndex: integer;
begin
  inherited;
  AIndex := Trunc(X / FButtonWidth);
  if AIndex > FSegments.Count-1 then
    AIndex := FSegments.Count-1;
  if AIndex <> FItemIndex then
  begin

    ItemIndex := AIndex;
  end;
end;

procedure TSegmentButtons.Paint;
var
  ARect: TRectF;
  AState: TCanvasSaveState;
  AIndex: integer;
  AStr: string;
  AThumbRect: TRectF;
  ACornerRadius: Single;
begin
  inherited;
  AState := Canvas.SaveState;
  try
    Canvas.IntersectClipRect(ClipRect);

    AThumbRect := ClipRect;
    AThumbRect.Inflate(-FXInset, -FYInset);

    if FSegments.Count = 0 then
      FItemIndex := -1
    else
    begin
      if FItemIndex = -1 then
        FItemIndex := 0;
    end;

    if FCornerRadius < 0 then
      ACornerRadius := (ClipRect.Height - (FYInset * 2)) / 2
    else
      ACornerRadius := FCornerRadius;

    ARect := AThumbRect;
    Canvas.Fill.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := claBlack;
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Stroke.Color := FBackStrokeColor;
    Canvas.Stroke.Thickness := 5;
    Canvas.Fill.Color := FBackFillColor;
    //Canvas.Stroke.Thickness := 4;
    Canvas.DrawRect(ARect, ACornerRadius, ACornerRadius, AllCorners, 1);
    Canvas.FillRect(ARect, ACornerRadius, ACornerRadius, AllCorners, 1);

    FButtonWidth := ARect.Width / FSegments.Count;


    ARect.Width := FButtonWidth;
    Canvas.Stroke.Kind := TBrushKind.Solid;
    Canvas.Fill.Color := FThumbColor;
    Canvas.Stroke.Thickness := 0;

    // thumb...
    Canvas.Fill.Color := FThumbColor;
    AThumbRect := ARect;
    AThumbRect.Offset(FThumbPos, 0);
    Canvas.FillRect(AThumbRect, ACornerRadius, ACornerRadius, AllCorners, 1);



    for AIndex := 0 to FSegments.Count-1 do
    begin
      AStr := FSegments[AIndex];

      if AIndex = FItemIndex then
      begin
        Canvas.Font.Style := [TFontStyle.fsBold];
        Canvas.Fill.Color := FThumbTextColor;
      end
      else
      begin
        Canvas.Font.Style := [];
        Canvas.Fill.Color := FBackTextColor;
      end;

      //Canvas.FillRect(ARect, 16, 16, AllCorners, 1);
//      Canvas.Fill.Color := FBackTextColor;
      Canvas.Font.Size := 15;
      Canvas.FillText(ARect, AStr, False, 1, [], TTextAlign.Center, TTextAlign.Center);
      ARect.Offset(FButtonWidth, 0);
    end;




  finally
    Canvas.RestoreState(AState);
  end;
end;


procedure TSegmentButtons.SetItemIndex(Value: integer);
var
  bw: single;
begin
  if Value > FSegments.Count-1 then Value := FSegments.Count-1;
  
  if (Value < 0) and (FSegments.Count > 0) then Value := 0;


  if FItemIndex <> Value then
  begin
    FItemIndex := Value;

    // FIX HERE
    if FButtonWidth = 0 then
      FButtonWidth:=(Self.Width - FCornerRadius) / FSegments.Count; //approximate for now if not already set

    bw := FButtonWidth;
    if csDesigning in ComponentState then
    begin
      ThumbPos := FItemIndex * bw;
    end
    else
      TAnimator.AnimateFloat(Self, 'ThumbPos', FItemIndex * bw);

    if Assigned(FOnSelectSegment) then
      FOnSelectSegment(Self, FItemIndex);
  end;
end;

procedure TSegmentButtons.SetSegments(const Value: TStrings);
begin
  FSegments.Assign(Value);
end;

procedure TSegmentButtons.SetThumbPos(const Value: single);
begin
  FThumbPos := Value;
  InvalidateRect(ClipRect);
end;


end.

