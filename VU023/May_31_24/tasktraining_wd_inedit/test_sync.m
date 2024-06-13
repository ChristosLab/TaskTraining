%test sync scripts
sca;
close all;
clearvars;
PsychDefaultSetup(2);
screens = Screen('Screens');
screenNumber = max(screens);
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
grey = white / 2;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, grey);
ifi = Screen('GetFlipInterval', window);
topPriorityLevel = MaxPriority(window);
numSecs = 1;
numFrames = round(numSecs / ifi);
waitframes = 1;
Priority(topPriorityLevel);
[vbl,stimtime,fliptime] = Screen('Flip', window);

for frame = 1:numFrames

    % Color the screen purple
    Screen('FillRect', window, [0.5 0 0.5]);
    % Flip to the screen
    [vbl,stimtime,fliptime] = Screen('Flip', window, vbl + (waitframes - 0.5) * ifi);

end
Priority(0);
sca;
%VBLSyncTest(100, 2, 0, 1, 0, 1, 0);
%VBLSyncTest(1000, 0, 0, 0, 0, 1, 0);
%VBLSyncTest(100, 10, 6, 1, 0, 1, 0);
