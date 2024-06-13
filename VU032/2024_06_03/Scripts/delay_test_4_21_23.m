n_it = 1000;
t = zeros(n_it, 5);
for i = 1:n_it
t(i, 1) = GetSecs;
Screen('CopyWindow',window_queue{1},window);
t(i, 2) = GetSecs;
Screen('Flip', window);
outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
t(i, 3) = GetSecs;
WaitSecs(rand(1) + 0.2);
Screen('CopyWindow',window_queue{2},window);
t(i, 4) = GetSecs;
Screen('Flip', window);
outputSingleScan(DO,[0,0,0,0,0,0,1,0]);
t(i, 5) = GetSecs;
WaitSecs(rand(1) + 0.2);
end
Screen('CopyWindow',window_queue{1},window);
Screen('Flip', window);
outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
save(fullfile('C:\Users\cclab\Documents\MATLAB\beh\delay_test_32_run_2'), "t");