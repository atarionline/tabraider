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

var
 cmap: array [1..mxHeight] of string;

 map: array [1..mxWidth, 1..mxHeight] of byte; { map }

 i, j: integer; { counters}
 currentplayerindex,lastplayerindex: integer;
 v: byte; { sokoban player direction }
 m, n: integer; { windth and height of player map }
 freesq,  {the number of free "containers" for boxes}
 countsq: integer; { number of boxes }
 c: char; { read keynoard}
 player: sPoint; { kplayer coord}
 nx, ny: integer;{new player x,y}
 blockpoint: array [1..maxBlocks] of sPoint; { array with movable items }
 
 
 


{get index of movable block, or 0 if no block on coordinates}
function get_block(x, y: integer): integer;
var
 i: integer;
 v: integer;
begin
 v := 0;
 for i := 1 to countsq do  
   if (blockpoint[i].x = x) and (blockpoint[i].y = y) then
   begin
     v := i;
     break;  
   end;
 get_block := v;
end;

{пытаеться переместить блок, ели его толкает сокобан, если удалось возвращает значение Истина, иначе Ложь}
function TryMoveBlock(id: integer): boolean;
var
 nx, ny, x, y: integer;
begin
 x := blockpoint[id].x;
 y := blockpoint[id].y; {запоминаем текущие координаты блока}

 

 case v of
   {определяем направление движения сокобана, чтобы в этом же направлении сдвинуть блок}
   1:
   begin
     nx := x;
     ny := y - 1;
   end; {вверх}
   2:
   begin
     nx := x;
     ny := y + 1;
   end; {вниз}
   3:
   begin
     nx := x - 1;
     ny := y;
   end; {влево}
   4:
   begin
     nx := x + 1;
     ny := y;
   end; {вправо}
 end;

 if (get_block(nx, ny) = 0) and (map[ny, nx] <> 1) then
   {if there is no further wall, or the second block, then move the block}
 begin

   blockpoint[id].x := nx;
   blockpoint[id].y := ny;
   if (map[ny, nx] = 3) and (map[y, x] = 0) and (blockpoint[id].elementtype=3) then
     {if the block is moved from an empty cell, then we decrease the counter of free containers}
     Dec(freesq)
   else if (map[ny, nx] = 0) and (map[y, x] = 3)  and (blockpoint[id].elementtype=3) then
     {if we move box out of a target, increase the counter of free containers}
     Inc(freesq);

   TryMoveBlock := true;
   exit;
 end;
 TryMoveBlock := false;

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
         if TryMoveBlock(bi) then begin  player.x := x;  player.y := y; end;
         {then first we try to move the block, and if we succeed, we move it after the sokoban}
     end else begin  player.x := x; player.y := y; end;
     
       
       
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
       if blockpoint[i].elementtype=7 then
       begin
           lastplayerindex:=i;
           Break;
       end;    
   end;
   if (lastplayerindex=startindex) then 
       for i := 1 to lastplayerindex-1 do
       begin
           if blockpoint[i].elementtype=7 then 
           begin
               lastplayerindex:=i;
               Break;
           end;    
       end;
       
       olpx:=player.x;
       oldpy:=player.y;
       
       player.x := blockpoint[lastplayerindex].x;
       player.y := blockpoint[lastplayerindex].y;
       
       blockpoint[lastplayerindex].x := olpx;
       blockpoint[lastplayerindex].y := oldpy;
end; 

begin
 freesq := 1;
 countsq := 0;
 {1-wall,2-pleceforbox,3-box,4-startsocoban,6-holycow,7-othersocoban}
 cmap[1] := '11111111111111111';
 cmap[2] := '10002001032010001';
 cmap[3] := '10070000304000711';
 cmap[4] := '10002060070000011';
 cmap[5] := '10002000000010071';
 cmap[5] := '10002000000010071';
 cmap[6] := '10000000000010001';
 cmap[7] := '10000000000000001';
 cmap[8] := '11111111111111111';
 n := 8;
 m := 17;
 for i := 1 to n do
   for j := 1 to m do
   begin
     Val(cmap[i][j], v);
     case v of
       1: map[i, j] := 1; {wall}
       2: map[i, j] := 3; {proper place}
       3,6,7:
       begin
         blockpoint[freesq].x := j;
         blockpoint[freesq].y := i;
         blockpoint[freesq].elementtype:= v;
         Inc(freesq);
         Inc(countsq);
       end; {block}
       4:
       begin
         player.x := j;
         player.y := i;
       end; {hero}
       
       
       

       else map[i, j] := 0; {empty}
     end;
   end;

 
  
 while (freesq > 1) do
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
       else if (map[i, j] = 3) then{proper place}
       begin
         TextColor(2);
         write('@');
       end

       else
         write(' ');
     end;

     writeln;
   end;

   for i := 1 to countsq do
   begin
           if blockpoint[i].elementtype=3 then
               begin {write blocks}
                 gotoxy(blockpoint[i].x, blockpoint[i].y);
                 TextColor(5);
                 write('#');
               end;
             if blockpoint[i].elementtype=6 then
               begin {write blocks}
                 gotoxy(blockpoint[i].x, blockpoint[i].y);
                 TextColor(5);
                 write('c');
               end;
             if blockpoint[i].elementtype=7 then
               begin {write blocks}
                 gotoxy(blockpoint[i].x, blockpoint[i].y);
                 TextColor(5);
                 write('s');
               end;
           
   end;        

   TextColor(14);
   gotoxy(player.x, player.y);
   write('%'); {write player}

   gotoxy(80, 25);
   
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

     #27: break; {выход }
   end;

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
