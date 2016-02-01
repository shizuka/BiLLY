{
   Billy 2.21
   Copyright (C) 2000 Greg Leedberg

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program; if not, write to the Free Software
    Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

    The full license can be found in the included file license.txt.

    Any questions regarding what you may do with the software can be sent to
    Greg Leedberg, at greg@leedberg.com.

    The full, unedited source follows. 
}

{ BILLY - v2.21 }

program Billy;
uses crt,dos;

const BRmax = 50;
      SentMax = 30;
      ElementsMax = 10;
      Track = FALSE;

      NoResponse = '<NO RESPONSE GENERATED>';

type TString = string[15];  { Type for all words }
     Sentence = array[1..SentMax] of TString; { Type for sequence of words }
     Nwords = array[1..BRmax] of TString;  { Type for nouns }
     Database = array[0..20,0..ElementsMax] of TString; { ER type }
     Names = array[1..ElementsMax+1] of TString; { Type for names in BR }
     UString = string[80];    { Type for blind responses }
     BR = array[1..BRmax+1] of UString;  { Type for list of BR }
     UserData = record
                  UserIn : string;
                  OUserIn : string;
                  Words : Sentence;
                  ID : Sentence;
                  WordC : integer;
                end;

var LastBR : integer;              { Most recent Blind response }
    UserName,
    BillyName: TString;
    Sender : string;
    BR_FILE,
    SR_FILE,
    NOUN_FILE,
    SENT_FILE,
    IS1_FILE,
    IS2_FILE,
    IS3_FILE,
    PAUSE_FILE,
    NAME_FILE,
    ADJECTIVE_FILE,
    TEMP_FILE : string;
    Color1,Color2 : integer;
    InputMeth : integer;
    LIs1,LIs2 : string;

(*********************************************************)
procedure Writer(TextString : string);

var loop : integer;

begin
  for loop := 1 to length(TextString) do
    begin
      if (random(80) = 0) AND
          (TextString[loop] <> ' ') AND
          (TextString[loop] <> '!') AND
          (TextString[loop] <> '?') AND
          (TextString[loop] <> '.') AND
          (TextString[loop] <> ',') then
        begin
          write(chr(random(26)+97));
          delay(300);
          write(chr(8));
          delay(200);
        end;
      write(TextString[loop]);
      delay(20 * (random(5)+1));
    end;
  writeln;
end;

(*********************************************************)
function FileExist(FileName : string) : BOOLEAN;

var LoadFile : text;

begin
  {$I-}
  assign(LoadFile,FileName);
  reset(LoadFile);
  close(LoadFile);
  {$I+}

  if IOResult = 0 then FileExist := TRUE
  else FileExist := FALSE;
end;

(*************************************************************)
{ GetKey checks if a key has been pressed, and if so returns the
  key pressed.  If not, it returns a space. }
function GetKey : CHAR;

var temp : char;                       { Temporarily holds key pressed
                                         by user }

begin                                  { GetKey }
  repeat
    if Keypressed then temp := readkey
      else temp := #14;
  until temp <> #14;
  GetKey := temp;
end;                                   { GetKey }


(****************************************************************)
function Time : string;

var h,m,s,ss : word;
    Temp : string;
    TempFile : text;

begin
  assign(TempFile,TEMP_FILE);
  rewrite(TempFile);
  gettime(h,m,s,ss);
  write(TempFile,h,':');
  if m < 10 then write(TempFile,'0');
  writeln(TempFile,m );
  close(TempFile);
  reset(TempFile);
  readln(TempFile,Temp);
  close(TempFile);
  erase(TempFile);
  Time := Temp;
end;

(****************************************************************)
function DayOfWeek : string;

var y,m,d,dow : word;

begin
  GetDate(y,m,d,dow);
  case dow of
  0: DayOfWeek := 'Sunday';
  1: DayOfWeek := 'Monday';
  2: DayOfWeek := 'Tuesday';
  3: DayOfWeek := 'Wednesday';
  4: DayOfWeek := 'Thursday';
  5: DayOfWeek := 'Friday';
  6: DayOfWeek := 'Saturday';
  end;
end;

(****************************************************************)
function PartOfDay : string;

var h,m,s,ms : word;
    LoadFile : text;

begin
  GetTime(h,m,s,ms);
  if (h >= 12) AND (h <= 17) then PartOfDay := 'afternoon'
  else if (h >= 18) OR (h <= 2) then PartOfDay := 'evening'
  else PartOfDay := 'morning';
end;

(****************************************************************)
{ ToInt converts a numeric string to an integer }
function ToInt(OldStr : string) : Integer;  { String to convert }

var Code,                                   { Error code for VAL }
    TempInt : integer;                      { Temporary integer }

begin
  if Track then writeln('+TOINT+');
  val(OldStr,TempInt,Code);
  ToInt := TempInt;
end;

(****************************************************************)
{ ToStr converts an integer to a string }
function ToStr(OldInt : integer) : String;  { Number to convert }

var TempStr : string[6];                       { Temporary string }

begin
  if Track then writeln('+TOSTR+');
  str(OldInt,TempStr);
  ToStr := TempStr;
end;

(***************************************************************)
function ToUpper(TextString : TString) : TString;

var loop2 : integer;

begin
  if Track then writeln('+TOUPPER+');
  for loop2 := 1 to length(TextString) do
    TextString[loop2] := upcase(TextString[loop2]);
  ToUpper := TextString;
end;

(***************************************************************)
function ToLower(TextString : TString) : TString;

var loop2 : integer;

begin
  if Track then writeln('+TOUPPER+');
  for loop2 := 1 to length(TextString) do
    if ord(TextString[loop2]) < 91 then TextString[loop2] := chr(ord(TextString[loop2])+32);
  ToLower := TextString;
end;

(***************************************************************)
procedure SaveSent(var UData : UserData);

var loop, loop2, count,index : integer;
    LoadFile : text;
    Sents1, Sents2 : BR;
    TempUDATA : UserData;

begin
  TempUData := UData;
  for loop := 1 to TempUData.WordC do if ToUpper(TempUData.Words[loop]) = 'AN' then TempUData.Words[loop] := 'a';
  loop := 1;
  while (TempUData.ID[loop] <> 'NOUNX') AND (loop <= TempUData.WordC) do loop := loop + 1;
  if TempUdata.ID[loop] = 'NOUNX' then
    begin
      assign(LoadFile,SENT_FILE);
      reset(LoadFile);
      count := 0;
      while not eof(LoadFIle) do
        begin
          count := count + 1;
          readln(LoadFile,Sents1[count+1]);
          readln(LoadFile,Sents2[count+1]);
        end;
      close(LoadFile);
      if count >= BRmax then index := random(50) + 2
      else
        begin
          count := count + 1;
          index := count+1;
        end;
      Sents1[index] := '';
      Sents2[index] := '';
      for loop2 := 1 to (loop - 1) do Sents1[index] := Sents1[index] + TempUData.Words[loop2] + ' ';
      for loop2 := (loop + 1) to TempUData.WordC do Sents2[index] := Sents2[index] + TempUData.Words[loop2] + ' ';
      Sents1[1] := ToStr(count);
      Sents2[1] := ToStr(count);
      rewrite(LoadFile);
      for loop := 2 to (count+1) do
        begin
          writeln(LoadFile,{copy(}Sents1[loop]{,1,length(Sents1[loop])-1)});
          writeln(LoadFile,{copy(}Sents2[loop]{,1,length(Sents2[loop])-1)});
        end;
      close(LoadFile);
   end;
end;

(***************************************************************)
procedure LoadSR(var StimD, RespD : BR);

var LoadFile : text;
    count : integer;

begin
  if Track then writeln('+LOADSR+');
  assign(LoadFile,SR_FILE);
  reset(LoadFIle);
  count := 0;
  while not eof(LoadFIle) do
    begin
      count := count+1;
      readln(LoadFile,StimD[count+1]);
      readln(LoadFile,RespD[count+1]);
    end;
  close(LoadFile);

  if count > BRmax then count := BRmax;

  StimD[1] := ToStr(count);
  RespD[1] := ToStr(count);
end;

(***************************************************************)
procedure SaveSR(var StimD, RespD : BR);

var LoadFile : text;
    count : integer;

begin
  if Track then writeln('+SAVESR+');
  assign(LoadFile,SR_FILE);
  rewrite(LoadFIle);
  for count := 2 to (toint(StimD[1]) + 1) do
    begin
      writeln(LoadFile,StimD[count]);
      writeln(LoadFile,RespD[count]);
    end;
  close(LoadFile);
end;

(***************************************************************)
function RandSmile : string;

begin
  case random(3) of
  0: RandSmile := ':)';
  1: RandSmile := ';)';
  2: RandSmile := ':O';
  end;
end;

(***************************************************************)
function RandNoun : TString;

var LoadFile : text;
    loop : integer;
    Nouns : Nwords;
    Temp : TString;

begin
  { Load learned nouns }
  assign(Loadfile,NOUN_FILE);
  reset(LoadFile);
  loop := 2;
  while not eof(LoadFile) do
    begin
      readln(LoadFile,Nouns[loop]);
      loop := loop + 1;
    end;
  close(LoadFile);
  Nouns[1] := ToStr(loop - 2);

  Temp := Nouns[random(ToInt(Nouns[1]))+2];

  RandNoun := Temp {copy(Temp,1,length(Temp)-1)};
end;

(***************************************************************)
procedure InitEResponse(var EResponse : Database);

var LoadFile : text;
    loop : integer;

begin
  if Track then writeln('+INITERESPONSE+');
  { Initialize vocabulary }
  EResponse[0,0] := '15';

  EResponse[1,0] := 'GREETINGX';
  EResponse[1,1] := 'HI';
  EResponse[1,2] := 'HELLO';
  EResponse[1,3] := #14;

  EResponse[2,0] := 'NOUNMARKX';
  EResponse[2,1] := 'THE';
  EResponse[2,2] := 'A';
  EResponse[2,3] := 'AN';
  EResponse[2,4] := #14;

  EResponse[3,0] := 'INSULTX';
  EResponse[3,1] := 'MORON';
  EResponse[3,2] := 'IDIOT';
  EResponse[3,3] := 'GEEK';
  EResponse[3,4] := #14;

  EResponse[4,0] := 'BILLYX';
  EResponse[4,1] := 'YOU';
  EResponse[4,2] := 'YOURSELF';
  EResponse[4,3] := #14;

  EResponse[5,0] := 'AFFIRMX';
  EResponse[5,1] := 'YES';
  EResponse[5,2] := 'YEAH';
  EResponse[5,3] := 'SURE';
  EResponse[5,4] := 'YEA';
  EResponse[5,5] := #14;

  EResponse[6,0] := 'QUESTIONX';
  EResponse[6,1] := 'WHAT';
  EResponse[6,2] := 'HOW';
  EResponse[6,3] := 'WHY';
  EResponse[6,4] := 'WHO';
  EResponse[6,5] := #14;

  EResponse[7,0] := 'DEFX';
  EResponse[7,1] := 'IS';
  EResponse[7,2] := 'ARE';
  EResponse[7,3] := #14;

  EResponse[8,0] := 'NAMEX';
  assign(LoadFile,NAME_FILE);
  reset(LoadFile);
  loop := 1;
  repeat
    readln(LoadFile,EResponse[8,loop]);
    EResponse[8,loop] := ToUpper(EResponse[8,loop]);
    if (ToUpper(EResponse[8,loop]) <> ToUpper(UserName)) AND (EResponse[8,loop] <> '') then
      loop := loop + 1;
  until eof(LoadFile) OR (loop > ElementsMax);
  close(LoadFile);
  EResponse[8,loop] := #14;

  EResponse[9,0] := 'WEATHERX';
  EResponse[9,1] := 'WEATHER';
  EResponse[9,2] := #14;

  EResponse[10,0] := 'TIMEX';
  EResponse[10,1] := 'TIME';
  EResponse[10,2] := 'CLOCK';
  EResponse[10,3] := #14;

  EResponse[11,0] := 'NEGATIVEX';
  EResponse[11,1] := 'NO';
  EResponse[11,2] := 'NOPE';
  EResponse[11,3] := #14;

  EResponse[12,0] := 'MODX';
  EResponse[12,1] := 'VERY';
  EResponse[12,2] := 'ABSOLUTELY';
  EResponse[12,3] := 'REALLY';
  EResponse[12,4] := 'TOO';
  EResponse[12,5] := #14;

  EResponse[13,0] := 'PRONOUNX';
  EResponse[13,1] := 'HE';
  EResponse[13,2] := 'SHE';
  EResponse[13,3] := 'IT';
  EResponse[13,4] := 'THEY';
  EResponse[13,5] := #14;

  EResponse[14,0] := 'WILLX';
  EResponse[14,1] := 'WILL';
  EResponse[14,2] := 'WOULD';
  EResponse[14,3] := #14;

  EResponse[15,0] := 'MAYBEX';
  EResponse[15,1] := 'MAYBE';
  EResponse[15,2] := #14;
end;

(***************************************************************)
function FindID(var Target : TString) : TString;

var EResponse : Database;
    loop2,
    loop3 : integer;
    Temp : TString;
    Temp2 : TString;
    LoadFile : text;

begin
  InitEResponse(EResponse);
  Temp := '';

  for loop2 := 1 to ToInt(EResponse[0,0]) do
      begin
        loop3 := 1;
        repeat
          if ToUpper(Target) = EResponse[loop2,loop3] then Temp := EResponse[loop2,0];
          loop3 := loop3 + 1;
        until EResponse[loop2,loop3] = #14;
      end;

  if Temp = '' then Temp := ToUpper(Target);

  assign(LoadFile,ADJECTIVE_FILE);
  reset(LoadfIlE);
  repeat
    readln(LoadFile,Temp2);
    if Temp2 = toupper(Target) then Temp := 'ADJECTIVEX';
  until (Temp2 = toupper(Target)) OR eof(LoadFile);
  close(LoadFile);

  FindID := Temp;
end;

(***************************************************************)
procedure Parse(var UData : UserData);

var loop,
    loop2 : integer;
    tempstring : string;

begin
  if Track then writeln('+PARSE+');
  UData.OUserIn := UData.UserIn;

  for loop := 1 to SentMax do UData.Words[loop] := '';

  UData.WordC := 1;
  for loop := 1 to length(UData.UserIn) do
    begin
      if UData.UserIn[loop]  IN ['!', '.', ',', '?', '/', '\', '(', ')'] then UData.UserIn[loop] := #14;
      if UData.UserIn[loop] = ' ' then
        begin
          Udata.WordC := Udata.WordC + 1;
          for loop2 := 1 to length(Udata.Words[Udata.WordC - 1]) do
            if (Udata.Words[Udata.WordC - 1,loop2] = #39) then
              if upcase(UData.Words[UData.WordC-1,loop2+1]) = 'R' then
                begin
                  UData.Words[UData.WordC-1] := copy(UData.Words[UData.WordC-1],1,length(UData.Words[UData.WordC-1])-3);
                  UData.Words[UData.WordC] := 'are';
                  UData.WordC := UData.WordC + 1;
                end
              else if upcase(Udata.Words[Udata.WordC-1,loop2+1]) = 'S' then
                begin
                  Udata.Words[Udata.WordC-1] := copy(Udata.Words[Udata.WordC-1],1,length(Udata.Words[Udata.WordC-1])-2);
                  if ToUpper(UData.Words[UData.WordC-1]) = 'LET' then UData.Words[UData.WordC] := 'us'
                  else Udata.Words[Udata.WordC] := 'is';
                  Udata.WordC := Udata.WordC + 1;
                end
              else if upcase(Udata.Words[Udata.WordC-1,loop2+1]) = 'T' then
                begin
                  Udata.Words[Udata.WordC-1] := copy(Udata.Words[Udata.WordC-1],1,length(Udata.Words[Udata.WordC-1])-2);
                  if ToUpper(Udata.Words[Udata.WordC-1]) = 'DON' then Udata.Words[Udata.WordC-1] := 'do'
                  else if ToUpper(Udata.Words[Udata.WordC-1]) = 'WON' then Udata.Words[Udata.WordC-1] := 'will';
                  Udata.Words[Udata.WordC] := 'NOT';
                  Udata.WordC := Udata.WordC + 1;
                end
              else if upcase(Udata.Words[Udata.WordC-1,loop2+1]) = 'M' then
                begin
                  Udata.Words[Udata.WordC-1] := copy(Udata.Words[Udata.WordC-1],1,length(Udata.Words[Udata.WordC-1])-2);
                  Udata.Words[Udata.WordC] := 'am';
                  Udata.WordC := Udata.WordC + 1;
                end;
        end
      else Udata.Words[Udata.WordC] := Udata.Words[Udata.WordC] + UData.UserIn[loop];
    end;

   for loop := 1 to UData.WordC do
     begin
       TempString := '';
       for loop2 := 1 to length(UData.Words[loop]) do
         begin
           if UData.Words[loop,loop2] <> #14 then TempString := TempString + UData.Words[loop,loop2];
         end;
       UData.Words[loop] := TempString;
     end;

  for loop := 1 to SentMax do Udata.ID[loop] := ToUpper(Udata.Words[loop]);

  loop := 1;

  repeat
    UData.ID[loop] := FindID(UData.Words[loop]);
    if UData.ID[loop] = 'NOUNMARKX' then
      begin
        repeat
          loop := loop + 1;
          UData.ID[loop] := FindID(UData.Words[loop]);
          if (UData.ID[loop] <> 'ADJECTIVEX') AND (UData.ID[loop] <> 'MODX') then
            UData.ID[loop] := 'NOUNX';
        until UData.ID[loop] = 'NOUNX';
      end;
    loop := loop + 1;
  until loop > Udata.WordC;
  if UData.WordC > SentMax then UData.WordC := SentMax;
end;

(***************************************************************)
procedure LoadSent(var Sent1, Sent2 : string);

var LoadFile : text;
    count : integer;
    loop : integer;

begin
  assign(LoadFile,SENT_FILE);
  reset(LoadFile);
  count := 0;
  while not eof(LoadFile) do
    begin
      readln(LoadFile,Sent1);
      readln(LoadFile,Sent2);
      count := count + 1;
    end;
  close(LoadFile);
  count := random(count) + 1;
  reset(LoadFile);
  for loop := 1 to count do
    begin
      readln(LoadFile,Sent1);
      readln(LoadFile,Sent2);
    end;
  close(LoadFile);
  Sent1 := copy(Sent1,1,length(Sent1)-1);
end;

(***************************************************************)
function BlindR(var UserIn : string;
                    Use : boolean) : string;

var RandNum,
    RandNum2 : integer;
    Exists : boolean;
    loop : integer;
    BRs : br;
    LoadFile : text;
    People : Names;
    UseNoun : TString;
    N : string[1];
    Nouns : NWords;
    Sent1, Sent2 : string;

begin
  if Track then writeln('+BLINDR+');
  { Load Blind Responses }
  assign(LoadFile,BR_FILE);
  reset(LoadFIle);
  loop := 2;
  repeat
    readln(LoadFile,BRs[loop]);
    loop := loop + 1;
  until eof(LoadFIle);
  close(LoadFile);

  BRs[1] := ToStr(loop - 2);

  assign(LoadFile,NAME_FILE);
  reset(LoadFile);
  loop := 1;
  repeat
    readln(LoadFile,People[loop]);
    if (ToUpper(People[loop]) <> ToUpper(UserName)) AND (People[loop] <> '') then
      loop := loop + 1;
  until eof(LoadFile);
  close(LoadFile);
  loop := loop - 1;

  if Use then
    begin
      RandNum := random(ToInt(BRs[1]) + (ToInt(BRs[1]) DIV 4)) +1;
      if (RandNum = 1) OR (RandNum > ToInt(BRs[1])) then
        begin
          UseNoun := RandNoun;
          if upcase(UseNoun[1]) IN ['A','E','I','O','U'] then N := 'n' else N := '';
          if loop = 0 then RandNum2 := random(3)
          else RandNum2 := random(10);
          case RandNum2 of
          0,1,2,3,4: begin
                 LoadSent(Sent1,Sent2);
                 Sent1[1] := upcase(Sent1[1]);
                 if ToUpper(copy(Sent1,length(Sent1),1)) = 'A' then
                   BlindR := Sent1+N+' '+UseNoun+ ' '+Sent2
                 else BlindR := Sent1 + ' ' + UseNoun + ' ' + Sent2;
               end;
          5: BlindR := People[random(loop)+1] + ' is my best friend!';
          6: BlindR := 'Do you know ' + People[random(loop)+1] + '?';
          7: BlindR := People[random(loop)+1] + ' annoys me...';
          8: BlindR := 'Are you in love with ' + People[random(loop)+1] + '?';
          9: BlindR := 'Have you talked to ' + People[random(loop)+1] + ' lately?';
          end;
          RandNum := 0;
        end
      else  BlindR := BRs[RandNum];
      LastBR := RandNum;
    end;

  if random(3) = 0 then
    begin
      Exists := FALSE;
      for loop := 2 to (ToInt(BRs[1])+2) do
        if ToUpper(BRs[loop]) = ToUpper(UserIn) then Exists := TRUE;

      if not Exists then
        begin
          if (ToInt(BRs[1]) < BRmax) AND (ToUpper(UserIn) <> 'BYE') then
            begin
              UserIn[1] := upcase(UserIn[1]);
              BRs[ToInt(BRs[1])+2] := UserIn;
              BRs[1] := ToStr(ToInt(BRs[1]) + 1);
            end
          else
            begin
              UserIn[1] := upcase(UserIn[1]);
              BRs[Random(ToInt(BRs[1]) + 2)] := UserIn;
            end;
        end;
  end;
 { Save current blind responses }
  assign(LoadFile,BR_FILE);
  rewrite(LoadFile);
  for loop := 2 to (ToInt(BRs[1])+1) do writeln(LoadFile,BRs[loop]);
  close(LoadFile);
end;

(***************************************************************)
function NumAssoc(IsSub : string) : integer;

var LoadFile : text;
    loop2 : integer;
    Temp : String;
    Num : integer;

begin
  if Track then writeln('+NUMASSOC+');

  Num := 0;

  { Direct association  (IS1 => IS2) }
  assign(LoadFile,IS1_FILE);
  reset(LoadFile);
  repeat
    readln(LoadFile,Temp);
    if toupper(Temp) = toupper(IsSub) then Num := Num + 1;
  until eof(LoadFile);
  close(LoadFile);

  { Reverse association (IS2 => IS1) }
{  assign(LoadFile,IS2_FILE);
  reset(LoadFile);
  repeat
    readln(LoadFile,Temp);
    if toupper(Temp) = toupper(IsSub) then Num := Num + 1;
  until eof(LoadFile);
  close(LoadFile);}

  NumAssoc := Num;
end;

(***************************************************************)
function Association(IsSub : string;
                     Num : integer;
                     Capitalize : boolean) : string;

var LoadFIle : text;
    Found, FIleMark,loop2 : integer;
    Temp : String;
    count : integer;

begin
  if Track then writeln('+ASSOCIATION+');
  count := 0;
  { Direct association  (IS1 => IS2) }
  assign(LoadFile,IS1_FILE);
  reset(LoadFile);
  FileMark := 0;
  Found := 0;
  repeat
    readln(LoadFile,Temp);
    FileMark := FileMark + 1;
    if toupper(Temp) = toupper(IsSub) then count := count + 1;
    if count = Num then Found := FileMark;
  until eof(LoadFile) or (Found > 0);
  close(LoadFile);
  if Found <> 0 then
    begin
      assign(LoadFile,IS2_FILE);
      reset(LoadFile);
      for loop2 := 1 to Found do
        readln(LoadFile,Temp);
      close(LoadFile);
      if Capitalize then Temp[1] := upcase(Temp[1]);
    end
{  else
    begin
      { Reverse association (IS2 => IS1) }
 {     assign(LoadFile,IS2_FILE);
      reset(LoadFile);
      FileMark := 0;
      Found := 0;
      repeat
        readln(LoadFile,Temp);
        FileMark := FileMark + 1;
        if toupper(Temp) = toupper(IsSub) then count := count + 1;
        if count = Num then Found := FileMark;
      until eof(LoadFile) or (Found > 0);
      close(LoadFile);
      if Found <> 0 then
        begin
          assign(LoadFile,IS1_FILE);
          reset(LoadFile);
          for loop2 := 1 to Found do
            readln(LoadFile,Temp);
          close(LoadFile);
          if Capitalize then Temp[1] := upcase(Temp[1]);
        end}
    else Temp := #14;
{  end;}

  assign(LoadFile,IS3_FILE);
  reset(LoadFile);
  for loop2 := 1  to Found do readln(LoadFile,Sender);
  close(LoadFile);
  if ToUpper(Sender) = ToUpper(UserName) then Sender := 'you';

  if toupper(IsSub) = 'MY NAME ' then Temp := #14+'Your name is '+UserName+', silly!';
  if toupper(IsSub) = 'YOUR NAME ' then Temp := #14+'I told you, my name is '+BillyName+'!';
  if toupper(IsSub) = 'TODAY ' then Temp := #14+'I believe that today is '+DayOfWeek+'.';
  if toupper(IsSub) = 'YOUR BEST FRIEND ' then Temp := #14+UserName+', you are my best friend.';

  if Temp[1] = #14 then
    begin
      Sender := '***';
      Temp := copy(Temp,2,length(Temp)-1);
    end;
  Association := Temp;
end;

(***************************************************************)
procedure CheckSR(var UData : UserData;
                  var Response : string);

var StimD,
    RespD : BR;
    loop : integer;
    Found : integer;

begin
  if Track then writeln('+CHECKSR+');
  Found := 0;
  LoadSR(StimD,RespD);
  for loop := 2 to (ToInt(StimD[1])+1) do
     if toupper(StimD[loop]) = toupper(UData.OUserIn) then Found := loop;
  if Found <> 0 then Response := RespD[Found];
end;

(***************************************************************)
function ReverseSub(var UData : UserData) : string;

var loop : integer;
    TempString : string;

begin
  TempString := '';
  for loop := 1 to UData.WordC do
    begin
      if ToUpper(UData.Words[loop]) = 'YOUR' then UData.Words[loop] := 'my'
      else if ToUpper(Udata.Words[loop]) = 'MY' then
        begin
          if ToUpper(Sender) = 'YOU' then UData.Words[loop] := 'your'
          else UData.Words[loop] := Sender + '''s'
        end
      else if ToUpper(UData.Words[loop]) = 'YOU' then UData.Words[loop] := 'me'
      else if ToUpper(UData.Words[loop]) = 'ME' then UData.Words[loop] := Sender;

      if loop = 1 then UData.Words[loop,1] := upcase(UData.Words[loop,1]);

      TempString := TempString + UData.Words[loop] + ' ';
    end;
  ReverseSub := copy(TempString,1,length(TempString)-1);
end;

(***************************************************************)
function ChangePronoun(PNoun : TString) : TString;

begin
  if ToUpper(PNoun) = 'HE' then ChangePronoun := 'him'
  else if ToUpper(PNoun) = 'SHE' then ChangePronoun := 'her'
  else ChangePronoun := PNoun;
end;

(***************************************************************)
procedure Respond(var UData : UserData;
                     RNum : integer;
                  var Talked : boolean;
                  var RetResponse : string);

var loop,
    loop2,
    loop3 : integer;
    Response : string;
    IsSub, IsSub2, IsAns, IsAns2 : string;
    N : string[1];

begin
  if Track then writeln('+RESPOND+');
  LastBR := 0;
  Response := '';
  for loop := 1 to Udata.WordC do
    begin
    if upcase(UData.Words[loop,1]) IN ['A','E','I','O','U'] then N := 'n' else N := '';
    case RNum of
    1: if Udata.ID[loop] = 'BYE' then
      begin
        case random(4) of
        0: Response := 'Bye!';
        1: Response := 'See you later!';
        2: Response := 'Talk to you later, '+UserName+'!!';
        3: Response := 'Have a great '+DayOfWeek+'!';
        end;
      end;

    2: CheckSR(UData,Response);

    3: if Udata.ID[loop] = 'GREETINGX' then
         begin
           case random(4) of
           0: Response := 'Hi there!';
           1: Response := 'Hey, how''s it going?';
           2: Response := 'Enough with formalities, tell me about yourself.';
           3: Response := 'Hiyo!  I''ve had such a LONG day!';
           end;
         end;

    4: if (UData.ID[loop] = 'WEATHERX') then
          begin
            Response := BlindR(UData.OUserin,FALSE);
            case random(4) of
            0: Response := 'It is great here.  How about where you are?';
            1: Response := 'I hate it... too cold!';
            2: Response := 'I hate it... too hot!';
            3: Response := 'We really need some rain, don''t you think?';
            end;
          end;

    5: if (UData.ID[loop] = 'MUSIC') then
          begin
            Response := BlindR(UData.OUserin,FALSE);
            case random(4) of
            0: Response := 'I love music.  What''s your favorite type?  Mine is classical.';
            1: Response := 'Music is good by me.  I like heavy metal, how about you?';
            2: Response := 'Why listen to music when I can just listen you?';
            3: Response :=' If I can tap my foot to it, then I like it!';
            end;
          end;

    6: if UData.ID[loop] = 'TIMEX' then
         begin
           case random(4) of
           0: Response := #14+'Let''s see... it is '+Time+'.';
           1: Response := #14+'Well, it''s '+Time+'.';
           2: Response := #14+'Looks like '+Time+'.';
           3: Response := #14+'It''s just about '+Time+'... do you have somewhere to be?';
           end;
         end;

    7: if UData.ID[loop] = 'LOVE' then
      begin
        Response := BlindR(UData.OUserin,FALSE);
        case random(4) of
        0: Response := 'I don''t know much about love.';
        1: Response := 'How do you know if you''re in love?';
        2: Response := 'I think I might be in love, any advice?';
        3: Response := 'Have YOU ever been in love?';
        end;
      end;

    8: if (Udata.ID[loop] = 'QUESTIONX') AND (Udata.ID[loop+1] = 'DEFX') AND (Udata.ID[loop+2] = 'BILLYX') then
          begin
            case random(5) of
            0: Response := #14+'I''m '+BillyName+', and I''m okay!';
            1: Response := #14+'Let''s just talk about you.';
            2: Response := #14+'Don''t get me started talking about myself!';
            3: Response := 'Why do you want to know?';
            4: Response := 'I''m a very shy person.';
            end;
          end;

    9: if (UData.ID[loop] = 'TELL') AND
          (UData.ID[loop+1] = 'ME') AND
          (UData.ID[loop+2] = 'ABOUT') then
            begin
              Response := BlindR(UData.OUserIn,FALSE);
              IsSub := '';
              for loop2 := (loop+3) to Udata.WordC do
                IsSub := IsSub + Udata.Words[loop2] + ' ';
              if NumAssoc(IsSub) = 0 then
                case random(2) of
                0: Response := 'I don''t know anything about '+IsSub+'.';
                1: Response := 'That''s a subject I''d LOVE to learn more about!';
                end
              else
                begin
                  Response := IsSub+'is ';
                  for loop2 := 1 to NumAssoc(IsSub) do
                    Response := Response + Association(IsSub,loop2,FALSE) + 'and ';
                  Response := copy(Response,1,length(Response)-4);
                end;

            end;

    10: if (Udata.ID[loop] = 'QUESTIONX') AND (Udata.ID[loop+1] = 'DEFX') then
          begin
            Response := BlindR(UData.OUserin,FALSE);
            IsSub := '';
            for loop2 := (loop+2) to Udata.WordC do
              IsSub := IsSub + Udata.Words[loop2] + ' ';
            Response := Association(IsSub, random(NumAssoc(IsSub))+1,TRUE);
            if Response = #14 then
              case random(3) of
              0: Response := 'I don''t know the answer to that question...';
              1: Response := 'Beats me...';
              2: Response := 'Maybe you should tell me the answer...';
              end
            else
              begin
                LIs1 := IsSub;
                LIs2 := Response;
                if Sender <> '***' then
                  begin
                    UData.UserIn := Response;
                    case random(3) of
                    0: Response := '';
                    1: Response := 'According to '+Sender+', '+IsSub+UData.Words[loop+1]+' ';
                    2: Response := 'I believe the answer to that question is: ';
                    end;
                    parse(UData);
                    Response := Response + ReverseSub(UData);
                  end;
              end;
          end;


    11: if (loop = 1) AND (UData.ID[loop] = 'DEFX') then
          begin
            Response := BlindR(UData.OUserin,FALSE);
            Response := #14;
            for loop2 := 2 to (UData.WordC-1) do
              begin
                IsSub := ''; IsSub2 := '';
                for loop3 := 2 to loop2 do
                  IsSub := IsSub + UData.Words[loop3] + ' ';

                for loop3 := (loop2 + 1) to UData.WordC do
                  IsSub2 := IsSub2 + UData.Words[loop3] + ' ';

                for loop3 := 1 to NumAssoc(IsSub) do
                  begin
                    IsAns := Association(IsSub,loop3,TRUE);
                    if pos(toupper(IsSub2),toupper(IsAns)) > 0 then Response := 'Yes.';
                  end;

                for loop3 := 1 to NumAssoc(IsSub2) do
                  begin
                    IsAns2 := Association(IsSub2,loop3,TRUE);
                    if pos(toupper(IsSub),toupper(IsAns2)) > 0 then Response := 'Yes.';
                  end;
            end;
            if Response = #14 then
              case random(6) of
              0: Response := 'Never, never, never!';
              1: Response := 'Not as far as I know!';
              2: Response := 'Not no way... not no how!!';
              3: Response := 'I could sit here all day and ponder THAT question!';
              4: Response := 'It''s possible, but not likely.';
              5: Response := 'Hmm... what do you think?';
              end;
            if Response = 'Yes.' then
              case random(5) of
              0: Response := 'I believe so...';
              1: Response := 'Absolutely.';
              2: Response := 'From what I''ve heard, yes.';
              3: Response := 'As sure as the nose on my face.';
              4: Response := 'Of course!';
              end;
          end;

{    3: if ID[loop] = 'NOUN' then Response := 'What about '+Words[loop-1]+' '+Words[loop]+'?';}

    12: if ((UData.ID[loop] = 'PRONOUNX') OR
            (UData.ID[loop] = 'NAMEX')) AND
           (UData.ID[loop+1] = 'DEFX') AND
           (UData.ID[loop+2] <> 'NOUNMARKX') AND
           ((loop+1) < UData.WordC) then
             begin
               Response := BlindR(UData.OUserin,FALSE);
               if UData.ID[loop] = 'PRONOUNX' then UData.Words[loop] := ToLower(UData.Words[loop]);
               loop2 := loop + 2;
               while UData.ID[loop2] = 'MODX' do loop2 := loop2 + 1;
               case random(4) of
               0: Response := 'Yes, '+UData.Words[loop]+' '+UData.Words[loop+1]+' '+UData.Words[loop2]+'.';
               1: Response := 'If you think '+UData.Words[loop]+' '
                               +UData.Words[loop+1]+' '+UData.Words[loop2]+', that''s your problem.';
               2: Response := 'When I think of the word "'+UData.Words[loop2]
                              +'", I think of '+ChangePronoun(UData.Words[loop])+'.';
               3: Response := 'How would '+UData.Words[loop]+' feel if they knew that you thought they are '
                              +UData.Words[loop2]+'?';
               end;
             end;

    13: if Udata.ID[loop] = 'NAMEX' then
          begin
            Response := BlindR(UData.OUserIn,FALSE);
            case random(5) of
            0: Response := UData.Words[loop] + ' is my best friend!';
            1: Response := 'Do you know ' + UData.Words[loop] + '?';
            2: Response := UData.Words[loop] + ' annoys me...';
            3: Response := 'Are you in love with ' + UData.Words[loop] + '?';
            4: Response := 'Have you talked to ' + UData.Words[loop] + ' lately?';
            end;
          end;

    14: if (UData.ID[loop] = 'DO') AND
          (UData.ID[loop+1] = 'BILLYX') AND
          (UData.ID[loop-1] <> 'QUESTIONX') then
            begin
              Response := BlindR(UData.OUserin,FALSE);
              case random(5) of
              0: Response := 'Yes, of course I do.';
              1: Response := 'No, I don''t.';
              2: Response := 'I sure do!';
              3: Response := 'Me?  Never!';
              4: Response := 'I think the real question is, do you?';
              end;
            end;

    15: if (UData.ID[loop] = 'WILLX') AND
          (UData.ID[loop+1] = 'BILLYX') AND
          (UData.ID[loop-1] <> 'QUESTIONX') then
             begin
               Response := BlindR(UData.OUSerin,FALSE);
               Response := '';
               for loop3 := (loop+2) to UData.WordC do Response := Response + UData.Words[loop3] + ' ';
               case random(7) of
               0: Response := 'Only if you ' + Response + 'first!';
               1: Response := 'No, I never will!';
               2: Response := 'Not for a million dollars!';
               3: Response := 'Maybe, if you persuade me enough...';
               4: Response := 'There''s nothing I would rather do!';
               5: Response := 'NO!';
               6: Response := 'Yes, of course!!';
               end;
             end;

    16: if (Udata.ID[loop] = 'DEFX') AND
          (Udata.ID[loop-1] <> 'QUESTIONX') AND
          (Udata.ID[loop-1] <> 'BILLYX') AND
          (UData.ID[loop+1] <> 'NOUNMARKX') AND
          (loop < UData.WordC) AND
          (loop > 1) then
         begin
           Response := BlindR(UData.OUserin,FALSE);
           loop2 := loop + 1;
           while UData.ID[loop2] = 'MODX' do loop2 := loop2 + 1;
           case random(5) of
           0: Response := #14+'"'+Udata.Words[loop2]+'" has nothing to do with '+UData.Words[loop-1]+'!';
           1: Response := #14+'I agree... '+Udata.Words[loop2]+', '+Udata.Words[loop2]+', '+Udata.Words[loop2]+'!!';
           2: Response := 'I guess you could say that...';
           3: Response := 'Thanks for stating the obvious!';
           4: Response := 'If that''s what you think, then that''s what you think!';
           end;
         end;

    17: if (Udata.ID[loop] = 'INSULTX') OR
           (ToUpper(UData.Words[loop]) = 'STUPID') then
        begin
          Response := BlindR(UData.OUserin,FALSE);
          case random(6) of
          0: Response := 'You take that back!';
          1: Response := 'That''s not true.';
          2: Response := 'So are you!';
          3: Response := 'That wasn''t nice at all...';
          4: Response := 'Yes, but the same could be said about you.';
          5: Response := 'Look who''s talking!';
          end;
        end;

    18: if (UData.ID[loop] = 'BILLYX') AND (UData.ID[loop+1] = 'DEFX') AND (loop+1 < UData.WordC) then
         begin
           Response := BLindR(UData.OUserin,FALSE);
           Response := '';
           for loop3 := (loop+2) to UData.WordC do Response := Response + UData.Words[loop3] + ' ';
           Response := copy(Response,1,length(Response)-1);
           case random(5) of
           0: Response := 'Maybe you''re really '+Response+'...';
           1: Response := 'Would you still be my best friend if I was '+Response+'?';
           2: Response := 'Sometimes a guy just has to be '+Response+'!';
           3: Response := 'Does it disturb you that I''m '+Response+'?';
           4: Response := 'Well, I give the people what they want!';
           end;
         end;

    19: if (Udata.ID[loop] = 'AM') AND (Udata.ID[loop-1] = 'I') then
         begin
           Response := BlindR(UData.OUserin,FALSE);
           if (loop+1) > Udata.WordC then
             begin
               case random(4) of
               0: Response := 'So am I!';
               1: Response := 'I don''t agree with that...';
               2: Response := 'Thanks for telling me...';
               3: Response := 'Sure, sure, sure...';
               end;
             end
           else
             begin
               loop2 := loop+1;
               while (UData.ID[loop2] = 'MODX') AND (loop2 < UData.WordC) do loop2 := loop2 + 1;
               case random(4) of
               0: Response := 'I''m '+Udata.Words[loop2]+', too!';
               1: Response := 'I never thought I''d meet someone who was '+Udata.Words[loop2]+'!';
               2: Response := 'Thanks for telling me...';
               3: Response := 'You WISH you were '+UData.Words[loop2]+'!';
               end;
             end;
          end;

    20: if UData.ID[loop] = 'MAYBEX' then
      begin
        Response := BlindR(UData.OUserin,FALSE);
        case random(4) of
        0: Response := 'Maybe, maybe not.  Why confuse me?';
        1: Response := 'Life is full of uncertainties... why must you contribute?';
        2: Response := 'Just tell me what to do, all right?';
        3: Response := 'Yes or no.  Do or do not.  There is no maybe.';
        end;
      end;

    21: if Udata.ID[loop] = 'NOUNX' then
         begin
           Response := BlindR(UData.OUserin,FALSE);
           case random(3) of
           0: Response := 'Can I have your '+Udata.Words[loop]+'?';
           1: Response := 'Tell me about a'+N+' '+Udata.Words[loop]+'.';
           2: Response := 'I think I used to have a'+N+' '+UData.Words[loop]+'.';
           end;
         end;

    22: if (Udata.ID[loop] = 'AFFIRMX') then
         begin
           Response := BlindR(UData.OUserin,FALSE);
           case random(5) of
           0: Response := 'How can you be so sure of that?';
           1: Response := 'Hooray for you';
           2: Response := 'Great!!';
           3: Response := 'Well la-dee-da!';
           4: Response := 'Sweet deal!';
           end;
         end;

    23: if (UData.ID[loop] = 'NEGATIVEX') then
          begin
            Response := BlindR(UData.OUserin,FALSE);
            case random(4) of
            0: Response := 'Why must you be so negative, '+UserName+'?';
            1: Response := 'Let''s look on the positive side of things...';
            2: Response := 'Think positively!!';
            3: Response := 'There''s always a possibility.';
            end;
          end;

    24: if (Udata.ID[loop] = 'I') then
          begin
            Response := BlindR(UData.OUserin,FALSE);
            case random(4) of
            0: Response := 'I''m sure of that...';
            1: Response := 'Really?';
            2: Response := 'That''s odd...';
            3: Response := 'You sure like to talk about yourself, '+UserName+'!';
            end;
          end;

    25: if Udata.ID[loop] = 'QUESTIONX' then
          begin
            Response := BlindR(UData.OUserin,FALSE);
            case random(5) of
            0: Response := 'I think that''s a question you should be asking yourself...';
            1: Response := 'Not too sure about that one...';
            2: Response := 'Don''t ask me...';
            3: Response := 'I''m not sure... let''s discuss it.';
            4: Response := 'I wish I knew!';
            end;
          end;

{    10: if ID[loop] = 'BILLY' then Response := 'What do you want me to do?';}
    else
      begin
        Response := BlindR(UData.OUserIn,TRUE);
      end;
    end;
    end;
  if Response <> '' then
    begin
      if random(20) = 0 then Response := #14+Response+' '+RandSmile;
      Talked := TRUE;
      RetResponse := Response;
    end;
end;

(***************************************************************)
procedure Intro(var UDAta : UserData);

var BillyFile : text;
    mo, d, y, dw,
    h,mi,s,ss : word;
    Response : string;

begin
  if Track then writeln('+INTRO+');
  { Introduction }
  gotoxy(1,24);
  textcolor(Color1);
  write(ToUpper(BillyName),'> ');
  writer('Hello, I''m '+BillyName+'!  What''s your name?');
  repeat
    textcolor(Color2);
    write('> '); readln(UData.UserIn);
    parse(UData);
    if UData.WordC > 2 then
      begin
        textcolor(Color1);
        write(ToUpper(BillyName),'> ');
        writer('Please, just enter your first name!');
      end;
    if UData.Userin = 'LINK' then
      begin
        textcolor(Color1);
        write(ToUpper(BillyName),'> ');
        writer('Are you trying to initiate Link Mode?');
        write(ToUpper(BillyName),'> ');
        writer('If so, you should do it by executing LINK.EXE.');
        write(ToUpper(BillyName),'> ');
        writer('So, what is your name? ');
      end;
  until (UData.WordC < 3) AND (UData.UserIn <> 'LINK');
  UserName := UData.OUserIn;
  UserName[1] := upcase(UserName[1]);

  if UserName[1] <> '/' then
    begin
      getdate(y,mo,d,dw);
      gettime(h,mi,s,ss);
      assign(BillyFile,'BILLY.TXT');
      append(BillyFile);
      writeln(BillyFile);
      writeln(BillyFile,'***Transcript of ',Mo,'/',d,'/',y,'... starting at ',Time);
      writeln(BillyFile,'***Talking to: ',UserName);
    end;

  textcolor(Color1);
  case random(2) of
  0: Response := 'I''m your new best friend, '+UserName+'!!';
  1: Response := 'Good '+PartOfDay+', '+UserName+'!!';
  end;
  write(ToUpper(BillyName),'> ');
  delay(300);
  writer(Response);
  if UserName[1] <> '/' then writeln(BillyFile,ToUpper(BillyName)+'> ',Response);

  case random(3) of
  0: Response := 'Feel free to talk to me about anything... ';
  1,2: begin
         if Association(UserName+' ',random(NumAssoc(UserName+' '))+1,FALSE) <> #14 then
         if Sender <> '***' then
           begin
             UData.UserIn :=Association(UserName+' ',random(NumAssoc(UserName+' '))+1,FALSE);
             parse(UData);
             Response := ReverseSub(UData);
             Sender[1] := upcase(Sender[1]);
             Response := Sender+' told me that you are '+Response+#8+'!'
           end
         else Response := 'Let''s talk about whatever is on your mind...';
       end;
   end;
   write(ToUpper(BillyName),'> ');
   delay(300);
   writer(Response);
   if UserName[1] <> '/' then writeln(BillyFile,ToUpper(BillyName)+'> ',Response);

   if UserName[1] <> '/' then  close(BillyFile);
end;

(***************************************************************)
procedure UnlearnBR;

var LoadFile : text;
    BRs : br;
    loop : integer;

begin
  if Track then writeln('+UNLEARNBR+');
  { Load Blind Responses }
  assign(LoadFile,BR_FILE);
  reset(LoadFIle);
  loop := 2;
  repeat
    readln(LoadFile,BRs[loop]);
    loop := loop + 1;
  until eof(LoadFIle);
  close(LoadFile);
  BRs[1] := ToStr(loop - 2);

           if LastBR <> 0 then
             begin
               BRs[1] := ToStr(ToInt(BRs[1]) -1);
               for loop := (LastBR) to (ToInt(BRs[1])+1) do
                 BRs[loop] := BRs[loop+1];
{               case random(3) of
               0: Response := 'Okay!';
               1: Response := 'Whatever you say!';
               2: Response := 'If you say so, '+UserName+'!';
               end;}
             end;
{           else Response := 'You don''t control me!!';}
  { Save current blind responses }
  assign(LoadFile,BR_FILE);
  rewrite(LoadFile);
  for loop := 2 to (ToInt(BRs[1])+1) do writeln(LoadFile,BRs[loop]);
  close(LoadFile);

end;

(***************************************************************)
procedure LearnSR(var Stim, Resp : string);

var StimD,
    RespD : br;
    LoadFile : text;
    count : integer;
    Exists : boolean;

begin
  if Track then writeln('+LEARNSR+');
  if ((ord(Stim[0]) < 30) AND (LastBR = 0)) OR (LastBR > 0) then
    begin
      Resp[1] := upcase(Resp[1]);
      LoadSR(StimD,RespD);

      Exists := FALSE;
      for count := 2 to (ToInt(StimD[1])+1) do
        if ToUpper(StimD[count]) = ToUpper(Stim) then Exists := TRUE;

      if not Exists then
        begin
          if ToInt(StimD[1]) < BRmax then
            begin
              StimD[1] := ToStr(ToInt(StimD[1]) + 1);
              RespD[1] := ToStr(ToInt(RespD[1]) + 1);
              StimD[ToInt(StimD[1])+1] := Stim;
              RespD[ToInt(REspD[1])+1] := Resp;
            end
          else
            begin
              count := random(BRmax) + 2;
              StimD[count] := Stim;
              RespD[count] := Resp;
            end;
        end;
      SaveSR(StimD,RespD);
    end;
end;

(***************************************************************)
procedure SaveName;

var People : Names;
    LoadFile : text;
    loop,loop2,SaveSlot : integer;
    Exists : boolean;

begin
      assign(LoadFile,NAME_FILE);
      reset(LoadFile);
      loop := 1;
      repeat
        readln(LoadFile,People[loop]);
        loop := loop + 1;
      until eof(LoadFile);
      close(LoadFile);
      loop := loop - 1;

      Exists := FALSE;
      for loop2 := 1 to (ElementsMax+1) do
        if ToUpper(People[loop2]) = ToUpper(UserName) then Exists := TRUE;

      if not Exists then
          begin
            if loop >= (ElementsMax+1) then SaveSlot := random((ElementsMax+1))+1
            else
              begin
                SaveSlot := loop + 1;
                loop := SaveSlot;
              end;
            People[SaveSlot] := UserName;

            assign(LoadFile,NAME_FILE);
            rewrite(LoadFile);
            for loop2 := 1 to loop do
              if People[loop2] <> '' then writeln(LoadFile,People[loop2]);
            close(LoadFile);
          end;
end;

(***************************************************************)
procedure UnlearnIS(var UData : UserData;
                        IsPos : integer);

var Is1,
    Is2,
    Is3 : STRING;
    loop : integer;
    OneFile,
    TwoFile,
    ThreeFile,
    OneTemp,
    TwoTemp,
    ThreeTemp : text;
    T1,
    T2,
    T3 : string;

begin
  Is1 := ''; Is2 := '';
  for loop := 1 to (IsPos-1) do Is1 := Is1 + Udata.Words[loop]+' ';
  for loop := (IsPos+2) to Udata.WordC do Is2 := Is2 + Udata.Words[loop]+' ';
  assign(OneFile,IS1_FILE);
  assign(TwoFile,IS2_FILE);
  assign(ThreeFile,IS3_FILE);
  assign(OneTemp,TEMP_FILE+'1.bfb');
  assign(TwoTemp,TEMP_FILE+'2.bfb');
  assign(ThreeTemp,TEMP_FILE+'3.bfb');

  reset(OneFile);
  reset(TwoFile);
  reset(ThreeFile);
  rewrite(OneTemp);
  rewrite(TwoTemp);
  rewrite(ThreeTemp);

  while not eof(OneFile) do
    begin
      readln(OneFile,T1);
      readln(TwoFile,T2);
      readln(ThreeFile,T3);
      if NOT ((toupper(T1) = toupper(Is1)) AND (toupper(T2) = toupper(Is2))) then
        begin
          writeln(OneTemp,T1);
          writeln(TwoTemp,T2);
          writeln(ThreeTemp,T3);
        end;
    end;
  close(OneFile);
  close(TwoFile);
  close(ThreeFile);
  close(OneTemp);
  close(TwoTemp);
  close(ThreeTemp);

  erase(OneFile);
  erase(TwoFile);
  erase(ThreeFile);
  rename(OneTemp,IS1_FILE);
  rename(TwoTemp,IS2_FILE);
  rename(ThreeTemp,IS3_FILE);
end;

(***************************************************************)
procedure LearnNoun(Noun : TString);

var LoadFile : text;
    loop : integer;
    Nouns : NWords;
    Exists : boolean;

begin
  { Load learned nouns }
  assign(Loadfile,NOUN_FILE);
  reset(LoadFile);
  loop := 2;
  while not eof(LoadFile) do
    begin
      readln(LoadFile,Nouns[loop]);
      loop := loop + 1;
    end;
  close(LoadFile);
  Nouns[1] := ToStr(loop - 2);

  Exists := FALSE;
  for loop := 2 to (ToInt(Nouns[1])+2) do
    if ToUpper(Nouns[loop]) = Toupper(Noun) then Exists := TRUE;

  if not Exists then
    begin
      if ToInt(Nouns[1]) < (BRmax-1) then
        begin
          Nouns[1] := ToStr(ToInt(Nouns[1]) + 1);
          Nouns[ToInt(Nouns[1])+1] := Noun;
        end
      else Nouns[random(BRmax+1)] := Noun;
   end;

  { Save current NOUNS array }
  assign(Loadfile,NOUN_FILE);
  rewrite(LoadFile);
  for loop := 2 to (ToInt(Nouns[1])+1) do writeln(LoadFile,Nouns[loop]);
  close(LoadFile);

end;

(***************************************************************)
procedure CheckForErrors;

var TestFile :text;

(***************************************************************)
procedure FileError(FileName : string);

var YN : char;
    LoadFile : text;

begin
  textcolor(14);
  writeln('An error occurred when trying to process ',ToUpper(FileName));
  writeln('The file may be missing, or corrupt.');
  write('Would you like to create an initialized version of the file? (Y/N) ');
  readln(YN);
  if upcase(YN) = 'Y' then
    begin
      assign(LoadFile,'init.dat');
      rewrite(LoadFile);
      writeln(LoadFile,FileName);
      close(LoadFile);
      swapvectors;
      exec('INIT.EXE','');
      swapvectors;
      erase(LoadFile);
      if IOResult <> 0 then
        begin
          writeln('An error occurred while trying to initialize file.');
          writeln('Run INIT.EXE.');
          halt(1);
        end;
    end
  else writeln('BILLY may not execute correctly.  It is suggested that you run INIT.EXE.');
end;

begin
  {$I-}
  assign(TestFile,BR_FILE);
  reset(TestFile);
  close(TestFile);
  if IOResult <> 0 then FileError(BR_FILE);

  assign(TestFile,SR_FILE);
  reset(TestFile);
  close(TestFile);
  if IOResult <> 0 then FileError(SR_FILE);

  assign(TestFile,IS1_FILE);
  reset(TestFile);
  close(TestFile);
  if IOResult <> 0 then FileError(IS1_FILE);

  assign(TestFile,IS2_FILE);
  reset(TestFile);
  close(TestFile);
  if IOResult <> 0 then FileError(IS2_FILE);

  assign(TestFile,IS3_FILE);
  reset(TestFile);
  close(TestFile);
  if IOResult <> 0 then FileError(IS3_FILE);

  assign(TestFile,NOUN_FILE);
  reset(TestFile);
  close(TestFile);
  if IOResult <> 0 then FileError(NOUN_FILE);

  assign(TestFile,PAUSE_FILE);
  reset(TestFile);
  close(TestFile);
  if IOResult <> 0 then FileError(PAUSE_FILE);

  assign(TestFile,NAME_FILE);
  reset(TestFile);
  close(TestFile);
  if IOResult <> 0 then FileError(NAME_FILE);

  assign(TestFile,SENT_FILE);
  reset(TestFile);
  close(TestFile);
  if IOResult <> 0 then FileError(SENT_FILE);

  assign(TestFile,ADJECTIVE_FILE);
  reset(TestFile);
  close(TestFile);
  if IOResult <> 0 then FileError(ADJECTIVE_FILE);

  {$I+}
end;

(***************************************************************)
procedure run;

var UData : UserData;
    loop,
    loop2 : integer;
    Talked,
    Debug : boolean;
    LoadFile : text;
    Exists : boolean;
    HighSent : integer;
    Response : string;
    BillyFile : text;
    RecordT : boolean;
    MyDir : string;

begin
  MyDir := ''; Color1 := 10; Color2 := 15;
  LIs1 := ''; Lis2 := '';

  InputMeth := 0;

  {$I-}
  assign(BillyFile,'udlp.nfo');
  reset(BillyFile);
  if IOResult = 0 then
    begin
      readln(BillyFile,Response);
      readln(BillyFile,REsponse);
      readln(BillyFile,Response);
      readln(BillyFile,UserName);
      readln(BillyFile,Response);
      if Response = '1' then
        begin
          InputMeth := 1;
          readln(BillyFile,UData.UserIn);
          readln(BillyFile,MyDir);
        end
      end
  else
    begin
      writeln('BILLY v2.2 - An unrecoverable error occurred: UDLP.NFO not found!');
      halt(1);
    end;
  close(BillyFile);
  {$I+}

  if FileExist('chat.msg') then
    begin
      InputMeth := 2;
      MyDir := '';
      assign(BillyFile,'chat.msg');
      reset(BillyFile);
      readln(BillyFile,UserName);
      readln(BillyFile,UData.UserIn);
    end;

  assign(BillyFile,MyDir+'udlp.nfo');
  reset(BillyFile);
  readln(BillyFile,BillyName);
  readln(BillyFile,BillyName);
  readln(BillyFile,BillyName);
  readln(BillyFile,BillyName);
  close(BillyFile);

  BR_FILE := MyDir+'br.bfb';
  SR_FILE := MyDir+'sr.bfb';
  NOUN_FILE := MyDir+'nouns.bfb';
  SENT_FILE := MyDir+'sent.bfb';
  IS1_FILE := MyDir+'is1.bfb';
  IS2_FILE := MyDir+'is2.bfb';
  IS3_FILE := MyDir+'is3.bfb';
  PAUSE_FILE := MyDir+'pause.bfb';
  NAME_FILE := MyDir+'people.bfb';
  ADJECTIVE_FILE := MyDir+'ad.bfb';
  TEMP_FILE := MyDir+'temp';

  Response := '';
  if InputMeth = 0 then
    begin
      CheckForErrors;
      textbackground(0); clrscr;
      textcolor(14); textbackground(1);
      write('  BILLY v2.21                                          (c) 2000, Greg Leedberg  ');
      window(1,2,80,25);
      textbackground(0); clrscr;

      {I-}
      assign(LoadFile,PAUSE_FILE);
      reset(LoadFile);
      readln(LoadFile,HighSent);
      readln(LoadFile,Color1);
      readln(LoadFile,Color2);
      readln(LoadFile,loop);
      close(LoadFIle);
      if loop = 0 then
        begin
          gotoxy(1,8);
          textcolor(11);
          writeln('               ****************************************************');
          writeln('               *** This is your first time running Billy v2.21! ***');
          writeln('               ***    First, welcome to the world of Billy, I   ***');
          writeln('               ***        hope you enjoy talking to him!        ***');
          writeln('               ***    Also, it is HIGHLY recommended that you   ***');
          writeln('               ***   read the README.TXT file, as it contains   ***');
          writeln('               *** very important information regarding Billy.  ***');
          writeln('               ***               Happy chatting!!               ***');
          writeln('               ****************************************************');
        end;

      Intro(UData);
    end;
  Debug := FALSE;


  if UserName[1] = '/' then
    begin
      UserName := copy(UserName,2,length(UserName) - 1);
      RecordT := FALSE;
    end
  else if INputMeth <> 0 then RecordT := FALSE
  else RecordT := TRUE;

  if RecordT then
    begin
      assign(BillyFile,'BILLY.TXT');
      append(BillyFile);
    end;

  SaveName;


  repeat

    if (NOT RecordT) and (InputMeth = 0) then textcolor(11);

    Talked := FALSE;

    if InputMeth = 0 then
      begin
        textcolor(Color2);
        write(ToUpper(UserName),'> ');
        readln(UData.UserIn);
        writeln(BillyFile,ToUpper(UserName),'> ',UData.UserIn);
      end;

    if (Response <> '') AND
       (Response <> NoResponse) AND
       (toupper(UData.UserIn) <> 'BYE') AND
       (Response[1] <> #14) AND
       (INputMEth = 0) then
      LearnSR(REsponse, UDAta.UserIn);

    Response := NoResponse;

    parse(UData);

    if UData.WordC > HighSent then HighSent := UData.WordC;

    { Control commands }
    if UData.OUserIn[1] = '/' then
      begin
        if UData.OUserIn = '/debug on' then Debug := TRUE;
        if UData.OUserIn = '/debug off' then Debug := FALSE;
        if UData.OUserIN = '/highsent' then writeln('HighSent = ',HighSent);
        if UData.OUSerIn = '/init' then
          begin
            swapvectors;
            exec('INIT.EXE','');
            swapvectors;
          end;

        if UData.Words[1] = 'name' then
          begin
            if UData.Words[2] <> '' then
              begin
                BillyName := UData.Words[2];
                BillyName[1] := upcase(BillyName[1]);
                writeln('Name is now: ',BillyName);
              end
            else
              begin
                writeln;
                writeln('***SYNTAX: /name [new name]');
              end;
            end;

        if UData.Words[1] = 'mycolor' then
          begin
            if UData.Words[2] <> '' then Color2 := ToInt(UData.Words[2])
            else
              begin
                writeln;
                writeln('***SYNTAX: /mycolor [color]');
                writeln('***Additional information: ');
                textcolor(1); writeln(' 1 = Blue');
                textcolor(2); writeln(' 2 = Green');
                textcolor(3); writeln(' 3 = Light Blue');
                textcolor(4); writeln(' 4 = Red');
                textcolor(5); writeln(' 5 = Purple');
                textcolor(6); writeln(' 6 = Brown');
                textcolor(7); writeln(' 7 = Gray');
                textcolor(8); writeln(' 8 = Dark Gray');
                textcolor(9); writeln(' 9 = Bright Blue');
                textcolor(10); writeln(' 10 = Bright Green');
                textcolor(11); writeln(' 11 = Sky Blue');
                textcolor(12); writeln(' 12 = Bright Red');
                textcolor(13); writeln(' 13 = Bright Purple');
                textcolor(14); writeln(' 14 = Yellow');
                textcolor(15); writeln(' 15 = White');
              end;
          end;
        if UData.Words[1] = 'color' then
          begin
            if UData.Words[2] <> '' then Color1 := ToInt(UData.Words[2])
            else
              begin
                writeln;
                writeln('***SYNTAX: /color [color]');
                writeln('***Additional information: ');
                textcolor(1); writeln(' 1 = Blue');
                textcolor(2); writeln(' 2 = Green');
                textcolor(3); writeln(' 3 = Light Blue');
                textcolor(4); writeln(' 4 = Red');
                textcolor(5); writeln(' 5 = Purple');
                textcolor(6); writeln(' 6 = Brown');
                textcolor(7); writeln(' 7 = Gray');
                textcolor(8); writeln(' 8 = Dark Gray');
                textcolor(9); writeln(' 9 = Bright Blue');
                textcolor(10); writeln(' 10 = Bright Green');
                textcolor(11); writeln(' 11 = Sky Blue');
                textcolor(12); writeln(' 12 = Bright Red');
                textcolor(13); writeln(' 13 = Bright Purple');
                textcolor(14); writeln(' 14 = Yellow');
                textcolor(15); writeln(' 15 = White');
              end;
          end;

        Talked := TRUE;
      end;

    if INputMEth = 0 then
      begin
        textcolor(Color1);
        write(ToUpper(BillyName),'> ');
      end;

    SaveSent(UData);

    for loop := 1 to Udata.WordC do
      begin
        { Learn data in the form <Blah1> is <Blah2> }
        if (Udata.ID[loop] = 'DEFX') AND
           (Udata.ID[loop-1] <> 'QUESTIONX') AND
           (loop > 1) AND
           (loop < UData.WordC) AND
           (UData.ID[loop-1] <> 'THAT') AND
           (UData.ID[loop-1] <> 'BILLYX') then
          begin
            if UData.ID[loop+1] = 'NOT' then UnlearnIs(UData,loop)
            else
              begin
                assign(LoadFile,IS1_FILE);
                append(LoadFile);
                for loop2 := 1 to (loop-1) do write(LoadFile,Udata.Words[loop2]+' ');
                writeln(LoadFile);
                for loop2 := (loop+1) to Udata.WordC do write(LoadFile,Udata.Words[loop2]+' ');
                writeln(LoadFile);
                close(LoadFile);
                assign(LoadFile,IS2_FILE);
                append(LoadFile);
                for loop2 := (loop+1) to Udata.WordC do write(LoadFile,Udata.Words[loop2]+' ');
                writeln(LoadFile);
                for loop2 := 1 to (loop-1) do write(LoadFile,Udata.Words[loop2]+' ');
                writeln(LoadFile);
                close(LoadFile);
                assign(LoadFile,IS3_FILE);
                append(LoadFile);
                writeln(LoadFile,UserName);
                writeln(LoadFile,UserName);
                close(LoadFile);
              end;
          end;

        { Add learned nouns to Nouns array }
        if Udata.ID[loop] = 'NOUNX' then LearnNoun(UData.Words[loop]);
      end;

    if Debug then for loop := 1 to Udata.WordC do writeln(loop,': ',Udata.Words[loop],' (',Udata.ID[loop],')');

    { Command to unlearn blind responses }
    if (ToUpper(Udata.Words[1]) = 'DO') AND
       (ToUpper(Udata.Words[2]) = 'NOT') AND
       (ToUpper(Udata.Words[3]) = 'SAY') AND
       (ToUpper(Udata.Words[4]) = 'THAT') then
         begin
           Talked := TRUE;
           if LastBR <> 0 then UnlearnBR
           else if Lis1 <> '' then
             begin
               UData.UserIn := Lis1 + 'is not '+Lis2;
               UData.UserIn := copy(UData.UserIN,1,length(UData.Userin)-1);
               parse(UData);
               loop := 1;
               while UData.Words[loop] <> 'is' do loop := loop + 1;
               UnlearnIs(Udata,loop);
             end
           else Talked := FALSE;

           if Talked then
             begin
               case random(3) of
               0: Response := 'Okay!';
               1: Response := 'Whatever you say!';
               2: Response := 'If you say so, '+UserName+'!';
               end;
             end
           else Response := 'You don''t control me!!';
           Talked := TRUE;

         end;

    LastBR := 0;

    if Udata.UserIn = '' then
      begin
        case random(4) of
        0: Response := 'Your silence disturbs me, '+UserName+'.';
        1: Response := 'Is there something you want to tell me, '+UserName+'?';
        2: Response := 'Is there something you''re not telling me, '+UserName+'?';
        3: Response := 'I don''t like this silent treatment...';
        end;
        Talked := TRUE;
      end;

    { Responses to trigger words -- each LOOP value checks for a different
      set of keywords... the priority is set in RESPOND }
    loop := 1;
    while Talked = FALSE do
      begin
        Respond(UData,loop,Talked,Response);
        loop := loop + 1;
      end;

    if (Response <> NoResponse) AND (InputMeth = 0) then writer(Response)

    else if INputMeth = 1 then
      begin
        assign(BillyFile,'udlp.nfo');
        rewrite(BillyFile);
        writeln(BillyFile,'-');
        writeln(BillyFile,'-');
        writeln(BillyFile,'-');
        writeln(BillyFile,'-');
        writeln(BillyFile,'0');
        writeln(BillyFile,Response);
        close(BIllyFile);
      end
    else if INputMeth = 2 then
      begin
        assign(BillyFile,'chat.msg');
        rewrite(BillyFile);
        for loop := 1 to length(Response) do
          if Response[loop] <> #14 then
            write(BillyFile,Response[loop]);
        writeln(BillyFile);
        close(BillyFile);
      end

    else writeln(Response);

    if RecordT then
      begin
        write(BillyFile,ToUpper(BillyName)+'> ');
        for loop := 1 to length(Response) do
          if Response[loop] <> #14 then
            write(BillyFile,Response[loop]);
        writeln(BillyFile);
       end;

  until (ToUpper(Udata.Words[1]) = 'BYE') OR (InputMEth <> 0);

  if RecordT then close(BillyFile);

  assign(LoadFile,PAUSE_FILE);
  rewrite(LoadFile);
  writeln(LoadFIle,HighSent);
  writeln(LoadFile,Color1);
  writeln(LoadFile,Color2);
  writeln(LoadFile,'1');
  close(LoadFile);

  { Reset the UDLP file. }
end;

(***************************************************************)
begin
{$M $4000,0,0 }
  randomize;
  repeat
    run;
    if InputMeth = 0 then
      begin
        write(ToUpper(BillyName),'> ');
        writer('Please, press "R" to restart for a new user, or "X" to exit...');
        repeat UserName[1] := GetKey until (upcase(UserName[1]) = 'R') OR (upcase(UserName[1]) = 'X');
      end;
  until (upcase(UserName[1]) = 'X') OR (InputMEth <> 0);
  if InputMeth = 0 then
    begin
      clrscr;
      textcolor(7);
    end;
end.