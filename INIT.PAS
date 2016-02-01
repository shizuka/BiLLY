{
   INIT for Billy 2.21
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

program BillyInit;
uses crt;

(***************************************************************)
function ToUpper(TextString : string) : String;

var loop2 : integer;

begin
  for loop2 := 1 to length(TextString) do
    TextString[loop2] := upcase(TextString[loop2]);
  ToUpper := TextString;
end;


(*************************************************************)
procedure InitFile(FileName : string);

var BillyFile : text;
begin
  FileName := ToUpper(FileName);
  if FileName = 'BR.BFB' then
    begin
      assign(BillyFile,'br.BFB');
      rewrite(BillyFile);
      writeln(BillyFile,'I''m not too sure about that...');
      writeln(BillyFile,'Tell more, please!');
      writeln(BillyFile,'Whoa, there!');
      close(BillyFile);
    end
  else if FileName = 'NOUNS.BFB' then
    begin
      assign(BillyFile,'nouns.bfb');
      rewrite(BillyFile);
      writeln(BillyFile,'car');
      writeln(BillyFile,'house');
      close(BillyFile);
    end
  else if FileName = 'IS1.BFB' then
    begin
      assign(BillyFile,'is1.BFB');
      rewrite(BillyFile);
      writeln(BillyFile,'up ');
      close(BillyFile);
    end
  else if FileName = 'IS2.BFB' then
    begin
      assign(BillyFile,'is2.BFB');
      rewrite(BillyFile);
      writeln(BillyFile,'not too much, really! ');
      close(BillyFile);
    end
  else if FileName = 'IS3.BFB' then
    begin
      assign(BillyFile,'is3.BFB');
      rewrite(BillyFile);
      writeln(BillyFile,'***');
      close(BillyFile);
    end
  else if FileName = 'PAUSE.BFB' then
    begin
      assign(BillyFile,'pause.bfb');
      rewrite(BIllyFile);
      writeln(BillyFile,'19');
      writeln(BillyFile,'10');
      writeln(BillyFile,'15');
      writeln(BillyFile,'0');
      close(BillyFile);
    end
  else if FileName = 'PEOPLE.BFB' then
    begin
      assign(BillyFile,'people.bfb');
      rewrite(BillyFile);
      close(BillyFile);
    end
  else if FileName = 'SR.BFB' then
    begin
      assign(BillyFile,'sr.BFB');
      rewrite(BillyFile);
      close(BillyFile);
    end
  else if FileName = 'SENT.BFB' then
    begin
      assign(BillyFile,'sent.BFB');
      rewrite(BillyFile);
      writeln(BillyFile,'Can I have your ');
      writeln(BillyFile,'?');
      close(BillyFile);
    end
  else if FileName = 'AD.BFB' then
    begin
      assign(BillyFile,'ad.bfb');
      rewrite(BillyFile);
      writeln(BillyFile,'BIG');
      writeln(BillyFile,'CONSIDERABLE');
      writeln(BillyFile,'EXTENSIVE');
      writeln(BillyFile,'HEFTY');
      writeln(BillyFile,'LARGE');
      writeln(BillyFile,'MAJOR');
      writeln(BillyFile,'SIZABLE');
      writeln(BillyFile,'FAT');
      writeln(BillyFile,'GREAT');
      writeln(BillyFile,'HUSKY');
      writeln(BillyFile,'PREGNANT');
      writeln(BillyFile,'HEAVY');
      writeln(BillyFile,'FULL');
      writeln(BillyFile,'CRAMMED');
      writeln(BillyFile,'CROWDED');
      writeln(BillyFile,'JAMMED');
      writeln(BillyFile,'IMPORTANT');
      writeln(BillyFile,'CONSEQUENTIAL');
      writeln(BillyFile,'MEANINGFUL');
      writeln(BillyFile,'MOMENTUS');
      writeln(BillyFile,'SIGNIFICANT');
      writeln(BillyFile,'SUBSTANTIAL');
      writeln(BillyFile,'WEIGHTY');
      writeln(BillyFile,'SMALL');
      writeln(BillyFile,'BLACK');
      writeln(BillyFile,'WHITE');
      writeln(BillyFile,'RED');
      writeln(BillyFile,'BLUE');
      writeln(BillyFile,'GREEN');
      writeln(BillyFile,'YELLOW');
      writeln(BillyFile,'UGLY');
      writeln(BillyFile,'BEAUTIFUL');
      writeln(BillyFile,'CUTE');
      writeln(BillyFile,'WARM');
      writeln(BillyFile,'HOT');
      writeln(BillyFile,'SLOW');
      writeln(BillyFile,'FAST');
      writeln(BillyFile,'LITTLE');
      writeln(BillyFile,'STUPID');
      writeln(BillyFile,'DUMB');
      writeln(BillyFile,'SWEET');
      writeln(BillyFile,'BEST');
      writeln(BillyFile,'WORST');
      writeln(BillyFile,'GOOD');
      writeln(BillyFile,'BAD');
      writeln(BillyFile,'SAME');
      writeln(BillyFile,'MOST');
      writeln(BillyFile,'COOLEST');
      writeln(BillyFile,'LAMEST');
      writeln(BillyFile,'DUMBEST');
      writeln(BillyFile,'VIOLENT');
      writeln(BillyFile,'PEACEFUL');
      writeln(BillyFile,'COMPLETE');
      writeln(BillyFile,'ALMIGHTY');
      writeln(BillyFile,'NEW');
      writeln(BillyFile,'OLD');
      writeln(BillyFile,'WRONG');
      writeln(BillyFile,'RIGHT');
      writeln(BillyFile,'SMILING');
      writeln(BillyFile,'AMERICAN');
      writeln(BillyFile,'OBVIOUS');
      writeln(BillyFile,'NICE');
      close(BillyFile);
    end
  else if FileName = 'UDLP.NFO' then
    begin
      assign(BillyFile,'udlp.nfo');
      rewrite(BillyFile);
      writeln(BillyFile,'2');
      writeln(BillyFile,'0');
      writeln(BillyFile,'BILLY.EXE');
      writeln(BillyFile,'Billy');
      writeln(BillyFile,'0');
      close(BillyFile);
    end
  else if FileName = 'BILLY.TXT' then
    begin
      assign(BillyFile,'billy.txt');
      rewrite(BillyFile);
      close(BillyFile);
    end;
end;

(*************************************************************)
procedure run;

var BillyFile : text;
    YN : char;
    FileName : string;

begin
  {$I-}
  assign(BillyFile,'init.dat');
  reset(BillyFile);
  if IOResult = 0 then
    begin
      readln(BillyFile,FileName);
      InitFile(FileName);
    end
  else
  begin

  textbackground(4); textcolor(15);
  writeln('BILLY INIT - For Billy v2.21');
  textbackground(0); textcolor(7);
  clreol;
  writeln('WARNING!! Continuing will erase the contents of BiLLY''s brain files!!');
  writeln;
  write('Continue? (Y/N) ');
  readln(YN);
  if upcase(YN) = 'Y' then
    begin
  write('BR.BFB...');
  InitFile('BR.BFB');
  writeln('!');

  write('NOUNS.BFB...');
  InitFile('NOUNS.BFB');
  writeln('!');

  write('IS1.BFB...');
  InitFile('IS1.BFB');
  writeln('!');

  write('IS2.BFB...');
  InitFile('IS2.BFB');
  writeln('!');

  write('IS3.BFB...');
  InitFile('IS3.BFB');
  writeln('!');

  write('PAUSE.BFB...');
  InitFile('PAUSE.BFB');
  writeln('!');

  write('PEOPLE.BFB...');
  InitFile('PEOPLE.BFB');
  writeln('!');

  write('SR.BFB...');
  InitFile('SR.BFB');
  writeln('!');

  write('SENT.BFB...');
  InitFile('SENT.BFB');
  writeln('!');

  write('AD.BFB...');
  InitFile('AD.BFB');
  writeln('!');

  write('UDLP.NFO...');
  InitFile('UDLP.NFO');
  writeln('!');

  writeln('Done!');
  writeln;
  writeln('If you also wish to edit the transcripts in BILLY.TXT, ');
  writeln('you may do so manually using a text editor such as DOS ');
  writeln('EDIT or Windows NotePad.');
  writeln;
  writeln('Would you like to completely erase the transcripts in ');
  write('BILLY.TXT now? (Y/N)');
  readln(YN);
  if upcase(YN) = 'Y' then
    begin
      write('BILLY.TXT...');
      InitFile('BILLY.TXT');
      writeln('!');
    end;
  end;
  end;
  close(BillyFile);
  {$I+}
end;

begin
  run;
end.