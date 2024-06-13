ifi = Screen('GetFlipInterval', window);
n_it = 1000;
t = zeros(n_it, 5);
vbl = Screen('Flip', window);
secs_to_wait = rand(1) + 0.2;
waitframes = ceil(secs_to_wait/ifi);
for i = 1:n_it
t(i, 1) = GetSecs;
Screen('CopyWindow',window_queue{1},window);
t(i, 2) = GetSecs;
vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi, 1);
outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
t(i, 3) = GetSecs;
Screen('CopyWindow',window_queue{2},window);
secs_to_wait = rand(1) + 0.2;
waitframes = ceil(secs_to_wait/ifi);
t(i, 4) = GetSecs;
vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi, 1);
outputSingleScan(DO,[0,0,0,0,0,0,1,0]);
t(i, 5) = GetSecs;
secs_to_wait = rand(1) + 0.2;
waitframes = ceil(secs_to_wait/ifi);
end
Screen('CopyWindow',window_queue{1},window);
vbl = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi, 1);
outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
save(fullfile('C:\Users\cclab\Documents\MATLAB\beh\delay_test_32_run_4'), "t");