%5 points for ISCAN calibration 6/10/20 Wenhao
sca; % Execute Screen(‘CloseAll’) closs all psychtoolbox windows
close all;  %close all figure windows
clearvars;  % delete all variables
WaveInitDaq
%PsychDefaultSetup(2);   %potential source of problem set up color range to [0,1], it exec1utes Screen(‘ColorRange’, window, 1, [], 1);
centerkey=KbName('5');
leftkey=KbName('4');
rightkey=KbName('6');
upkey=KbName('2');
downkey=KbName('8');
escapekey=KbName('1');
rewardkey=KbName('0');

screens=Screen('Screens');
screenNumber=max(screens);
black=BlackIndex(screenNumber);
[window,windowRect]=PsychImaging('OpenWindow',screenNumber,black);
ifi=Screen('GetFlipInterval',window);
[screenXpixels,screenYpixels]=Screen('WindowSize',window);

exit_cali=false;
numSecs=3;
%numFrames=round(numSecs/ifi);
baseRect=[0,0,15,15];
loc=3;   %delete this line
deg=10; 
distance=69; %in cm animal to screen
screen_width=103;
screen_height=57.5;
vertical_offset=round(distance*atan(deg/180*pi)/(screen_height/2)*(screenYpixels/2));
horizontal_offset=round(distance*atan(deg/180*pi)/(screen_width/2)*(screenXpixels/2));
update1=0;
update2=1;
breaktime=0;
while exit_cali==false
    [keyIsDown,secs,keyCode]=KbCheck;
if keyCode(escapekey)
    break;
elseif keyCode(centerkey)
    xCenter=screenXpixels/2;
    yCenter=screenYpixels/2;
    update1=1;
elseif keyCode(leftkey)
    xCenter=screenXpixels/2-horizontal_offset;
    yCenter=screenYpixels/2;
    update1=1;
elseif keyCode(rightkey)
    xCenter=screenXpixels/2+horizontal_offset;
    yCenter=screenYpixels/2;
    update1=1;
elseif keyCode(upkey)
    xCenter=screenXpixels/2;
    yCenter=screenYpixels/2+vertical_offset;
    update1=1;
elseif keyCode(downkey)
    xCenter=screenXpixels/2;
    yCenter=screenYpixels/2-vertical_offset;
    update1=1;
elseif keyCode(rewardkey)
       for burst=1:1
            outputSingleScan(DO,[1,0,0,0,0,0,0,0]);
            outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
            WaitSecs(0.75);
       end
end

  if update1==1  %update1 if key just pressed, update2 screen is blank
      update1=0;
      update2=0;
      keyCode=[];
      breaktime = GetSecs;
      centeredRect=CenterRectOnPointd(baseRect,xCenter,yCenter);
      wavesoundplay('fix_on.wav',0.4);
     Screen('FillRect',window,[255,0,0],centeredRect);
     Screen('Flip',window);
  end
  if (GetSecs-breaktime>numSecs && update2==0)
         Screen('FillRect',window,black);
         Screen('Flip',window);
  end
end
