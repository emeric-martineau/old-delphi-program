program SWISS;

uses
  Forms,
  main in 'main.pas' {Form1},
  raccourci in 'raccourci.pas' {ShortCutForm};

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
