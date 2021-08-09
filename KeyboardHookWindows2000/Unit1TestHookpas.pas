unit Unit1TestHookpas;
//http://phidels.com
interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls;

const

  HookDll='HOOKDLL.DLL';

type
  TProcCallBack=procedure(Msg:Integer); stdcall;
  TForm1 = class(TForm)
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    LabelnNumMessage: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public
    // procedure qui sera déclenchée lorsqu'un message WM_COPYDATA arrivera
    procedure OnWmCopyData(var msg:TMessage); message WM_COPYDATA;
  end;

var
  Form1: TForm1;
  MouseHookStruct:TMouseHookStruct;

procedure FinalisationHook; stdcall; external HookDll;
function InitialisationHook(HandelDestData:HWnd):Boolean; stdcall; external HookDll;

implementation





{$R *.DFM}
Type
//TPDataEnvoyes est un type pointeur (adresse) sur un TDataEnvoyes :
TPDataEnvoyes=^TDataEnvoyes;
  TDataEnvoyes =Packed record  //packed pour "compressé"
    AMsg:Integer;
    pt: TPoint;
    hwnd: HWND;
    wHitTestCode: UINT;
    dwExtraInfo: DWORD;
  end;



procedure TForm1.OnWmCopyData(var msg: TMessage);
// procedure qui sera déclenchée lorsqu'un message WM_COPYDATA arrivera
// de la part de la dll HookDll
// ca va nous permettre de récupérer les données
type
  TPCopyDataStruct=^TCopyDataStruct;
  TPDataEnvoyes=^TDataEnvoyes;
Var
  DataEnvoyes:TDataEnvoyes;
  PDataEnvoyes:TPDataEnvoyes;
  PCopyDataStruct:TPCopyDataStruct;
begin
  PCopyDataStruct:=TPCopyDataStruct(msg.LParam);
  //PCopyDataStruct^ signifie "ce qui est pointé par le PCopyDataStruct"
  PDataEnvoyes:=PCopyDataStruct^.lpData;
  DataEnvoyes:=PDataEnvoyes^;
  Label2.Caption:=IntToStr(DataEnvoyes.pt.x)+':'+IntToStr(DataEnvoyes.pt.y);
  Label3.Caption:='Window: '+IntToStr(DataEnvoyes.hWnd);
  Label4.Caption:='HitTestCode: '+IntToStr(DataEnvoyes.wHitTestCode);
  Label5.Caption:='ExtraInfo: '+IntToStr(DataEnvoyes.dwExtraInfo);
  LabelnNumMessage.Caption:='message '+IntToStr(DataEnvoyes.AMsg);
end;



procedure TForm1.FormCreate(Sender: TObject);
begin
  if not InitialisationHook(Handle)then ShowMessage('erreur à la création du Hook');
   //initialise le hook en faisant passer le handle de Form1 en paramètre
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
  FinalisationHook;
end;

end.
