%5 points for ISCAN calibration 6/10/20 Wenhao
% Check display params before use
Screen('Preference', 'VisualDebugLevel', 3);
sca; % Execute Screen(‘CloseAll’) closs all psychtoolbox windows
close all;  %close all figure windows
clearvars;  % delete all variables
WaveInitDaq
%PsychDefaultSetup(2);   %potential source of problem set up color range to [0,1], it exec1utes Screen(‘ColorRange’, window, 1, [], 1);
centerkey=KbName('5');
leftkey=KbName('4');
rightkey=KbName('6');
upkey=KbName('8');
downkey=KbName('2');
leftupkey=KbName('7');
rightupkey=KbName('9');
rightdownkey=KbName('3');
leftdownkey=KbName('1');


escapekey=KbName('return');
rewardkey=KbName('0');
animal_shift=[0,0];
%animal_shift=[-120,105];

screens=Screen('Screens');
%screenNumber=max(screens);
screenNumber=2;
black=BlackIndex(screenNumber);
[window,windowRect]=PsychImaging('OpenWindow',screenNumber,black);
ifi=Screen('GetFlipInterval',window);
[screenXpixels,screenYpixels]=Screen('WindowSize',window);

exit_cali=false;
numSecs=2;
%numFrames=round(numSecs/ifi);
baseRect=[0,0,15,15];
deg=10; 
distance=68; %in cm animal to screen
screen_width=94;
screen_height=53;
pix=[screen_width screen_height]./[screenXpixels,screenYpixels]; %calculates the size of a pixel in cm
degpix=atan(pix./distance).*(180/pi);
pixdeg=1./degpix;
vertical_offset=round(pixdeg(1,1)*deg);
horizontal_offset=round(pixdeg(1,2)*deg);
%vertical_offset=round(distance*atan(deg/180*pi)/(screen_height/2)*(screenYpixels/2));
%horizontal_offset=round(distance*atan(deg/180*pi)/(screen_width/2)*(screenXpixels/2));
update1=0;
update2=1;
breaktime=0;
while exit_cali==false
    [keyIsDown,secs,keyCode]=KbCheck;
if keyCode(escapekey)
    break;
    clear;
elseif keyCode(centerkey)
    xCenter=screenXpixels/2+animal_shift(1);
    yCenter=screenYpixels/2+animal_shift(2);
    update1=1;
elseif keyCode(leftkey)
    xCenter=screenXpixels/2-horizontal_offset+animal_shift(1);
    yCenter=screenYpixels/2+animal_shift(2);
    update1=1;
elseif keyCode(rightkey)
    xCenter=screenXpixels/2+horizontal_offset+animal_shift(1);
    yCenter=screenYpixels/2+animal_shift(2);
    update1=1;
elseif keyCode(upkey)
    xCenter=screenXpixels/2+animal_shift(1);
    yCenter=screenYpixels/2-vertical_offset+animal_shift(2);
    update1=1;
elseif keyCode(downkey)
    xCenter=screenXpixels/2+animal_shift(1);
    yCenter=screenYpixels/2+vertical_offset+animal_shift(2);
    update1=1;
elseif keyCode(leftupkey)
    xCenter=screenXpixels/2-horizontal_offset+animal_shift(1);
    yCenter=screenYpixels/2-vertical_offset+animal_shift(2);
    update1=1;
elseif keyCode(rightupkey)
    xCenter=screenXpixels/2+horizontal_offset+animal_shift(1);
    yCenter=screenYpixels/2-vertical_offset+animal_shift(2);
    update1=1;
elseif keyCode(leftdownkey)
    xCenter=screenXpixels/2-horizontal_offset+animal_shift(1);
    yCenter=screenYpixels/2+vertical_offset+animal_shift(2);
    update1=1;
elseif keyCode(rightdownkey)
    xCenter=screenXpixels/2+horizontal_offset+animal_shift(1);
    yCenter=screenYpixels/2+vertical_offset+animal_shift(2);
    update1=1;
elseif keyCode(rewardkey)
       for burst=1:1
            outputSingleScan(DO,[1,0,0,0,0,0,0,0]);
            WaitSecs(0.65);
            outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
            WaitSecs(0.1);
       end
end

  if update1==1  %update1 if key just pressed, update2 screen is blank
      update1=0;
      update2=0;
      keyCode=[];
      breaktime = GetSecs;
      centeredRect=CenterRectOnPointd(baseRect,xCenter,yCenter);
      wavesoundplay('fix_on.wav',0.4);
     Screen('FillRect',window,[0,255,0],centeredRect);
     Screen('Flip',window);
  end
  if (GetSecs-breaktime>numSecs && update2==0)
         Screen('FillRect',window,black);
         Screen('Flip',window);
  end
end
