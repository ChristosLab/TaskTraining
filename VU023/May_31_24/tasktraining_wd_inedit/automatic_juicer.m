%automatic juicer
WaveInitDaq
BreakState = 0;
for i=1:10000
   BreakState = CheckBreakState;
if BreakState==1
    break;
end
WaitSecs(10);
       for burst=1:1
            outputSingleScan(DO,[1,0,0,0,0,0,0,0]);
            outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
            WaitSecs(0.75);
       end
end
function [BreakState] = CheckBreakState

[MouseX, ~, Breakbutton] = GetMouse;

%  Check for mouse click
if any(Breakbutton)
    Breakbuttons = 0;
    disp('Program paused, click once for continue, twice to exit')
    WaitSecs(1)
    while 1
        Breakbuttons = GetClicks;
        if Breakbuttons == 1
            BreakState = 0;
            Breakbuttons
            return
        elseif Breakbuttons > 1
            BreakState = 1;
            Breakbuttons
            return
        end
    end
else
    BreakState = 0;
end
end