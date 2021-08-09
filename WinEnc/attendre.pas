{*******************************************************************************
 * Unité : attente
 *
 * Attend qu'on appuit sur le bouton Reprendre pour reprendre l'ajout ou
 * l'extraction des fichiers.
 ******************************************************************************}
unit attendre;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, StdCtrls;

type
  Tattente = class(TForm)
    Label1: TLabel;
    fichierEnCours: TLabel;
    Annuler: TButton;
    Reprendre: TButton;
    Reduire: TButton;
    ProgressBar1: TProgressBar;
    procedure FormShow(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure ReprendreClick(Sender: TObject);
    procedure ReduireClick(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure AnnulerClick(Sender: TObject);
  private
    { Déclarations privées}
  public
    { Déclarations publiques}
    toClose : ^Boolean ;
  end;

var
  attente: Tattente;

implementation

{$R *.DFM}

procedure Tattente.FormShow(Sender: TObject);
begin
    Left := (Owner as TForm).Left ;
    Top := (Owner as TForm).Top ;
end;

procedure Tattente.FormClose(Sender: TObject; var Action: TCloseAction);
begin
    (Owner as TForm).Left := Left ;
    (Owner as TForm).Top := Top ;
end;

procedure Tattente.ReprendreClick(Sender: TObject);
begin
  Close() ;
end;

procedure Tattente.ReduireClick(Sender: TObject);
begin
    { Réduit toute les fenêtres }
    ((Owner as TForm).Owner as TForm).WindowState := wsMinimized ;
    (Owner as TForm).WindowState := wsMinimized ;
    WindowState := wsMinimized ;
end;

procedure Tattente.FormResize(Sender: TObject);
begin
    { Réaffiche toute les fenêtres }
    ((Owner as TForm).Owner as TForm).WindowState := wsNormal ;
    (Owner as TForm).WindowState := wsNormal ;
    WindowState := wsNormal ;
end;

procedure Tattente.AnnulerClick(Sender: TObject);
begin
  toClose^ := True ;
end;

end.
