%  Balbir Singh 10-30-19
%     Now user can only break out of the program during intertrial interval

% only display 8 stimulus in a circle for training 
% VBLSyncTest  %synchronization test
clc;
clear all;
close all;
[mousex,mousey] = GetMouse;
warning off all;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% if nargin<1
    datain(1:4) = [1.5 0.5 0.5 0.2];    %  Default waiting times for each frame %%fixation, cue, delay
    datain(5) = 4;                 %  Trial type
    datain(6) = 40;                %  Number of blocks
    datain(7) = 10;                %  Stimulus eccentricity
    datain(8) = 5; %  Radius in degrees of fixation window
    datain(9) = 6;%  Radius in degrees of target window
    datain(10) = 100;              %  Stimulus Luminance
    gray2 =30;  %30;                      % Luminance of second stimulus (for training purposes)
    datasin = 'TEMP';
    burst_amount = 3;
    aquisition_time = 2.0;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Visual Settings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    vstruct.res = [1280 1024];    % screen resolution
    vstruct.siz = [61 46];        % screen size in cm  %[61 55]
    vstruct.dis = 68;             % viewing distance in cm
    vstruct.voltage = 3.5;        % Analog to degree conversion constant
    vstruct.radius = datain(7);   % Stimulus excentricity
    vstruct.angs = [360 45 90 135 180 225 270 315];  % Stimulus angles
    vstruct.angs2= [1:8]; 
% else
%     % arguments exist from Gui, use them
%     dataintemp = varargin(1);      % varargin is cell and convert to structure
%     datain(1:11) = dataintemp{1,1};
%     datasin = varargin{2};
%     vstruct = varargin{3};
% end


correct_class(1:8)=ones(1,8)*0;
errors(1:8) =0;
errors2(1:8) =0;    


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize eye display figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Figdata, hFig, hAxes, hLine] = WaveInitEyeDisplay;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialize Nidaq board   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% WaveInitDaq_B

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Calculate Pixels/Degree constants and coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[vstruct, Display] = WaveDisplayParams(vstruct, datain);  % make circle 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Declare Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% filename = ['/DataFiles/',datasin,'.apm'];
FixWindowSize(1,:) = datain(8)*Figdata.xcoord;
FixWindowSize(2,:) = datain(8)*Figdata.ycoord;
TarWindowSize(1,:) = datain(9)*Figdata.xcoord;
TarWindowSize(2,:) = datain(9)*Figdata.ycoord;
totalblocks = datain(6);
totaltrials = length(vstruct.angs);
consecutive_correct = 0;
BreakState = 0;
outputcounter = 0;
correctcounter = 0;
blockcounter = 1;
intertrial_interval_correct = 2;
intertrial_interval_error   = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixation times in seconds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

frame1 = datain(1);  %fixation time for fixation point
frame2 = datain(2);  %fixation time for fix + target display
frame3 = datain(3);  %fixation time for target alone display
frame4 = datain(4); % fixation time on target until reward

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Trial type, 1 = visual, 2 = memory, 3 = No Saccade
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

trialtype = datain(5);

switch trialtype
    case 1
        totalframes = 4;
    case 2
        totalframes = 4;
    case 3
        totalframes = 3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %  Declare coordinates of 8 points and fixation point
% %  Coordinates in pixels on 1280/1024 32 bit display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

fCenter = [Display.centerX,Display.centerY];
fRect = [Display.fX1,Display.fY1,Display.fX2,Display.fY2];
for n = 1:8
    tCenter(n,:) = Display.pixs(n,:)+[Display.centerX Display.centerY];
    wRect(n,:) =  [Display.X1+(Display.pixs(n,1)),Display.Y1 + ...
            (Display.pixs(n,2)),Display.X2+(Display.pixs(n,1)),   ...
            Display.Y2+(Display.pixs(n,2))];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate 8 random integers and * 45 for shuffled degrees for each trial
% Then generate two opposing random points in the 2nd and 3rd dimension of Seq
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


RandYN = rand(totalblocks,8);
for n = 1:totalblocks
    Seq(n,:,1) = vstruct.angs2(randperm(8)); % sample display
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate variable to store data to be saved as filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

white=WhiteIndex(0);
black=BlackIndex(0);
gray = datain(10);
[window] = Screen(0,'OpenWindow',black,[],32);
% Screen('CloseALL')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Make offscreen windows  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Fixation

f = Screen(window,'OpenOffscreenWindow',black,[],32);
Screen(f,'FillRect',white,fRect);
% screen(f, 'FillRect', white, [0,0,50,30])
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus + Fixation (sf) and Stimulus alone (s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n = 1:8
    sf(n) = Screen(window,'OpenOffscreenWindow',black,[],32);
    Screen(sf(n),'FillRect',white,fRect);
    Screen(sf(n),'FillRect', gray,wRect(n,:));
    %     screen(sf(n), 'FillRect', white, [0,0,50,30])
    s(n) = Screen(window,'OpenOffscreenWindow',black,[],32); 
    Screen(s(n),'FillRect',gray,wRect(n,:));
    %     screen(s(n), 'FillRect', white, [0,0,50,30])
    secstim(n)= Screen(window,'OpenOffscreenWindow',black,[],32); 
    Screen(secstim(n),'FillRect',gray2,wRect(n,:));
end
datain(7)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% APM Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
% APMConn = ApmSendFilename(filename);
% APMStartRecording

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AI.startBackground
WaitSecs(.1)
AllData.synctime  = clock;
AllData.starttime = GetSecs;

try
    while (BreakState ~= 1) & (blockcounter <= totalblocks)
        trialcounter = 1;
        AllData.block(blockcounter).time = GetSecs;
        outputcounter                    = outputcounter + 1;
        dataout(outputcounter,1:8)       = {'Trial' 'Trial Type' 'Correct' 'Success' 'All %'...
                                            'All_delayerror %' 'Current Class %' 'Reaction Time'}
    end
    
catch
    lasterr        
end

