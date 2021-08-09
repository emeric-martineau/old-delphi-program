unit functions;

interface

uses Classes, Registry, Windows, SysUtils ;

// to use string with case
function AnsiIndexStr(AText : string; const AValues : array of string) : integer;
// split command line in TStrings
procedure SplitCommands(cmd : string; liste : TStrings) ;
// show error with command line
procedure ErrorCommande(cmd : string) ;
// Change .. in string
function CompleteArguments(dir : string; directory : string) : string ;
// Show error
procedure ErrorStd(msg : string) ;
// get value with "hex:000" string
function getValue(value : string) : Integer ;
// get binary value
function getBinaryValue(key:string) : string ;

function OpenKey(Registre : TRegistry; key : TStrings) : boolean ;
function LoadRoot(Registre : TRegistry; key : TStrings) : string ;
procedure ListKey(Registre : TRegistry; key : TStrings; directory : string) ;
procedure MakeKey(Registre : TRegistry; key : TStrings) ;
procedure RemoveKey(Registre : TRegistry; key : TStrings) ;
function MakeValue(Registre : TRegistry; key : TStrings) : boolean ;
procedure RemoveValue(Registre : TRegistry; key : TStrings) ;
procedure Help(key : TStrings) ;

implementation

{ http://www.developpez.com/delphi/faq/?page=typechaine#caseofstring }
function AnsiIndexStr(AText : string; const AValues : array of string) : integer;
begin
  Result := 0;
  while Result <= High(AValues) do
    if AValues[Result] = AText then exit
    else inc(Result);
  Result := -1;
end;

procedure SplitCommands(cmd : string; liste : TStrings) ;
var i, nb : integer ;
    guillemet : boolean ;
    tmp : string ;
begin
    nb := length(cmd) ;
    guillemet := False ;
    tmp := '' ;
    i := 1 ;

    while i <= nb do
    begin
        // \\ => \ \" => "...
        if (cmd[i] = ' ') and (guillemet = False)
        then begin
            liste.Add(tmp)  ;
            tmp := '' ;
        end
        else if (cmd[i] = '"') and (guillemet = True)
        then begin
            liste.Add(tmp);
            tmp := '' ;
        end
        else if (cmd[i] = '"') and (guillemet = False)
        then
            guillemet := True
        else
            tmp := tmp + cmd[i] ;
        inc(i) ;
    end ;

    if tmp <> ''
    then
        liste.Add(tmp);
end ;

procedure ErrorCommande(cmd : string) ;
begin
    writeln('Error ! Commande is "' + cmd + '"') ;
    ExitCode := -1 ;
end ;

function CompleteArguments(dir : string; directory : string) : string ;
var Cmd : TStringList ;
    tmp : string ;
    i   : integer ;
    nb  : integer ;
begin
    cmd := TStringList.Create ;
    tmp := '' ;

    if dir[1] <> '\'
    then
        dir := directory + dir ;

    For i := 1 to Length(dir) do
    begin
        if (dir[i] = '\')
        then begin
            cmd.Add(tmp) ;
            tmp := '' ;
        end
        else
            tmp := tmp + dir[i] ;
    end ;

    cmd.Add(tmp) ;
    tmp := '' ;
    nb := cmd.Count - 1;

    while nb > 0 do
    begin
        if (cmd[nb] = '')
        then begin
            cmd.Delete(nb);
            Dec(nb) ;
        end
        else if (cmd[nb] = '..')
        then begin
            cmd.Delete(nb);
            Dec(nb) ;
            cmd.Delete(nb);
            Dec(nb) ;
        end
        else
            Dec(nb) ;
    end ;

    For i := 0 to cmd.Count -1 do
    begin
        tmp := tmp + cmd[i] + '\'
    end ;

    Result := tmp ;

    cmd.Free ;
end ;

procedure ErrorStd(msg : string) ;
begin
    writeln('Error ! ' + msg) ;
    ExitCode := -1 ;
end ;

function getValue(value : string) : integer ;
var i   : integer ;
    j   : integer ;
begin
    value := lowerCase(value) ;
    Result := 0 ;

    if (value[1] = 'h') and (value[2] = 'e') and (value[3] = 'x') and
       (value[4] = ':')
    then begin
         j := 0 ;
         for i := length(value) downto 5 do
         begin
             Result := (StrToInt(value[i]) shl j) + Result ;
             j := j + 4 ;
         end ;
    end
    else
        Result := StrToInt(value) ;
end ;

function getBinaryValue(key:string) : string ;
var i   : integer ;
begin
    i := 1 ;
    Result := '' ;

    while i <= length(key) do
    begin
        Result := Result + Char(StrToInt(key[i]) + StrToInt(key[i+1])) ;
        i := i+2 ;
    end ;
end ;
{*******************************************************************************
 * COMMANDS
 ******************************************************************************}
function OpenKey(Registre : TRegistry; key : TStrings) : boolean ;
begin
    Result := Registre.OpenKey(key[1], false) ;
end ;

function LoadRoot(Registre : TRegistry; key : TStrings) : string ;
begin
    Result := '' ;

    if (key[1] = 'HKCU') or (key[1] = 'HKEY_CURRENT_USER')
    then begin
        Registre.RootKey := HKEY_CURRENT_USER ;
        Result := 'HKEY_CURRENT_USER' ;
    end
    else if (key[1] = 'HKCR') or (key[1] = 'HKEY_CLASSES_ROOT')
    then begin
        Registre.RootKey := HKEY_CLASSES_ROOT ;
        Result := 'HKEY_CLASSES_ROOT' ;
    end
    else if (key[1] = 'HKLM') or (key[1] = 'HKEY_LOCAL_MACHINE')
    then begin
        Registre.RootKey := HKEY_LOCAL_MACHINE ;
        Result := 'HKEY_LOCAL_MACHINE' ;
    end
    else if (key[1] = 'HKU') or (key[1] = 'HKEY_USERS')
    then begin
        Registre.RootKey := HKEY_USERS ;
        REsult := 'HKEY_USERS' ;
    end
    else if (key[1] = 'HKPD') or (key[1] = 'HKEY_PERFORMANCE_DATA')
    then begin
        Registre.RootKey := HKEY_PERFORMANCE_DATA ;
        Result := 'HKEY_PERFORMANCE_DATA' ;
    end
    else if (key[1] = 'HKCC') or (key[1] = 'HKEY_CURRENT_CONFIG')
    then begin
        Registre.RootKey := HKEY_CURRENT_CONFIG ;
        Result := 'HKEY_CURRENT_CONFIG' ;
    end
    else if (key[1] = 'HKDD') or (key[1] = 'HKEY_DYN_DATA')
    then begin
        Registre.RootKey := HKEY_DYN_DATA ;
        Result := 'HKEY_DYN_DATA' ;
    end
    else begin
        writeln('Error ! Root key doesn''t exist !') ;
    end ;
end ;

procedure ListKey(Registre : TRegistry; key : TStrings; directory : string) ;
Var detail : Boolean ;
    page : Boolean ;
    tmp : string ;
    i : Integer ;
    nb : Integer ;
    list : TStringList ;
    listOutput : TStringList ;
    keyInfo : TRegKeyInfo ;
    SysTimeStruct: SYSTEMTIME;
    RegDataInfo : TRegDataInfo ;
begin
   detail := False ;
   page := False ;
   tmp := '' ;
   list := TStringList.Create ;
   listOutput := TStringList.Create ;

   // if ls [-l -p] ... maybe contain options
   if key.Count > 1
   then begin
       nb := key.Count ;

       //for each element, we look if an option
       for i := 1 to key.Count do
       begin
           if key[1] = '-l'
           then begin
               // this is an option, setup and delete element in array
               detail := true ;
               key.Delete(1);
               Dec(nb) ;
           end
           else if key[1] = '-p'
           then begin
               page := true ;
               key.Delete(1);
               Dec(nb) ;
           end ;

           // we use for and if we don't have error message, we must exit for boucle
           if nb <= 1
           then
               break ;
       end ;
   end ;

   // if a path open key
   if (key.Count = 2)
   then begin
       tmp := key[1] ;
       Registre.CloseKey ;
       Registre.OpenKey(tmp, false) ;
   end ;

   // Read keys
   Registre.GetKeyNames(list);

   // for each key, we add in listOutPu with detail if needed
   For i := 0 to list.Count-1 do
   begin
       tmp := '' ;

       if detail
       then begin
           Registre.CloseKey ;
           Registre.OpenKey(directory, false) ;
           if Registre.GetKeyInfo(keyInfo)
           then begin
               FileTimeToSystemTime(keyInfo.FileTime, SysTimeStruct) ;
               tmp := IntToStr(SysTimeStruct.wYear) + '/' + IntToStr(SysTimeStruct.wMonth) + '/' +
                      IntToStr(SysTimeStruct.wDay) + ' ' + IntToStr(SysTimeStruct.wHour) + ':' +
                      IntToStr(SysTimeStruct.wMinute) + ':' + IntToStr(SysTimeStruct.wSecond) + '     ' ;
           end
           else
               tmp := '                         ' ;
       end ;

       listOutPut.Add(tmp + list[i]) ;
   end ;

   // to have detail, we must open key. Now, we close and reopen root key
   if detail
   then begin
       Registre.CloseKey ;
       Registre.OpenKey(directory, false) ;
   end ;
   
   // Read value
   Registre.GetValueNames(list);

   For i := 0 to list.Count-1 do
   begin
       if detail
       then begin
           if Registre.GetDataInfo(list[i], RegDataInfo)
           then begin
               case RegDataInfo.RegData of
                   rdString	  : tmp := 'String       ' ;
                   rdExpandString : tmp := 'Expand String' ;
                   rdInteger      : tmp := 'dword        ' ;
                   rdBinary	  : tmp := 'Binary       ' ;
                   else
                                    tmp := 'Unknow       ' ;
               end ;

               tmp := tmp + Format('%8d', [RegDataInfo.DataSize]) + ' ' ;
           end
           else
               tmp := '                     ' ;
       end ;
       
       listOutPut.Add(tmp + list[i]) ;
   end ;

   // print data
   for i := 1 to listOutPut.Count do
   begin
       writeln(listOutPut[i-1]) ;

       if page
       then
           if (i mod 24) = 0
           then begin
               write('Press ENTER to continue') ;
               readln ;
           end ;
   end ;

   listOutput.Free ;
   list.Free ;

   // if we have path, we have open a tempory new key. We restore root key
   if (key.Count = 2)
   then begin
       Registre.CloseKey ;
       Registre.OpenKey(directory, false) ;
   end ;
end ;

procedure MakeKey(Registre : TRegistry; key : TStrings) ;
var i : integer ;
begin
    For i := 1 to key.Count -1 do
        if not Registre.CreateKey(key[i])
        then
            ErrorStd('Can''t create key "' + key[i] + '"') ;
end ;

procedure RemoveKey(Registre : TRegistry; key : TStrings) ;
var prompt : boolean ;
    debut : integer ;
    i : integer ;
    tmp : string ;
begin
    prompt := True ;
    debut := 1 ;

    if key[1] = '-f'
    then begin
        prompt := False ;
        debut := 2 ;
    end ;

    for i := debut to key.Count -1 do
    begin
        if prompt
        then begin
            write('Are you sur you want delete "' + key[i] + '" ? [Yes/No/All/Quit]') ;
            readln(tmp) ;
        end
        else
            tmp := 'y' ;

        case AnsiIndexStr(LowerCase(tmp), ['y', 'n', 'a', 'q']) of
            0 : begin
                    if not Registre.DeleteKey(key[i])
                    then
                        ErrorStd('Can''t delete value "' + key[i] + '"') ;
                end ;
            1 : ;
            2 : begin
                    prompt := False ;
                    if not Registre.DeleteKey(key[i])
                    then
                        ErrorStd('Can''t delete value "' + key[i] + '"') ;
                end ;
            3 : exit ;
        end ;
    end ;
end ;

function MakeValue(Registre : TRegistry; key : TStrings) : boolean ;
var tmp : string ;
begin
    Result := True ;

    if (key[1] <> '-f') and (key.Count = 4)
    then begin
        if Registre.ValueExists(key[1])
        then begin
            write('Value allready exist. Overwrite ? [Yes/No]') ;
            readln(tmp) ;

            if LowerCase(tmp) = 'n'
            then begin
                Result := True ;
                exit ;
            end ;
        end ;
    end
    else if (key[1] = '-f') and (key.Count = 5)
    then
    else
        ErrorCommande('mkvalue name_of_value dword|binary|string|estring [hex:]value') ;


    case AnsiIndexStr(key[2], ['string', 'dword', 'binary' , 'estring']) of
        0 : Registre.WriteString(key[1], key[3]);
        1 : Registre.WriteInteger(key[1], getValue(key[3]));
        2 : begin
                if (length(key[3]) mod 2) = 0
                then begin
                    tmp := getBinaryValue(key[3]) ;
                    Registre.WriteBinaryData(key[1], tmp[1], length(tmp)) ;
                end
                else
                    ErrorStd('Length of data must be pair') ;
            end ;
        3 : Registre.WriteExpandString(key[1], key[3]);
        else begin
            ErrorCommande('mkvalue name_of_value dword|binary|string|estring [hex:]value') ;
            Exit ;
        end ;
    end ;
end ;

procedure RemoveValue(Registre : TRegistry; key : TStrings) ;
var prompt : boolean ;
    debut : integer ;
    i : integer ;
    tmp : string ;
begin
    prompt := True ;
    debut := 1 ;
    
    if key[1] = '-f'
    then begin
        prompt := False ;
        debut := 2 ;
    end ;

    for i := debut to key.Count -1 do
    begin
        if prompt
        then begin
            write('Are you sur you want delete value "' + key[i] + '" ? [Yes/No/All/Quit]') ;
            readln(tmp) ;
        end
        else
            tmp := 'y' ;

        case AnsiIndexStr(LowerCase(tmp), ['y', 'n', 'a', 'q']) of
            0 : begin
                    if not Registre.DeleteValue(key[i])
                    then
                        ErrorStd('Can''t delete value "' + key[i] + '"') ;
                end ;
            1 : ;
            2 : begin
                    prompt := False ;
                    if not Registre.DeleteValue(key[i])
                    then
                        ErrorStd('Can''t delete value "' + key[i] + '"') ;
                end ;
            3 : exit ;
        end ;
    end ;
end ;

procedure Help(key : TStrings) ;
begin
    case AnsiIndexStr(key[1], ['quit', 'exit', 'pwk', 'cd', 'ck', 'load',
                               'ls', 'mkkey', 'rmkey', 'mkvalue', 'rmvalue',
                               'help') of
    0..1 : writeln('quit/exit : exit OpenRegCommand') ;
    2    : writeln('pwk : print work key') ;
    3..4 : writeln('cd/ck : change key') ;
    5    : begin
               writeln('load HKCU|HKCR|HKLM|HKU|HKPD|HKCC|HKDD|HKEY_CURRENT_USER|HKEY_CLASSES_ROOT|HKEY_LOCAL_MACHINE|HKEY_USERS|HKEY_PERFORMANCE_DATA|HKEY_CURRENT_CONFIG|HKEY_DYN_DATA') ;
               writeln('Change root key') ;
           end ;
    6    : writeln('ls [-l] [-p] [-k|-v] key : list all key and value') ;
           writeln('  -l : list detail') ;
           writeln('  -p : stop page per page') ;
           writeln('  -k : list only key') ;
           writeln('  -v : list only value') ;           
    else
        writeln('quit/exit') ;
        writeln('pwk') ;
        writeln('cd/ck') ;
        writeln('load') ;
        writeln('ls') ;
        writeln('mkkey') ;
        writeln('rmkey') ;
        writeln('mkvalue') ;
        writeln('rmvalue') ;
        writeln('help') ;
    end ;
end ;

end.
