library HookDll;
//http://phidels.com
uses SysUtils, Windows, Messages, Dialogs;


type
  // type servant pour les données à envoyer à notre application
  TDataEnvoyes =Packed record  //packed pour "compressé"
    AMsg:WParam;
    pt: TPoint;
    hwnd: HWND;
    wHitTestCode: UINT;
    dwExtraInfo: DWORD;
  end;

// type servant au file mappping
  TDonneesHook=class
     HookHandle:HHook; {Handle du Hook retourné par SetWindowsHookEx}
     HandleDest:THandle; {Le Handle de la TForm auquel on veut envoyer le message}
  end;

Var
   DonneesHook:TDonneesHook=nil; {Pointeur sur les données qui seront mappées: le FileView}
   HookMap:THandle=0; {Contiendra le Handle du FileMapping}


function HookActionCallBack(Code: integer; Msg: WPARAM; MouseHook: LPARAM):LRESULT; stdcall;
{cette fonction reçoit tous les messages détournés                                            }
{elle envoit en retour un message avec les renseignements vers la fenêtre de handle HandleDest}
{ MouseHook est un pointeur pointant vers un TMouseHookStruct}

{les données vont être envoyées à notre application ProjectTestHook via un message WM_COPYDATA.}
{ pour bien comprendre, voir le tutorial portant sur les messages WM_COPYDATA }
var
  DataEnvoyes:TDataEnvoyes;
  CopyDataStruct:TCopyDataStruct;
  MouseStruct:TMouseHookStruct;
begin
  Result:=0;
  if Code=HC_ACTION then
  begin
    MouseStruct:= PMouseHookStruct(MouseHook)^;
    if DonneesHook.HandleDest<>0 then
    begin
      DataEnvoyes.pt:=MouseStruct.pt;
      DataEnvoyes.hWnd:=MouseStruct.hwnd;
      DataEnvoyes.wHitTestCode:=MouseStruct.wHitTestCode;
      DataEnvoyes.dwExtraInfo:=MouseStruct.dwExtraInfo;
      DataEnvoyes.AMsg:=Msg;

      //taille des données à envoyer :
      CopyDataStruct.cbData:=SizeOf(DataEnvoyes);
      //adresse de nos données à envoyer :
      CopyDataStruct.lpData:=@DataEnvoyes;
      SendMessage(DonneesHook.HandleDest, WM_COPYDATA,HInstance,LongInt(@CopyDataStruct));
    end;
  end;
  if Code<0 then Result:=CallNextHookEx(DonneesHook.HookHandle,Code,Msg,MouseHook);
end;

function InitialisationHook(HandleDestData:HWnd):Boolean; stdcall; export;
{SetWindowsHookEx permet de donner à windows le nom de la fonction}
{(ici HookActionCallBack)qui sera exécutée à chaque fois qu'il    }
{reçoit un message de type WH_MOUSE                               }
begin
  Result:=false;
  if (DonneesHook.HookHandle=0) and (HandleDestData<>0) then
  begin
    DonneesHook.HookHandle:=SetWindowsHookEx(WH_MOUSE,HookActionCallBack,HInstance,0);
    DonneesHook.HandleDest:=HandleDestData;
    Result:=DonneesHook.HookHandle<>0;
  end;
end;

procedure FinalisationHook; stdcall; export;
begin
  if DonneesHook.HookHandle<>0 then
  begin
    UnhookWindowsHookEx(DonneesHook.HookHandle);
    DonneesHook.HookHandle:=0;
  end;
end;

procedure LibraryProc(AReason:Integer);
// création d'un espace partagé
begin
  case AReason of
    DLL_PROCESS_ATTACH:begin
      {Il faut d'abord créer le FileMapping}
      {le $FFFFFFFF indique seulement que ce n'est pas un fichier qui sera mappé, mais des données}
      {TDonneesHook.InstanceSize permet de donner à Windows la bonne taille de mémoire à réserver}
      HookMap:=CreateFileMapping($FFFFFFFF,nil,PAGE_READWRITE,0,TDonneesHook.InstanceSize,'Michel');
      {Ensuite faire un View sur tout le fichier}
      DonneesHook:=MapViewOfFile(HookMap,FILE_MAP_WRITE,0,0,0);
    end;
    DLL_PROCESS_DETACH:begin //libérer les ressources prisent par notre FileMapping
      UnMapViewOfFile(DonneesHook);
      CloseHandle(HookMap);
    end;
    DLL_THREAD_ATTACH:;
    DLL_THREAD_DETACH:;
  end;
end;




exports
  InitialisationHook,
  FinalisationHook;

begin
  DllProc:=@LibraryProc;
  LibraryProc(DLL_PROCESS_ATTACH);
end.

