; -- Example1.iss --
; Demonstrates copying 3 files and creating an icon.

; SEE THE DOCUMENTATION FOR DETAILS ON CREATING .ISS SCRIPT FILES!

[Setup]
AppCopyright=Copyright © 1997 My Company, Inc.
WindowVisible=yes
; Nom de l'application
AppName=AMC*Designor
; Nom et version de l'application
AppVerName=AMC*Designor 5.1.0 32 bits
; Réperoire d'install par défaut
DefaultDirName={pf}\AMC_Demo
; Nom du groupe de programme (raccourci) par défaut
DefaultGroupName=AMC Designer
; Icone de désinstallation
UninstallDisplayIcon={uninstallexe}
; Compression choisi : zip, zip/1 à zip/9, bzip, bzip/1 à bzip/9, lzma, lzma/fast, lzma/normal, lzma/max, none
Compression=lzma
; Les fichiers sont compressé en un seul fichier ? : yes, no
SolidCompression=yes
; Détection de la langue : yes, no, auto
ShowLanguageDialog=auto
LicenseFile="license2.txt"
; Encryption
; Password

;InfoBeforeFile=""
;InfoAfterFile=""

;	 PrivilegesRequired

; WizardImageFile=

; WizardImageStretch

;	WizardSmallImageFile

;[Languages]
;Name: en; MessagesFile: "compiler:Default.isl"; LicenseFile : "license.txt"
;Name: nl; MessagesFile: "compiler:Languages\Dutch.isl"; LicenseFile : "license.txt"
;Name: de; MessagesFile: "compiler:Languages\German.isl"; LicenseFile : "license.txt"
;Name: fr; MessagesFile: "compiler:Languages\French.isl"; LicenseFile : "license.txt"
;Name: ca; MessagesFile: "compiler:Languages\Catalan.isl"; LicenseFile : "license.txt"
;Name: cs; MessagesFile: "compiler:Languages\Czech.isl"; LicenseFile : "license.txt"
;Name: no; MessagesFile: "compiler:Languages\Norwegian.isl"; LicenseFile : "license.txt"
;Name: pl; MessagesFile: "compiler:Languages\Polish.isl"; LicenseFile : "license.txt"
;Name: pt; MessagesFile: "compiler:Languages\PortugueseStd.isl"; LicenseFile : "license.txt"
;Name: ru; MessagesFile: "compiler:Languages\Russian.isl"; LicenseFile : "license.txt"
;Name: sl; MessagesFile: "compiler:Languages\Slovenian.isl"; LicenseFile : "license.txt"


[Files]
;Source: "AMCDEF.PBL"; DestDir: "{app}"
;Source: "amcdo50.exe"; DestDir: "{app}"
;Source: "AMCDO50.HLP"; DestDir: "{app}"
;Source: "amcics50.exe"; DestDir: "{app}"
;Source: "amcomnis.lbr"; DestDir: "{app}"
;Source: "cognos.exa"; DestDir: "{app}"
;Source: "install.iss"; DestDir: "{app}"
;Source: "MFCANS32.DLL"; DestDir: "{app}"
;Source: "nsaccess.exa"; DestDir: "{app}"
;Source: "powerbld.exa"; DestDir: "{app}"
;Source: "powerpfc.exa"; DestDir: "{app}"
;Source: "progress.exa"; DestDir: "{app}"
;Source: "sdctrl32.dll"; DestDir: "{app}"
;Source: "SDDTBL32.DLL"; DestDir: "{app}"
;Source: "sdrpt32.dll"; DestDir: "{app}"
;Source: "teamwin.exa"; DestDir: "{app}"
;Source: "uniface.exa"; DestDir: "{app}"
;Source: "vb.exa"; DestDir: "{app}"
;Source: "vb3.exa"; DestDir: "{app}"

[Icons]
;Name: "{group}\AMC Designer"; Filename: "{app}\amcdo50.exe"; WorkingDir: "{app}" ; Parameters:""
;Name: "{group}\AMC Designer ICS"; Filename: "{app}\amcics50.exe"; WorkingDir: "{app}"
;Name: "{group}\Désinstallation d'AMC Designor"; Filename: "{uninstallexe}"
;Name: "{group}\Aide"; Filename: "{app}\AMCDO50.HLP"
;Name: "{userdesktop}\AMC Designer"; Filename: "{app}\amcdo50.exe"; WorkingDir: "{app}"
