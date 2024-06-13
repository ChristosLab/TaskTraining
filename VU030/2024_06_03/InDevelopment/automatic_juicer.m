%automatic juicer
WaveInitDaq
BreakState = 0;
while ~KbCheck 
WaitSecs(3);
       for burst=1:1
            outputSingleScan(DO,[1,0,0,0,0,0,0,0]);
            WaitSecs(0.65);
            outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
            WaitSecs(2);
       end
end