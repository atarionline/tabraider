program sokoban;

uses
 crt;

type
 sPoint = record
   x: integer;
   y: integer;
   elementtype: integer;
 end; { structure type for map point }

const

 mxWidth = 100;
 mxHeight = 100; { max width and height of field }

 maxBlocks = 100; { max count of blocks }
{1-wall,2-pleceforbox,3-box,4-startsocoban,6-holycow,7-othersocoban}
 cmap: array [0..135] of byte = (
   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,
   1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
   1,0,0,0,2,0,3,0,0,0,0,0,6,0,0,0,1,
   1,0,0,0,2,0,3,0,0,0,0,0,0,0,0,0,1,
   1,0,0,0,2,0,3,0,0,4,0,0,0,0,7,0,1,
   1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,
   1,0,0,0,0,0,0,0,0,0,0,0,6,0,7,0,1,
   1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
   );

var
 map: array [0..mxWidth, 0..mxHeight] of byte; { map }

 i, j,tmpint: integer; { counters}
 lastblockx,lastblocky:integer;
 lastplayerindex: integer;
 v: byte; { sokoban player direction }
 m, n: integer; { windth and height of player map }
 freesq,  {the number of free "containers" for boxes}
 countsq: integer; { number of boxes }
 c: char; { read keynoard}
 player: sPoint; { kplayer coord}
 nx, ny: integer;{new player x,y}

 blockpointx: array [0..maxBlocks] of integer; { array with movable items }
 blockpointy: array [0..maxBlocks] of integer; { array with movable items }
 blockpointelementtype: array [0..maxBlocks] of integer; { array with movable items }


procedure drawSingleDynamicBlockElement(i: integer);
begin
               if blockpointelementtype[i]=3 then
               begin {write blocks}
                 gotoxy(blockpointx[i], blockpointy[i]);
                 TextColor(5);
                 write('#');
               end;
             if blockpointelementtype[i]=6 then
               begin {write blocks}
                 gotoxy(blockpointx[i], blockpointy[i]);
                 TextColor(5);
                 write('c');
               end;
             if blockpointelementtype[i]=7 then
               begin {write blocks}
                 gotoxy(blockpointx[i], blockpointy[i]);
                 TextColor(5);
                 write('s');
               end;
end;

{get index of movable block, or 0 if no block on coordinates}
function get_block(x, y: integer): integer;
var
 i: integer;
 v: integer;
begin
 v := 0;
 for i := 1 to countsq do
   if (blockpointx[i] = x) and (blockpointy[i] = y) then
   begin
     v := i;
     break;
   end;
 get_block := v;
end;


function TryMoveBlock(id: integer): boolean;
var
 nx, ny, x, y: integer;
begin
 x := blockpointx[id];
 y := blockpointy[id];

 case v of
   1:
   begin
     nx := x;
     ny := y - 1;
   end; {up}
   2:
   begin
     nx := x;
     ny := y + 1;
   end; {down}
   3:
   begin
     nx := x - 1;
     ny := y;
   end; {left}
   4:
   begin
     nx := x + 1;
     ny := y;
   end; {right}
 end;

 if (get_block(nx, ny) = 0) and (map[ny, nx] <> 1) then
   {if there is no further wall, or the second block, then move the block}
 begin

   blockpointx[id] := nx;
   blockpointy[id] := ny;
   drawSingleDynamicBlockElement(id);
   if (map[ny, nx] = 2) and (map[y, x] = 0) and (blockpointelementtype[id]=3) then
     {if the block is moved from an empty cell, then we decrease the counter of free containers}
        Dec(freesq)
   else if (map[ny, nx] = 0) and (map[y, x] = 2)  and (blockpointelementtype[id]=3) then
     {if we move box out of a target, increase the counter of free containers}
     Inc(freesq);
     {if next element is sokoban then check whole line}
    if (map[y, x] = 7) then
        begin
         if v=2 then {down}
            begin
               for i := y to n do
                  begin
                    {write(map[i, x]);}
                  end;
                readln;
            end;
         end;

        if v=1 then {up}
            begin
            write('v');write(v);
            readln;
               for i := y downto 1 do
                  begin
                    write(' x');write(x);write(' y');write(i);write('--'); write(map[i, x]);
                  end;
                readln;
            end;

        if v=3 then {right}
            begin
            write('v');write(v);
            readln;
               for i := x downto 1 do
                  begin
                    write(' x');write(i);write(' y');write(y);write('--'); write(map[y, i]);
                  end;
                readln;
            end;


        if v=4 then {right}
            begin
            write('v');write(v);
            readln;
               for i := x  to m do
                  begin
                    write(' x');write(i);write(' y');write(y);write('--'); write(map[y, i]);
                  end;
                readln;
            end;

   TryMoveBlock := true;
   exit;
 end;
 TryMoveBlock := false;

end;

procedure cleanOldPlayer;
var
 tmpx,tmpy: integer;
begin
   tmpx:=player.x;
   tmpy:=player.y;
   if v=1 then  tmpy := player.y + 1;
   if v=2 then  tmpy := player.y - 1;
   if v=3 then  tmpx := player.x + 1;
   if v=4 then  tmpx := player.x - 1;

        if map[tmpy, tmpx] = 2 then
             begin
                gotoxy(tmpx, tmpy);
                write('@');
            end
        else
            begin
                gotoxy(tmpx, tmpy);
                write(' '); {write player}
            end;

end;

procedure reDrawPlayer;
begin
   TextColor(14);
   cleanOldPlayer;
   gotoxy(player.x, player.y);
   write('%'); {write player}
end;

procedure MoveSokoban(x, y: integer);
var
 bi: integer; {block id}
begin


 if (x > 0) and (y > 0) and (x < m) and (y < n) then
   if map[y, x] <> 1 then
   begin {}
     bi := get_block(x, y); { find out if there is a block }
     if bi > 0 then {if there is}
     begin
         if TryMoveBlock(bi) then begin  player.x := x;  player.y := y; reDrawPlayer; end;
         {then first we try to move the block, and if we succeed, we move it after the sokoban}
     end else
     begin


         player.x := x;
         player.y := y;
         reDrawPlayer;
     end;

   end;

end;



procedure getNextPlayerIndex;
var
 startindex,olpx,oldpy: integer;
begin
   startindex:=0;
   if (lastplayerindex>0) then startindex:=lastplayerindex;

   for i := startindex+1 to countsq do
   begin
       if blockpointelementtype[i]=7 then
       begin
           lastplayerindex:=i;
           Break;
       end;
   end;
   if (lastplayerindex=startindex) then
    begin
         for i := 1 to lastplayerindex-1 do
         begin
             if blockpointelementtype[i]=7 then
             begin
                 lastplayerindex:=i;
                 Break;
             end;
         end;
    end;

       olpx:=player.x;
       oldpy:=player.y;

       player.x := blockpointx[lastplayerindex];
       player.y := blockpointy[lastplayerindex];
       gotoxy(player.x, player.y);
       write('%'); {write player}
       blockpointx[lastplayerindex] := olpx;
       blockpointy[lastplayerindex] := oldpy;
       drawSingleDynamicBlockElement(lastplayerindex);
end;


procedure getControlKey;
  begin
  c := ReadKey;
   case c of
     'w':
     begin
       nx := player.x;
       ny := player.y - 1;
       v := 1;
     end;
     's':
     begin
       nx := player.x;
       ny := player.y + 1;
       v := 2;
     end;
     'a':
     begin
       nx := player.x - 1;
       ny := player.y;
       v := 3;
     end;
     'd':
     begin
       nx := player.x + 1;
       ny := player.y;
       v := 4;
     end;
     'c':
     begin
       getNextPlayerIndex;
     end;
     {#27: break;}
   end;
end;


procedure drawAllStaticElements;
 begin
   clrscr;
   for i := 1 to n do
   begin
     for j := 1 to m do
     begin {write static elements in screen}
       gotoxy(j, i);
       TextColor(14);
       if (map[i, j] = 1) then{wall}
         write('0')
       else if (map[i, j] = 2) then{proper place}
       begin
         TextColor(2);
         write('@');
       end

       else
         write(' ');
     end;
     writeln;
   end;
end;

procedure drawAllDynamicBlockElements;
 begin
       for i := 1 to countsq do
   begin
        drawSingleDynamicBlockElement(i);
   end;
   reDrawPlayer;
end;



{main}
begin

 freesq := 1;
 countsq := 1;
 {1-wall,2-pleceforbox,3-box,4-startsocoban,6-holycow,7-othersocoban}

 n := 8;
 m := 17;
 tmpint:=0;
 for i := 1 to n do
   for j := 1 to m do
   begin
     {Val(cmap[i][j], v);}

     v:=cmap[tmpint];
     inc(tmpint);
     case v of
       1: map[i, j] := 1; {wall}
       2: map[i, j] := 2; {proper place}
       3,6,7:
       begin
         blockpointx[countsq] := j;
         blockpointy[countsq] := i;
         blockpointelementtype[countsq]:= v;
         if v=3 then Inc(freesq);
         Inc(countsq);
         map[i, j] := v;
       end; {block}
       4:
       begin
         player.x := j;
         player.y := i;
       end; {hero}

       else map[i, j] := 0; {empty}
     end;
   end;

   drawAllStaticElements;
   drawAllDynamicBlockElements;


 while (freesq > 1) do
 begin




   gotoxy(80, 25);
   getControlKey;
   if(c<>'c') then MoveSokoban(nx, ny);
 end;



 clrscr;
 textcolor(15);

 if (freesq = 1) then
   writeln('You Win!')
 else
   writeln('You Lose!');
 writeln('Press Enter for exit!');
 readln;
end.
