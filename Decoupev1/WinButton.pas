{
  ****
 Version 1.2
  ****
}
unit WinButton;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, StdCtrls;
type
    TWinButtonLayout = (wbBitmapTop, wbBitmapBottom, wbBitmapLeft, wbBitmapRight);

    TWinButton = class(TButton)
    private
      FBitmap:TBitmap;
      FCaption:TCaption;
      FLayout: TWinButtonLayout;
      FOnEnter, FOnExit: TNotifyEvent;
      FPushed:boolean;
      FShowCaption:boolean;
      MouseIn:boolean;
      rect:TRect;
      procedure CMDialogChar(var Message: TCMDialogChar); message CM_DIALOGCHAR;

    protected
      procedure CMMouseEnter(var msg: TMessage); message CM_MOUSEENTER;
      procedure CMMouseLeave(var msg: TMessage); message CM_MOUSELEAVE;
      procedure BitmapChange(Sender: TObject);
      procedure SetEnabled(value: Boolean); override;
      procedure SetBitmap(value:TBitmap);
      procedure SetLayout(value: TWinButtonLayout);
      procedure SetCaption(value:TCaption);
      procedure SetShowCaption(value:boolean);
      procedure WMLButtonDown(var msg: TWMLButtonDown); message WM_LBUTTONDOWN;
      procedure WMLButtonUp(var msg: TWMLButtonUp); message WM_LBUTTONUP;
      procedure WMPaint(var msg: TWMPaint); message WM_PAINT;
    public
      constructor Create(Owner:TComponent); override;
      destructor Destroy; override;
    published
      property BitmapLayout: TWinButtonLayout read FLayout write SetLayout;
      property Bitmap:TBitmap read FBitmap write SetBitmap;
      property Caption: TCaption read FCaption write SetCaption;
      property OnEnter: TNotifyEvent read FOnEnter write FOnEnter;
      property OnExit: TNotifyEvent read FOnExit write FOnExit;
      property ShowCaption: boolean read FShowCaption write SetShowCaption;

    end;

procedure Register;

implementation
uses dialogs;
const
     bmOffsetX = 6;
     bmOffsetY = 6;
     txOffsetX = 4;
     txOffsetY = 4;

// DrawTransparentBitmap:
// adapted from TExplorerButton by Fabrice Deville

procedure DrawTransparentBitmap(dc:HDC; bmp: TBitmap; xStart,yStart: Integer; cTransparentColor: LongInt);
var
   bm: TBitmap;
   cColor: TColorRef;
   bmAndBack, bmAndObject, bmAndMem, bmSave, oldBmp: HBITMAP;
   bmBackOld, bmObjectOld, bmMemOld, bmSaveOld, hBmp: HBITMAP;
   hdcMem, hdcBack, hdcObject, hdcTemp, hdcSave: HDC;
   ptSize: TPoint;
   temp_bitmap: TBitmap;
begin
     temp_bitmap := TBitmap.Create;
     temp_bitmap.Assign(bmp);
     try
          hBmp := temp_bitmap.Handle;
          hdcTemp := CreateCompatibleDC(dc);
          oldBmp := SelectObject(hdcTemp, hBmp);

          GetObject(hBmp, SizeOf(bm), @bm);
          ptSize.x := bmp.Width;
          ptSize.y := bmp.Height;

          hdcBack   := CreateCompatibleDC(dc);
          hdcObject := CreateCompatibleDC(dc);
          hdcMem    := CreateCompatibleDC(dc);
          hdcSave   := CreateCompatibleDC(dc);

          bmAndBack   := CreateBitmap(ptSize.x, ptSize.y, 1, 1, nil);

          bmAndObject := CreateBitmap(ptSize.x, ptSize.y, 1, 1, nil);

          bmAndMem    := CreateCompatibleBitmap(dc, ptSize.x, ptSize.y);
          bmSave      := CreateCompatibleBitmap(dc, ptSize.x, ptSize.y);

          bmBackOld   := SelectObject(hdcBack, bmAndBack);
          bmObjectOld := SelectObject(hdcObject, bmAndObject);
          bmMemOld    := SelectObject(hdcMem, bmAndMem);
          bmSaveOld   := SelectObject(hdcSave, bmSave);

          SetMapMode(hdcTemp, GetMapMode(dc));

          BitBlt(hdcSave, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCCOPY);

          cColor := SetBkColor(hdcTemp, cTransparentColor);

          BitBlt(hdcObject, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCCOPY);

          SetBkColor(hdcTemp, cColor);

          BitBlt(hdcBack, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, NOTSRCCOPY);
          BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, dc, xStart, yStart, SRCCOPY);
          BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcObject, 0, 0, SRCAND);
          BitBlt(hdcTemp, 0, 0, ptSize.x, ptSize.y, hdcBack, 0, 0, SRCAND);
          BitBlt(hdcMem, 0, 0, ptSize.x, ptSize.y, hdcTemp, 0, 0, SRCPAINT);
          BitBlt(dc, xStart, yStart, ptSize.x, ptSize.y, hdcMem, 0, 0, SRCCOPY);
          BitBlt(hdcTemp, 0, 0, ptSize.x, ptSize.y, hdcSave, 0, 0, SRCCOPY);

          DeleteObject(SelectObject(hdcBack, bmBackOld));
          DeleteObject(SelectObject(hdcObject, bmObjectOld));
          DeleteObject(SelectObject(hdcMem, bmMemOld));
          DeleteObject(SelectObject(hdcSave, bmSaveOld));

          SelectObject(hdcTemp, oldBmp);

          DeleteDC(hdcMem);
          DeleteDC(hdcBack);
          DeleteDC(hdcObject);
          DeleteDC(hdcSave);
          DeleteDC(hdcTemp);
     finally
            temp_bitmap.Free;
     end;
end;

constructor TWinButton.Create(Owner:TComponent);
begin
     inherited Create(Owner);
     ControlStyle := [csOpaque, csDoubleClicks];

     FBitmap:=TBitmap.Create;
     FBitmap.OnChange := BitmapChange;

     FShowCaption:=true;
     FLayout:=wbBitmapLeft;

     if (csDesigning in ComponentState) and not (csLoading in TControl(Owner).ComponentState) then
     begin
          FCaption := 'WinButton';
     end;

     inherited Caption:='';

     Width:=75;
     Height:=25;
     MouseIn:=false;

end;

destructor TWinButton.Destroy;
begin
     FBitmap.free;
     inherited;
end;

procedure TWinButton.SetBitmap(value:TBitmap);
begin
     FBitmap.Assign(value);
     if not FBitmap.Empty then
        FBitmap.Dormant;
     Repaint;
end;

procedure TWinButton.CMMouseEnter(var msg:TMessage);
begin
     MouseIn := True;
     if Enabled then
             Repaint;
     if Assigned(FOnEnter) then
             FOnEnter(Self);
end;

procedure TWinButton.CMMouseLeave(var msg:TMessage);
begin
     MouseIn := false;
     if Enabled then
             Repaint;
     if Assigned(FOnEnter) then
             FOnEnter(Self);
end;

// DrawDisabledBitmap:
// adapted from TExplorerButton by Fabrice Deville
procedure DrawDisabledBitmap(DC:HDC; x, y: Integer; bmp: TBitmap);
var
   MonoBmp: TBitmap;
   OldBkColor:COLORREF;
   OldTextColor:COLORREF;
   OldBrush:HBrush;
   Brush:HBrush;
begin
     MonoBmp := TBitmap.Create;
     OldbkColor:=SetBkColor(DC, clWhite);
     OldTextColor:=SetTextColor(DC, clBlack);
     Brush:=CreateSolidBrush(GetSysColor(COLOR_BTNHIGHLIGHT));
     OldBrush:=SelectObject(DC,Brush);

     try
             MonoBmp.Assign(bmp);
             MonoBmp.Canvas.Brush.Color := clBlack;
             MonoBmp.Monochrome := True;
             BitBlt(DC, x+1, y+1, bmp.Width, bmp.Height,
                     MonoBmp.Canvas.Handle, 0, 0, $00E20746);
             DeleteObject(Brush);
             Brush:=CreateSolidBrush(GetSysColor(COLOR_BTNSHADOW));
             SelectObject(DC,Brush);

             SetTextColor(DC, clBlack);
             SetBkColor(DC, clWhite);
             BitBlt(DC, x, y, bmp.Width, bmp.Height,
                     MonoBmp.Canvas.Handle, 0, 0, $00E20746);
     finally
             MonoBmp.Free;
             SetBkColor(DC,OldBkColor);
             SetTextColor(DC,OldTextColor);
             DeleteObject(Brush);
             SelectObject(DC,OldBrush);
     end
end;


procedure TWinButton.WMPaint(var msg: TWMPaint);
var
   incy,incx:integer;
   tempDibX,tempDibY:integer;
   tempTextX,tempTextY:integer;
   fo:HFONT;
   dc:HDC;
begin
     inherited;
     fo:=self.Font.Handle;
     dc:=GetDC(Handle);
     selectObject(dc,fo);
     SetBkMode(dc,TRANSPARENT);
     
     tempDibX:=0;
     TempDibY:=0;
     incy:=0;
     incx:=0;
     if FShowCaption then
     begin
          case FLayOut of
               wbBitmapTop:
               begin
                 tempDibX:=(Width div 2)-(FBitmap.Width div 2);
                 TempDibY:=bmOffsetY;
               end;
               wbBitmapLeft:
               begin
                 TempDibX:=bmOffsetX;
                 tempDibY:=(Height div 2) - (FBitmap.Height div 2);
               end;
               wbBitmapRight:
               begin
                 tempDibX:=Width-FBitmap.Width-bmOffsetX;
                 tempDibY:=(Height div 2) - (FBitmap.Height div 2);
               end;
               wbBitmapBottom:
               begin
                 tempDibX:=(Width div 2)-(FBitmap.Width div 2);
                 TempDibY:=Height-FBitmap.Height-bmOffsetY;
               end;
          end;
     end
     else
     begin
          TempDibX:=(width div 2)-(FBitmap.Width div 2);
          TempDibY:=(Height div 2)-(FBitmap.Height div 2);
     end;


     TempTextX:=0;
     TempTextY:=0;

(*    // para que al pulsar actue como los viejos botones, "Hundiendose"
     if enabled and  FPushed and MouseIn then
     begin
          tempDibX:=tempDibX+1;
          tempDibY:=tempDibY+1;
          TempTextX:=1;
          TempTextY:=1;

     end;
*)

     if (FCaption <> '') and (FShowCaption) then
     begin
          fo:=self.Font.Handle;
          SelectObject(dc,fo);

          case FLayout of
               wbBitmapTop:
               begin
                    rect.Left:=txOffsetX;
                    rect.Top:=FBitmap.Height+txOffsetY;
                    rect.Bottom:=Height-txOffsetY;
                    rect.Right:=width-txOffsetX;
               end;
               wbBitmapLeft:
               begin
                    rect.Left:=FBitmap.Width+txOffsetX;
                    rect.Top:=txOffsetY;
                    rect.Bottom:=Height-txOffsetY;
                    rect.Right:=Width-txOffsetX;
               end;
               wbBitmapBottom:
               begin
                    rect.Left:=txOffsetX;
                    rect.Top:=txOffsetY;
                    rect.Bottom:=height-FBitmap.Height-txOffsetY;
                    rect.Right:=width-txOffsetY;
               end;
               wbBitmapRight:
               begin
                    rect.Left:=txOffsetX;
                    rect.Top:=txOffsetY;
                    Rect.Bottom:=Height-txOffsetY;
                    Rect.Right:=Width-FBitmap.Width-txOffsetX;
               end;
          end;
          DrawText(dc,PChar(Caption),length(Caption),rect,DT_CENTER or DT_VCENTER or DT_CALCRECT or DT_WORDBREAK);
          // ya tenemos el "rect" que va a ocupar el texto, lo centramos en el boton
          case FLayout of
               wbBitmapTop:
               begin
                    incy:=((height-FBitmap.Height-2)div 2)-(rect.Bottom div 2)+(FBitmap.Height div 2);
                    incx:=((width-txOffsetX) div 2 - (rect.Right div 2));
               end;
               wbBitmapLeft:
               begin
                    incy:=((height-txOffsetY) div 2 - (rect.Bottom div 2));
                    incx:=((width-FBitmap.Width-txOffsetX)div 2)-(rect.Right div 2)+(FBitmap.Width div 2);
               end;
               wbBitmapBottom:
               begin
                    incy:=((height-FBitmap.Height-txOffsetY)div 2)-(rect.Bottom div 2);
                    incx:=((width-txOffsetX) div 2 - (rect.Right div 2));
               end;
               wbBitmapRight:
               begin
                    incy:=((height-txOffsetY) div 2 - (rect.Bottom div 2));
                    incx:=((width-FBitmap.Width-txOffsetX) div 2 - (rect.Right div 2));
               end;
          end;
          inc(rect.Top,incy+TempTextY);
          inc(rect.Left,incx+TempTextX);
          inc(rect.Bottom,incy+TempTextY);
          inc(rect.Right,incx+TempTextX);
     end;

     if enabled then
     begin
          if not FBitmap.Empty then
          begin
               DrawTransparentBitmap(DC,FBitmap,TempDibX,TempDibY,ColorToRGB(FBitmap.Canvas.Pixels[0, 0]));
          end;
          SetTextColor(dc,GetSysColor(COLOR_BTNTEXT));
     end
     else
     begin
          SetTextColor(dc,GetSysColor(COLOR_GRAYTEXT));
          DrawDisabledBitmap(dc,TempDibX,TempDibY,FBitmap);
     end;

     if (FCaption <> '') and (FShowCaption) then
     begin
          DrawText(dc,PChar(FCaption),length(FCaption),rect,DT_CENTER or DT_VCENTER or DT_WORDBREAK);
     end;
     ReleaseDC(handle,dc);
end;

procedure TWinButton.BitmapChange(Sender: TObject);
begin
     if not FBitmap.Empty then
        FBitmap.Dormant;
     Repaint;
end;

procedure TWinButton.WMLButtonDown(var msg: TWMLButtonDown);
begin
     inherited;
     if Enabled and Visible then
     begin
          FPushed:=true;
          repaint;
     end;
end;
procedure TWinButton.WMLButtonUp(var msg: TWMLButtonUp);
begin
     inherited;
     if Enabled and visible then
     begin
          FPushed:=false;
          repaint;
     end;
end;

procedure TWinButton.SetLayout(value: TWinButtonLayout);
begin
     if FLayout <> value then
     begin
          FLayout:=value;
          repaint;
     end;
end;

procedure TWinButton.SetEnabled(value: Boolean);
begin
     inherited;
     repaint;
end;

procedure TWinButton.SetShowCaption(value:boolean);
begin
     if FShowCaption <> value then
     begin
          FShowCaption:=value;
          repaint;
     end;
end;

procedure TWinButton.CMDialogChar(var Message: TCMDialogChar);
begin
  with Message do
    if IsAccel(CharCode, Caption) and CanFocus then
    begin
      Click;
      Result := 1;
    end else
      inherited;
end;

procedure TWinButton.SetCaption(value:TCaption);
begin
     if value <> FCaption then
     begin
          Perform(CM_TEXTCHANGED, 0, 0);
          FCaption:=value;
          Repaint;
     end;
end;

procedure Register;
begin
     RegisterComponents('Win32', [TWinButton]);
end;

end.
