function WaveDisplayStimulus(offscreenwindow, window)
Screen(window,'Flip');
Screen('CopyWindow',offscreenwindow,window);
Screen(window,'Flip');
