unit ficheErreurs;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, Clipbrd;

type
  TficheErreur = class(TForm)
    Panel1: TPanel;
    ListeErreurs: TMemo;
    Button2: TButton;
    Button1: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées}
  public
    { Déclarations publiques}
  end;

var
  ficheErreur: TficheErreur;

implementation

uses main;

{$R *.DFM}

procedure TficheErreur.Button1Click(Sender: TObject);
begin
    Close() ;
end;

procedure TficheErreur.Button2Click(Sender: TObject);
Var i : Integer ;
    Clipboard : TClipboard ;
    c : String ;
begin
    Clipboard := TClipboard.Create() ;
    c := '' ;

    for i := 0 to ListeErreurs.Lines.Count do
        c := c + ListeErreurs.Lines[i] + Char(13) + Char(10) ;

Clipboard.SetTextBuf(PChar(c)) ;
end;

procedure TficheErreur.FormCreate(Sender: TObject);
begin
      ListeErreurs.Lines := Form1.ListeErreurs.Lines ;
end;

end.
