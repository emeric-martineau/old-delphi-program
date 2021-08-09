{
  Copyright (C) 2002 MARTINEAU Emeric

  Ce programme est libre, vous pouvez le redistribuer et/ou le modifier selon
  les termes de la Licence Publique Générale GNU publiée par la Free Software
  Foundation version 2.

  Ce programme est distribué car potentiellement utile, mais SANS AUCUNE
  GARANTIE, ni explicite ni implicite, y compris les garanties de
  commercialisation ou d'adaptation dans un but spécifique. Reportez-vous à
  la Licence Publique Générale GNU pour plus de détails.
}
unit main;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ComCtrls, Registry;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Button2: TButton;
    PageControl1: TPageControl;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    affichage_NoDispCPL: TCheckBox;
    affichage_Options: TGroupBox;
    affichage_NoDispBackgroudPage: TCheckBox;
    affichage_NoDispAppearencePage: TCheckBox;
    affichage_NoDispSettingsPage: TCheckBox;
    affichage_NoDispScrSavPage: TCheckBox;
    Button3: TButton;
    imprimante_NoAddPrinter: TCheckBox;
    imprimante_NoDeletePrinter: TCheckBox;
    imprimante_NoPrinterTab: TCheckBox;
    TabSheet3: TTabSheet;
    systeme_NoDevMgrPage: TCheckBox;
    systeme_performances: TGroupBox;
    systeme_NoFileSysPage: TCheckBox;
    systeme_NoVirtMemPage: TCheckBox;
    systeme_NoConfigPage: TCheckBox;
    TabSheet4: TTabSheet;
    password_NoSecCPL: TCheckBox;
    password_Options: TGroupBox;
    password_NoPwdPage: TCheckBox;
    procedure FormCreate(Sender: TObject);
    procedure affichage_NoDispCPLClick(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  private
    { Déclarations privées}
    { Affichage }
    function lectureProprieteAffichage() : boolean ;
    function ecritureProprieteAffichage() : boolean ;
    { Imprimante }
    function lectureProprieteImprimante() : boolean ;
    function ecritureProprieteImprimante() : boolean ;
    { Propriété système }
    function lectureProprieteSysteme() : boolean ;
    function ecritureProprieteSysteme() : boolean ;
    { Mot de passe }
    function lectureProprieteMotDePasse() : boolean ;

  public
    { Déclarations publiques}
  end;

var
  Form1: TForm1;
const
  { Constantes pour le panneau Affichage }
  AFFICHAGE_PATH : string = 'Software\Microsoft\Windows\CurrentVersion\Policies\System\' ;
  CPL            : string = 'NoDispCPL' ;
  BackgroundPage : string = 'NoDispBackgroundPage' ;
  AppearencePage : string = 'NoDispAppearancePage' ;
  SettingsPage   : string = 'NoDispSettingsPage' ;
  ScrSavPage     : string = 'NoDispScrSavPage' ;

  { Constantes pour le panneau Imprimantes }
  IMPRIMANTE_PATH : string = 'Software\Microsoft\Windows\CurrentVersion\Policies\Explorer\' ;
  AddPrinter      : string = 'NoAddPrinter' ;
  DeletePrinter   : string = 'NoDeletePrinter';
  PrinterTab      : string = 'NoPrinterTab' ;

  { Constantes pour l'accès aux propriétés système }
  SYSTEME_PATH : string = 'Software\Microsoft\Windows\CurrentVersion\Policies\System\' ;
  DevMgrPage   : string = 'NoDevMgrPage' ;
  ConfigPage   : string = 'NoConfigPage' ;
  FileSysPage  : string = 'NoFileSysPage' ;
  VirtMemPage  : string = 'NoVirtMemPage' ;

  { Constantes pour l'accès aux mots de passe }
  MDP_PATH : string = 'Software\Microsoft\Windows\CurrentVersion\Policies\System\' ;
  SecCPL  : string = 'NoSecCPL' ;
  PwdPage : string = 'NoPwdPage' ;


implementation

uses a_propos_de;

{$R *.DFM}

{*****************************************************************************
 * Procédure appelée lors de la création de la fenêtre principale
 *****************************************************************************}
procedure TForm1.FormCreate(Sender: TObject);
begin
    { Ne fonctionne pas ???
    Screen.Cursors[crHandPoint] := LoadCursor(HInstance, PCHAR('NEWHAND')); }


    { Lecture des paramètre pour l'affichage }
    lectureProprieteAffichage() ;
    { Lecture des paramètre pour les imprimantes }
    lectureProprieteImprimante() ;
    { Lecture des paramètre pour les propriétés système }
    lectureProprieteSysteme() ;
    { Lecture des paramètres pour les mots de passe }
    lectureProprieteMotDePasse() ;

end;

{*****************************************************************************
 * Fonction qui lit les valeus dans la base de registre et paramètre les
 * objets en conséquence pour le panneau affichage.
 *****************************************************************************
 * Retourne True si le chargement s'est bien passé, sinon False
 *****************************************************************************}
function TForm1.lectureProprieteAffichage() : boolean ;
var registre : TRegistry ;
begin
    // Créer un objet de type registre
    registre := TRegistry.Create ;
    // par défaut on n'a pas réussi
    lectureProprieteAffichage := False ;
    try
        // définit la clef racine
        Registre.RootKey := HKEY_CURRENT_USER ;

        // Ouvre la clef
        if registre.OpenKeyReadOnly(AFFICHAGE_PATH)
        then begin
             { Activation du panneau d'affichage }
             if registre.ValueExists(CPL)
             then begin
                 if (registre.ReadInteger(CPL) <> 0)
                 then begin
                     { Par défaut, la case n'est pas cochée }
                     affichage_NoDispCPL.Checked := True ;
                     { Désactive les options du panneau d'affichage }
                     affichage_Options.Enabled := False ;
                 end
                 else begin
                     { Onglet Arrière-plan }
                     if registre.ValueExists(BackgroundPage)
                     then begin
                         if (registre.ReadInteger(BackgroundPage) <> 0)
                         then begin
                             { Par défaut, la case n'est pas cochée }
                             affichage_NoDispBackgroudPage.Checked := True ;
                         end ;
                     end ;

                     { Onglet Apparence }
                     if registre.ValueExists(AppearencePage)
                     then begin
                         if (registre.ReadInteger(AppearencePage) <> 0)
                         then begin
                             { Par défaut, la case n'est pas cochée }
                             affichage_NoDispAppearencePage.Checked := True ;
                         end ;
                     end ;

                     { Onglet Effets, Web, Paramètres }
                     if registre.ValueExists(SettingsPage)
                     then begin
                         if (registre.ReadInteger(SettingsPage) <> 0)
                         then begin
                             { Par défaut, la case n'est pas cochée }
                             affichage_NoDispSettingsPage.Checked := True ;
                         end ;
                     end ;

                     { Onglet Ecran de veille }
                     if registre.ValueExists(ScrSavPage)
                     then begin
                         if (registre.ReadInteger(ScrSavPage) <> 0)
                         then begin
                             { Par défaut, la case n'est pas cochée }
                             affichage_NoDispScrSavPage.Checked := True ;
                         end ;
                     end ;
                     
                     lectureProprieteAffichage := True ;

                 end ;
             end ;

        end
        else begin
             { On créer le chemin complet ! }
             if (registre.CreateKey(AFFICHAGE_PATH) <> true)
             then begin
                 { Une erreur s'est produite, on ne peut donc pas logiquement
                   écrire dans la bas de registre :-( }
                 Application.MessageBox(
                             'Impossible d''écrire dans la base de registre !',
                             'Erreur', MB_OK + MB_ICONERROR) ;
             end ;
        end ;
    finally
        // libère le registre
        Registre.Free ;
    end ;

end;

{*****************************************************************************
 * Fonction qui écrit les valeus dans la base de registre pour le panneau
 * Affichage.
 *****************************************************************************
 * Retourne True si le chargement s'est bien passé, sinon False
 *****************************************************************************}
function TForm1.ecritureProprieteAffichage() : boolean ;
var registre : TRegistry ;
begin
    // Créer un objet de type registre
    registre := TRegistry.Create ;
    // par défaut on n'a pas réussi
    ecritureProprieteAffichage := False ;
    try
        // définit la clef racine
        Registre.RootKey := HKEY_CURRENT_USER ;

        // Ouvre la clef
        if registre.OpenKey(AFFICHAGE_PATH, True)
        then begin
             { Activation du panneau d'affichage }
             if affichage_NoDispCPL.Checked
             then begin
                     registre.WriteInteger(CPL, 1) ;
             end
             else begin
                 registre.WriteInteger(CPL, 0) ;
                 { Onglet Arrière-plan }
                 if affichage_NoDispBackgroudPage.Checked
                 then begin
                     registre.WriteInteger(BackgroundPage, 1) ;
                 end
                 else begin
                     registre.WriteInteger(BackgroundPage, 0) ;
                 end ;

                 { Onglet Apparence }
                 if affichage_NoDispAppearencePage.Checked
                 then begin
                     registre.WriteInteger(AppearencePage, 1) ;
                 end
                 else begin
                     registre.WriteInteger(AppearencePage, 0) ;
                 end ;

                 { Onglet Effets, Web, Paramètres }
                 if affichage_NoDispSettingsPage.Checked
                 then begin
                     registre.WriteInteger(SettingsPage, 1) ;
                 end
                 else begin
                     registre.WriteInteger(SettingsPage, 0) ;
                 end ;

                 { Onglet Ecran de veille }
                 if affichage_NoDispScrSavPage.Checked
                 then begin
                     registre.WriteInteger(ScrSavPage, 1) ;
                 end
                 else begin
                     registre.WriteInteger(ScrSavPage, 0) ;
                 end ;

             end ;

             ecritureProprieteAffichage := True ;
        end
        else begin
                 { Une erreur s'est produite, on ne peut donc pas logiquement
                   écrire dans la bas de registre :-( }
                 Application.MessageBox('Impossible d''écrire dans la base de registre !','Erreur', MB_OK + MB_ICONERROR) ;
        end ;
    finally
        // libère le registre
        Registre.Free ;
    end ;

end ;

{*****************************************************************************
 * Fonction qui lit les valeus dans la base de registre pour les imprimantes
 *****************************************************************************
 * Retourne True si le chargement s'est bien passé, sinon False
 *****************************************************************************}
function TForm1.lectureProprieteImprimante() : boolean ;
var registre : TRegistry ;
begin
    // Créer un objet de type registre
    registre := TRegistry.Create ;
    // par défaut on n'a pas réussi
    lectureProprieteImprimante := False ;
    try
        // définit la clef racine
        Registre.RootKey := HKEY_CURRENT_USER ;

        // Ouvre la clef
        if registre.OpenKeyReadOnly(IMPRIMANTE_PATH)
        then begin
            { Ajout d'imprimante }
            if registre.ValueExists(AddPrinter)
            then begin
                if (registre.ReadInteger(AddPrinter) <> 0)
                then begin
                    { Par défaut, la case n'est pas cochée }
                     imprimante_NoAddPrinter.Checked := True ;
                end ;
            end ;

            { Suppression d'imprimante }
            if registre.ValueExists(DeletePrinter)
            then begin
                if (registre.ReadInteger(DeletePrinter) <> 0)
                then begin
                    { Par défaut, la case n'est pas cochée }
                     imprimante_NoDeletePrinter.Checked := True ;
                end ;
            end ;

            { Paramètre d'imprimante }
            if registre.ValueExists(PrinterTab)
            then begin
                if (registre.ReadInteger(PrinterTab) <> 0)
                then begin
                    { Par défaut, la case n'est pas cochée }
                     imprimante_NoPrinterTab.Checked := True ;
                end ;
            end ;

            lectureProprieteImprimante := True ;

        end
        else begin
             { On créer le chemin complet ! }
             if (registre.CreateKey(IMPRIMANTE_PATH) <> true)
             then begin
                 { Une erreur s'est produite, on ne peut donc pas logiquement
                   écrire dans la bas de registre :-( }
                 Application.MessageBox(
                             'Impossible d''écrire dans la base de registre !',
                             'Erreur', MB_OK + MB_ICONERROR) ;
             end ;
        end ;
    finally
        // libère le registre
        Registre.Free ;
    end ;

end ;

{*****************************************************************************
 * Fonction qui écrit les valeus dans la base de registre pour les imprimantes
 *****************************************************************************
 * Retourne True si le chargement s'est bien passé, sinon False
 *****************************************************************************}
function TForm1.ecritureProprieteImprimante() : boolean ;
var registre : TRegistry ;
begin
    // Créer un objet de type registre
    registre := TRegistry.Create ;
    // par défaut on n'a pas réussi
    ecritureProprieteImprimante := False ;
    try
        // définit la clef racine
        Registre.RootKey := HKEY_CURRENT_USER ;

        // Ouvre la clef
        if registre.OpenKey(IMPRIMANTE_PATH, True)
        then begin
             { Ajout d'imprimante }
             if imprimante_NoAddPrinter.Checked
             then begin
                     registre.WriteInteger(AddPrinter, 1) ;
             end
             else begin
                     registre.WriteInteger(AddPrinter, 0) ;
             end ;

             { Suppression d'imprimante }
             if imprimante_NoDeletePrinter.Checked
             then begin
                     registre.WriteInteger(DeletePrinter, 1) ;
             end
             else begin
                     registre.WriteInteger(DeletePrinter, 0) ;
             end ;

             { Paramètre d'imprimante }
             if imprimante_NoPrinterTab.Checked
             then begin
                     registre.WriteInteger(PrinterTab, 1) ;
             end
             else begin
                     registre.WriteInteger(PrinterTab, 0) ;
             end ;

             ecritureProprieteImprimante := True ;
        end
        else begin
                 { Une erreur s'est produite, on ne peut donc pas logiquement
                   écrire dans la bas de registre :-( }
                 Application.MessageBox('Impossible d''écrire dans la base de registre !','Erreur', MB_OK + MB_ICONERROR) ;
        end ;
    finally
        // libère le registre
        Registre.Free ;
    end ;

end ;

{*****************************************************************************
 * Fonction qui lit les valeus dans la base de registre pour les mots de passe
 *****************************************************************************
 * Retourne True si le chargement s'est bien passé, sinon False
 *****************************************************************************}
function TForm1.lectureProprieteMotDePasse() : boolean ;
var registre : TRegistry ;
begin
    // Créer un objet de type registre
    registre := TRegistry.Create ;
    // par défaut on n'a pas réussi
    lectureProprieteMotDePasse := False ;
    try
        // définit la clef racine
        Registre.RootKey := HKEY_CURRENT_USER ;

        // Ouvre la clef
        if registre.OpenKeyReadOnly(MDP_PATH)
        then begin
            { Affichage du panneau }
            if registre.ValueExists(SecCPL)
            then begin
                if (registre.ReadInteger(SecCPL) <> 0)
                then begin
                    { Par défaut, la case n'est pas cochée }
                     password_NoSecCPL.Checked := True ;
                     password_Options.Enabled := False ;
                end
                else begin
                    { Paramètre d'imprimante }
                    if registre.ValueExists(PwdPage)
                    then begin
                        if (registre.ReadInteger(PwdPage) <> 0)
                        then begin
                            { Par défaut, la case n'est pas cochée }
                             password_NoPwdPage.Checked := True ;

                        end ;
                    end ;
                end ;
            end ;

            lectureProprieteMotDePasse := True ;

        end
        else begin
             { On créer le chemin complet ! }
             if (registre.CreateKey(MDP_PATH) <> true)
             then begin
                 { Une erreur s'est produite, on ne peut donc pas logiquement
                   écrire dans la bas de registre :-( }
                 Application.MessageBox(
                             'Impossible d''écrire dans la base de registre !',
                             'Erreur', MB_OK + MB_ICONERROR) ;
             end ;
        end ;
    finally
        // libère le registre
        Registre.Free ;
    end ;

end ;

{*****************************************************************************
 * Procédure qui est appelé lors qu'on clique sur désactiver le panneau
 * d'Affichage. Il désactive les autres objets de la page.
 *****************************************************************************}
procedure TForm1.affichage_NoDispCPLClick(Sender: TObject);
begin
    { On a cliqué sur la désactivation }
    if affichage_NoDispCPL.Checked
    then
        affichage_Options.Enabled := False
    else
        affichage_Options.Enabled := True ;
end;

{*****************************************************************************
 * Procédure qui est appeler lorsqu'on clique sur quitter
 *****************************************************************************}
procedure TForm1.Button2Click(Sender: TObject);
begin
    Application.Terminate ;
end;

{*****************************************************************************
 * Procedure qui est appeler lorqu'on clique sur enregistrer
 *****************************************************************************}
procedure TForm1.Button1Click(Sender: TObject);
begin
    { Enregistre les paramètres d'affichage }
    ecritureProprieteAffichage() ;
    { Enregistre les paramètres pour les imprimantes }
    ecritureProprieteImprimante() ;
    { Propriété système }
    ecritureProprieteSysteme() ;

end;

{*****************************************************************************
 * Procédure qui est appeler lorsqu'on clique su a propos de ... fait
 * apparaitre la feuille 2.
 *****************************************************************************}
procedure TForm1.Button3Click(Sender: TObject);
begin
    Form2.ShowModal ;
end;

{*****************************************************************************
 * Fonction qui lit les valeus dans la base de registre pour les propriétés
 * système.
 *****************************************************************************
 * Retourne True si le chargement s'est bien passé, sinon False
 *****************************************************************************}
function TForm1.lectureProprieteSysteme() : boolean ;
var registre : TRegistry ;
begin
    // Créer un objet de type registre
    registre := TRegistry.Create ;
    // par défaut on n'a pas réussi
    lectureProprieteSysteme := False ;
    try
        // définit la clef racine
        Registre.RootKey := HKEY_CURRENT_USER ;

        // Ouvre la clef
        if registre.OpenKeyReadOnly(SYSTEME_PATH)
        then begin
            { Gestionnaire de périférique }
            if registre.ValueExists(DevMgrPage)
            then begin
                if (registre.ReadInteger(DevMgrPage) <> 0)
                then begin
                    { Par défaut, la case n'est pas cochée }
                     systeme_NoDevMgrPage.Checked := True ;
                end ;
            end ;

            { Profils matériels }
            if registre.ValueExists(ConfigPage)
            then begin
                if (registre.ReadInteger(ConfigPage) <> 0)
                then begin
                    { Par défaut, la case n'est pas cochée }
                     systeme_NoConfigPage.Checked := True ;
                end ;
            end ;

            { Système de fichier }
            if registre.ValueExists(FileSysPage)
            then begin
                if (registre.ReadInteger(FileSysPage) <> 0)
                then begin
                    { Par défaut, la case n'est pas cochée }
                     systeme_NoFileSysPage.Checked := True ;
                end ;
            end ;

            { Mémoire virtuelle }
            if registre.ValueExists(VirtMemPage)
            then begin
                if (registre.ReadInteger(VirtMemPage) <> 0)
                then begin
                    { Par défaut, la case n'est pas cochée }
                     systeme_NoVirtMemPage.Checked := True ;
                end ;
            end ;

            lectureProprieteSysteme := True ;

        end
        else begin
             { On créer le chemin complet ! }
             if (registre.CreateKey(SYSTEME_PATH) <> true)
             then begin
                 { Une erreur s'est produite, on ne peut donc pas logiquement
                   écrire dans la bas de registre :-( }
                 Application.MessageBox(
                             'Impossible d''écrire dans la base de registre !',
                             'Erreur', MB_OK + MB_ICONERROR) ;
             end ;
        end ;
    finally
        // libère le registre
        Registre.Free ;
    end ;
end ;

{*****************************************************************************
 * Fonction qui ecrit les valeus dans la base de registre pour les propriétés
 * système.
 *****************************************************************************
 * Retourne True si le chargement s'est bien passé, sinon False
 *****************************************************************************}
function TForm1.ecritureProprieteSysteme() : boolean ;
var registre : TRegistry ;
begin
    // Créer un objet de type registre
    registre := TRegistry.Create ;
    // par défaut on n'a pas réussi
    ecritureProprieteSysteme := False ;
    try
        // définit la clef racine
        Registre.RootKey := HKEY_CURRENT_USER ;

        // Ouvre la clef
        if registre.OpenKey(SYSTEME_PATH, True)
        then begin
             { GEstionnaire de périphérique }
             if systeme_NoDevMgrPage.Checked
             then begin
                     registre.WriteInteger(DevMgrPage, 1) ;
             end
             else begin
                     registre.WriteInteger(DevMgrPage, 0) ;
             end ;

             { Profils matériel }
             if systeme_NoConfigPage.Checked
             then begin
                     registre.WriteInteger(ConfigPage, 1) ;
             end
             else begin
                     registre.WriteInteger(ConfigPage, 0) ;
             end ;

             { système de fichier }
             if systeme_NoFileSysPage.Checked
             then begin
                     registre.WriteInteger(FileSysPage, 1) ;
             end
             else begin
                     registre.WriteInteger(FileSysPage, 0) ;
             end ;

             { mémoire virtuelle }
             if systeme_NoVirtMemPage.Checked
             then begin
                     registre.WriteInteger(VirtMemPage, 1) ;
             end
             else begin
                     registre.WriteInteger(VirtMemPage, 0) ;
             end ;


             ecritureProprieteSysteme := True ;
        end
        else begin
                 { Une erreur s'est produite, on ne peut donc pas logiquement
                   écrire dans la bas de registre :-( }
                 Application.MessageBox('Impossible d''écrire dans la base de registre !','Erreur', MB_OK + MB_ICONERROR) ;
        end ;
    finally
        // libère le registre
        Registre.Free ;
    end ;
end ;

end.

