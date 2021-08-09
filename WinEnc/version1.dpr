program version1;

uses
  Forms,
  main in 'main.pas' {Form1},
  ajouter in 'ajouter.pas' {ajouterFichiers},
  attendre in 'attendre.pas' {attente},
  ficheErreurs in 'ficheErreurs.pas' {ficheErreur},
  aproposde in 'aproposde.pas' {apropos},
  extraire in 'extraire.pas' {extraireArchive};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
