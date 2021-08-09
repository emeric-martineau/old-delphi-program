unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  ExtCtrls, StdCtrls, shellapi, ComCtrls;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    ListView1: TListView;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées}
  public
    { Déclarations publiques}
  end;

var
  Form1: TForm1;
  ImageList1 : TImageList;

implementation

{$R *.DFM}

procedure TForm1.Button1Click(Sender: TObject);
Var Bmp1 : TBitmap ;
    ShInfo1 : SHFILEINFO ;
    ListItem: TListItem;
begin
    // Voir retour fonction
    SHGetFileInfo(PChar(Edit1.Text), 0, ShInfo1, sizeOF(SHFILEINFO), SHGFI_ICON or SHGFI_SMALLICON) ;

    Bmp1 := TBitmap.Create() ;

    try
        Bmp1.Canvas.Brush.Color := GetSysColor(COLOR_WINDOW) ;
        Bmp1.Height := 16 ;
        Bmp1.Width := 16;

        DrawIconEx(Bmp1.Canvas.Handle, 0, 0, ShInfo1.hIcon, 0, 0, 0, 0, DI_NORMAL) ;

        ListItem := ListView1.Items.Add;
        ListItem.Caption := Edit1.Text ;
        ListItem.SubItems.Add('000000000000');
        ListItem.ImageIndex := ImageList1.Add(Bmp1, nil) ;

        ListView1.Columns.Items[1].AutoSize := True ;

    finally
        Bmp1.Free ;
    end ;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    ImageList1 := TImageList.Create(Self) ;
    ListView1.SmallImages := ImageList1 ;
end;

end.
