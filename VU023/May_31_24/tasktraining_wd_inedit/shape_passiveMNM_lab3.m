function shape_passiveMNM_lab3(varargin)
%  Wenhao Dang Aug 2020
myfolder='C:\Users\CCLAB\Documents\MATLAB\tasktraining_wd_inedit\shapes';
bmpshapes = fullfile(myfolder, '*.png');
bmpFiles = dir(bmpshapes);
for k = 1:length(bmpFiles)
  baseFileName = bmpFiles(k).name;
  fullFileName = fullfile(myfolder, baseFileName);
  imageArray{k} = imread(fullFileName);
end
[mousex,mousey] = GetMouse;   %delete this line
warning off all
alpha=0.2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1                      %   If there are no arguments given
    datain(1:4) = [4 .1 .1 .1];     %  Default waiting times for each frame
    datain(5) = 3;                 %  Trial type
    datain(6) = 1;                %  Number of blocks
    datain(7) = 10;                %  Stimulus eccentricity
    datain(8) = 40;               %  Radius in pixels of fixation window
    datain(9) = 600;                %  Repeat stimulus this many times before go to next location
    datain(10) = 127;
 %   datasin = 'GRUeye00000';               %file name
    vstruct.res = [1920 1080];     % screen resolution
    vstruct.siz = [103 57.5];        % screen size in cm [61 55]
    vstruct.dis = 69;             % viewing distance in cm
    vstruct.ang = 10;
    vstruct.voltage = 3.5;        % Analog to degree conversion constant
    numBurst = 4;              % Number of bursts received for correct trial
else
    % arguments exist from Gui, use them
    dataintemp = varargin(1);      % varargin is cell and convert to structure
    datain(1:11) = dataintemp{1,1};
    datasin = varargin{2};
    vstruct = varargin{3};
end

%  Calculate Pixels/Degree using CalcAngs function
pix=vstruct.siz./vstruct.res; %calculates the size of a pixel in cm
%degpix=(2*atan(pix./(2*vstruct.dis))).*(180/pi);
degpix=atan(pix./(vstruct.dis)).*(180/pi);
pixdeg=1./degpix;
vstruct.pixvolt = pixdeg*vstruct.voltage;
%vstruct.pixeye  = vstruct.res./(vstruct.voltage*20);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Calculate the coordinates using the pixels/degree var
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vstruct.ang = datain(7);                 % excentricity inputed by user
angs = [360 45 90 135 180 225 270 315];  % angles
radians = (angs*0.0174532925)';          % convert degrees to radians
coors(:,1) = cos(radians)*vstruct.ang;   % Calculate all x coordinates
coors(:,2) = sin(radians)*vstruct.ang;   % Calculate all y coordinates
pixs(:,1) = pixdeg(1,1)*coors(:,1);      % Convert x degs to pixels
pixs(:,2) = pixdeg(1,2)*coors(:,2);      % Convert y degs to pixels
pixs(1:1:8,:) = pixs(8:-1:1,:);          % Invert the pixels to clockwise order
pixs(9,1:2) = [0 0];
pixsX = -pixs(4,1);
pixsY = -pixs(2,2);
pixs = [pixsX -pixsY; 0 -pixsY; -pixsX -pixsY; -pixsX 0; -pixsX pixsY; 0 pixsY; pixsX pixsY; pixsX 0; 0 0]; %the last one is center
newcoors = [vstruct.ang vstruct.ang;0 vstruct.ang; -vstruct.ang vstruct.ang; -vstruct.ang 0;...
    -vstruct.ang -vstruct.ang; 0 -vstruct.ang; vstruct.ang -vstruct.ang; vstruct.ang 0; 0 0];

FixSize = [4 4];                        % size of the stimuli in pixels
StimSize= [15,15];
FixationWindow = datain(8);
%TargetWindow = datain(9);
Xscale = 5.5;
Xscalecenter = 0;
Yscale = 4;
Yscalecenter = 0;

centerX = vstruct.res(1,1)/2;            % Calculate the center of the screen (X)
centerY = vstruct.res(1,2)/2;            % Calculate the center of the screen (Y)
X1 = centerX-FixSize(1,1);              % With center pixel, make rectangle around it, the conors of fix square
X2 = centerX+FixSize(1,1);               
Y1 = centerY-FixSize(1,2);
Y2 = centerY+FixSize(1,2);
dX1 = centerX-StimSize(1,1);              % With center pixel, make rectangle around it, the conors of fix square
dX2 = centerX+StimSize(1,1);               
dY1 = centerY-StimSize(1,2);
dY2 = centerY+StimSize(1,2);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  This section creates a window to graphically display the analog eye
%  position in realtime.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
btnColor=get(0,'DefaultUIControlBackgroundColor');

% Position the figure on right extended screen at the bottom
screenUnits=get(0,'Units');
screenSize=get(0,'ScreenSize');
set(0,'Units',screenUnits);
figWidth=640;
figHeight=512;
figPos=[0 40  ...
    figWidth                    figHeight];

% Create the figure window.
hFig=figure(...
    'Color'             ,btnColor                 ,...
    'IntegerHandle'     ,'off'                    ,...
    'DoubleBuffer'      ,'on'                     ,...
    'MenuBar'           ,'none'                   ,...
    'HandleVisibility'  ,'on'                     ,...
    'Name'              ,'Eye Position'  ,...
    'Tag'               ,'Eye Position'  ,...
    'NumberTitle'       ,'off'                    ,...
    'Units'             ,'pixels'                 ,...
    'Position'          ,figPos                   ,...
    'UserData'          ,[]                       ,...
    'Colormap'          ,[]                       ,...
    'Pointer'           ,'arrow'                  ,...
    'Visible'           ,'off'                     ...
    );

% Create target,fixation window,eye position xy plot

hAxes(1) = axes(...
    'Position'          , [0.08 0.3 0.55 0.55],...
    'Parent'            , hFig,...
    'XLim'              , [-25 25],...
    'YLim'              , [-25 25]...
    );

i=1:33;
xcoord(i)=cos(i*pi/16);
ycoord(i)=sin(i*pi/16);
hLine(3) = plot(1*xcoord,1*ycoord,'Parent',hAxes(1));
hLine(2) = line('XData',0,'YData',0,'marker','+');  % eye position
hLine(1) = line('XData',0,'YData',0,'marker','s'); % stimulus position
% markerradii = ((4/2.54)*72)/4;

% Label the plot.
xlabel('X');
ylabel('Y');

% Create Eye X subplot.

hAxes(2) = axes(...
    'Position'          , [0.6700 0.650 0.30 0.15],...
    'Parent'            , hFig,...
    'XLim'              , [0 400],...
    'YLim'              , [-10 10]...
    );
hLine(4) = plot(200,0);
% hLine(6) = line('XData',200,'YData',10, 'marker', 'v');
% Label the plot.
title('Eye X');

% Create Eye Y subplot.

hAxes(3) = axes(...
    'Position'          , [0.670 0.350 0.30 0.15],...
    'Parent'            , hFig,...
    'XLim'              , [0 400],...
    'YLim'              , [-10 10]...
    );
hLine(5) = plot(0,0);
% Label the plot.
xlabel('Time');
title('Eye Y');

data.handle.figure = hFig;
data.handle.axes = hAxes;
data.handle.line = hLine;
set(hFig,'Visible','on','UserData',data);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %  Declare coordinates of 8 points and fixation point
% %  Coordinates in pixels on 1280/1024 32 bit display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fCenter = [centerX,centerY];
fRect = [X1,Y1,X2,Y2];
for n = 1:9
    tCenter(n*45,:) = pixs(n,:)+[centerX centerY];   %center of calibration points
    wRect(n*45,:) = [X1+(pixs(n,1)),Y1+(pixs(n,2)),X2+(pixs(n,1)),Y2+(pixs(n,2))]; %pixe coordinates of calibration points
    sRect(n*45,:) = [dX1+(pixs(n,1)),dY1+(pixs(n,2)),dX2+(pixs(n,1)),dY2+(pixs(n,2))];
    dRect(n*45,1:2) = [newcoors(n,1) newcoors(n,2)];  %degree of calibration points
end

% Fixation times in seconds
frame1 = datain(1);  %fixation time for fixation point
frame2 = datain(2);  %fixation time for fix + target display
frame3 = datain(3);  %fixation time for target alone display
frame4 = datain(4); % fixation time on target until reward

% Trial type, 1 = visual, 2 = memory, 3 = No Saccade
trialtype = datain(5);
switch trialtype
    case 1
        totalframes = 4;
    case 2
        totalframes = 4;
    case 3
        totalframes = 3;  %passive task
end
% Number of blocks
totalblocks = datain(6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate 8 random integers and * 45 for shuffled degrees for each trial
% Then generate two opposing random points in the 2nd and 3rd dimension of Seq
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for n = 1:totalblocks
    Seq(n,:) = [405 360 45 90 135 180 225 270 315];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate variable to store data to be saved as filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
screens = Screen('Screens');
%screenNumber = max(screens);
screenNumber=1;
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
gray=(white+black)/2;
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, gray);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Make offscreen windows  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus + Fixation (sf) and Stimulus alone (s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n = 45:45:405 %generating fixation stim
    s(n) = Screen(window,'OpenOffscreenWindow',gray,[],32);
    Screen(s(n),'FillRect',[255,255,255],wRect(n,:)); %make screen for each calibration points
end

for n = 45:45:405 %generating distractor stim    
    d(n) = Screen(window,'OpenOffscreenWindow',gray,[],32);
    d_color=[255,0,0];
    old_color=[0,0,0];
    %alpha=0.5;
    new_color=round(alpha*d_color+(1-alpha)*old_color);
    Screen(d(n),'FillRect',[new_color;255,255,255]',[sRect(n,:);wRect(405,:)]');
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Configure the Nidaq board   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WaveInitDaq
outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start Trial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
totaltrials = 9; % not really trials, but number of locations
repeatmax = datain(9);   %number of repeat for 1 location in each block
BreakState = 0;
outputcounter = 1; % as long as a trial start outputcounter increase
correctcounter = 0;
%intertrial_interval = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%startBackground(ai)
%waitsecs(.1)
AllData.synctime = clock;
AllData.starttime = GetSecs;
blockcounter = 1;
try
    while (BreakState ~= 1) && (blockcounter <= totalblocks)
        trialcounter = 1;  %not count trials, but how many locations had been shown
        repeatcounter = 1;
        AllData.block(blockcounter).time = GetSecs;
      %  outputcounter = outputcounter + 1;
        dataout(outputcounter,1:4) = {'Trial' 'Trial Type' 'Trials Correct' 'Success'};
        while (trialcounter <= totaltrials) && (BreakState ~=1)
            Deg = Seq(blockcounter,trialcounter);
            AllData.outputcounter = outputcounter; %record number of started trials, no matter success or fail
            AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).time = GetSecs;  %record correct trial start time since repeatcounter only update at coorect response
            AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).degree = Seq(blockcounter,trialcounter); %recorde correct trial degree
            while (repeatcounter <= repeatmax) && (BreakState ~=1)
                outputcounter = outputcounter + 1; 
                all_eye=[];
                all_eyetime=[];
                while 1
                    Statecode = 1;
                    FixState = 0;
                    Result = 0;
                    %  Display Fixation

                    Screen(window,'WaitBlanking');   % Wait for the next monitor refresh cycle
                    Screen('CopyWindow',s(Deg),window);   % First frame is fixation window

                    Screen(window,'Flip');  
                    wavesoundplay('fix_on.wav',0.4);
                    Screen(window,'waitBlanking');   %try comment out this line
                   % Screen(window,'Flip');
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).fixOn=GetSecs;%get correct trial fixon time
                    xStimDisplay = dRect(Deg,1);
                    yStimDisplay = dRect(Deg,2);
                    xWindowDisplay = (datain(8)*xcoord)+xStimDisplay;
                    yWindowDisplay = (datain(8)*ycoord)+yStimDisplay;
                    set(hLine(1),'XData',xStimDisplay,'YData',yStimDisplay,'Visible', 'on'); % stimulus position
                    set(hLine(3),'XData',xWindowDisplay,'YData',yWindowDisplay);
                    breaktime = GetSecs;
                    trial_start=GetSecs;
                %    loop_count1=0;
                    %  Give subject 5 seconds to move to fixation window
                    while (FixState <= 0) && ((GetSecs - breaktime) < 5)
                 %       loop_count1=loop_count1+1;
                        eye=inputSingleScan(ai);
                        all_eyetime=[all_eyetime,GetSecs];
                        eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                        eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                        all_eye=[all_eye;[eyeX,eyeY]];
                        set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                        set(hLine(2), 'XData', eyeX, 'YData', eyeY*-1); % eye position
                        drawnow
                        [FixState] = CheckFixation([0,0], FixationWindow,Xscale,Yscale,ai);
                    end
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).fixIn=GetSecs; %record fixatioin start time
                    
                    %  If subject didn't get to window within 2 seconds, or break
                    %  button was pushed, break out of trial
                    if FixState == 0
                        break;
                    end
                    Statecode = 2;
                    breaktime = GetSecs;
                    distractor_breaktime = GetSecs;
                    distractor1_fliped=0;
                    distractor2_fliped=0;
                    fix_fliped=0;
                    distractor_match=randi([0,1],1);
                    temp_loc=[45:45:360];
                    temp_index=randperm(8);
                    nonmatch_lookup=[5,6,7,8,1,2,3,4];
                    while (FixState == 1) && ((GetSecs - breaktime) < frame1)
                   %   loop_count1=loop_count1+1;
                      if (GetSecs - distractor_breaktime)<=0.5
                         distractor1_state=0;
                         distractor2_state=0;
                      elseif (GetSecs - distractor_breaktime)>0.5 && (GetSecs - distractor_breaktime)<=1
                         distractor1_state=1;
                         distractor2_state=0;
                      elseif (GetSecs - distractor_breaktime)>2.5 && (GetSecs - distractor_breaktime)<=3
                         distractor1_state=0;
                         distractor2_state=1;
                      else
                         distractor1_state=0;
                         distractor2_state=0;  
                      end
                      if distractor1_state==1 && distractor2_state==0 && distractor1_fliped==0
                       % Screen('CopyWindow',d(temp_loc(temp_index(1))),window);
                        [s1,s2,s3]=size(imageArray{temp_index(1)});
                        theRect=[0 0 round(s1/2) round(s2/2)];
                        distRect=CenterRectOnPointd(theRect,centerX,centerY);
                        temp_image=imageArray{temp_index(1)};
                        temp_image(:,:,4)=255*alpha*ones(s1,s2);
                        imageTexture = Screen('MakeTexture', window,temp_image);
                        Screen('DrawTextures', window, imageTexture, [], distRect);
                        Screen('FillRect', window, [255,255,255]',[X1,Y1,X2,Y2]');
                        Screen(window,'Flip'); 
                        distractor1_fliped=1;
                        fix_fliped=0;
                      end
                      if distractor1_state==0 && distractor2_state==1 && distractor2_fliped==0
                        if distractor_match==1
                        temp_image=imageArray{temp_index(1)};  
                        temp_image(:,:,4)=255*alpha*ones(s1,s2);
                        imageTexture = Screen('MakeTexture', window, temp_image);
                        Screen('DrawTextures', window, imageTexture, [], distRect);
                        else
                        [s1,s2,s3]=size(imageArray{nonmatch_lookup(temp_index(1))});
                        theRect=[0 0 round(s1/2) round(s2/2)];
                        distRect=CenterRectOnPointd(theRect,centerX,centerY);
                        temp_image=imageArray{nonmatch_lookup(temp_index(1))};
                        temp_image(:,:,4)=255*alpha*ones(s1,s2);
                        imageTexture = Screen('MakeTexture', window, temp_image);
                        Screen('DrawTextures', window, imageTexture, [], distRect);
                        end
                        Screen('FillRect', window, [255,255,255]',[X1,Y1,X2,Y2]');
                        Screen(window,'Flip'); 
                        distractor2_fliped=1;
                        fix_fliped=0;
                      end
                      if distractor1_state==0 && distractor2_state==0 && fix_fliped==0
                        Screen('CopyWindow',s(405),window);
                        Screen(window,'Flip'); 
                        fix_fliped=1;
                      end
                        eye=inputSingleScan(ai);
                        all_eyetime=[all_eyetime,GetSecs];
                        eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                        eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                        all_eye=[all_eye;[eyeX,eyeY]];                        
                        set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                        set(hLine(2), 'XData', eyeX, 'YData', eyeY*-1); % eye position
                        drawnow
                        [FixState] = CheckFixation([0,0], FixationWindow,Xscale,Yscale,ai);
                    end
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).fixOut=GetSecs; %record fixoff time
                    
                    if FixState == 0
                        break;
                    end
                    Result = 1;

                    break
                end
                %  If this point in the code is reached, the subject completed
                %  the trial successfully and Result is changed from 0 to 1
                %                 putvalue(dio, [0 0 0 0 0 0 0 0]);
                Screen(window,'FillRect',gray)  % Clear screen
                Screen(window,'Flip');
                set(hLine(1),'Visible', 'off'); % stimulus position
                set(hLine(3),'XData',(datain(8)*xcoord)+xStimDisplay,'YData',(datain(8)*ycoord)+yStimDisplay);
                if Result == 1
                    RectionTime = 0;
                 %   [AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,1:3), ...
                 %    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,4)] = getdata(ai,ai.SamplesAvailable);
                 
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).Rewardtime = GetSecs;
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).Reward = 'Yes';
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).Statecode = Statecode;
                    %                     sendapmreward(((blockcounter-1)*8)+trialcounter,1)
                    clc
                    correctcounter = correctcounter + 1;
                    dataout(outputcounter,1:4) = {outputcounter-blockcounter, trialtype, correctcounter, 1};
                    %  Correct auditory feedback
                    wavesoundplay('correct.wav',0.6)
                    for burst=1:numBurst
                    outputSingleScan(DO,[1,0,0,0,0,0,0,0]);
                    outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
                    WaitSecs(0.75);
                    end
                    intertrial_interval = 2;
                    repeatcounter = repeatcounter + 1;
                else
                    RectionTime = 0;
                  %  [AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,1:3), ...
                  %  AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,4)] = getdata(ai,ai.SamplesAvailable);
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).Rewardtime = GetSecs;
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).Reward = 'No';
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).Statecode = Statecode;
                    %                     sendapmreward(((blockcounter-1)*8)+trialcounter,0)
                    clc
                    dataout(outputcounter,1:4) = {outputcounter-blockcounter, trialtype, correctcounter, 0}
                    %  Incorrect auditory feedback
               %     Snd('Play',[sin(1:500)],[1000]);
                    intertrial_interval = 2;
                end
                %                 sendapmmessage(((blockcounter-1)*8)+trialcounter,Deg,datain(7), trialtype)
                %xq 2018 4 23
                set(hLine(4), 'XData',all_eyetime-trial_start,...
                    'YData', all_eye(:,1)');
                set(hLine(5), 'XData',all_eyetime-trial_start,...
                    'YData', all_eye(:,2)');
                set(hAxes(2),'YLim', [-15 15],'XLim', [0 frame1+5]);
                set(hAxes(3),'YLim', [-15 15],'XLim', [0 frame1+5]);
                drawnow
                breaktime = GetSecs;
                AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).eye_time = all_eyetime;
                AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).eye_loc = all_eye;
                %  Intertrial inverval
                while ((GetSecs - breaktime) < intertrial_interval) && (BreakState ~=1)
                %    loop_count1=loop_count1+1;
                    eye=inputSingleScan(ai);
                    all_eyetime=[all_eyetime,GetSecs];
                    eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                    eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                    all_eye=[all_eye;[eyeX,eyeY]];
                    set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                    set(hLine(2), 'XData', eyeX, 'YData', eyeY*-1, 'marker', '+')
                    drawnow
                    BreakState = CheckBreakState;
                end

                if (BreakState == 1)
                    break;
                end
             %   repeatcounter = repeatcounter + 1;
             %   Snd('Quiet');  %  Clear soundcard buffer
            end
            trialcounter = trialcounter + 1;
        end
        blockcounter = blockcounter + 1;
    end
catch
    lasterr
end
Screen('CloseAll')
stop(ai)
AllData.endtime = GetSecs;
close(hFig)
%save(['C:\MATLAB6p5\work\Behavioral_Data_Files\' datasin],'AllData')
clear



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FixState,BreakState] = CheckFixation(cCenter, WindowRadius,Xscale,Yscale,ai)
%  CheckFixation is a subfunction that inputs rectangular coordinates and
%  duration to check that the mouse coordinates stay within the inputed
%  rectangle for the duration and send back to the main function whether
%  the subject was successful or errored or clicked the mouse button.
%global ai Xscalecenter Xscale Yscalecenter Yscale vstruct degpix

eye=inputSingleScan(ai);
eyeX = -1*(((eye(1,1)-0)*Xscale));
eyeY = (((eye(1,2)-0)*Yscale));

%  Compare distance from mouse coordinates from inputed window center
if (((cCenter(1,1)-eyeX)^2)+((cCenter(1,2)-eyeY)^2))^.5 <= WindowRadius
    %  If distance between mouse and window is less than inputted radius,
    %  then mouse is in correct position
    FixState = 1;
else
    %  If not then it is outside of the radius
    FixState = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [BreakState] = CheckBreakState

[MouseX, ~, Breakbutton] = GetMouse;

%  Check for mouse click
if any(Breakbutton)
    Breakbuttons = 0;
    disp('Program paused, click once for continue, twice to exit')
    WaitSecs(1)
    while 1
        Breakbuttons = GetClicks;
        if Breakbuttons == 1
            BreakState = 0;
            Breakbuttons
            return
        elseif Breakbuttons > 1
            BreakState = 1;
            Breakbuttons
            return
        end
    end
else
    BreakState = 0;
end

