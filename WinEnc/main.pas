unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus, ComCtrls, StdCtrls, FileCtrl, ShellApi ;

type
  TForm1 = class(TForm)
    MainMenu1: TMainMenu;
    Fichier1: TMenuItem;
    Nouvellearchive1: TMenuItem;
    {
        ofAllowMultiSelect     = False
        ofCreatePrompt         = False
        ofEnableIncludeNotify  = False
        ofEnableSizing         = True
        ofExtensionDifferent   = False
        ofFileMustExist        = False
        ofHideReadOnly         = True
        ofNoChangeDir          = False
        ofNoDereferenceLinks   = False
        ofNoLongNames          = False
        ofNoNetworkButton      = False
        ofNoReadOnlyReturn     = False
        ofNoTestFileCreate     = False
        ofNoValidate           = False
        ofOldStyleDialog       = False
        ofOverwritePrompt      = False
        ofPathMustExist        = True
        ofReadOnly             = False
        ofShareAware           = False
        ofShowHelp             = False
    }
    OpenDialog1: TOpenDialog;
    ListView1: TListView;
    ListeErreurs: TMemo;
    Action1: TMenuItem;
    Ouvrirarchive1: TMenuItem;
    Ajouter1: TMenuItem;
    Fermerarchive1: TMenuItem;
    N1: TMenuItem;
    Quitter1: TMenuItem;
    N2: TMenuItem;
    Toutslectionner1: TMenuItem;
    Inverserslection1: TMenuItem;
    Aide1: TMenuItem;
    Aproposde1: TMenuItem;
    Extraire1: TMenuItem;
    Voirleserreurs1: TMenuItem;
    N3: TMenuItem;
    StatusBar1: TStatusBar;
    procedure Nouvellearchive1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Ouvrirarchive1Click(Sender: TObject);
    procedure Ajouter1Click(Sender: TObject);
    procedure Fermerarchive1Click(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure Quitter1Click(Sender: TObject);
    procedure Toutslectionner1Click(Sender: TObject);
    procedure Inverserslection1Click(Sender: TObject);
    procedure Aproposde1Click(Sender: TObject);
    procedure Extraire1Click(Sender: TObject);
    procedure Voirleserreurs1Click(Sender: TObject);
    procedure ListView1ColumnClick(Sender: TObject; Column: TListColumn);
    procedure ListView1Click(Sender: TObject);
  private
    { ** Déclarations privées ** }
    NbEtTailleFichierTotal : String ;
    procedure ShowErrorIfExists() ;
    function IgnoreExctractUUEncode(Var fichierALire : TextFile) : Cardinal ;
    function UUReadFile(nomFichierAlire : String) : Boolean ;
  public
    { ** Déclarations publiques ** }
    { Nom de l'archive en cours }
    NomArchive : String ;
    pathFile : String ;
    function StrCopyN(chaine : String; valMax : Integer) : String ;
    function StrCopyToN(chaine : String; startPos : Integer) : String ;
    function CodeOfUUD(Octet : String) : Byte ;
    function CodeOfUUE(Octet : Byte) : String ;
    procedure DisplayHint(Sender: TObject);
    function FormatSize(taille : Integer) : String ;
    function StringToInt(chaine : String) : Cardinal ;        
  end;

var
  Form1: TForm1;

implementation

uses ficheErreurs, aproposde, extraire, ajouter ;

Const TexteQuandVide = 'Choississez "Nouvelle Archive" pour créer ou "Ouvrir Archive" pour ouvrir une archive' ;

{$R *.DFM}

{*******************************************************************************
 * Menu -> Nouvelle arhive
 ******************************************************************************}
procedure TForm1.Nouvellearchive1Click(Sender: TObject);
Var ajouterFichier : TajouterFichiers ;
begin
    { Configure la boite de dialogue }
    OpenDialog1.Title := 'Nouvelle Archive' ;
    OpenDialog1.Options := OpenDialog1.Options - [ ofFileMustExist, ofAllowMultiSelect ] + [ofNoReadOnlyReturn] ;
    OpenDialog1.FilterIndex := 1 ;
    OpenDialog1.FileName := NomArchive ;
    OpenDialog1.InitialDir := pathFile ;    

    { Exécute la boite de dialogue }
    if OpenDialog1.Execute = True
    then begin
        if LowerCase(ExtractFileExt(OpenDialog1.FileName)) <> '.uue'
        then
            OpenDialog1.FileName := OpenDialog1.FileName + '.uue' ;

        { Si le fichier existe }
        if (FileExists(OpenDialog1.FileName))
        then begin
            { Demande si on le remplace. Si c'est non, on ne fait rien }
            if Application.MessageBox('Le fichier sélectionnez existe déjà. Voulez-vous le remplacer ?', 'Nouvelle archive existante', MB_YESNO + MB_ICONQUESTION) = ID_NO
            then
                Exit ;
        end ;
             
        { Affecte le nom de l'archive }
        NomArchive := OpenDialog1.FileName ;
        
        ListView1.Items.Clear ;

        { Configure la boite de dialogue }
        OpenDialog1.Title := 'Ajouter fichiers' ;
        OpenDialog1.Options := OpenDialog1.Options + [ ofFileMustExist, ofAllowMultiSelect ] - [ofNoReadOnlyReturn] ;
        OpenDialog1.FilterIndex := 2 ;
        OpenDialog1.FileName := '' ;
        OpenDialog1.InitialDir := pathFile ;

        { Exécute la boite de dialogue }
        if OpenDialog1.Execute = True
        then begin
            pathFile := ExtractFilePath(OpenDialog1.FileName) ;
            ajouterFichier := TajouterFichiers.Create(Self) ;
            ajouterFichier.Left := Left + ((Width - ajouterFichier.Width) div 2) ;
            ajouterFichier.Top := Top + ((Height - ajouterFichier.Height) div 2) ;
            ajouterFichier.AppendModeFile := False ;
            ajouterFichier.ShowModal ;
            ajouterFichier.Free ;

            { Active le menu Ajouter }
            Ajouter1.Enabled := True ;
            Extraire1.Enabled := True ;

            Caption := 'Wbtt (' + ExtractFileName(nomArchive) + ')' ;
            Application.Title := Caption ;

            ShowErrorIfExists() ;
        end ;
    end ;            
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
    { Initialise les variable }
    pathFile := '' ;
    NomArchive := '' ;

    { Gestionnaire pour afficher l'aide dans la barre d'état}
    Application.OnHint := DisplayHint;

    { Bouton de la barre des tâches }
    Application.Title := Caption ;

    { Définit l'ordre de tri }
    ListView1.Tag := -1 ;

    { Définit les raccourcis clavier }
    Ajouter1.ShortCut := ShortCut(Word('A'), [ssShift]);
    Fermerarchive1.ShortCut := ShortCut(Word('L'), [ssShift]);
    Quitter1.ShortCut := ShortCut(VK_F4, [ssAlt]);
    Extraire1.ShortCut := ShortCut(Word('E'), [ssShift]);
    Voirleserreurs1.ShortCut := ShortCut(Word('C'), [ssShift]);

    StatusBar1.SimpleTExt := TexteQuandVide ;
end;

{*******************************************************************************
 * Affiche la fenêtre d'erreur s'il y en a
 *
 * Entrée : aucun
 * Sortie : aucune
 * Retour : auncun
 ******************************************************************************}
procedure TForm1.ShowErrorIfExists() ;
Var FicheErreur : TFicheErreur ;
begin
        if ListeErreurs.Lines.Count <> 0
        then begin
            FicheErreur := TFicheErreur.Create(Self) ;
            FicheErreur.Left := Left + ((Width - FicheErreur.Width) div 2) ;
            FicheErreur.Top := Top + ((Height - FicheErreur.Height) div 2) ;

            FicheErreur.ShowModal ;
            FicheErreur.Free ;
        end ;
end ;

{*******************************************************************************
 * Menu -> Ouvrir archive
 ******************************************************************************}
procedure TForm1.Ouvrirarchive1Click(Sender: TObject);
begin
    { Configure la boite de dialogue }
    OpenDialog1.Title := 'Ouvrir archive' ;
    OpenDialog1.Options := OpenDialog1.Options + [ ofFileMustExist ] - [ofNoReadOnlyReturn, ofAllowMultiSelect] ;
    OpenDialog1.FilterIndex := 1 ;
    OpenDialog1.FileName := '' ;
    OpenDialog1.InitialDir := ExtractFilePath(NomArchive) ; ;

    if OpenDialog1.Execute = True
    then begin
        if FileExists(OpenDialog1.FileName) 
        then begin
            nomArchive := OpenDialog1.FileName ;
            
            ListView1.Items.Clear ;

            UUReadFile(OpenDialog1.FileName) ;
            ShowErrorIfExists() ;

            { Active le menu ajouter }
            Ajouter1.Enabled := True ;
            Extraire1.Enabled := True ;
            FermerArchive1.Enabled := True ;

            Caption := 'Wbtt (' + ExtractFileName(nomArchive) + ')' ;
            Application.Title := Caption ;
        end
        else
            Application.MessageBox(PChar('L''archive ' + OpenDialog1.FileName + ' est introuvable !'), 'Fichier introuvable', MB_OK + MB_ICONERROR) ;
    end ;

end;

{*******************************************************************************
 * Décode tous les fichiers contenu dans une archive
 *
 * Entrée : archive, répertoire de destination
 * Sortie : aucune
 * Retour : True si ok, False sinon
 ******************************************************************************}
function TForm1.UUReadFile(nomFichierAlire : String) : Boolean ;
Var fichierALire : TextFile ;
    ligne, debutLigne, nomDeSortie : String ;
    ListItem: TListItem;
    i, j : ShortInt ;
    Taille, TailleTotale : Cardinal ;
begin
    Result := True ;

    AssignFile(fichierALire, nomFichierALire) ;
    FileMode := 0 ;
    Reset(fichierALire) ;

    i := 1 ;
    TailleTotale := 0 ;
    
    while not Eof(fichierALire) do
    begin
        StatusBar1.SimpleText := 'Chargement en cours ' ;

        For j := 0 to i do
            StatusBar1.SimpleText := StatusBar1.SimpleText + '.' ;

        i := (i + 1) and 7 ;

        ReadLn(fichierALire, ligne) ;
        ligne := Trim(ligne) ;
        debutLigne := LowerCase(StrCopyN(ligne, 5)) ;

        Application.ProcessMessages ;

        if debutLigne = 'begin'
        then begin
             { Ajoute le fichier dans la liste de la feuille principale }
             ListItem := ListView1.Items.Add ;
             ListItem.Caption := StrCopyToN(ligne, 11) ;
             Taille := IgnoreExctractUUEncode(fichierALire) ;
             TailleTotale := TailleTotale + Taille ;
             ListItem.SubItems.Add(FormatSize(Taille)) ;

             { Lit une ligne. Normalement le end }
             ReadLn(fichierALire, ligne) ;
             ligne := LowerCase(ligne) ;

             if ligne <> 'end'
             then
                  ListeErreurs.Lines.Append('La ligne "end" n''a pas été détectée à la fin des données pour le fichier ' + nomDeSortie) ;
        end ;
    end ;

    NbEtTailleFichierTotal := 'Total ' + IntToStr(ListView1.Items.count) + ' fichiers, ' + FormatSize(TailleTotale) + ' octet(s)';
    StatusBar1.SimpleText := NbEtTailleFichierTotal ;
    CloseFile(fichierALire) ;
end ;

{*******************************************************************************
 * Ignore le flux de donnée en cours
 *
 * Entrée : Fichier à lire
 * Sortie : aucune
 * Retour : auncun
 ******************************************************************************}
function TForm1.IgnoreExctractUUEncode(Var fichierALire : TextFile) : Cardinal ;
Var ligneEnCours : String ;
begin
    Result := 0 ;

    repeat
        ReadLn(fichierALire, ligneEnCours) ;
        ligneEnCours := Trim(ligneEnCours) ;

        if ligneEnCours <> ''
        then begin
            { Si le premier caractère est compris entre '!' et 'M' }
            if (Ord(ligneEnCours[1]) > $20) and (Ord(ligneEnCours[1]) < $4E)
            then begin
                { Calcule la longueur des données de la ligne }
                Result := Result + CodeOfUUD(ligneEnCours[1]) ;
            end ;
        end ;
    until (ligneEnCours = '`') or eof(fichierALire);
end ;

{*******************************************************************************
 * Dencode un caractère en UUE
 *
 * Entrée : Octet à encoder
 * Sortie : aucune
 * Retour : Chaine de caractère contenant l'octet
 ******************************************************************************}
function TForm1.CodeOfUUD(Octet : String) : Byte ;
begin
    if (Octet  <> '`')
    then
        Result := Ord(Octet[1]) - $20  { Octet + Espace }
    else
        Result := 0 ;
end ;

{*******************************************************************************
 * Copie les X premiers caractères d'une chaine.
 * Si la chaine est plus courte que ce qu'on veut copier, c'est la chaine qui
 * est retourné.
 *
 * Entrée : chaine à copier, nombre de caractères à copier
 * Sortie : aucune
 * Retour : la chaine voulue
 ******************************************************************************}
function TForm1.StrCopyN(chaine : String; valMax : Integer) : String ;
Var i : Integer ;
begin
    Result := '' ;

    if (Length(chaine) >= valMax)
    then
        for i := 1 to valMax do
            Result := Result + chaine[i]
    else
        Result := chaine ;
end ;

{*******************************************************************************
 * Copie du caractère X à la fin de la chaine.
 * Si la position est suppérieur à la taille de la chaine, une chaine vide est
 * retournée.
 *
 * Entrée : chaine à copier, position de début de copie
 * Sortie : aucune
 * Retour : la chaine voulue
 ******************************************************************************}
function TForm1.StrCopyToN(chaine : String; startPos : Integer) : String ;
Var i : Integer ;
    lenChaine : Integer ;
begin
    Result := '' ;

    lenChaine := Length(chaine) ;

    if (lenChaine >= startPos)
    then
        for i := startPos to lenChaine do
            Result := Result + chaine[i]
    else
        Result := '' ;
end ;

{*******************************************************************************
 * Menu -> Ajouter
 ******************************************************************************}
procedure TForm1.Ajouter1Click(Sender: TObject);
Var ajouterFichier : TajouterFichiers ;
begin
        { Configure la boite de dialogue }
        OpenDialog1.Title := 'Ajouter fichiers' ;
        OpenDialog1.Options := OpenDialog1.Options + [ ofFileMustExist, ofAllowMultiSelect ] - [ofNoReadOnlyReturn] ;
        OpenDialog1.FilterIndex := 2 ;
        OpenDialog1.FileName := '' ;
        OpenDialog1.InitialDir := pathFile ;

        { Exécute la boite de dialogue }
        if OpenDialog1.Execute = True
        then begin
            pathFile := ExtractFilePath(OpenDialog1.FileName) ;
            ajouterFichier := TajouterFichiers.Create(Self) ;
            ajouterFichier.Left := Left + ((Width - ajouterFichier.Width) div 2) ;
            ajouterFichier.Top := Top + ((Height - ajouterFichier.Height) div 2) ;
            ajouterFichier.AppendModeFile := True ;
            ajouterFichier.ShowModal ;
            ajouterFichier.Free ;

            ShowErrorIfExists() ;
        end ;
end;

{*******************************************************************************
 * Menu -> Fermer archive
 ******************************************************************************}
procedure TForm1.Fermerarchive1Click(Sender: TObject);
begin
    pathFile := ExtractFilePath(NomArchive) ;
    NomArchive := '' ;
    
    ListView1.Items.BeginUpdate ;
    ListView1.Items.Clear ;
    ListView1.Items.EndUpdate ;

    { Desactive les éléments nécessaire }
    Fermerarchive1.Enabled := False ;
    Ajouter1.Enabled := False ;
    Extraire1.Enabled := False ;

    { Efface tout les messages d'erreurs }
    ListeErreurs.Lines.Clear ;

    Caption := 'Wbtt' ;
    Application.Title  := Caption ;

    StatusBar1.SimpleText := TexteQuandVide ;
    StatusBar1.SimplePanel := True ;
end;

{*******************************************************************************
 * Quand on redimensionne la fenêtre
 ******************************************************************************}
procedure TForm1.FormResize(Sender: TObject);
begin
    { redimentionne les tailles des panneaux }
    ListView1.Columns[0].Width := ListView1.ClientWidth - ListView1.Columns[1].Width ;
    StatusBar1.Panels[0].Width := StatusBar1.ClientWidth div 2 ;
    StatusBar1.Panels[1].Width := StatusBar1.Panels[0].Width ;
end;

{*******************************************************************************
 * Menu -> Quitter
 ******************************************************************************}
procedure TForm1.Quitter1Click(Sender: TObject);
Begin
    Application.Terminate ;
end;

{*******************************************************************************
 * Menu -> Tout sélectionner
 ******************************************************************************}
procedure TForm1.Toutslectionner1Click(Sender: TObject);
Var i : Integer ;
begin
    if ListView1.Items.Count > 0
    then
        For i := 0 to ListView1.Items.Count - 1 do
            ListView1.Items[i].Selected := True
end;

{*******************************************************************************
 * Menu -> Inverser sélection
 ******************************************************************************}
procedure TForm1.Inverserslection1Click(Sender: TObject);
Var i : Integer ;
begin
    if ListView1.Items.Count > 0
    then
        For i := 0 to ListView1.Items.Count - 1 do
            if ListView1.Items[i].Selected
            then
                ListView1.Items[i].Selected := False
            else
                ListView1.Items[i].Selected := True ;
end;

{*******************************************************************************
 * Menu -> A propos de ...
 ******************************************************************************}
procedure TForm1.Aproposde1Click(Sender: TObject);
Var apropos : Tapropos ;
begin
    apropos := Tapropos.Create(Self) ;
    apropos.Left := Left + ((Width - apropos.Width) div 2) ;
    apropos.Top := Top + ((Height - apropos.Height) div 2) ;
    apropos.ShowModal ;
    apropos.Free ;
end;

{*******************************************************************************
 * Menu -> Extraire
 ******************************************************************************}
procedure TForm1.Extraire1Click(Sender: TObject);
Var extraireArchive : TextraireArchive ;
begin
    if (FileExists(NomArchive))
    then begin
        if ListView1.SelCount = 0
        then
            Toutslectionner1Click(Sender) ;

        if SelectDirectory('Sélectionnez un répertoire', '', pathFile)
        //if SelectDirectory(pathFile, [sdAllowCreate, sdPerformCreate, sdPrompt], 0)
        then begin
           if pathFile[length(pathFile)] <> '\'
           then
               pathFile := pathFile + '\' ;

            extraireArchive := TextraireArchive.Create(Self) ;
            extraireArchive.Left := Left + ((Width - extraireArchive.Width) div 2) ;
            extraireArchive.Top := Top + ((Height - extraireArchive.Height) div 2) ;
            extraireArchive.ShowModal ;
            extraireArchive.Free ;

           ShowErrorIfExists() ;
        end ;
    end
    else
        Application.MessageBox(PChar('L''archive ' + NomArchive + ' est introuvable !'), 'Fichier introuvable', MB_OK + MB_ICONERROR) ;

end;

{*******************************************************************************
 * Encode un caractère en UUE
 *
 * Entrée : Octet à encoder
 * Sortie : aucune
 * Retour : Chaine de caractère contenant l'octet
 ******************************************************************************}
function TForm1.CodeOfUUE(Octet : Byte) : String ;
begin
    if (Octet <> 0)
    then
        Result := Chr(Octet + $20)  { Octet + Espace }
    else
        Result := '`' ;
end ;

procedure TForm1.Voirleserreurs1Click(Sender: TObject);
Var FicheErreur : TFicheErreur ;
begin
        FicheErreur := TFicheErreur.Create(Self) ;
        FicheErreur.Left := Left + ((Width - FicheErreur.Width) div 2) ;
        FicheErreur.Top := Top + ((Height - FicheErreur.Height) div 2) ;

        FicheErreur.ShowModal ;
        FicheErreur.Free ;
end ;

procedure TForm1.DisplayHint(Sender: TObject);
begin
  StatusBar1.SimplePanel := True ;
  StatusBar1.SimpleText := GetLongHint(Application.Hint);
end;

{*******************************************************************************
 * Format la taille des fichier
 *
 * Entrée : taille
 * Sortie : aucune
 * Retour : Chaine formatée
 ******************************************************************************}
function TForm1.FormatSize(taille : Integer) : String ;
Var i : Integer ;
    j : ShortInt ;
    chaine : String ;
begin
    chaine := IntToStr(taille) ;
    j := 0 ;
    Result := '' ;

    For i := length(chaine) downto 1 do
    Begin
        if j = 3
        then begin
            Result := ' ' + Result ;
            j := 0 ;
        end ;

        Result := chaine[i] + Result ;
        j := j + 1 ;
    End ;
end;

procedure TForm1.ListView1ColumnClick(Sender: TObject;
  Column: TListColumn);
Const Colonne : Integer = -1 ;           { Colone de la dernière fois }
      OrdreCroissant : Boolean = True ; { Odre croissant }
var i, j, NumSubItem : Integer ;
    temp : TListItems ;
    ListItem: TListItem;
    NewListView : TListView ;
    Found : Boolean ;
    Condition : Boolean ;

    { Recopie tous les sous-items et leurs propriétés }
    procedure CopieSubItem(Sender : TListView; ListItem: TListItem; i : Integer) ;
    Var k : Integer ;
    begin
        { Copie les sous items }
        For k := 0 to Sender.Items.Item[i].SubItems.Count - 1 do
        begin
            with Sender.Items.Item[i] do
            begin
                { Copie tout les élements de configurations }
                ListItem.SubItems.Add(SubItems[k]);

                if NewListView.Checkboxes
                then
                    ListItem.Checked := Checked ;

                ListItem.Cut := Cut ;
                ListItem.Data := Data ;
                ListItem.DropTarget := DropTarget ;
                ListItem.Focused := Focused ;
                ListItem.ImageIndex := ImageIndex ;
                ListItem.Indent := Indent ;
                ListItem.Left := Left ;
                ListItem.OverlayIndex := OverlayIndex ;
                ListItem.Selected := Selected ;
                ListItem.StateIndex := StateIndex ;
                ListItem.Top := Top ;
            end ;
        end ;
    end ;
begin
{
    ListItem
            -> Items (TListItems)
                    -> Item[...] (TListItem)
                                -> Caption  (String)
                                -> SubItems (TStrings)
                                           -> Count
                                           -> Strings[...] (String)
                    -> Insert
                    -> Delete
}

    { Si on clique sur la même colone, on inverse l'ordre }
    if Colonne = Column.ID
    then
        OrdreCroissant := not OrdreCroissant
    else
        OrdreCroissant := True ;

    { Mémorise la colone }
    Colonne := Column.ID ;

    { Créer une liste view }
    NewListView := TListView.Create(Self) ;
    NewListView.Visible := False ;

    { L'affecte à la feuille courante }
    NewListView.Parent := Self;
    { On mémorise s'il y a les case à cocher car lors de la recopie elles
      apparaissent sans qu'on leur demande quelque chose }
    NewListView.Checkboxes := (Sender as TListView).Checkboxes ;

    { Créer une liste }
    temp := TListItems.Create(NewListView) ;

    {** On trie la première colone **}
    if Column.ID = 0
    then begin
        { Pour chaque élement de la liste qu'on doit trier }
        For i := 0 to (Sender as TListView).Items.Count - 1 do
        begin
            { Indique qu'on n'a pas trouver de position pour l'occurence en
              cours }
            Found := False ;

            { On la trie par rapport à la nouvelle liste }
            For j := 0 to temp.Count -1 do
            begin
                {** Si l'élément se situe avant **}

                { Ci-dessous la condition quand on est en ordre croissant }
                Condition := (Sender as TListView).Items.Item[i].Caption < temp.Item[j].Caption ;

                { Si on veut l'ordre décroissant, on inverse la condition }
                if OrdreCroissant = False
                then
                    Condition := not Condition ;

                if Condition
                then begin
                    { Copie l'item principale }
                    ListItem := temp.Insert(j) ;
                    ListItem.Caption := (Sender as TListView).Items.Item[i].Caption ;

                    CopieSubItem((Sender as TListView), ListItem, i) ;

                    Found := True ;
                    { On sort de la boucle pour ne pas répéter l'élément }
                    Break ;
                end ;
            end ;

            if Found = False
            { Sinon on le copie après }
            then begin
                { Copie l'item principale }
                ListItem := temp.Add ;
                ListItem.Caption := (Sender as TListView).Items.Item[i].Caption ;

                CopieSubItem((Sender as TListView), ListItem, i) ;
            end ;
        end ;
    end
    else begin
       { Mémorise la colone dans une variable évitant ainsi de recalculer a
         chaque fois et gagnant donc du temps en exécution }
        NumSubItem := Column.ID - 1 ;

        { Pour chaque élement de la liste qu'on doit trier }
        For i := 0 to (Sender as TListView).Items.Count - 1 do
        begin
            { Indique qu'on n'a pas trouver de position pour l'occurence en
              cours }
            Found := False ;

            { On la trie par rapport à la nouvelle liste }
            For j := 0 to temp.Count -1 do
            begin
                {** Si l'élément se situe avant **}
                { Ci-dessous la condition quand on est en ordre croissant }
                {** DEBUT DU PATCH POUR WBTT **}
                if Column.ID = 1
                then
                    Condition := StringToInt((Sender as TListView).Items.Item[i].SubItems.Strings[NumSubItem]) < StringToInt(temp.Item[j].SubItems.Strings[NumSubItem])
                else
                {** FIN DU PATCH POUR WBTT **}
                    Condition := (Sender as TListView).Items.Item[i].SubItems.Strings[NumSubItem] < temp.Item[j].SubItems.Strings[NumSubItem] ;

                { Si on veut l'ordre décroissant, on inverse la condition }
                if OrdreCroissant = False
                then
                    Condition := not Condition ;

                if Condition
                then begin
                    { Copie l'item principale }
                    ListItem := temp.Insert(j) ;
                    ListItem.Caption := (Sender as TListView).Items.Item[i].Caption ;

                    CopieSubItem((Sender as TListView), ListItem, i) ;

                    Found := True ;
                    { On sort de la boucle pour ne pas répéter l'élément }
                    Break ;
                end ;
            end ;

            if Found = False
            { Sinon on le copie après }
            then begin
                { Copie l'item principale }
                ListItem := temp.Add ;
                ListItem.Caption := (Sender as TListView).Items.Item[i].Caption ;

                CopieSubItem((Sender as TListView), ListItem, i) ;
            end ;
        end ;
    end ;

    (Sender as TListView).Items.BeginUpdate ;

    (Sender as TListView).Items := NewListView.Items ;
    (Sender as TListView).Checkboxes := NewListView.Checkboxes ;

    (Sender as TListView).Items.EndUpdate ;
end;

{*******************************************************************************
 * Converti un chaine type XX XXX XXX en un entier
 *
 * Entrée : chaine
 * Sortie : aucune
 * Retour : le chiffre
 ******************************************************************************}
function TForm1.StringToInt(chaine : String) : Cardinal ;
Var i : Integer ;
    temp : String ;
begin
    temp := '' ;

    For i := 1 to length(chaine) do
        if chaine[i] <> ' '
        then
            temp := temp + chaine[i] ;

    Result := StrToInt(temp) ;
end;

procedure TForm1.ListView1Click(Sender: TObject);
Var i : Integer ;
    Taille : Cardinal ;
begin
    StatusBar1.SimpleText := 'Sélectionnés ' + IntToStr((Sender as TListView).Items.Count) + ' fichier(s), ';

    Taille := 0 ;

    For i := 0 to (Sender as TListView).Items.Count - 1 do
        if (Sender as TListView).Items[i].Selected
        then
            Taille := Taille + StringToInt((Sender as TListView).Items.Item[i].SubItems.Strings[0]) ;

    if NomArchive <> ''
    then begin
        StatusBar1.SimplePanel := False ;
        StatusBar1.Panels[0].Text := StatusBar1.SimpleText + FormatSize(Taille) + ' octet(s)' ;
        StatusBar1.Panels[1].Text := NbEtTailleFichierTotal ;
    end
    else
        StatusBar1.SimpleText := TexteQuandVide ;
end;

end.
