// intercepter Crtl+C
program OpenRegCommand;

{$APPTYPE CONSOLE}

uses
  SysUtils,
  Classes,
  Registry,
  Windows,
  functions in 'functions.pas';

Const VERSION : string = '1.0 beta 1' ;

var i : integer ;
    cmd : string = '' ;
    commandline : boolean = False ;
    quit : boolean = False ;
    Arguments : TStrings ;
    Registre : TRegistry ;
    Ruche : string ;
    directory : string ;
    tmp : string ;
    autocomplet : boolean ;
begin
  Arguments := TStringList.Create ;
  Registre := TRegistry.Create ;
  autocomplet := True ;
  Ruche := 'HKEY_CURRENT_USER' ;
  directory := '\' ;

  Registre.RootKey := HKEY_CURRENT_USER ;
  Registre.OpenKey('\', false) ;
  
  if ParamCount > 0
  then begin
      for i := 1 to ParamCount do
          cmd := cmd + ParamStr(i) + ' ' ;

      commandline := True ;
      quit := true ;
  end ;

  repeat
      ExitCode := 0 ;

      if commandline = False
      then begin
          write('[' + Ruche + '@' + ExtractLastDir(directory) + '] ') ;
          Arguments.Clear ;
          readln(cmd) ;
      end ;

      // read command
      SplitCommands(cmd, Arguments) ;

      Arguments[0] := trim(Arguments[0]) ;
//      Arguments := CompleteArguments(Arguments, directory) ;

      case AnsiIndexStr(Arguments[0],['quit', 'exit', 'pwk', 'cd', 'ck', 'load',
                                      'ls', 'mkkey', 'rmkey', 'mkvalue', 'rmvalue',
                                      'help', 'cat', 'export', 'mv', 'about',
                                      'import', 'autocomplet']) of
          // QUIT/EXIT
          0..1 : quit := True ;
          // PWK
          2 : writeln(Ruche + directory) ;
          // CD/CK
          3..4 : begin
                     if Arguments.Count = 2
                     then begin
                         if OpenKey(Registre, Arguments, directory, autocomplet)
                         then begin
                             if Arguments[1] <> ''
                             then begin
                                 if Arguments[1][1] <> '\'
                                 then
                                     if directory <> '\'
                                     then
                                         directory := directory + '\' + Arguments[1]
                                     else
                                         directory := directory + Arguments[1]
                                 else
                                     directory := Arguments[1]
                             end ;
                         end
                         else begin
                             writeln('"' + Arguments[1] + '" not found') ;
                             ExitCode := -1 ;
                         end
                     end
                     else begin
                         ErrorCommande('cd|ck <key>') ;
                     end ;
                 end ;
          // LOAD
          5 : begin
                  if Arguments.Count = 2
                  then begin
                      tmp := LoadRoot(Registre, Arguments) ;
                      if tmp <> ''
                      then begin
                          Ruche := tmp ;
                          Registre.OpenKey('', false) ;
                      end ;
                  end
                  else
                      ErrorCommande('load HKCU|HKCR|HKLM|HKU|HKPD|HKCC|HKDD|HKEY_CURRENT_USER|HKEY_CLASSES_ROOT|HKEY_LOCAL_MACHINE|HKEY_USERS|HKEY_PERFORMANCE_DATA|HKEY_CURRENT_CONFIG|HKEY_DYN_DATA') ;
              end ;
          // LS
          6 : if (Arguments.Count >= 1) and (Arguments.Count <= 6) 
              then begin
                  listKey(Registre, Arguments, directory, autocomplet)
              end
              else
                  ErrorCommande('ls [-l -p -k -v] path') ;
          // MKKEY
          7 : if Arguments.Count >= 2
              then begin
                  MakeKey(Registre, Arguments, directory, autocomplet) ;
              end
              else
                  ErrorCommande('mkkey key_name keyname_2') ;
          // RMKEY
          8 : if (Arguments.Count >= 2)
              then begin
                  RemoveKey(Registre, Arguments, directory, autocomplet)
              end
              else
                  ErrorCommande('rmkey [-f] key1 key2') ;
          // MKVALUE
          9 : if (Arguments.Count = 4) or (Arguments.Count = 5)
              then begin
                  if not MakeValue(Registre, Arguments)
                  then
                      ErrorStd('Can''t create value !') ;
              end
              else
                  ErrorCommande('mkvalue [-f] name_of_value dword|binary|string|estring [hex:]value') ;
          // RMVALUE
          10 : if (Arguments.Count >= 2)
              then begin
                  RemoveValue(Registre, Arguments)
              end
              else
                  ErrorCommande('rmvalue [-f] value1 value2') ;
          // HELP
          11 : Help(Arguments) ;
          // CAT
          12 : if (Arguments.Count >= 2)
               then begin
                   CatValue(Registre, Arguments)
               end
               else
                   ErrorCommande('cat value1 value2') ;
          // EXPORT
          13 : if (Arguments.Count >= 3)
               then begin
                   ExportKey(Registre, Arguments, directory, autocomplet)
               end
               else
                   ErrorCommande('export [-f] file key') ;
           // MOVEKEY
           14 : if (Arguments.Count = 3)
               then begin
                   MoveKey(Registre, Arguments, directory, autocomplet)
               end
               else
                   ErrorCommande('mv oldkeyname newkeyname') ;
           // ABOUT
           15 : begin
                    writeln('OpenRegCommand version '+ VERSION) ;
                    writeln('Writting by MARTINEAU Emeric (C) 2007 - php4php@free.fr');
                    writeln;
                    writeln('Open and Free program to edit registry in command line') ;
                    writeln;
                    writeln('GPL v2 license. See License.txt to more info')
                end ;
           // IMPORT
           16 : if (Arguments.Count >= 3)
                then begin
                    ImportKey(Registre, Arguments, directory, autocomplet)
                end
                else
                    ErrorCommande('import [-f] file key') ;
           // AUTOCOMPLET
           17 : if (Arguments.Count > 1)
                then begin
                    if Arguments[1] = 'enable'
                    then
                        autocomplet := True
                    else if Arguments[1] = 'disable'
                    then
                        autocomplet := False
                end
                else begin
                    if autocomplet
                    then
                        writeln('autocomplet are enable')
                    else
                        writeln('autocomplet are disable') ;
                    writeln ;    
                    writeln('autocomplet enable|disable')
                end ;
          else
              ErrorStd('Command "' + Arguments[0] + '" not found. Type "help" to know commands') ;
      end ;
  until quit = True ;

  Registre.Free ;
  Arguments.Free ;
end.
