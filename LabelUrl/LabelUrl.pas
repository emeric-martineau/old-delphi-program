unit LabelUrl;

interface

uses
  Windows, Messages, SysUtils, Classes, Controls, StdCtrls, ShellApi, Graphics,
  Forms, Registry;

type
  TLabelUrl = class(TLabel)
  private
    { Déclarations privées }
    Furl : string ;
    function getColorLink(color : string) : Integer ;
  protected
    { Déclarations protégées }
  public
    { Déclarations publiques }
    procedure OnMouseEnterLabel(Sender: TObject);
    procedure OnMouseLeaveLabel(Sender: TObject);

    constructor Create(Sender : TComponent); override ;
  published
    { Déclarations publiées }
    property Align;
    property Alignment;
    property Anchors;
    property AutoSize;
    property BiDiMode;
    property Caption;
    property Color;
    property Constraints;
    property Cursor ;
    property DragCursor;
    property DragKind;
    property DragMode ;
    property Enabled ;
    property FocusControl;
    property Font;
    property ParentBiDiMode;
    property ParentColor;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowAccelChar;
    property ShowHint;
    property Transparent;
    property Layout;
    property Url : string read Furl write Furl ;    
    property Visible ;
    property WordWrap;
    property OnClick ;
    procedure OnClickLabel(Sender: TObject); virtual ;
    property OnDblClick;
//    property OnDragDrap;
    property OnDragOver;
    property OnEndDock;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
    property OnStartDock;
    property OnStartDrag ;
  end;

procedure Register;

implementation

{$R TLabelUrl.dcr}

procedure Register;
begin
  RegisterComponents('Exemples', [TLabelUrl]);
end;

constructor TLabelUrl.Create(Sender : TComponent);
var Registre : TRegistry ;
begin
    inherited ;

    if not assigned(OnClick)
    then
        OnClick := OnClickLabel ;

    if not (assigned(OnMouseEnter))
    then
        OnMouseEnter := OnMouseEnterLabel ;

    if not (assigned(OnMouseLeave))
    then
        OnMouseLeave := OnMouseLeaveLabel ;

    Cursor := crHandPoint ;

    // Charge l'icone de la main de Windows plutôt que de delphi
    Screen.Cursors[crHandPoint] := LoadCursor(0, IDC_HAND);

    Registre := TRegistry.Create ;
    Registre.RootKey := HKEY_CURRENT_USER ;

    if Registre.OpenKey('Software\Microsoft\Internet Explorer\Settings', false)
    then begin
        if Registre.ValueExists('Anchor Color')
        then
            Font.Color := getColorLink(Registre.ReadString('Anchor Color'))
        else
            Font.Color := clHotLight ;
    end
    else
        Font.Color := clHotLight ;
end ;

procedure TLabelUrl.OnClickLabel(Sender: TObject);
begin
    ShellExecute(Parent.Handle, 'OPEN', PChar(FUrl),'','',SW_SHOWNORMAL);
//    appeler le gestionnaire onclick en plus;
end ;

procedure TLabelUrl.OnMouseEnterLabel(Sender: TObject);
begin
    Font.Style := Font.Style + [fsUnderline] ;
end ;

procedure TLabelUrl.OnMouseLeaveLabel(Sender: TObject);
begin
    Font.Style := Font.Style - [fsUnderline] ;
end ;

function TLabelUrl.getColorLink(color : string) : Integer ;
Var i, choix, nb, j : integer ;
    Rouge, Vert, Blue : String ;
begin
    Rouge := '' ;
    Vert := '' ;
    Blue := '' ;

    nb := length(color) ;
    j := nb ;
    choix := 2 ;

    for i := nb downto 1 do
    begin
        if color[j] = ','
        then  begin
            dec(j) ;
            dec(choix) ;
        end ;

        case choix of
           0 : Rouge := color[j] + Rouge ;
           1 : Vert := color[j] + Vert ;
           2 : Blue := color[j] + Blue ;
        end ;

        if j > 1
        then
            dec(j)
        else
            break ;
    end ;

    Result := (StrToInt(Blue) shl 16) + (StrToInt(Vert) shl 8) + StrToInt(Rouge) ;
end ;

end.
