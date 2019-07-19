function WaveDisplayStimulus(offscreenwindow, window)
screen(window,'WaitBlanking');
Screen('CopyWindow',offscreenwindow,window);
screen(window,'waitBlanking');
