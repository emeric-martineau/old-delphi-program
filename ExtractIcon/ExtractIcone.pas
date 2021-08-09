unit ExtractIcone;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, ShellApi, StdCtrls, registry, ImgList, ComCtrls;

type
  TForm1 = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    ListView1: TListView;
    ImageList1: TImageList;
    Image1: TImage;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées}
    function ExtractFileName(chaine : String) : String ;
    function ExtractIndex(Chaine : String) : Integer ;
  public
    { Déclarations publiques}
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
//Pour extraire l'icone :
var
    Registre : TRegistry ;
    DefaultVal : String ;
    ListItem : TListItem ;
    h : hIcon;
    h2 : TIcon ;
begin
    h2 := TIcon.Create() ;
    
    { Creer la l'objet registre }
    Registre := TRegistry.Create() ;
    Registre.RootKey := HKEY_CLASSES_ROOT ;

    { Récupère les informations pour voir l'icone }
    Registre.OpenKeyReadOnly(Edit1.Text) ;
    DefaultVal := Registre.ReadString('') ; { Chape la valeur par défaut }
    Registre.CloseKey() ;
    
    { Récupère le chemin de l'icône }
    Registre.OpenKeyReadOnly(DefaultVal + '\DefaultIcon') ;
    DefaultVal := Registre.ReadString('') ; { Chope la valeur par défaut }
    Registre.CloseKey() ;

    //Caption := IntToStr(ExtractIndex(DefaultVal)) ;

    h := ExtractIcon(hInstance, PChar(ExtractFileName(DefaultVal)), Cardinal(ExtractIndex(DefaultVal)) ) ;
    DrawIcon(Image1.Canvas.Handle,0,0,h) ;

    h2.Handle := h ;

    ListItem := ListView1.Items.Add ;
    ListItem.Caption := ExtractFileName(DefaultVal) ;
    ListItem.SubItems.Add('Nouvelle Taille');
    ListItem.ImageIndex := ImageList1.AddIcon(h2) ;


end;

function TForm1.ExtractFileName(Chaine : String) : String ;
Var i : Integer ;
begin
    Result := '' ;

    for i := 1 to Length(Chaine) do
    begin
        if (Chaine[i] <> ',')
        then
            Result := Result + Chaine[i]
        else
            Break ;
    end ;

end ;

function TForm1.ExtractIndex(Chaine : String) : Integer ;
Var P : PChar ;
    i : Integer ;
begin
    Result := 0 ;

    P := StrPos(PChar(Chaine), ',') ;

    if (P <> nil)
    then begin
        P := P + 1 ; { Pointe après la virgule }
        Chaine := '' ; { On n'a plus besoin d'elle }

        For i := 0 to StrLen(P) do
            Chaine := Chaine + P[i] ;

        Result := StrToInt(Chaine) ;
    end ;

end ;

procedure TForm1.FormCreate(Sender: TObject);

begin

end;
{
Cet exemple nécessite uniquement une fiche vide.  Les autres objets :   TListView, TListColumns, TListItems sont créés dynamiquement.

procedure TForm1.FormCreate(Sender: TObject);
const
  Names: array[0..5, 0..1] of ShortString = (
    ('Rubble', 'Barney'),
    ('Michael', 'Johnson'),
    ('Bunny', 'Bugs'),
    ('Silver', 'HiHo'),
    ('Simpson', 'Bart'),
    ('Squirrel', 'Rockey')
    );

var
  I: integer;
  NewColumn: TListColumn;
  ListItem: TListItem;
  ListView: TListView;
begin
  ListView := TListView.Create(Self);
  with ListView do
  begin
    Parent := Self;
    Align := alClient;

    ViewStyle := vsReport;

    NewColumn := Columns.Add;
    NewColumn.Caption := 'Last';
    NewColumn := Columns.Add;
    NewColumn.Caption := 'First';

    for I := 0 to High(Names) do
    begin
      ListItem := Items.Add;
      ListItem.Caption := Names[I][0];
      ListItem.SubItems.Add(Names[I][1]);
    end;
  end;
end;
}
end.
