unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    ListBox1: TListBox;
    procedure Button1Click(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.Button1Click(Sender: TObject);
var
  Tray, Child, Buttons, MyButton : hWnd;
  C, D, E : Array[0..127] of Char;
begin
   // Récupère la barre des taches
   Tray := FindWindow('Shell_TrayWnd', NIL);
   // Récupère la partie enfant
   Child := GetWindow(Tray, GW_CHILD);

   // Dans cette boucle on choisit la barre de tâche (MSTaskSwWClass)
   while Child <> 0 do
   begin
        if GetClassName(Child, C, SizeOf(C)) > 0 then
        begin
           // Si on est sur la barre des tâche
           if UpperCase(StrPAS(C)) = 'REBARWINDOW32'
           then begin
               // Récupère la partie enfant
               Buttons := GetWindow(Child, GW_CHILD);

               while Buttons <> 0 do
               begin
                   if GetClassName(Buttons, D, SizeOf(D)) > 0 then
                   begin
                       // Si on est sur la zone de bouton de la barre des tâche
                       if UpperCase(StrPAS(D)) = 'MSTASKSWWCLASS'
                       then begin
                           // Récupère la partie enfant
                           MyButton := GetWindow(Buttons, GW_CHILD);

                           while MyButton <> 0 do
                           begin
                               if GetClassName(Buttons, E, SizeOf(E)) > 0 then
                               begin
                                   ListBox1.Items.Add(StrPAS(E)) ;
                               end ;

                               MyButton := GetWindow(MyButton, GW_HWNDNEXT);
                           end ;

                       end ;

                       ListBox1.Items.Add(StrPAS(D)) ;
                   end ;

                   Buttons := GetWindow(Buttons, GW_HWNDNEXT);
               end ;

           end;
       end;

       Child := GetWindow(Child, GW_HWNDNEXT);
   end;
     //          SetWindowText(Child,'Hello !');
   //            SendMessage(Child,WM_PAINT,0,0);

end;

end.
