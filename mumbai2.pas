program sokoban;

uses
  crt;

type
  sPoint = record
    x: shortint;
    y: shortint;
    elementtype: shortint;
  end; { structure type for map point }

const
  MULTIPUSH = false;
  EMPTY = 0;
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
  cmap: array [0..7, 0..16] of shortint = (
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
  map: array [0..mxWidth, 0..mxHeight] of shortint; { map }

  i, j, tmpint: shortint; { counters}
  lastblockx, lastblocky: shortint;
  lastplayerindex: shortint;
  v: shortint; { sokoban player direction }
  m, n: shortint; { windth and height of player map }
  iswin: boolean;  {check if all landing places has box in it}
  countland: shortint; { number of landing places for boxes}
  countplayers: shortint; { number of inactive socobans in game}
  c: char; { read keynoard}
  player: sPoint; { kplayer coord}
  nx, ny: shortint;{new player x,y}
  linehasemptyspace: boolean;
  linemoved: boolean;
  elementtopushcount, pushingsokobanscount: shortint;

  landingpointx: array [0..maxBlocks] of shortint; { array with movable items }
  landingpointy: array [0..maxBlocks] of shortint; { array with movable items }

  playersx: array [0..maxBlocks] of shortint; { array with movable items }
  playersy: array [0..maxBlocks] of shortint; { array with movable items }
  templine: array [0..20] of shortint;

procedure customgotoxy(x, y: shortint);
begin
  gotoxy(x + 2, y + 4);
end;

procedure drawdebug;
begin
  n := 7;
  m := 16;

  for i := 0 to n do
    for j := 0 to m do
    begin
      customgotoxy(j + 5, i + 9);
      write(map[j, i]);
      {customgotoxy(j+30,i); write(map[j, i]);}
    end;
  {customgotoxy(player.x+30,player.y); write('%');}
  customgotoxy(player.x + 5, player.y + 9);
  write('%');

end;

procedure cleanOldPlayer;
var
  tmpx, tmpy: shortint;
  islanding: boolean;
begin
  islanding := false;
  tmpx := player.x;
  tmpy := player.y;
  if v = 1 then
    tmpy := player.y + 1;
  if v = 2 then
    tmpy := player.y - 1;
  if v = 3 then
    tmpx := player.x + 1;
  if v = 4 then
    tmpx := player.x - 1;

  for i := 0 to countland do
    if ((landingpointx[i] = tmpx) and (landingpointy[i] = tmpy)) then
      islanding := true;
  if (islanding = true) then
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
  {TextColor(14);}
  cleanOldPlayer;
  customgotoxy(player.x, player.y);
  write('%'); {write player}
end;

procedure drawSingleDynamicBlockElement(x, y, blocktype: shortint);
begin
  if blocktype = STARTSOCOBAN then
    reDrawPlayer;

  if blocktype = BOX then
  begin {write blocks}
    customgotoxy(x, y);
    {TextColor(5);}
    write('#');
  end;
  if blocktype = HOLYCOW then
  begin {write holycow}
    customgotoxy(x, y);
    {TextColor(5);}
    write('c');
  end;
  if blocktype = OTHERSOCOBAN then
  begin {write blocks}
    customgotoxy(x, y);
    {TextColor(5);}
    write('s');
  end;
end;

procedure drawLandingElements;
begin
  for i := 0 to countland do
  begin
    customgotoxy(landingpointx[i], landingpointy[i]);
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
      {TextColor(14);}
      if (map[j, i] = WALL) then{wall}
        write('0')
      else if (map[j, i] = LANDING) then{proper place}
        write('@'){TextColor(2);}
      else
        write(' ');
      drawSingleDynamicBlockElement(j, i, map[j, i]);
    end;
    writeln;
  end;
end;

procedure initArray;
begin
  for i := 0 to mxWidth do
    for j := 0 to mxWidth do
      map[i][j] := 0;
end;

procedure initLevel;
begin
  iswin := false;
  countland := 0;
  countplayers := 0;
  lastplayerindex := 0;
  {1-wall,2-pleceforbox,3-box,4-startsocoban,6-holycow,7-othersocoban}

  n := 7;
  m := 16;
  for i := 0 to n do
    for j := 0 to m do
    begin
      if ((cmap[i][j] <> STARTSOCOBAN) and (cmap[i][j] <> LANDING)) then
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
  olpx, oldpy: shortint;
begin
  if (lastplayerindex = countplayers - 1) then
    lastplayerindex := 0
  else
    Inc(lastplayerindex);

  olpx := player.x;
  oldpy := player.y;

  player.x := playersx[lastplayerindex];
  player.y := playersy[lastplayerindex];
  map[player.x, player.y] := EMPTY;
  customgotoxy(player.x, player.y);
  write('%'); {write player}
  playersx[lastplayerindex] := olpx;
  playersy[lastplayerindex] := oldpy;
  map[olpx, oldpy] := OTHERSOCOBAN;
  drawSingleDynamicBlockElement(olpx, oldpy, OTHERSOCOBAN);
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
    'c': getNextPlayerIndex;
    {#27: break;}
  end;
end;

{get index of movable block, or 0 if no block on coordinates}
function get_block(xg, yg: shortint): shortint;
begin
  customgotoxy(1, 19);write('xg');write(yg);write('yg');write(yg);write('map');write(map[xg][yg]);
  if (map[xg][yg]<>WALL) and (map[xg][yg]<>EMPTY) then
  BEGIN
    write('xgygok   ');
    get_block := map[xg][yg]
  END else BEGIN
    write('notxgygok');
    get_block := 0;
  END;


end;

procedure checkwin();
var
  blockcorrectplaces: shortint;
begin
  blockcorrectplaces := 0;
  for i := 0 to countland do
    if map[landingpointx[i], landingpointy[i]] = BOX then
      Inc(blockcorrectplaces);

  if (blockcorrectplaces = countland) then
    iswin := true
  else
    iswin := false;
end;

procedure DoModifyGameLine(x, y: shortint);
var
  tmpcnt: shortint;
begin
  tmpcnt := 0;
  linemoved := true;
  if v = 2 then {down}
  begin
    for i := y to n do
    begin
      if (templine[tmpcnt] <> 0) then
      begin
        map[x, i + 1] := templine[tmpcnt];
        drawSingleDynamicBlockElement(x, i + 1, map[x, i + 1]);
      end;
      Inc(tmpcnt);
    end;
    map[x, y] := EMPTY;
    player.x := x;
    player.y := player.y + 1;
    reDrawPlayer;
  end;

  if v = 1 then {up}
  begin
    for i := y downto 1 do
    begin
      if (templine[tmpcnt] <> 0) then
      begin
        map[x, i - 1] := templine[tmpcnt];
        drawSingleDynamicBlockElement(x, i - 1, map[x, i - 1]);
      end;
      Inc(tmpcnt);
    end;
    map[x, y] := EMPTY;
    player.x := x;
    player.y := player.y - 1;
    reDrawPlayer;
  end;

  if v = 3 then {right}
  begin
    for i := x downto 1 do
    begin
      if (templine[tmpcnt] <> 0) then
      begin
        map[i - 1, y] := templine[tmpcnt];
        drawSingleDynamicBlockElement(i - 1, y, map[i - 1, y]);
      end;
      Inc(tmpcnt);
    end;
    map[x, y] := EMPTY;
    player.x := player.x - 1;
    player.y := y;
    reDrawPlayer;
  end;

  if v = 4 then {right}
  begin
    for i := x to m do
    begin
      if (templine[tmpcnt] <> 0) then
      begin
        map[i + 1, y] := templine[tmpcnt];
        drawSingleDynamicBlockElement(i + 1, y, map[i + 1, y]);
      end;
      Inc(tmpcnt);
    end;
    map[x, y] := EMPTY;
    player.x := player.x + 1;
    player.y := y;
    reDrawPlayer;

  end;

end;

procedure checkSingleGameLineElement(x, y, cnt: shortint);
begin
  if map[x, y] = OTHERSOCOBAN then
    Inc(pushingsokobanscount);
  if ((map[x, y] <> OTHERSOCOBAN) and (map[x, y] <> EMPTY)) then
    Inc(elementtopushcount);
  templine[cnt] := map[x, y];
end;

procedure tryModifyGameLine(x, y: shortint);
var
  tmpcnt: shortint;
begin
  tmpcnt := 0;
  linehasemptyspace := false;
  elementtopushcount := 0;
  pushingsokobanscount := 1;
  if v = 2 then {down}
    for i := y to n do
    begin
      {gotoxy(x+50,i);  write(map[x, i]);}
      checkSingleGameLineElement(x, i, tmpcnt);
      Inc(tmpcnt);
      if map[x, i] = EMPTY then
      begin
        linehasemptyspace := true;
        break;
      end;
    end{gotoxy(50,2); write('v'); write(v);};

  if v = 1 then {up}
    for i := y downto 1 do
    begin
      {gotoxy(50+x,i); write(' x');write(x);write(' y');write(i);write('--'); write(map[x, i]);}
      checkSingleGameLineElement(x, i, tmpcnt);
      Inc(tmpcnt);
      if map[x, i] = EMPTY then
      begin
        linehasemptyspace := true;
        break;
      end;

    end{gotoxy(50,2); write('v'); write(v);};

  if v = 3 then {right}
    for i := x downto 1 do
    begin
      {gotoxy(50+x,i); write(' x');write(x);write(' y');write(i);write('--'); write(map[i, y]);}
      checkSingleGameLineElement(i, y, tmpcnt);
      Inc(tmpcnt);
      if map[i, y] = EMPTY then
      begin
        linehasemptyspace := true;
        break;
      end;
    end;

  if v = 4 then {right}
    for i := x to m do
    begin
      {gotoxy(50,2); write(' x');write(i);write(' y');write(y);write('--'); write(map[y, i]);}
      {gotoxy(50+x,i); write(' x');write(x);write(' y');write(i);write('--'); write(map[i, y]);}
      checkSingleGameLineElement(i, y, tmpcnt);
      Inc(tmpcnt);
      if map[i, y] = EMPTY then
      begin
        linehasemptyspace := true;
        break;
      end;
    end;

                          {gotoxy(45,3); write('pushcount'); write(elementtopushcount);
                          write('psokobanscount'); write(pushingsokobanscount);writeln;}

  if ((linehasemptyspace = true) and (pushingsokobanscount >= elementtopushcount) and
    (pushingsokobanscount > 1)) then
    DoModifyGameLine(x, y);

end;

function TryMoveBlock(x, y: shortint): boolean;
{var
 nx, ny: SHORTINT;}
begin
  linemoved := false;
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

  {drawdebug;}
  if (map[x, y] = OTHERSOCOBAN) and (map[ny, nx] <> WALL) then
  begin
    {gotoxy(45,6); write('trymodifygameline            ');}
    if MULTIPUSH then
      tryModifyGameLine(x, y);
  end
  else
    {gotoxy(45,6); write('llllllllllllllll>>>');write(map[nx,ny]);write('<<');write(map[x,y]);};
  {gotoxy(50,7); write('v');write(v);write('>map[x,y]>');write(map[x,y]);}
  {gotoxy(50,8); write('<map[nx,ny]<');write(map[nx,ny]);write('<x<');write(x);write('<nx<');write(nx);write('');}

  linemoved := false;
  {if there is no further wall, or the second block, then move the block}
  customgotoxy(3, 8);write('nx');write(nx);write('ny');write(ny);write('map[nx, ny]');write(map[nx,ny]);write('  ');
  if ((map[nx,ny] = EMPTY) and (linemoved = false)) then
  write('okpartmb');
  begin
    drawSingleDynamicBlockElement(x, y, map[x,y]);
    if (map[x, y] <> STARTSOCOBAN) then
    begin
      i := map[nx, ny];
      map[nx, ny] := map[x, y];
      map[x, y] := i;
      drawSingleDynamicBlockElement(nx, ny, map[nx, ny]);
    end;

    checkwin;
    TryMoveBlock := true;
    exit;
  end;
  TryMoveBlock := false;
end;

procedure MoveSokoban(x, y: shortint);
var
  bi: shortint; {block id}
begin
  if (x > 0) and (y > 0) and (x < m) and (y < n) then
    if map[x, y] <> WALL then
    begin
      customgotoxy(3, 17);write('x');write(x);write('y');write(y);write('mapxy');write(map[x, y]);write('  ');
      bi := get_block(x, y); { find out if there is a block }
      customgotoxy(20, 19);write('bi');write(bi);
      if bi > 0 then {if there is}
      begin
        if TryMoveBlock(x, y) then
        begin
          customgotoxy(3, 18);write('try move block succeed');
          player.x := x;
          player.y := y;
          reDrawPlayer;
        end else BEGIN
          customgotoxy(3, 18);write('try move block failed');
        END;

        {then first we try to move the block, and if we succeed, we move it after the sokoban}
      end
      else
      begin
        customgotoxy(3, 18);write('bi block failed          ');
        player.x := x;
        player.y := y;
        reDrawPlayer;
      end;
    end;
end;

{main}
begin
  clrscr;
  {textcolor(15);}
  initArray;
  initLevel;
  drawAllStaticElements;
  drawLandingElements;
  reDrawPlayer;
  {main game loop}
  while (iswin = false) do
  begin
    getControlKey;
    {gotoxy(45,8); write('uuuu>'); write(nx);write('>y>');write(ny);write('   ');}
    if (c <> 'c') then
      MoveSokoban(nx, ny);
    drawdebug;
    {customgotoxy(80, 25);}
    {drawdebug;}
  end;
  {gotoxy(j + 2, i + 2);
  write(map[j][i]);}

end. 
