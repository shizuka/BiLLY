{
   UDLP2 Link Shell 1.0
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


program linkmode;
uses dos,crt;

(***************************************************************)
{ ToUpper converts a string to uppercase }
function ToUpper(TextString : string) : string;  { Original string }

var loop2 : integer;                   { Loop control variable }

begin
  for loop2 := 1 to length(TextString) do
    TextString[loop2] := upcase(TextString[loop2]);
  ToUpper := TextString;
end;


(***********************************************************)
procedure run;

var Path1, Path2, CurDir : string;
    Exe1,Exe2,Name1,Name2 : string[20];
    LoadFile : text;
    Version,Col1,Col2 : integer;
    temp : string;

begin
  {$M $4000,0,0 }
  GetDir(0,CurDir);
  curdir := curdir + '\';
  textbackground(1);
  clrscr;
  gotoxy(1,1);
  textcolor(10);
  write(' UDLP2 Shell 1.0                                 A Greg Leedberg Creation, 2000');
  window(1,2,80,25);
  textbackground(0); clrscr;
  textcolor(7);
  write('Enter path to bot #1: ');
  readln(Path1);
  if Path1[length(Path1)] <> '\' then Path1 := Path1 + '\';
  write('Enter path to bot #2: ');
  readln(Path2);
  if Path2[length(Path2)] <> '\' then Path2 := Path2 + '\';
  randomize;
  Col1 := random(15) + 1;
  Col2 := random(15) + 1;
  while Col2 = Col1 do Col2 := random(15) + 1;
  assign(LoadFile,Path1+'udlp.nfo');
  reset(LoadFile);
  readln(LoadFile,Version);
  if Version = 1 then
    begin
      writeln('Bot #1 does not support UDLP 2.0!!');
      writeln('Try initiating link mode from within bot #1.');
      halt(1);
    end;
  readln(LoadFile,temp);
  readln(LoadFile,Exe1);
  readln(LoadFile,Name1);
  close(LoadFile);

  assign(LoadFile,Path2+'udlp.nfo');
  reset(LoadFile);
  readln(LoadFile,Version);
  if Version = 1 then
    begin
      writeln('Bot #2 does not support UDLP 2.0!!');
      writeln('Try initiating link mode from within bot #2.');
      halt(1);
    end;
  readln(LoadFile,temp);
  readln(LoadFile,Exe2);
  readln(LoadFile,Name2);
  close(LoadFile);
  chdir(path1);
  assign(LoadFile,'chat.msg');
  rewrite(LoadFile);
  writeln(LoadFile,Name2);
  writeln(LoadFile,'Hi!');
  close(LoadFile);

  repeat
    textcolor(Col1);
    write(ToUpper(Name1),'> ');
    swapvectors;
    exec(Path1+Exe1,'');
    swapvectors;

    { Get/write #1 response }
    reset(LoadFile);
    readln(LoadFile,temp);
    close(LoadFile);
    append(LoadFile);
    writeln(LoadFile,Col1);
    close(LoadFile);
    swapvectors;
    exec(CurDir+'writer.exe','');
    swapvectors;

    erase(LoadFile);

    { Generate #2 response }
    chdir(Path2);
    assign(LoadFile,'chat.msg');
    rewrite(LoadFile);
    writeln(LoadFile,Name1);
    writeln(LoadFile,temp);
    close(LoadFile);

    textcolor(Col2);
    write(ToUpper(Name2),'> ');
    swapvectors;
    exec(PAth2+Exe2,'');
    swapvectors;

    { Get/write #2 response }
    reset(LoadFile);
    readln(LoadFile,temp);
    close(LoadFile);
    append(LoadFile);
    writeln(LoadFile,Col2);
    close(LoadFile);
    swapvectors;
    exec(CurDir+'writer.exe','');
    swapvectors;

    erase(LoadFile);

    { Generate #1 response }
    chdir(Path1);
    assign(LoadFile,'chat.msg');
    rewrite(LoadFile);
    writeln(LoadFile,Name2);
    writeln(LoadFile,temp);
    close(LoadFile);
  until keypressed;

  erase(LoadFile);
  chdir(curdir);
end;

(***********************************************************)
begin
  run
end.