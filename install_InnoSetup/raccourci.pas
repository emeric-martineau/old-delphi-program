unit raccourci;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ExtCtrls ;

type
  TShortCutForm = class(TForm)
    ShortCutName: TLabeledEdit;
    ComboBox1: TComboBox;
    Label1: TLabel;
    Ok: TButton;
    Annuler: TButton;
    Params: TLabeledEdit;
    procedure FormCreate(Sender: TObject);
    procedure OkClick(Sender: TObject);
  private
    { Déclarations privées }
  public
    { Déclarations publiques }
  end;

var
  ShortCutForm: TShortCutForm;

implementation

uses main;

{$R *.dfm}

procedure TShortCutForm.FormCreate(Sender: TObject);
begin
    annuler.Caption := Form1.annuler.Caption ;
    Caption := TitreRaccourci ;
    Ok.Caption := BoutonOkRaccourci ;
    ShortCutName.EditLabel.Caption  := CaptionFichier ;
    Params.EditLabel.Caption := CaptionParams ;

    ComboBox1.Items := Form1.ListFile.Items ;
    ComboBox1.ItemIndex := 0 ;
end;

procedure TShortCutForm.OkClick(Sender: TObject);
begin
    if ShortCutName.Text <> ''
    then
        ModalResult := mrOk
    else
        Application.MessageBox(PChar(Erreur10Text), PChar(Erreur1Titre), MB_OK + MB_ICONERROR) ;
end;

end.
