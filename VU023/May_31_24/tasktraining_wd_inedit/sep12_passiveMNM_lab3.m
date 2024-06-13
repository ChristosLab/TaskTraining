function record_passiveMNM_lab3(varargin)
%  Wenhao Dang Aug 2020
clear global trial_eye_data
[~,mousey] = GetMouse;   %delete this line
warning off all
Screen('closeall');
daqreset;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
version = 'passiveMNM Aug-17-2020 WD'; 
if nargin < 1                      %   If there are no arguments given
    datain(1:5) = [3. .5 .5 1.5 .5];     %  Default waiting times for each frame
    datain(6) = 1;                %  Number of blocks
    datain(7) = 10;                %  Stimulus eccentricity
    datain(8) = 4;               %  Radius in pixels of fixation window
    datain(9) = 2;                %  Repeat each stim id for this times
    datain(10) = 127;
 %   datasin = 'GRUeye00000';               %file name
    vstruct.res = [1920 1080];     % screen resolution
    vstruct.siz = [103 57.5];        % screen size in cm [61 55]
    vstruct.dis = 69;             % viewing distance in cm
    vstruct.ang = 10;
    numBurst = 2;              % Number of bursts received for correct trial
else
    % arguments exist from Gui, use them
    dataintemp = varargin(1);      % varargin is cell and convert to structure
    datain(1:11) = dataintemp{1,1};
    datasin = varargin{2};
    vstruct = varargin{3};
end

%  Calculate Pixels/Degree using CalcAngs function
pix=vstruct.siz./vstruct.res; %calculates the size of a pixel in cm
degpix=atan(pix./(vstruct.dis)).*(180/pi);
pixdeg=1./degpix;

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
targ_coors=[ 0 0;vstruct.ang 0;vstruct.ang vstruct.ang;0 vstruct.ang; -vstruct.ang vstruct.ang; -vstruct.ang 0;...
    -vstruct.ang -vstruct.ang; 0 -vstruct.ang; vstruct.ang -vstruct.ang ];

FixSize = [5 5];                        % size of the stimuli in pixels
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Name Output File 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OutputFileNames = fileoutdlg({'Behavior output file',}, 'Output Files',[1 30],{'GRU00x_xx'});
if isempty(OutputFileNames)
    return;
else
    savename = OutputFileNames{1};
end

go = 1;
filenamecheck = ['C:\Users\CCLAB\Documents\Behavioral_Data\' savename '.mat'];
filecheck = dir(filenamecheck);
if ~isempty(filecheck)
    button = questdlg('File name exists, do you want to continue?',...
        'Continue Operation','Yes','No','Help','No');
    if strcmp(button,'Yes')
        disp('Creating file')
        go = 1;
    elseif strcmp(button,'No')
        disp('Canceled file operation')
        go = 0;
    elseif strcmp(button,'Help')
        disp('Sorry, no help available')
        go = 0;
    end
end
if  go == 1
    cd C:\Users\CCLAB\Documents\Behavioral_Data\
else
    return
end


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
%hLine(4) = plot(200,0);
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
%hLine(5) = plot(0,0);
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

fCenter = [centerX,centerY];  %fixation center in pixel
fRect = [X1,Y1,X2,Y2];   %fixation conners in pixel
for n = 1:8
    tCenter(n*45,:) = pixs(n,:)+[centerX centerY];   %center of 8 stim
    sRect(n*45,:) = [dX1+(pixs(n,1)),dY1+(pixs(n,2)),dX2+(pixs(n,1)),dY2+(pixs(n,2))];  %pixe coordinates of conners of 8 stim
    dRect(n*45,1:2) = [newcoors(n,1) newcoors(n,2)];  %degree of calibration points
end

% Fixation times in seconds
frame1 = datain(1);  %fixation time for fixation point
frame2 = datain(2);  %fixation time for fix + target display
frame3 = datain(3);  %fixation time for target alone display
frame4 = datain(4); % fixation time on target until reward
frame5 = datain(5);

% Trial type, 1 = visual, 2 = memory, 3 = No Saccade
%trialtype = 3;
%switch trialtype
%    case 1
%        totalframes = 4;
%    case 2
%        totalframes = 4;
%    case 3
%        totalframes = 3;  %passive task
%end
% Number of blocks
totalblocks = datain(6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate 8 random integers and * 45 for shuffled degrees for each trial
% Then generate two opposing random points in the 2nd and 3rd dimension of Seq
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%for n = 1:totalblocks
%    Seq(n,:) = [360 45 90 135 180 225 270 315];
%end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialize Nidaq board   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WaveInitDaq

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate variable to store data to be saved as filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
screens = Screen('Screens');
%screenNumber = max(screens);
screenNumber=1;
white = WhiteIndex(screenNumber);
black = BlackIndex(screenNumber);
[window, windowRect] = PsychImaging('OpenWindow', screenNumber, black);
topPriorityLevel=MaxPriority(window);
Priority(topPriorityLevel);
Screen('BlendFunction', window, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Make offscreen windows  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus + Fixation (sf) and Stimulus alone (s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n = 45:45:360 %generating fixation stim fixation for all stim are center
    s(n) = Screen(window,'OpenOffscreenWindow',black,[],32);
    Screen(s(n),'FillRect',white,[X1,Y1,X2,Y2]); %make screen for each calibration points
end

for n = 45:45:360 %generating distractor stim    
    d(n) = Screen(window,'OpenOffscreenWindow',black,[],32);
    d_color=[255,0,0];
    old_color=[0,0,0];
    alpha=1;
    new_color=round(alpha*d_color+(1-alpha)*old_color); %color for stim
    Screen(d(n),'FillRect',[new_color;255,255,255;255,255,255]',[sRect(n,:);[X1,Y1,X2,Y2];[25,20,45,40]]');%first square stim,second fixation, third sync square
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
total_stims = 8; % not really trials, but number of locations
repeatmax = datain(9);   %number of repeat for 1 location in each block
num_condition=total_stims*2; %match and nonmatch
num_trials=num_condition*repeatmax;
all_cues=repmat([1:total_stims],1,2);
nonmatch_lookup=[5,6,7,8,1,2,3,4];
loc_list=[45:45:360];
all_ismatch=[ones(1,total_stims),zeros(1,total_stims)];
all_samples=[[1:total_stims],nonmatch_lookup([1:total_stims])];
BreakState = 0;
outputcounter = 1; % as long as a trial start outputcounter increase
correctcounter = 0;
intertrial_interval = 2;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%AllData.parameters.Display = Display;% Display: fix and stim center locations, lumniance and size of fix and sitm
AllData.version = version;
AllData.parameters.fixtotal = datain(1);
AllData.parameters.fixduration = datain(2);
AllData.parameters.cueduration = datain(3);
AllData.parameters.cuedelayduration = datain(4);
AllData.parameters.sampleduration = datain(5);
AllData.parameters.totalBlocks = datain(6);
AllData.parameters.stimulusEccentricity = datain(7);
AllData.parameters.fixationWindow = datain(8);
AllData.parameters.luminance = alpha;
AllData.parameters.vstruct = vstruct;
AllData.parameters.ITI = intertrial_interval;
AllData.parameters.FixAquisition = 2;
AllData.synctime = clock;
AllData.starttime = GetSecs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%startBackground(ai)
%waitsecs(.1)
blockcounter = 1;
try
    while (BreakState ~= 1) && (blockcounter <= totalblocks)

       % temp_loc=[45:45:405];

        AllData.block(blockcounter).time = GetSecs; %record block start time
      %  outputcounter = outputcounter + 1;
        dataout(outputcounter,1:3) = {'Trial' 'Trials Correct' 'Success'};
        repeatcounter = 1;
        while (repeatcounter <= repeatmax) && (BreakState ~=1)
            finished_trialcounter=1;
            temp_index=randperm(num_condition);
            unused_index=temp_index;
            correct_inrepeat=1;  %correct trial counter in each repeat
        %    Deg = Seq(blockcounter,trialcounter);
            AllData.outputcounter = outputcounter; %record number of started trials, no matter success or fail
            while (correct_inrepeat <= num_condition) && (BreakState ~=1)
                outputcounter = outputcounter + 1; 
                temp_pick=unused_index(randperm(length(unused_index),1));
                AllData.block(blockcounter).repeat(repeatcounter).trial(finished_trialcounter).cuedegree = loc_list(all_cues(temp_pick)); %cue degree
                AllData.block(blockcounter).repeat(repeatcounter).trial(finished_trialcounter).sampledegree = loc_list(all_samples(temp_pick)); %sample degree
                AllData.block(blockcounter).repeat(repeatcounter).trial(finished_trialcounter).ismatch = all_ismatch(temp_pick); 

                while 1
                    Statecode = 1;
                    FixState = 0;
                    Result = 0;
                    %  Display Fixation

                    Screen(window,'WaitBlanking');   % Wait for the next monitor refresh cycle
                    Screen('CopyWindow',s(loc_list(all_cues(temp_pick))),window);   % First frame is fixation window
                    Screen(window,'Flip');  
                    AllData.block(blockcounter).repeat(repeatcounter).trial(finished_trialcounter).time = GetSecs;  %record correct trial start time since repeatcounter only update at coorect response
                    wavesoundplay('fix_on.wav',0.4);
                    global trial_eye_data;
                    outputSingleScan(DO,[0,0,0,0,1,0,0,0]);
                  %  AllData.repeat(repeatcounter).trial(finished_trialcounter).start = GetSecs;
                    AllData.outputcounter = outputcounter;
                   % Screen(window,'waitBlanking');   %try comment out this line
                   % Screen(window,'Flip');
                   % AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).fixOn=GetSecs;%get correct trial fixon time
                    xStimDisplay = 0;
                    yStimDisplay = 0;
                    xWindowDisplay = (datain(8)*xcoord)+xStimDisplay;
                    yWindowDisplay = (datain(8)*ycoord)+yStimDisplay;
                    set(hLine(1),'XData',xStimDisplay,'YData',yStimDisplay,'Visible', 'on'); % stimulus position
                    set(hLine(3),'XData',xWindowDisplay,'YData',yWindowDisplay);
                    breaktime = GetSecs;
                    %  Give subject 2 seconds to move to fixation window
                    while (FixState <= 0) && ((GetSecs - breaktime) < 2)
                        eye=inputSingleScan(ai);
                        eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                        eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                        set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                        set(hLine(2), 'XData', eyeX, 'YData', eyeY); % eye position
                        drawnow
                        [FixState] = CheckFixation([0,0], FixationWindow,Xscale,Yscale,ai);
                    end
                    AllData.block(blockcounter).repeat(repeatcounter).trial(finished_trialcounter).fixIn=GetSecs; %record fixatioin start time
                    
                    %  If subject didn't get to window within 2 seconds, or break
                    %  button was pushed, break out of trial
                    if FixState == 0
                        stop(ai);
                        wavesoundplay('abort.wav',0.8);
                        break;
                    end
                    Statecode = 2;
                    breaktime = GetSecs;
                    distractor_breaktime = GetSecs;
                    distractor1_fliped=0;
                    distractor2_fliped=0;
                    fix_fliped=0;
                    distractor_match=randi([0,1],1);
                    nonmatch_lookup=[5,6,7,8,1,2,3,4];

                    while (FixState == 1) && ((GetSecs - breaktime) < frame1)
          
                      if (GetSecs - distractor_breaktime)<=frame2
                         distractor1_state=0;
                         distractor2_state=0;
                      elseif (GetSecs - distractor_breaktime)>frame2 && (GetSecs - distractor_breaktime)<=frame2+frame3
                         distractor1_state=1;
                         distractor2_state=0;
                      elseif (GetSecs - distractor_breaktime)>frame2+frame3+frame4 && (GetSecs - distractor_breaktime)<=frame2+frame3+frame4+frame5
                         distractor1_state=0;
                         distractor2_state=1;
                      else
                         distractor1_state=0;
                         distractor2_state=0;  
                      end
                      if distractor1_state==1 && distractor2_state==0 && distractor1_fliped==0
                        Screen('CopyWindow',d(loc_list(all_cues(temp_pick))),window);
                        Screen(window,'Flip'); 
                        outputSingleScan(DO,[0,0,0,0,1,0,1,0]);
                        distractor1_fliped=1;
                        fix_fliped=0;
                      end
                      if distractor1_state==0 && distractor2_state==1 && distractor2_fliped==0
                        Screen('CopyWindow',d(loc_list(all_samples(temp_pick))),window);           
                        Screen(window,'Flip'); 
                        outputSingleScan(DO,[0,0,0,0,1,0,1,0]);          
                        distractor2_fliped=1;
                        fix_fliped=0;
                      end
                      if distractor1_state==0 && distractor2_state==0 && fix_fliped==0
                        Screen('CopyWindow',s(loc_list(all_cues(temp_pick))),window);
                        Screen(window,'Flip'); 
                        if (GetSecs - distractor_breaktime)>0.1
                            outputSingleScan(DO,[0,0,0,0,1,0,0,0]);
                        end
                        fix_fliped=1;
                      end
                        eye=inputSingleScan(ai);
                        eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                        eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                        set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                        set(hLine(2), 'XData', eyeX, 'YData', eyeY); % eye position
                        drawnow
                        [FixState] = CheckFixation([0,0], FixationWindow,Xscale,Yscale,ai);

                    end

                    AllData.block(blockcounter).repeat(repeatcounter).trial(finished_trialcounter).fixOut=GetSecs; %record fixoff time
                    
                    if FixState == 0
                        stop(ai);
                        wavesoundplay('abort.wav',0.8);
                        break;
                    end
                    Result = 1;

                    break
                end
                %  If this point in the code is reached, the subject completed
                %  the trial successfully and Result is changed from 0 to 1
                %                 putvalue(dio, [0 0 0 0 0 0 0 0]);
                Screen(window,'FillRect',black)  % Clear screen
                Screen(window,'Flip');
                set(hLine(1),'Visible', 'off'); % stimulus position
                set(hLine(3),'XData',(datain(8)*xcoord)+xStimDisplay,'YData',(datain(8)*ycoord)+yStimDisplay);
                if Result == 1
                  %  RectionTime = 0;
                 %   [AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,1:3), ...
                 %    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,4)] = getdata(ai,ai.SamplesAvailable);
                    unused_index(unused_index==temp_pick)=[];
                    AllData.block(blockcounter).repeat(repeatcounter).trial(finished_trialcounter).Reward = 'Yes';
                    AllData.block(blockcounter).repeat(repeatcounter).trial(finished_trialcounter).Statecode = Statecode;
                    %                     sendapmreward(((blockcounter-1)*8)+trialcounter,1)
                    clc
                    finished_trialcounter=finished_trialcounter+1;
                    correct_inrepeat=correct_inrepeat+1;
                    correctcounter = correctcounter + 1;
                    dataout(outputcounter,1:3) = {outputcounter-blockcounter, correctcounter, 1};
                    %  Correct auditory feedback
                    wavesoundplay('correct.wav',0.6)
                    AllData.block(blockcounter).repeat(repeatcounter).trial(finished_trialcounter-1).Rewardtime = GetSecs;
                    clc
                    dataout(outputcounter,1:3) = {outputcounter,blockcounter, correctcounter}
                    for burst=1:numBurst
                    outputSingleScan(DO,[1,0,0,0,0,0,0,0]);
                  %  WaitSecs(0.1);
                    outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
                    
                    end
           %         intertrial_interval = 2;

                else
                  %  RectionTime = 0;
                  %  [AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,1:3), ...
                  %  AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,4)] = getdata(ai,ai.SamplesAvailable);
                  %  AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).Rewardtime = GetSecs;
                    AllData.block(blockcounter).repeat(repeatcounter).trial(finished_trialcounter).Reward = 'No';
                    AllData.block(blockcounter).repeat(repeatcounter).trial(finished_trialcounter).Statecode = Statecode;
                    %                     sendapmreward(((blockcounter-1)*8)+trialcounter,0)
                    clc
                    dataout(outputcounter,1:3) = {outputcounter,blockcounter, correctcounter}

                    %  Incorrect auditory feedback
               %     Snd('Play',[sin(1:500)],[1000]);
               %     intertrial_interval = 2;
                end
                %                 sendapmmessage(((blockcounter-1)*8)+trialcounter,Deg,datain(7), trialtype)
                %xq 2018 4 23
             %   set(hLine(4), 'XData',(AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,4)- ...
             %       AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(1,4)), ...
             %       'YData', AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,2))
             %   set(hLine(5), 'XData',(AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,4)- ...
             %       AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(1,4)), ...
             %       'YData', AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,1))
                set(hAxes(2),'YLim', [-10 10],'XLim', [0 3])
                set(hAxes(3),'YLim', [-10 10],'XLim', [0 3])
                drawnow
                breaktime = GetSecs;
                
                %  Intertrial inverval
                while ((GetSecs - breaktime) < intertrial_interval) && (BreakState ~=1)
                    eye=inputSingleScan(ai);
                    eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                    eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                    set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                    set(hLine(2), 'XData', eyeX, 'YData', eyeY, 'marker', '+')
                    drawnow
                    BreakState = CheckBreakState;
                end
                if (BreakState == 1)
                    break;
                end
             %   repeatcounter = repeatcounter + 1;
             %   Snd('Quiet');  %  Clear soundcard buffer
            end
           repeatcounter = repeatcounter + 1;
        end
        blockcounter = blockcounter + 1;
    end
catch
    lasterr
end
outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
Screen('CloseAll')
stop(ai)
AllData.endtime = GetSecs;
close(hFig)
save(['C:\Users\CCLAB\Documents\Behavioral_Data\' savename],'AllData');
clear all;
clear global trial_eye_data


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

