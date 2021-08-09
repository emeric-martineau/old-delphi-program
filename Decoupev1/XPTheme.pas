unit XPTheme;

{
  Inno Setup
  Copyright (C) 1998-2001 Jordan Russell
  Portions by Martijn Laan
  For conditions of distribution and use, see LICENSE.TXT.

  Enables themes in Windows XP

  $Id: XPTheme.pas,v 1.1 2001/09/05 22:23:18 jr Exp $
}

interface

implementation

{$R XPTheme.res}

uses
  CommCtrl;

initialization
  { Note: This call is required! SetupLdr won't start without it. }
  InitCommonControls;
end.
