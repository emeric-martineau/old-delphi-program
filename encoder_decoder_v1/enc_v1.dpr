program enc_v1;

uses
  Forms,
  main in 'main.pas' {mainForm},
  ficheErreurs in 'ficheErreurs.pas' {ficheErreur};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TmainForm, mainForm);
  Application.Run;
end.
