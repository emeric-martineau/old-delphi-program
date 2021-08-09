unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ficheErreurs;

type
  TmainForm = class(TForm)
    Button1: TButton;
    Edit1: TEdit;
    Label1: TLabel;
    Edit2: TEdit;
    Button2: TButton;
    Edit3: TEdit;
    Label2: TLabel;
    Edit4: TEdit;
    CheckBox1: TCheckBox;
    ListeErreurs: TMemo;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    { Déclarations privées}
    function UUEncodeFile(nomFichierAEncoder : String; nomFichierDestination : String; AppendVar : Boolean) : Boolean;
    function CodeOfUUE(Octet : Byte) : String ;
    function UUDecodeFile(nomFichierAlire : String; repertoireDestination : string) : Boolean ;
    function StrCopyN(chaine : String; valMax : Integer) : String ;
    function StrCopyToN(chaine : String; startPos : Integer) : String ;
    function ExtractUUEncode(nomDeSortie : String; repertoireDestination : String; Var fichierALire : TextFile) : Boolean;
    function CodeOfUUD(Octet : String) : Byte ;
    procedure IgnoreExctractUUEncode(Var fichierALire : TextFile) ;
    procedure ShowErrorIfExists() ;    
  public
    { Déclarations publiques}
  end;


var
  mainForm: TmainForm;
  FichierErreur : TFicheErreur ;

implementation

{$R *.DFM}

{*******************************************************************************
 * Lit un fichier et l'encode en l'enregstrant dans un autres fichiers.
 *
 * Entrée : nom du fichier à encoder, nom du fichier destination
 * Sortie : aucune
 * Retour : True si aucune erreur, False sinon
 ******************************************************************************}
function TmainForm.UUEncodeFile(nomFichierAEncoder : String; nomFichierDestination : String;  AppendVar : Boolean) : Boolean ;
Var FichierALire : File ;
    FichierAEcrire : TextFile ;
    NbDeCarLu : Integer ;
    Buffer : Array[0..44] of Byte ;
    ChaineEncodee : String[64] ;
    i : Integer ;
    c1, c2, c3 : Byte ;
begin
    Result := True ;

    { Ouvre le fichier à lire }
    AssignFile(FichierALire, nomFichierAEncoder) ;
    Reset(FichierALire, 1) ;          { voir ce qui se passe à 45 au lieu de 1 }

    { Ouvre le fichier à écrire }
    AssignFile(FichierAEcrire, nomFichierDestination) ;

    if (AppendVar = True)
    then
        Append(FichierAEcrire)
    else
        Rewrite(FichierAEcrire) ;

    { Ecrit l'entête }
    WriteLn(FichierAEcrire, 'begin 666 ' + ExtractFileName(nomFichierAEncoder)) ;

    repeat
        { Lit 45 Caractères }
        BlockRead(FichierALire, Buffer, 45, NbDeCarLu) ;

        { Configure le premier caractère en fonction du nombre de caractères
          lu. Espace + NbDeCarLu }
        ChaineEncodee := Char($20 + NbDeCarLu) ;

        { Encode les caractère }
        i := 0 ;
        repeat
            { Définit la valeur du premier octet à encoder }
            if i < NbDeCarLu
            then
                c1 := Buffer[i]
            else
                c1 := 0 ;

            { Définit la valeur du premier deuxième à encoder }
            if ((i + 1) < NbDeCarLu)
            then
                c2 := Buffer[i + 1]
            else
                c2 := 0 ;

            { Définit la valeur du troisième octet à encoder }
            if ((i + 2) < NbDeCarLu)
            then
                c3 := Buffer[i + 2]
            else
                c3 := 0 ;

            ChaineEncodee := ChaineEncodee + CodeOfUUE(c1 shr 2) + CodeOfUUE(((c1 and 3) shl 4) or ((c2 shr 4) and 15)) + CodeOfUUE(((c2 shl 2) and 60) or ((c3 shr 6) and 3)) + CodeOfUUE(c3 and 63);

            { Saute aux trois prochains caractères }
            i := i + 3 ;
        until (i >= NbDeCarLu) ; { On encode tant qu'on n'a pas tout encodé }

        { Ecrit la chaine encodée }
        WriteLn(FichierAEcrire, ChaineEncodee) ;
    until (NbDeCarLu < 45) ; { S'il  a moins de 45 caractères, c'est qu'on est à la fin du fichier }

    { Ecrit le pied de page }
    WriteLn(FichierAEcrire, '`') ;
    WriteLn(FichierAEcrire, 'end') ;

    {Ferme les fichiers }
    CloseFile(FichierALire) ;
    CloseFile(FichierAEcrire) ;
end ;

procedure TmainForm.Button1Click(Sender: TObject);
begin
    if (FileExists(Edit1.Text))
    then begin
        UUEncodeFile(Edit1.Text, Edit2.Text, CheckBox1.Checked) ;
        ShowErrorIfExists() ;
    end
    else
       Application.MessageBox(PChar('Le fichier ' + Edit1.Text + ' est introuvable !'), 'Fichier introuvable', MB_OK + MB_ICONERROR) ;

end;

{*******************************************************************************
 * Encode un caractère en UUE
 *
 * Entrée : Octet à encoder
 * Sortie : aucune
 * Retour : Chaine de caractère contenant l'octet
 ******************************************************************************}
function TmainForm.CodeOfUUE(Octet : Byte) : String ;
begin
    if (Octet <> 0)
    then
        Result := Chr(Octet + $20)  { Octet + Espace }
    else
        Result := '`' ;
end ;

procedure TmainForm.Button2Click(Sender: TObject);
begin
    if (FileExists(Edit3.Text))
    then begin
        UUDecodeFile(Edit3.Text, Edit4.Text) ;
        ShowErrorIfExists() ;
    end
    else
        Application.MessageBox(PChar('Le fichier ' + Edit3.Text + ' est introuvable !'), 'Fichier introuvable', MB_OK + MB_ICONERROR) ;
end;

{*******************************************************************************
 * Décode tous les fichiers contenu dans une archive
 *
 * Entrée : archive, répertoire de destination
 * Sortie : aucune
 * Retour : True si ok, False sinon
 ******************************************************************************}
function TmainForm.UUDecodeFile(nomFichierAlire : String; repertoireDestination : string) : Boolean ;
Var fichierALire : TextFile ;
    ligne, debutLigne, nomDeSortie : String ;
    retourMessageBox : Integer ;
begin

    Result := True ;

    AssignFile(fichierALire, nomFichierALire) ;
    Reset(fichierALire) ;

    while not Eof(fichierALire) do
    begin
        ReadLn(fichierALire, ligne) ;
        ligne := Trim(ligne) ;
        debutLigne := LowerCase(StrCopyN(ligne, 5)) ;

        if debutLigne = 'begin'
        then begin
             nomDeSortie := StrCopyToN(ligne, 11) ;

             { Vérifie que le fichier de destination n'existe pas }
             if (FileExists(repertoireDestination + nomDeSortie))
             then begin
                 retourMessageBox := Application.MessageBox(PChar('Le fichier ' + repertoireDestination + nomDeSortie + ' existe déjà. Voulez-vous le remplacer ?'), 'Fichier déjà existant', MB_ICONQUESTION + MB_YESNOCANCEL) ;

                 if (retourMessageBox = IDYES)
                 then begin
                     { Remplace le fichier }
                     if ExtractUUEncode(nomDeSortie, repertoireDestination, fichierALire) = False
                     then begin
                         Result := False ;
                         CloseFile(fichierALire) ;                         
                         exit ;
                     end
                 end
                 else if (retourMessageBox = IDNO)
                 then
                     IgnoreExctractUUEncode(fichierALire)
                 else begin
                     Result := False ;
                     CloseFile(fichierALire) ;
                     { Quitte la fonction }
                     exit ;
                 end ;
             end
             else begin
                 if ExtractUUEncode(nomDeSortie, repertoireDestination, fichierALire) = False
                 then begin
                     Result := False ;
                     CloseFile(fichierALire) ;                     
                     exit ;
                 end ;
             end ;

             { Lit une ligne. Normalement le end }
             ReadLn(fichierALire, ligne) ;
             ligne := LowerCase(ligne) ;

             if ligne <> 'end'
             then
                  ListeErreurs.Lines.Append('La ligne "end" n''a pas été détectée à la fin des données pour le fichier ' + nomDeSortie) ;
        end ;
    end ;

    CloseFile(fichierALire) ;
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
function TmainForm.StrCopyN(chaine : String; valMax : Integer) : String ;
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
function TmainForm.StrCopyToN(chaine : String; startPos : Integer) : String ;
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
 * Décode les information dans un fichier à partir de la position de la dernière
 * ligne.
 * Après appel de la fonction, si tout c'est bien passé, la ligne courante du
 * fichier est la ligne end.
 *
 * Entrée : Nom de sortie du fichier, répertoire de de destination, fichier à lire
 * Sortie : aucune
 * Retour : False en cas d'erreur
 ******************************************************************************}
function TmainForm.ExtractUUEncode(nomDeSortie : String; repertoireDestination : String; Var fichierALire : TextFile) : Boolean;
Var Buffer : Array[0..45] of Byte;
    ligneEncours : String ;
    fichierAEcrire : File ;
    longueurLigneEnCours : Integer ;
    longueurPresume : Integer ;
    longueurBuffer : Integer ;
    tailleFichier  : Integer ;
    i, j : Integer ;
    c1, c2, c3, c4 : Byte ;
    nbCarEcrit : Integer ;
begin
    Result := True ;
    
    { Ouvre le fichier a écrire }
    AssignFile(fichierAEcrire, repertoireDestination + nomDeSortie) ;
    Rewrite(fichierAEcrire, 1) ;

    { Initialise la taille du fichier à 0 }
    tailleFichier := 0 ;

    repeat
        { Lit une ligne du fichier }
        repeat
            ReadLn(fichierALire, ligneEnCours) ;
            ligneEnCours := Trim(ligneEnCours) ;

            if ligneEnCours = ''
            then
                 ListeErreurs.Lines.Append('Une ligne vide a été détectée dans le flux de données du fichier ' + nomDeSortie + '. Ligne ignorée.') ;

        until ligneEnCours <> '';   { Si on rencontre une ligne vide, on l'ignore}

        ligneEnCours := Trim(ligneEncours) ;

        if (ligneEnCours <> '`')
        then begin
            longueurLigneEncours := length(ligneEnCours) ;

            { Si le premier caractère est compris entre '!' et 'M' }
            if (Ord(ligneEnCours[1]) > $20) and (Ord(ligneEnCours[1]) < $4E)
            then begin
                { Calcule la longueur des données de la ligne }
                longueurBuffer := CodeOfUUD(ligneEnCours[1]) ;

                { Calcule la longueur présumé de la ligne.
                  Longueur des données /3 * 4 -> transcrit 3 caractère pour 4.
                  Il faut ajouter 4 caractères s'il y a une reste. + 1 pour l'
                  octet de longueur. }
                longueurPresume := ((longueurBuffer div 3) * 4) + 1 ;

                if (longueurBuffer mod 3) > 0
                then
                    longueurPresume := longueurPresume + 4 ;

                if longueurPresume <> longueurLigneEncours
                then begin
                    ListeErreurs.Lines.Append('La longueur indiqué par l''indicateur de longueur de la ligne ne correspond pas à la longueur réelle de la ligne. Ligne ignorée.') ;
                end
                else begin
                    tailleFichier := tailleFichier + longueurBuffer ;

                    i := 2 ;
                    j := 0 ;

                    repeat
                        c1 := CodeOfUUD(ligneEncours[i]) ;
                        c2 := CodeOfUUD(ligneEncours[i + 1]) ;
                        c3 := CodeOfUUD(ligneEncours[i + 2]) ;
                        c4 := CodeOfUUD(ligneEncours[i + 3]) ;

                        Buffer[j] := (c1 shl 2) or ((c2 and 48) shr 4) ;
                        Buffer[j + 1] := ((c2 and 15) shl 4) or (c3 shr 2) ;
                        Buffer[j + 2] := ((c3 and 3) shl 6) or c4 ;

                        i := i + 4 ;
                        j := j + 3 ;
                    until (i >= longueurLigneEnCours) ;

                    BlockWrite(fichierAEcrire, Buffer, longueurBuffer, nbCarEcrit) ;
                end ;
            end
            else
                ListeErreurs.Lines.Append('Un indicateur de longueur de ligne est erroné dans le flux de données du fichier ' + nomDeSortie + '. Ligne ignorée.') ;
        end ;
    until (ligneEnCours = '`') ;

    { Vérifie que la taille extaite du fichier est la taille sur le disque dur }
    if FileSize(fichierAEcrire) <> tailleFichier
    then
        if Application.MessageBox(PChar('La taille des données extraites du fichier ' + repertoireDestination + nomDeSortie + ' ne correspondent pas à sa taille sur le disque ! Voulez-vous continuer l''extraction ?'#10#13'(Le fichier ne sera pas supprimé)'), 'Erreur', MB_ICONERROR + MB_YESNO) = IDNO
        then
             Result := False ;

    CloseFile(fichierAEcrire) ;
end ;

{*******************************************************************************
 * Dencode un caractère en UUE
 *
 * Entrée : Octet à encoder
 * Sortie : aucune
 * Retour : Chaine de caractère contenant l'octet
 ******************************************************************************}
function TmainForm.CodeOfUUD(Octet : String) : Byte ;
begin
    if (Octet  <> '`')
    then
        Result := Ord(Octet[1]) - $20  { Octet + Espace }
    else
        Result := 0 ;
end ;

procedure TmainForm.FormCreate(Sender: TObject);
begin
end;

{*******************************************************************************
 * Ignore le flux de donnée en cours
 *
 * Entrée : Fichier à lire
 * Sortie : aucune
 * Retour : auncun
 ******************************************************************************}
procedure TmainForm.IgnoreExctractUUEncode(Var fichierALire : TextFile) ;
Var ligneEnCours : String ;
begin
    repeat
        ReadLn(fichierALire, ligneEnCours) ;
        ligneEnCours := Trim(ligneEnCours) ;
    until ligneEnCours = '`';   { Si on rencontre une ligne vide, on l'ignore}
end ;

{*******************************************************************************
 * Affiche la fenêtre d'erreur s'il y en a
 *
 * Entrée : aucun
 * Sortie : aucune
 * Retour : auncun
 ******************************************************************************}
procedure TmainForm.ShowErrorIfExists() ;
begin
        if ListeErreurs.Lines.Count <> 0 
        then begin
            FicheErreur := TFicheErreur.Create(Self) ;
            FicheErreur.ShowModal ;
            FicheErreur.Free ;
        end ;
end ;

end.

