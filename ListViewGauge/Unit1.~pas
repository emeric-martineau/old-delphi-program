unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, CommCtrl, Gauges;

type
  TForm1 = class(TForm)
    ListView1: TListView;
    procedure FormCreate(Sender: TObject);
    procedure ListView1CustomDrawItem(Sender: TCustomListView;
      Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
    procedure ListView1CustomDraw(Sender: TCustomListView;
      const ARect: TRect; var DefaultDraw: Boolean);
  private
    { Private declarations }
    procedure WMNotify(var Message: TWMNotify); message WM_NOTIFY;
    procedure AdjustProgressBar(item: TListItem; r: TRect);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.FormCreate(Sender: TObject);
var
  i: Byte;
  r: TRect;
  pb: TGauge;
  ListItem : TListItem ;
begin

  //Ajout de lignes pour le test
  Randomize;
  for i:=0 to 40 do
  begin
    //Ajout d'un texte bidon
    ListItem := ListView1.Items.Add ;
    ListItem.Caption := 'Texte ' + IntToStr(i);

    //On récupère le rectangle d'affichage de l'élément
    //Il sera utilisé pour mettre la progressbar à la bonne taille
    r := ListItem.DisplayRect(drBounds);

    //Création et initialisation de la progressbar
    pb := TGauge.Create(Self);
    pb.Parent := Listview1;
    //Ici, c'est juste pour avoir des positions différentes
    pb.Progress := Random(pb.MaxValue);
    pb.ForeColor := clHighlight ;
    pb.Color := clHighlight;
    pb.BackColor := clWindow ;
    pb.BorderStyle := bsSingle ;

    //On stoque la progressbar dans la propriété Data de l'élément
    //afin de pouvoir la récupérer plus tard
    ListItem.Data := pb;
    ListItem.SubItems.Add('Complet') ;

    ListItem.SubItems.Add('45') ;
    ListItem.SubItems.Add('erer') ;

    AdjustProgressBar(ListItem, r);
  end;
end;

{*******************************************************************************
 * Procédure qui capture le message de "colonne resize" afin d'adapter la taille
 * de toutes les progressbar de la listview.
 ******************************************************************************}
procedure TForm1.WMNotify(var Message: TWMNotify);
var i : Integer ;
    r : TRect ;
begin
    case Message.NMHdr.code of
        HDN_ITEMCHANGED, HDN_ITEMCHANGING :
                                           { Pour plus d'infos sur les différents
                                             messages des headers pour les listview,
                                             ce rapporter ici : (en anglais)
                                             http://msdn.microsoft.com/library/default.asp?url=/library/en-us/shellcc/platform/commctls/header/notifications/hdn_itemchanged.asp
                                           }
                                           begin
                                               for i := 0 to Listview1.Items.Count-1 do
                                               begin
                                                   r := Listview1.Items[i].DisplayRect(drBounds) ;
                                                   AdjustProgressBar(Listview1.Items[i], r) ;
                                               end ;

                                               { On force le repaint de la listview
                                                 pour éviter un bug d'affichage : il
                                                 affichait des progressbar dans le
                                                 header de la colonne.
                                                 L'inconvénient est que le repaint
                                                 clignote un peu dans ce cas. :(
                                               }
                                               { NOTE : Ayant modifier le code de
                                                 la procédure de dessin des éléments
                                                 on n'a plus le problème.
                                                 Le fait de repaindre fait clignoter
                                               }  
                                               //ListView1.Repaint;
                                           end ;
    end;

    { Appèle la procédure dont on irrite }
    inherited;
end;

{*******************************************************************************
 * Fonction appelé pour mettre à jour un item
 ******************************************************************************}
procedure TForm1.ListView1CustomDrawItem(Sender: TCustomListView;
  Item: TListItem; State: TCustomDrawState; var DefaultDraw: Boolean);
var r : TRect ;
begin
    // Renvoie le rectangle de délimitation de la totalité de l'élément de la liste, y compris le libellé et l'icône
    r := Item.DisplayRect(drBounds);

    // On teste si le rectangle de l'élément se trouve en dessous du header des colonnes.
    // Sinon, il affiche les progressbar sur les colonnes
    if r.Top >= (TListview(Sender).BoundsRect.Top - TListview(Sender).Top)
    then
        AdjustProgressBar(Item, r) ;
end;

{*******************************************************************************
 * Procédure qui met à jour la taille de la ProgressBar en fonction du rectangle
 * d'affichage de l'élément qui contient la ProgressBar et en fonction de la
 * taille de la colonne dans laquelle on met la progressbar (ici, la 2ème colonne).
 ******************************************************************************}
procedure TForm1.AdjustProgressBar(item: TListItem; r: TRect);
var pb: TGauge;
    ParentListView : TListView ;
begin
    ParentListView := TListView(Item.ListView) ;

    r.Left := r.Left + ParentListView.columns[0].Width;
    r.Right := r.Left + ParentListView.columns[1].Width;
    pb := item.Data;

    if pb.Progress < 100
    then begin
        // BUG : Laisse la dernière barre de progression affichée
        //  if item.Index in [ListView1.TopItem.Index..ListView1.TopItem.Index + ListView1.VisibleRowCount-1]
        if item.Index in [(ParentListView.TopItem.Index)..(ParentListView.TopItem.Index + ParentListView.VisibleRowCount)]
        then begin
            pb.BoundsRect := r ;
            pb.Visible := true ;
        end
        else
            pb.Visible := false ;
    end
    else
        pb.Visible := false ;
end;

procedure TForm1.ListView1CustomDraw(Sender: TCustomListView;
  const ARect: TRect; var DefaultDraw: Boolean);
Var i : Integer ;
    pb : TGauge;
begin
    // Cache les barres de progression
    for i := 0 to TListView(Sender).Items.Count - 1 do
    begin
        pb := TListView(Sender).Items.Item[i].Data ;

        if pb.Progress < 100
        then begin
            if TListView(Sender).Items.Item[i].Index in [(TListView(Sender).TopItem.Index)..(TListView(Sender).TopItem.Index + TListView(Sender).VisibleRowCount)]
            then begin
                pb.Visible := true ;
            end
            else
                pb.Visible := false ;
        end
        else
            pb.Visible := False ;
    end ;
end;

end.
