{
  Copyright (C) 2002 MARTINEAU Emeric

  Ce programme est libre, vous pouvez le redistribuer et/ou le modifier selon
  les termes de la Licence Publique Générale GNU publiée par la Free Software
  Foundation version 2.

  Ce programme est distribué car potentiellement utile, mais SANS AUCUNE
  GARANTIE, ni explicite ni implicite, y compris les garanties de
  commercialisation ou d'adaptation dans un but spécifique. Reportez-vous à
  la Licence Publique Générale GNU pour plus de détails.
}
unit a_propos_de;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls;

type
  TForm2 = class(TForm)
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    Button1: TButton;
    Memo1: TMemo;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    procedure Button1Click(Sender: TObject);
  private
    { Déclarations privées}
  public
    { Déclarations publiques}
  end;

var
  Form2: TForm2;

implementation

{$R *.DFM}

procedure TForm2.Button1Click(Sender: TObject);
begin
    Form2.Close ;
end;

end.
