program ProjectTestHook;
//http://phidels.com
uses
  Forms,
  Unit1TestHookpas in 'Unit1TestHookpas.pas' {Form1};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
