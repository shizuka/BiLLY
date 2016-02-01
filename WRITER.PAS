{
   WRITER for Billy 2.21
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


program LinkWrite;

uses crt;

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

procedure run;

var LoadFile : text;
    WriteString : string;
    Color : integer;

begin
  assign(LoadFile,'chat.msg');
  reset(LoadFile);
  readln(LoadFile,WriteString);
  readln(LOadFile,Color);
  textcolor(Color);
  writer(WriteString);
end;

begin
  run
end.