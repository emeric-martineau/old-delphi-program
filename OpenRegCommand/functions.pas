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
//function CompleteArguments(dir : TStrings; directory : string) : TStrings ;
function CompleteArguments(dir : String; directory : string) : String ;
// Show error
procedure ErrorStd(msg : string) ;
// get value with "hex:000" string
function getValue(value : string) : Integer ;
// get binary value
function getBinaryValue(key:string) : string ;
// Extract last directory of string
function ExtractLastDir(dir : string) : string ;
// Setup backup privilege with NT/2000/XP
function SetBackupPrivilege (hProcess : THANDLE; Enable : Boolean) : Boolean ;
// Setup restore privilege with NT/200/XP
function SetRestorePrivilege (hProcess : THANDLE; Enable : Boolean) : Boolean ;
// Setup privilege
function SetPrivilege (hProcess : THANDLE; privilege : String; Enable : Boolean) : Boolean ;

// Open a key
function OpenKey(Registre : TRegistry; key : TStrings; directory : string; autocomplet : boolean) : boolean ;
// Load root key
function LoadRoot(Registre : TRegistry; key : TStrings) : string ;
// List key and value in a key
procedure ListKey(Registre : TRegistry; key : TStrings; directory : string; autocomplet : boolean) ;
// Create key
procedure MakeKey(Registre : TRegistry; key : TStrings; directory : string; autocomplet : boolean) ;
// Remove key
procedure RemoveKey(Registre : TRegistry; key : TStrings; directory : string; autocomplet : boolean) ;
// Create value
function MakeValue(Registre : TRegistry; key : TStrings) : boolean ;
// Remove value
procedure RemoveValue(Registre : TRegistry; key : TStrings) ;
// Show help
procedure Help(key : TStrings) ;
// Show value of value
procedure CatValue(Registre : TRegistry; key : TStrings) ;
// Export key in file
procedure ExportKey(Registre : TRegistry; key : TStrings; directory : string; autocomplet : boolean) ;
// Move key
procedure MoveKey(Registre : TRegistry; key : TStrings; directory : string; autocomplet : boolean) ;
// Import key in file
procedure ImportKey(Registre : TRegistry; key : TStrings; directory : string; autocomplet : boolean) ;

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

{function CompleteArguments(dir : TStrings; directory : string) : TStrings ;
var Cmd : TStringList ;
    tmp : string ;
    i   : integer ;
    j   : integer ;
    k   : integer ;
    nb  : integer ;
    parse : boolean ;
begin
    cmd := TStringList.Create ;
    Result := TStringList.Create ;

    For j := 0 to dir.Count - 1 do
    begin
        parse := False ;

        // if in command line we found \ we must parse
        for k := 1 to length(dir[j]) do
        begin
            if dir[j][k] = '\'
            then begin
                parse := True ;
                break ;
            end ;
        end ;

        if dir[j] = '..'
        then begin
            dir[j] := dir[j] + '\' ;
            Parse := True ;
        end ;

        if Parse = True
        then begin
            tmp := '' ;

            if dir[j][1] <> '\'
            then
                dir[j] := directory + '\' + dir[j] ;

            For i := 1 to Length(dir[j]) do
            begin
                tmp := tmp + dir[j][i] ;

                if dir[j][i] = '\'
                then begin
                    if tmp <> ''
                    then begin
                        cmd.Add(tmp) ;
                    end ;
                    tmp := '' ;
                end ;
            end ;

            if tmp <> ''
            then
                cmd.Add(tmp) ;

            tmp := '' ;
            nb := cmd.Count - 1;

            while nb > 0 do
            begin
                if (cmd[nb] = '..\')
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
                tmp := tmp + cmd[i]
            end ;
        end
        else
            tmp := dir[j] ;

        Result.Add(tmp) ;
    end ;

    cmd.Free ;
end ;}
function CompleteArguments(dir : String; directory : string) : String ;
var Cmd : TStringList ;
    tmp : string ;
    i   : integer ;
    k   : integer ;
    nb  : integer ;
    parse : boolean ;
begin
    cmd := TStringList.Create ;
    Result := '' ;

        parse := False ;

        // if in command line we found \ we must parse
        for k := 1 to length(dir) do
        begin
            if dir[k] = '\'
            then begin
                parse := True ;
                break ;
            end ;
        end ;

        if dir = '..'
        then begin
            dir := dir + '\' ;
            Parse := True ;
        end
        else if dir = '.'
        then begin
            dir := dir + '\' ;
            Parse := True ;
        end ;

        if Parse = True
        then begin
            tmp := '' ;

            if (dir[1] <> '\')
            then
                if (directory[length(directory)] <> '\')
                then
                    dir := directory + '\' + dir
                else
                    dir := directory + dir ;

            For i := 1 to Length(dir) do
            begin
                tmp := tmp + dir[i] ;

                if dir[i] = '\'
                then begin
                    if tmp <> ''
                    then begin
                        cmd.Add(tmp) ;
                    end ;
                    tmp := '' ;
                end ;
            end ;

            if tmp <> ''
            then
                cmd.Add(tmp) ;

            tmp := '' ;
            nb := cmd.Count - 1;

            while nb > 0 do
            begin
                if (cmd[nb] = '..\')
                then begin
                    cmd.Delete(nb);
                    Dec(nb) ;
                    cmd.Delete(nb);
                    Dec(nb) ;
                end
                else if (cmd[nb] = '.\')
                then begin
                    cmd.Delete(nb);
                    Dec(nb) ;
                end
                else
                    Dec(nb) ;
            end ;

            For i := 0 to cmd.Count -1 do
            begin
                tmp := tmp + cmd[i]
            end ;
        end
        else
            tmp := dir ;

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

function ExtractLastDir(dir : string) : string ;
var i : integer ;
    nb : integer ;
begin
    Result := '' ;
    nb := length(dir) ;
    
    if dir[length(dir)] = '\'
    then
        nb := nb - 1 ;

    for i := nb downto 1 do
    begin
        if dir[i] = '\'
        then
            break ;
            
        Result := dir[i] + Result ;
    end ;

    if Result = ''
    then
        Result := '\' ;
end ;

function SetPrivilege (hProcess : THANDLE; privilege : String; Enable : Boolean) : Boolean ;
Var
  Info  : TTokenPrivileges;
  Token : THandle;
  Res   : Boolean;
  h     : DWORD;
begin
  Result := False ;
  // Ouverture des droits
  Res := OpenProcessToken(hProcess, TOKEN_ADJUST_PRIVILEGES, Token);

  if Res
  then begin
      Info.PrivilegeCount := 1;

      if  Enable
      then
          Info.Privileges[0].Attributes := SE_PRIVILEGE_ENABLED
      else
          Info.Privileges[0].Attributes := 0 ;

      // Get LUID.
      Res := LookupPrivilegeValue(nil, PChar(privilege), Info.Privileges[0].Luid) ;

      if Res
      then begin
          Res := AdjustTokenPrivileges(Token, False, Info, 0, PTokenPrivileges(nil)^, h) ;

          if Res
          then begin
              if GetLastError = ERROR_SUCCESS
              then
                  Result := True
              else
                  ErrorStd('Can''t setup privilege right. Check security policies')
          end
          else
              ErrorStd('Can''t setup privilege') ;
      end
      else
          ErrorStd('Can''t set right') ;
  end
  else
      ErrorStd('Can''t get right') ;


  CloseHandle(Token) ;
End;

// Setup backup privilege with NT/2000/XP
function SetBackupPrivilege (hProcess : THANDLE; Enable : Boolean) : Boolean ;
begin
    Result := SetPrivilege (hProcess, 'SeBackupPrivilege', Enable)
end ;

// Setup backup privilege with NT/2000/XP
function SetRestorePrivilege (hProcess : THANDLE; Enable : Boolean) : Boolean ;
begin
    Result := SetPrivilege (hProcess, 'SeRestorePrivilege', Enable)
end ;

{*******************************************************************************
 * COMMANDS
 ******************************************************************************}
function OpenKey(Registre : TRegistry; key : TStrings; directory : string; autocomplet : boolean) : boolean ;
begin
    if autocomplet
    then
        key[1] := CompleteArguments(key[1], directory) ;
        
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

procedure ListKey(Registre : TRegistry; key : TStrings; directory : string; autocomplet : boolean) ;
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
    valueOnly : boolean ;
    keyOnly : boolean ;
begin
   detail := False ;
   page := False ;
   tmp := '' ;
   list := TStringList.Create ;
   listOutput := TStringList.Create ;
   valueOnly := False ;
   keyOnly := False ;

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
           end
           else if key[1] = '-k'
           then begin
               keyOnly := true ;
               key.Delete(1);
               Dec(nb) ;
           end
           else if key[1] = '-v'
           then begin
               valueOnly := true ;
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
       if autocomplet
       then
           key[1] := CompleteArguments(key[1], directory) ;

       tmp := key[1] ;
       Registre.CloseKey ;
       Registre.OpenKey(tmp, false) ;
   end ;

   if not ValueOnly
   then begin
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
                          IntToStr(SysTimeStruct.wMinute) + ':' + IntToStr(SysTimeStruct.wSecond) + '    ' ;
               end
               else
                   tmp := '                      ' ;
           end ;
               
           listOutPut.Add(tmp + list[i]) ;
       end ;

       // to have detail, we must open key. Now, we close and reopen root key
       if detail
       then begin
           Registre.CloseKey ;
           Registre.OpenKey(directory, false) ;
       end ;
   end ;

   if not KeyOnly
   then begin
       // Read value
       Registre.GetValueNames(list);

       if list.IndexOf('') = -1
       then
           list.add('') ;
              
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
                   tmp := '                      ' ;
           end ;
           
           if list[i] = ''
           then
               list[i] := '<default>' ;

           listOutPut.Add(tmp + list[i]) ;
       end ;
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

procedure MakeKey(Registre : TRegistry; key : TStrings; directory : string; autocomplet : boolean) ;
var i : integer ;
begin
    For i := 1 to key.Count -1 do
    begin
        if autocomplet
        then
            key[i] := CompleteArguments(key[i], directory) ;

        if not Registre.CreateKey(key[i])
        then
            ErrorStd('Can''t create key "' + key[i] + '"') ;
    end ;
end ;

procedure RemoveKey(Registre : TRegistry; key : TStrings; directory : string; autocomplet : boolean) ;
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
        if autocomplet
        then
            key[i] := CompleteArguments(key[i], directory) ;
        
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
    start : integer ;
begin
    Result := True ;
    start := 2 ;

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
        start := 3    
    else
        ErrorCommande('mkvalue [-f] name_of_value dword|binary|string|estring [hex:]value') ;

    if key[start-1] = '<default>'
    then begin
        key[start-1] := '' ;
    end ;
        
    case AnsiIndexStr(key[start], ['string', 'dword', 'binary' , 'estring']) of
        0 : Registre.WriteString(key[start-1], key[start+1]);
        1 : Registre.WriteInteger(key[start-1], getValue(key[start+1]));
        2 : begin
                if (length(key[start+1]) mod 2) = 0
                then begin
                    tmp := getBinaryValue(key[start+1]) ;
                    Registre.WriteBinaryData(key[start-1], tmp[1], length(tmp)) ;
                end
                else
                    ErrorStd('Length of data must be pair') ;
            end ;
        3 : Registre.WriteExpandString(key[start-1], key[start+1]);
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
var tmp : string ;
begin
    if key.Count > 1
    then
        tmp := key[1]
    else
        tmp := '' ;

    case AnsiIndexStr(tmp, ['quit', 'exit', 'pwk', 'cd', 'ck', 'load',
                               'ls', 'mkkey', 'rmkey', 'mkvalue', 'rmvalue',
                               'cat', 'export', 'mv', 'import', 'autocomplet']) of
    // QUIT/EXIT
    0..1 : writeln('quit/exit : exit OpenRegCommand') ;
    // PWK
    2    : writeln('pwk : print work key') ;
    // CD/CK
    3..4 : writeln('cd/ck : change key') ;
    // LOAD
    5    : begin
               writeln('load HKCU|HKCR|HKLM|HKU|HKPD|HKCC|HKDD|HKEY_CURRENT_USER|HKEY_CLASSES_ROOT|HKEY_LOCAL_MACHINE|HKEY_USERS|HKEY_PERFORMANCE_DATA|HKEY_CURRENT_CONFIG|HKEY_DYN_DATA') ;
               writeln('Change root key') ;
           end ;
    // LS
    6    : begin
               writeln('ls [-l] [-p] [-k|-v] path : list all key and value') ;
               writeln('  -l : list detail') ;
               writeln('  -p : stop page per page') ;
               writeln('  -k : list only key') ;
               writeln('  -v : list only value') ;
           end ;
    // MKKEY
    7    : writeln('mkkey key : create a key') ;
    // RMKEY
    8    : begin
               writeln('rmkey [-f] key1 key2... : remove key') ;
               writeln('  -f : don''t prompt') ;
           end ;
    // MKVALUE
    9    : begin
               writeln('mkvalue name_of_value dword|binary|string|estring [hex:]value') ;
               writeln('  hex: only for dword') ;
               writeln('  if binary enter value in number (e.g. 010203)') ;
               writeln('  estring : expand string (string who contain %var%') ;
           end ;
    // RMVALUE
    10   : begin
               writeln('rmvalue [-f] value1 value2') ;
               writeln('  -f : don''t prompt') ;
           end ;
    // CAT
    11   : writeln('cat value1 value2') ;
    // EXPORT
    12   : writeln('export [-f] file key') ;
    // MV
    13   : writeln('mv oldname newname') ;
    // IMPORT
    14   : writeln('import [-f] file key') ;
    // AUTOCOMPLET
    15   : begin
               writeln('autocomplet enable|disable') ;
               writeln('leave blanck to know if enable or disable') ;
           end ;
    else
        writeln('about') ;
        writeln('autocomplet') ;
        writeln('cat') ;
        writeln('cd/ck') ;
        writeln('export') ;
        writeln('help') ;
        writeln('import') ;
        writeln('load') ;
        writeln('ls') ;
        writeln('mkkey') ;
        writeln('mkvalue') ;
        writeln('mv') ;
        writeln('pwk') ;
        writeln('quit/exit') ;
        writeln('rmkey') ;
        writeln('rmvalue') ;        
    end ;
end ;

procedure CatValue(Registre : TRegistry; key : TStrings) ;
Var i, j : integer ;
    RegDataInfo : TRegDataInfo ;
    tmp, tmp2 : string ;
    tab : array of char ;
    len : integer ;
begin
    For i := 1 to key.Count -1 do
    begin
        tmp := '' ;
        tmp2 := '' ;
        
        if Registre.ValueExists(key[i])
        then begin
            if Registre.GetDataInfo(key[i], RegDataInfo)
            then begin
                case RegDataInfo.RegData of
                     rdString, rdExpandString : tmp := Registre.ReadString(key[i]) ;
                     rdInteger : tmp := IntToStr(Registre.ReadInteger(key[i])) ;
                     // binary or REG_NONE (unknow)
                     else begin
                         len := RegDataInfo.DataSize ;
                         SetLength(tab, len) ;
                         len := Registre.ReadBinaryData(key[i], tab[0], len) ;

                         for j := 0 to len - 1 do
                         begin
                             tmp2 := Format('%2d', [Ord(tab[j])]) ;

                             if (tmp2[1] = ' ')
                             then
                                 tmp2[1] := '0' ;

                             tmp := tmp + tmp2 ;
                         end ;
                     end ;
                end ;

                writeln(tmp) ;
            end ;
        end
        else
            ErrorStd('"' + key[i] + '" does''nt exists') ;
    end ;
end ;

procedure ExportKey(Registre : TRegistry; key : TStrings; directory : string; autocomplet : boolean) ;
Var tmp : string ;
begin
    if key[1] = '-f'
    then begin
        key.Delete(1);
        DeleteFile(key[1]) ;
    end
    else
        if FileExists(key[1])
        then begin
            write('File already exists. Overwrite ? [Yes/No]') ;
            readln(tmp) ;

            if LowerCase(tmp) = 'n'
            then
                exit ;

            DeleteFile(key[1]) ;
        end ;

    if autocomplet
    then
        key[2] := CompleteArguments(key[2], directory) ;

    SetBackupPrivilege(GetCurrentProcess, True);

    if not Registre.SaveKey(key[2], key[1])
    then
        ErrorStd('Unabled to create file or read registry') ;

    SetBackupPrivilege(GetCurrentProcess, False);
end ;

procedure MoveKey(Registre : TRegistry; key : TStrings; directory : string; autocomplet : boolean) ;
begin
    if autocomplet
    then begin
        key[1] := CompleteArguments(key[1], directory) ;
        key[2] := CompleteArguments(key[2], directory) ;
    end ;
    
    if Registre.ValueExists(key[1])
    then
        if Registre.ValueExists(key[2])
        then
            ErrorStd('Destination already exists')
        else
            Registre.RenameValue(key[1], key[2])
    else
        Registre.MoveKey(key[1], key[2], True) ;
end ;

procedure ImportKey(Registre : TRegistry; key : TStrings; directory : string; autocomplet : boolean) ;
Var tmp : string ;
begin
    if key[1] = '-f'
    then begin
        key.Delete(1);
        DeleteFile(key[1]) ;
    end
    else begin
        write('Are-you sur you want import ? [Yes/No]') ;
        readln(tmp) ;

        if LowerCase(tmp) = 'n'
        then
            exit ;

        DeleteFile(key[1]) ;
    end ;

    if autocomplet
    then
        key[2] := CompleteArguments(key[2], directory) ;

    SetBackupPrivilege(GetCurrentProcess, True);
    SetRestorePrivilege(GetCurrentProcess, True);

    if not Registre.RestoreKey(key[2], key[1])
    then begin
        ErrorStd('Unabled to read file or write in registry') ;
    end ;

    SetRestorePrivilege(GetCurrentProcess, False);
    SetBackupPrivilege(GetCurrentProcess, False);
end ;


end.
