 %automatic juicer
WaveInitDaq
BreakState = 0;
burst_interval = 3;
n_burst = 1;
breaktime = GetSecs; 
while ~KbCheck
if ((GetSecs - breaktime) > burst_interval)
       for burst=1:n_burst
            outputSingleScan(DO,[1,0,0,0,0,0,0,0]);
            outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
            WaitSecs(0.75);
       end
       breaktime = GetSecs;
end 
end