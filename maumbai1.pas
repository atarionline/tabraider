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
  EMPTY=0;
  WALL = 1;
  LANDING = 2;
  BOX = 3;
  STARTSOCOBAN = 4;
  HOLYCOW = 6;
  OTHERSOCOBAN = 7;
  mxWidth = 50;
  mxHeight = 50; { max width and height of field }
  maxBlocks = 50; { max count of blocks }
  {1-wall,2-pleceforbox,3-box,4-startsocoban,6-holycow,7-othersocoban}
  cmap: array [0..7, 0..16] of byte = (
    (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1),
    (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1),
    (1, 0, 0, 0, 2, 0, 3, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1),
    (1, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 7, 3, 0, 1),
    (1, 0, 0, 0, 2, 0, 3, 0, 0, 4, 0, 0, 0, 3, 7, 0, 1),
    (1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 7, 0, 0, 4, 0, 1),
    (1, 0, 0, 0, 0, 6, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1),
    (1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1)
    );

var
  map: array [0..mxWidth, 0..mxHeight] of byte; { map }

  i, j, tmpint: integer; { counters}
  lastblockx, lastblocky: integer;
  lastplayerindex: integer;
  v: byte; { sokoban player direction }
  m, n: integer; { windth and height of player map }
  iswin:boolean;  {check if all landing places has box in it}
  countland: integer; { number of landing places for boxes}
  countplayers: integer; { number of inactive socobans in game}
  c: char; { read keynoard}
  player: sPoint; { kplayer coord}
  nx, ny: integer;{new player x,y}
  linehasemptyspace:boolean;
  linemoved:boolean;
  elementtopushcount,pushingsokobanscount:byte;

  landingpointx: array [0..maxBlocks] of byte; { array with movable items }
  landingpointy: array [0..maxBlocks] of byte; { array with movable items }

  playersx: array [0..maxBlocks] of byte; { array with movable items }
  playersy: array [0..maxBlocks] of byte; { array with movable items }
  templine: array [0..20] of byte;


procedure customgotoxy(x,y:byte);
begin
    gotoxy(x+2,y+1);
end;

procedure  drawdebug;
begin
n := 7;
m := 16;

 for i := 0 to n do
   for j := 0 to m do
   begin
        customgotoxy(j+30,i); write(map[j, i]);
    end;
    customgotoxy(player.x+30,player.y); write('%');

end;


procedure cleanOldPlayer;
var
 tmpx,tmpy: integer;
 islanding:boolean;
begin
   islanding:=false;
   tmpx:=player.x;
   tmpy:=player.y;
   if v=1 then  tmpy := player.y + 1;
   if v=2 then  tmpy := player.y - 1;
   if v=3 then  tmpx := player.x + 1;
   if v=4 then  tmpx := player.x - 1;

        for i := 0 to countland do
        begin
           if  ((landingpointx[i]=tmpx) and (landingpointy[i]=tmpy)) then islanding:=true;
        end;
        if (islanding=true) then
            begin
                customgotoxy(tmpx, tmpy);
                write('@');
            end
        else
            begin
                customgotoxy(tmpx, tmpy);
                write(' '); {write player}
            end;
end;

procedure reDrawPlayer;
begin
   TextColor(14);
   cleanOldPlayer;
   customgotoxy(player.x, player.y);
   write('%'); {write player}
end;

procedure drawSingleDynamicBlockElement(x, y, blocktype: integer);
begin
  if blocktype =STARTSOCOBAN then
    reDrawPlayer;

  if blocktype = BOX then
  begin {write blocks}
    customgotoxy(x, y);
    TextColor(5);
    write('#');
  end;
  if blocktype = HOLYCOW then
  begin {write holycow}
    customgotoxy(x, y);
    TextColor(5);
    write('c');
  end;
  if blocktype = OTHERSOCOBAN then
  begin {write blocks}
    customgotoxy(x, y);
    TextColor(5);
    write('s');
  end;
end;


procedure drawLandingElements;
begin
    for i := 0 to countland do
    begin
         customgotoxy(landingpointx[i],landingpointy[i]);
         write('@');
    end;
end;

procedure drawAllStaticElements;
begin

  for i := 0 to n do
  begin
    for j := 0 to m do
    begin {write static elements in screen}
      customgotoxy(j, i);
      TextColor(14);
      if (map[j, i] = WALL) then{wall}
        write('0')
      else if (map[j, i] = LANDING) then{proper place}
      begin
        TextColor(2);
        write('@');
      end
      else
        write(' ');
      drawSingleDynamicBlockElement(j, i, map[j, i]);
    end;
    writeln;
  end;
end;

procedure initLevel;
begin
  iswin := false;
  countland := 0;
  countplayers:= 0;
  {1-wall,2-pleceforbox,3-box,4-startsocoban,6-holycow,7-othersocoban}

  n := 7;
  m := 16;
  for i := 0 to n do
    for j := 0 to m do
    begin
      if ((cmap[i][j]<>STARTSOCOBAN) AND (cmap[i][j]<>LANDING)) then
        map[j][i] := cmap[i][j];
      v := cmap[i][j];
      {gotoxy(j+2,i+2); write(v); }
      if v = LANDING then
      begin
        landingpointx[countland] := j;
        landingpointy[countland] := i;
        Inc(countland);
      end;

      if v = OTHERSOCOBAN then
      begin
        playersx[countplayers] := j;
        playersy[countplayers] := i;
        Inc(countplayers);
      end;

      if v = STARTSOCOBAN then
      begin
        player.x := j;
        player.y := i;
       end;{hero}
    end;
end;


procedure getNextPlayerIndex;
var
 startindex,olpx,oldpy: integer;
begin
   startindex:=0;
   if (lastplayerindex>0) then startindex:=lastplayerindex;

   for i := startindex+1 to countplayers do
   begin
           lastplayerindex:=i;
           Break;
   end;
   if (lastplayerindex=startindex) then
    begin
         for i := 1 to lastplayerindex-1 do
         begin
                 lastplayerindex:=i;
                 Break;
         end;
    end;

       olpx:=player.x;
       oldpy:=player.y;

       player.x := playersx[lastplayerindex];
       player.y := playersy[lastplayerindex];
       customgotoxy(player.x, player.y);
       write('%'); {write player}
       playersx[lastplayerindex] := olpx;
       playersy[lastplayerindex] := oldpy;
       drawSingleDynamicBlockElement(olpx,oldpy,OTHERSOCOBAN);
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



{get index of movable block, or 0 if no block on coordinates}
function get_block(xg, yg: integer): integer;
var
 i: integer;
 tmp: integer;
begin
 tmp := 0;
   if (map[xg][yg] <> WALL) and (map[xg][yg] <> EMPTY) and (map[xg][yg] <> LANDING)  then
   begin
     tmp := map[xg][yg];
   end;
 get_block := tmp;
end;


procedure checkwin();
    var blockcorrectplaces: integer;
    begin
    blockcorrectplaces:=0;
    for i := 0 to countland do
    begin
        if map[landingpointx[i],landingpointy[i]]=BOX then inc(blockcorrectplaces);

    end;

    if (blockcorrectplaces=countland) then
    begin
        iswin:=true;
    end else
        iswin:=false;
end;




procedure DoModifyGameLine(x,y:integer);
    var tmpcnt:byte;
    begin
        linemoved := true;
        if v=2 then {down}
        begin
                       for i := y to n do
                          begin
                               if (templine[tmpcnt]<>0) then begin
                                map[x,i+1] := templine[tmpcnt];
                                drawSingleDynamicBlockElement(x,i+1, map[x, i+1]);
                              end;
                            inc(tmpcnt)
                          end;
                          map[x,y] := EMPTY;
                          player.x := x;
                          player.y := player.y+1;
                          reDrawPlayer;
        end;

        if v=1 then {up}
        begin
                       for i := y downto 1 do
                          begin
                           if (templine[tmpcnt]<>0) then begin
                            map[x,i-1] := templine[tmpcnt];
                            drawSingleDynamicBlockElement(x,i-1, map[x, i-1]);
                           end;
                           inc(tmpcnt)
                          end;
                          map[x,y] := EMPTY;
                          player.x := x;
                          player.y := player.y-1;
                          reDrawPlayer;
        end;

        if v=3 then {right}
        begin
                       for i := x downto 1 do
                       begin
                           if (templine[tmpcnt]<>0) then begin
                            map[i-1,y] := templine[tmpcnt];
                            drawSingleDynamicBlockElement(i-1,y, map[i-1,y]);
                           end;
                           inc(tmpcnt)
                          end;
                          map[x,y] := EMPTY;
                          player.x := player.x-1;
                          player.y := y;
                          reDrawPlayer;
        end;


        if v=4 then {right}
        begin
                       for i := x  to m do
                       begin
                           if (templine[tmpcnt]<>0) then begin
                                map[i+1,y] := templine[tmpcnt];
                                drawSingleDynamicBlockElement(i+1,y, map[i+1,y]);
                           end;
                           inc(tmpcnt)
                          end;
                          map[x,y] := EMPTY;
                          player.x := player.x+1;
                          player.y := y;
                          reDrawPlayer;

        end;

end;





procedure checkSingleGameLineElement(x,y,cnt:integer);
begin
      if map[x, y]=OTHERSOCOBAN then inc(pushingsokobanscount);
      if ((map[x, y]<>OTHERSOCOBAN) AND (map[x, y]<>EMPTY)) then
      begin
        inc(elementtopushcount);
      end;
      templine[cnt] := map[x, y];
end;


procedure tryModifyGameLine(x,y:integer);
    var tmpcnt:byte;
    begin
      tmpcnt := 0;
      linehasemptyspace:=false;
      elementtopushcount:=0;
      pushingsokobanscount:=1;
        if v=2 then {down}
        begin
                    {gotoxy(50,2); write('v'); write(v);}

                       for i := y to n do
                          begin
                            {gotoxy(x+50,i);  write(map[x, i]);}
                            checkSingleGameLineElement(x,i,tmpcnt);
                            inc(tmpcnt);
                            if map[x, i]=EMPTY then begin linehasemptyspace:=true; break; end;
                          end;
        end;

        if v=1 then {up}
        begin
                    {gotoxy(50,2); write('v'); write(v);}

                       for i := y downto 1 do
                          begin
                            {gotoxy(50+x,i); write(' x');write(x);write(' y');write(i);write('--'); write(map[x, i]);}
                            checkSingleGameLineElement(x,i,tmpcnt);
                            inc(tmpcnt);
                            if map[x, i]=EMPTY then begin linehasemptyspace:=true; break; end;

                          end;

                    end;

                if v=3 then {right}
                    begin
                       for i := x downto 1 do
                          begin
                            {gotoxy(50+x,i); write(' x');write(x);write(' y');write(i);write('--'); write(map[i, y]);}
                            checkSingleGameLineElement(i,y,tmpcnt);
                            inc(tmpcnt);
                            if map[i, y]=EMPTY then begin linehasemptyspace:=true; break; end;
                          end;

                    end;


                if v=4 then {right}
                    begin
                       for i := x  to m do
                          begin
                            {gotoxy(50,2); write(' x');write(i);write(' y');write(y);write('--'); write(map[y, i]);}
                            {gotoxy(50+x,i); write(' x');write(x);write(' y');write(i);write('--'); write(map[i, y]);}
                            checkSingleGameLineElement(i,y,tmpcnt);
                            inc(tmpcnt);
                            if map[i, y]=EMPTY then begin linehasemptyspace:=true; break; end;
                          end;

                    end;

                          gotoxy(45,3); write('pushcount'); write(elementtopushcount);
                          write('psokobanscount'); write(pushingsokobanscount);writeln;

                          if( (linehasemptyspace=true) and (pushingsokobanscount>=elementtopushcount) and (pushingsokobanscount>1) ) then
                          begin
                            DoModifyGameLine(x,y);
                          end;

end;


function TryMoveBlock(x,y: integer): boolean;
{var
 nx, ny: integer;}
begin
 linemoved:=false;
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


     if (map[x,y] = OTHERSOCOBAN) and (map[ny,nx] <> WALL) then
     begin
          gotoxy(45,6); write('trymodifygameline            ');
          tryModifyGameLine(x,y);
     end else begin
        gotoxy(45,6); write('llllllllllllllll>>>');write(map[nx,ny]);write('<<');write(map[x,y]);
     end;
     gotoxy(45,7); write('oooooooooooo>>>');write(map[x,y]);write('<<');write(map[nx,ny]);write('<x<');write(x);write('<nx<');write(nx);write('   ');
     {gotoxy(45,8); write(map[x,y]);write('ll');write(map[ny,nx]);}


 {if there is no further wall, or the second block, then move the block}
 if((map[nx,ny] = 0) and (linemoved=false) ) then
 begin
  drawSingleDynamicBlockElement(x,y,map[x,y]);
  if (map[x,y]<>STARTSOCOBAN) then
  begin
     i:=map[nx,ny];
     map[nx,ny]:= map[x,y];
     map[x,y]:=i;
     drawSingleDynamicBlockElement(nx,ny,map[nx,ny]);
  end;

  checkwin;
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
   if map[x, y] <> 1 then
   begin
     bi := get_block(x, y); { find out if there is a block }
     if bi > 0 then {if there is}
     begin
         if TryMoveBlock(x,y) then begin  player.x := x;  player.y := y; reDrawPlayer; end;
         {then first we try to move the block, and if we succeed, we move it after the sokoban}
     end else
     begin
         player.x := x;
         player.y := y;
         reDrawPlayer;
     end;
   end;
end;






{main}
begin
  clrscr;
  textcolor(15);

  initLevel;
  drawAllStaticElements;
  drawLandingElements;
  reDrawPlayer;
  {main game loop}
  while (iswin = false) do
  begin
    getControlKey;
    if(c<>'c') then MoveSokoban(nx, ny);
    {drawdebug;}
    customgotoxy(80, 25);
    drawdebug;
  end;
  {gotoxy(j + 2, i + 2);
  write(map[j][i]);}

end.
