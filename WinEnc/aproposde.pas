unit aproposde;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, ShellApi;

type
  Tapropos = class(TForm)
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Panel1: TPanel;
    Label7: TLabel;
    Label8: TLabel;
    Label9: TLabel;
    Button1: TButton;
    Label4: TLabel;
    procedure Label9Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées}
  public
    { Déclarations publiques}
  end;

var
  apropos: Tapropos;

implementation

{$R *.DFM}

procedure Tapropos.Label9Click(Sender: TObject);
begin
    ShellExecute(Handle, 'OPEN', 'http://php4php.free.fr/winenc/','','',SW_SHOWNORMAL);
end;

procedure Tapropos.Button1Click(Sender: TObject);
begin
    Close ;
end;

procedure Tapropos.FormCreate(Sender: TObject);
begin
Label4.Caption := 'Wbtt (Windows Binary To Texte) est un'#10#13'programme gratuit. Vous pouvez librement'#10#13'le copier et le diffuser librement.'#10#13'Il est interdit de le modifier ou de le décompiler'#10#13'sans accord préalable de l''auteur.'
end;

end.
