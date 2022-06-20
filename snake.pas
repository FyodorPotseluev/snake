program snake;
uses crt;
const
    snk = 'o';
    fly = '*';
    apl = '@';
    FlyReward = 10;
    AplReward = 50;
    AplShowTime = 60;                           {N of loop iterations apl shwn} 
    InitialDelayTime = 500;                     {Delay of snake moves}
    SpeedUpPeriod = 10;                         {Every x flies game speeds up}
    SpeedUP = 50;                               {How faster snake moves}
    MaxSpeed = 50;
    GameOverMessage = 'The snake has died :(((((';
    ScoreMessage = 'Your score is ';
type
    cell = record
        x, y: byte;
    end;
    location = array [1..255] of cell;
var
    lngth : Integer;

procedure
    SetInitialLocationArray(var c: location);
var
    i: byte;
begin
    for i := 1 to 255 do
        begin
        c[i].x := 0;
        c[i].y := 0;
        end
end;

procedure
    SetInitialCoordinates(var c: location);
var
    i: byte;
begin
    c[1].x := ScreenWidth div 2;            
    c[1].y := ScreenHeight div 2;
    for i := 2 to lngth do
        begin
        c[i].x := c[i-1].x + 1;
        c[i].y := c[i-1].y
        end
end;

procedure
    WriteInitialSnake(var c: location);
var
    i: byte;
begin
    for i := 1 to lngth do
        begin
        GotoXY(c[i].x, c[i].y);
        TextColoR(LightGreen);
        write(snk)
        end
end;

procedure GetKey(var code: shortint);
var
    c: char;
begin
    c := ReadKey;
    if c = #0 then
        begin
        c := ReadKey;
        code := -ord(c)
        end
    else
        code := ord(c)
end;

procedure 
    ChangeDirection(var dx, dy: shortint; a, b: shortint);
begin
    if (dx <> 0) and (a <> 0) then
        exit;
    if (dy <> 0) and (b <> 0) then
        exit;
    dx := a;
    dy := b
end;

function
    SnakeOverlap(var c: location; x, y: byte): boolean;
var
    i: byte;
begin
    for i := 1 to lngth do
        begin
        if (x = c[i].x) and (y = c[i].y) then
            SnakeOverlap := true
        else
            SnakeOverlap := false
        end
end;

function
    FlyOverlap(FlyX, FlyY, x, y: byte): boolean;
begin
    if (x = FlyX) and (y = FlyY) then
        FlyOverlap := true
    else
        FlyOverlap := false
end;

procedure
    ShowingFly(var c: location; var FlyExist: boolean; var FlyX, FlyY: byte);
begin
    if not FlyExist then
        begin
        while true do                           {Check if coordinates occupied}
            begin
            FlyX := (random(ScreenWidth)) + 1;
            FlyY := (random(ScreenHeight)) + 1;
            if SnakeOverlap(c, FlyX, FlyY) then
            else
                break;
            if (((FlyX = ScreenWidth) or (FlyX = ScreenWidth - 1)) and (FlyY = 1)) or ((FlyX = ScreenWidth) and (FlyY = ScreenHeight)) then
            else                                {The last screen pixel and}
                break                           {score panel overlap protection}
            end;
        GotoXY(FlyX, FlyY);
        TextColor(LightGray);
        write(fly);
        FlyExist := true
        end
end;

procedure
    AreWeShowingApple(var AplCount: integer; var AplX, AplY: byte; var AplExist: boolean; count: byte);
begin
    if AplExist then
        begin
        AplCount := AplCount + 1;
        if AplCount = AplShowTime then
            begin
            AplExist := false;
            GotoXY(AplX, AplY);
            write(' ');
            AplX := 0;
            AplY := 0
            end
        end;
    if count mod 10 = 8 then                    {Prevent endless apple appear}
        AplCount := 0                           {when count mod 10 = 9} 
end;

procedure
    ShowingApple(var c: location; var AplExist: boolean; var AplCount: integer; var AplX, AplY: byte; count, FlyX, FlyY: byte);
begin
    if (not AplExist) and (count mod 10 = 9) and (AplCount = 0) then
        begin                                   {Apl appears 1 fly bef. speedup}
        while true do                           {Check if coordinates occupied}
            begin
            AplX := (random(ScreenWidth)) + 1;
            AplY := (random(ScreenHeight)) + 1;
            if SnakeOverlap(c, AplX, AplY) or FlyOverlap(FlyX, FlyY, AplX, AplY) then
            else
                break;
            if (((AplX = ScreenWidth) or (AplX = ScreenWidth - 1)) and (AplY = 1)) or ((AplX = ScreenWidth) and (AplY = ScreenHeight)) then
            else                                {The last screen pixel and}
                break                           {score panel overlap protection}
            end;
        GotoXY(AplX, AplY);
        TextColor(LightRed);
        write(apl);
        AplExist := true;
        end;
    AreWeShowingApple(AplCount, AplX, AplY, AplExist, count)
end;

procedure
    ProcessingInput(var dx, dy: shortint);
var
    k: shortint;
begin
    if KeyPressed then
        begin
        GetKey(k);
        case k of
            -72:                                {down key}
                ChangeDirection(dx, dy, 0, -1);
            -80:                                {up key}
                ChangeDirection(dx, dy, 0, 1);
            -75:                                {left key}
                ChangeDirection(dx, dy, -1, 0);
            -77:                                {right key}
                ChangeDirection(dx, dy, 1, 0);
            27:                                 {finish (escape key)}
                begin
                clrscr;
                write(#27'[Om');
                halt
                end
            end
        end
end;

procedure 
    MovingSnake(var c: location; var growth: boolean; dx, dy: shortint);
var
    i: byte;
begin
    if growth then                              {Bigger snake option}
        begin
        lngth := lngth + 1;                     {Keep tale. Increase length}
        c[lngth].x := c[lngth-1].x + dx;        {+1 step (bigger snake)}
        c[lngth].y := c[lngth-1].y + dy;
        growth := false
        end
    else                                        {Same snake option}
        begin
        if (c[lngth].x = ScreenWidth) and (c[lngth].y = ScreenHeight) then
        else                                    {Avoiding the last screen pixel}
            GotoXY(c[1].x, c[1].y);             {Tale deleting}
        write(' ');
        for i := 1 to lngth - 1 do              {Body moving}
            begin
            c[i].x := c[i+1].x;
            c[i].y := c[i+1].y;
            end;
        c[lngth].x := c[lngth].x + dx;          {+1 step (same snake)}
        c[lngth].y := c[lngth].y + dy
        end
end;

procedure
    TransScreenMoveCheck(var c: location);
begin
    if c[lngth].x > ScreenWidth then           
        c[lngth].x := 1;
    if c[lngth].x < 1 then
        c[lngth].x := ScreenWidth;
    if c[lngth].y > ScreenHeight then
        c[lngth].y := 1;
    if c[lngth].y < 1 then
        c[lngth].y := ScreenHeight
end;

procedure
    FlyCheck(var c: location; var FlyExist, growth: boolean; var count: byte; FlyX, FlyY: byte; var score: word);
begin
    if (c[lngth].x = FlyX) and (c[lngth].y = FlyY) then
        begin
        FlyExist := false;
        growth := true;
        count := count + 1;
        score := score + FlyReward;
        end
end;

procedure
    AppleCheck(var c: location; var AplExist, growth: boolean; count: byte; var AplX, AplY: byte; var score: word);
begin
    if (c[lngth].x = AplX) and (c[lngth].y = AplY) then
        begin
        growth := true;
        AplExist := false;
        AplX := 0;
        AplY := 0;
        score := score + AplReward
        end
end;

procedure
    SelfCollisionCheck(var c: location; score: word; ScDigit: byte);
var
    i, x, y: byte;
begin
    for i := 1 to (lngth - 1) do
        begin
        if (c[i].x = c[lngth].x) and (c[i].y = c[lngth].y) then
            begin
            clrscr;
            x := (ScreenWidth - length(GameOverMessage)) div 2;
            y := ScreenHeight div 2;
            GotoXY(x, y);
            TextColor(Brown);
            write(GameOverMessage);
            x := (ScreenWidth - length(ScoreMessage) - ScDigit) div 2;
            GotoXY(x, y + 2);
            write(ScoreMessage, score);
            GotoXY(1, 1);
            Delay(2000);
            clrscr;
            write(#27'[Om');
            halt
            end
        end
end;

procedure
    WritingScorePanel(var score: word; var ScDigit: byte);
var
    i: word;
begin
    i := score;
    ScDigit := 0;
    while i > 0 do 
        begin
        i := i div 10;
        ScDigit := ScDigit + 1
        end;
    if score > 0 then
        begin
        GotoXY(ScreenWidth - ScDigit + 1, 1);
        TextColor(LightGray);
        write(score)
        end
    else
        begin
        GotoXY(ScreenWidth, 1);
        TextColor(LightGray);
        write(score)
        end
end;

procedure
    DelayCount(count: byte; var PrevCount: byte; var DelayTime: word);
begin
    if (PrevCount mod SpeedUpPeriod = SpeedUpPeriod - 1) and (Count mod SpeedUpPeriod = 0) then
        begin
        if DelayTime <> MaxSpeed then
            DelayTime := DelayTime - SpeedUp
        end;
    PrevCount := count;
end;

var
    c: location;
    score, DelayTime: word;
    dx, dy: shortint;
    FlyX, FlyY, AplX, AplY, count, PrevCount, ScDigit: byte;
    AplCount: integer;
    AplExist, FlyExist, growth: boolean;
begin
    randomize;
    clrscr;
    lngth := 3;
    dx := 1;                                    {Set initial moving direction}
    dy := 0;
    DelayTime := InitialDelayTime;
    FlyExist := false;
    AplExist := false;
    count := 0;                                 {The number of flies eaten}
    PrevCount := 0;                             {Count from previous iteration}
    score := 0;
    growth := false;
    SetInitialLocationArray(c);
    SetInitialCoordinates(c);
    WriteInitialSnake(c);
    while true do
        begin
        ShowingFly(c, FlyExist, FlyX, FlyY);
        ShowingApple(c, AplExist, AplCount, AplX, AplY, count, FlyX, FlyY);
        ProcessingInput(dx, dy);
        MovingSnake(c, growth, dx, dy);
        TransScreenMoveCheck(c);         {Checks}
        FlyCheck(c, FlyExist, growth, count, FlyX, FlyY, score);
        AppleCheck(c, AplExist, growth, count, AplX, AplY, score);
        SelfCollisionCheck(c, score, ScDigit);
        if (c[lngth].x = ScreenWidth) and (c[lngth].y = ScreenHeight) then
        else                                    {Avoiding the last screen pixel}
            begin
            GotoXY(c[lngth].x, c[lngth].y);     {Writing first snake's cell}
            TextColor(LightGreen);
            write(snk)
            end;
        WritingScorePanel(score, ScDigit);
        DelayCount(count, PrevCount, DelayTime);
        GotoXY(1, 1);
        delay(DelayTime)
        end
end.
