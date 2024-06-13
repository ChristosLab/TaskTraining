%automatic juicer
WaveInitDaq
BreakState = 0;
while ~KbCheck 
WaitSecs(2);
       for burst=1:1
            outputSingleScan(DO,[1,0,0,0,0,0,0,0]);
            WaitSecs(3 ...
                ...
                ...
                );
            outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
            WaitSecs(0.1);
       end
end