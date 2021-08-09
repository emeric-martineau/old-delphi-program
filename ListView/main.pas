unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ComCtrls, ImgList;

type
  TForm1 = class(TForm)
    ListView1: TListView;
    ImageList1: TImageList;
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées}
  public
    { Déclarations publiques}
  end;

var
  Form1: TForm1;

implementation

{$R *.DFM}

procedure TForm1.FormCreate(Sender: TObject);
Var  ListItem: TListItem;

begin
    ListItem := ListView1.Items.Add ;
    ListItem.Caption := 'Kikoo' ;
    ListItem.SubItems.Add('Nouvelle Taille');
    ListItem.ImageIndex := 1 ;
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
