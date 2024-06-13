%test sync scripts
sca;
close all;
clearvars;
WaveInitDaq
outputSingleScan(DO,[0,0,0,0,0,0,0,0]); 
PsychDefaultSetup(2);
%Screen('Preference','EmulateOldPTB');
screens = Screen('Screens');
%screenNumber = max(screens);
screenNumber=1;
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
ifi = Screen('GetFlipInterval', window);
topPriorityLevel = MaxPriority(window);
numSecs = 1;
numFrames = round(numSecs / ifi);
waitframes = 1;
Priority(topPriorityLevel);
%[vbl,stimtime,fliptime] = Screen('Flip', window);

    % Color the screen purple
WaitSecs(3); 
   % Screen('FillRect', window, [1.0 1.0 1.0],[25,20,45,40]);
    Screen('FillRect', window, [1.0 1.0 1.0]);
    % Flip to the screen
     
%  [vbl,stimtime,fliptime] = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);
  Screen('Flip',window);
  WaitSecs(0.05);
  outputSingleScan(DO,[0,0,0,0,1,0,1,0]);
  WaitSecs(3);  
    %[vbl,stimtime,fliptime] = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

Priority(0);
sca;
outputSingleScan(DO,[0,0,0,0,0,0,0,0]); 
%VBLSyncTest(100, 2, 0, 1, 0, 1, 0);
%VBLSyncTest(1000, 0, 0, 0, 0, 1, 0);
%VBLSyncTest(100, 10, 6, 1, 0, 1, 0);
