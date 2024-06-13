function ActiveMNM_lab3(varargin)

[mousex,mousey] = GetMouse;
warning off all
Screen('closeall');
daqreset;
clc
load('C:\Users\CCLAB\Documents\MATLAB\inuse\Feature_classes.mat');

%SizeofStim = 2;% XQ, size 2 degree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1                      %  If there are no arguments given
    datain(1:4) = [1 .5 1.5 .5];    %  Default waiting times for each frame
    datain(5) = 3;                 %  Trial type
    datain(6) = 5;                %  Number of blocks
    datain(7) = 0;                %  Stimulus eccentricity, not used here
    datain(8) = 3;                 %  Radius in degree of fixation window
    datain(9) = 7.5;                 %  Radius in degree of target window
    datain(10) = 100;              %  Luminance
    datain(5)=0.5;
    datasin = 'fiona';

  %  disp('using default values')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Visual Settings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    vstruct.res = [1920 1080];    % screen resolution
    vstruct.siz = [103 57.5];        % screen size in cm
    vstruct.dis = 69;             % viewing distance in cm
    vstruct.radius = datain(7);   % Stimulus excentricity
    numBurst = 2;  
else
    % arguments exist from Gui, use them
    dataintemp = varargin(1);      % varargin is cell and convert to structure
    datain(1:11) = dataintemp{1,1};
    MNM = varargin{4};
    datasin = varargin{2};
    vstruct = varargin{3};
end
MNM = 'Both';
Xscale = 5.7;
Xscalecenter = 0;
Yscale = 3.8;
Yscalecenter = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Name Output File 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OutputFileNames = fileoutdlg({'Behavior output file',}, 'Output Files',[1 30],{'Fiona_'});
if isempty(OutputFileNames)
    return;
else
    savename = OutputFileNames{1};
end

go = 1;
filenamecheck = ['C:\Users\CCLAB\Documents\MATLAB\Behavioral_Data\' savename '.mat'];
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
    cd C:\Users\CCLAB\Documents\MATLAB\inuse\
else
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize eye display figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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
FixWindow=datain(8)*[xcoord;ycoord];
hLine(3) = plot(1*xcoord,1*ycoord,'Parent',hAxes(1));
hLine(2) = line('XData',0,'YData',0,'marker','+');  % eye position
hLine(1) = line('XData',0,'YData',0,'marker','s'); % stim position
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

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialize Nidaq board   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WaveInitDaq
%outputSingleScan(DO,[1,1,1,1,1,1,1,1]);
%WaitSecs(0.1);
outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Calculate Pixels/Degree constants and coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[vstruct, Display] = WaveDisplayParams(vstruct, datain);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Declare Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

version = 'ActivefeatureMNM 10NOV20' ; % after code changes, change version
%filename = ['/DataFiles/ELV/',datasin,'.apm'];
%FixWindowSize(1,:) = datain(8)*Figdata.xcoord;
%FixWindowSize(2,:) = datain(8)*Figdata.ycoord;
%TargWindowSize(1,:) = datain(9)*Figdata.xcoord;
%TargWindowSize(2,:) = datain(9)*Figdata.ycoord;
totalblocks = datain(6);
switch MNM   
    case 'Match'
        totaltrials = length(GeneralVars.ClassStructure);
        realtrials = totaltrials/2;  
    case 'NonMatch'
        totaltrials = length(GeneralVars.ClassStructure);
        realtrials = totaltrials/2;
    case 'Both'
        totaltrials = length(GeneralVars.ClassStructure);
        realtrials = totaltrials;
end
BreakState = 0;
outputcounter = 0;
save_counter = 1;
correctcounter = 0;
blockcounter = 1;
gate_off_time = 1;
intertrial_interval_correct = 3.5;
intertrial_interval_error   = 3.5;
aquisition_time = 2;
Target_aquisition_time = .5;
black = BlackIndex(0);
white = WhiteIndex(0);
gray = datain(10);
ReactionTime = 0;
subWrong = 1;
target_error = 0;
p_correct = 0;
p_correctcounter = 0;
t_correct = 0;
t_correctcounter(1:totaltrials) = 0;
t_errorcounter(1:totaltrials) = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixation times in seconds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    frametime = GeneralVars.ClassStructure(1).frametime; % check if classstructure contains frametime information
    using_new_classes = 1;
catch
    using_new_classes = 0;
    frametime = [datain(1:3) datain(2) datain(3) datain(4)];  %fixation time for fixation point
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus Windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[window, f, r, WindowStructure, AllCoordinates] = CreateWindowStruct5(Display, vstruct, GeneralVars.ClassStructure,MNM);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%start(ai)
AllData.parameters.Display = Display;
AllData.version = version;
AllData.ClassStructure = GeneralVars.ClassStructure;
AllData.parameters.fixationDuration = datain(1);
AllData.parameters.stimulusDuration = datain(2);
AllData.parameters.delayDuration = datain(3);
AllData.parameters.targetDuration = datain(4);
AllData.parameters.totalBlocks = datain(6);
AllData.parameters.stimulusEccentricity = datain(7);
AllData.parameters.fixationWindow = datain(8);
AllData.parameters.targetWindow = datain(9);
AllData.parameters.luminance = datain(10);
AllData.parameters.vstruct = vstruct;
AllData.parameters.ITI_Correct = intertrial_interval_correct;
AllData.parameters.ITI_Error   = intertrial_interval_error;
AllData.parameters.FixAquisition = aquisition_time;
AllData.synctime = clock;
AllData.starttime = GetSecs;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

try
    while (BreakState ~= 1) & (blockcounter <= totalblocks)
        trialcounter = 1;
        repeatcounter = 1;
        outputcounter = outputcounter + 1;
        dataout(outputcounter,1:7) = {'Trial' 'Class #' 'Correct' ...
                'Success' '%' 'Notes','Class %'};
        IndexHist = zeros(1,totaltrials); %totaltrials is  number of trials in one block
        IndexTotl = randperm(length(GeneralVars.ClassStructure));
        switch MNM
            case 'Match' %index to use when only use match or nonmatch trials
                IndexTotl = IndexTotl(rem(IndexTotl,4) == 1 | rem(IndexTotl,4) == 2);
            case 'NonMatch'
                IndexTotl = IndexTotl(rem(IndexTotl,4) == 3 | rem(IndexTotl,4) == 0);
        end
        CurrentClass = IndexTotl(1);
        while (repeatcounter <= realtrials) & (BreakState ~=1)            
            WaitSecs(gate_off_time);% why need gate off?
        %    flushdata(ai)
            outputSingleScan(DO,[0,0,0,0,0,0,0,1]);
            AllData.trials(save_counter).time = GetSecs;
            AllData.trials(save_counter).Class = CurrentClass;
            AllData.outputcounter = outputcounter;
            outputcounter = outputcounter + 1;
    %        if using_new_classes
    %            frametime = GeneralVars.ClassStructure(CurrentClass).frametime;
    %        end 
            all_eye=[];
            all_eyetime=[];
            trial_start=GetSecs;
            while 1
                Statecode = 1;
                FixState = 0;
                Result = 0;
                %  Display Fixation
                Screen(window,'WaitBlanking');
                outputSingleScan(DO,[0,0,0,0,1,0,0,1]);
                Screen('CopyWindow',f,window);
                Screen(window,'Flip');
                AllData.trials(save_counter).FixOn = GetSecs;
                outputSingleScan(DO,[0,0,0,0,0,0,0,1]);
                wavesoundplay('fix_on.wav',0.4);
                WaveUpdateEyeDisplay(AllCoordinates.fRect, FixWindow, AllCoordinates.fRect,vstruct, hLine,'on')
              %  xfixwindow = (datain(8)*xcoord)+AllCoordinates.fCenter(1);
              %  yfixwindow = (datain(8)*ycoord)+AllCoordinates.fCenter(2);
              %  set(hLine(1),'XData',AllCoordinates.fCenter(1),'YData',AllCoordinates.fCenter(1),'Visible', 'on'); % stimulus position
              %  set(hLine(3),'XData',xfixwindow,'YData',yfixwindow); 
                breaktime = GetSecs;
                %  Give subject 2 seconds to move to fixation window
                while (FixState <= 0) & ((GetSecs - breaktime) < aquisition_time)
                    eye=inputSingleScan(ai);
                    eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                    eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                    all_eyetime=[all_eyetime,GetSecs];
                    all_eye=[all_eye;[eyeX,eyeY]];
                    set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                    set(hLine(2), 'XData', eyeX, 'YData', eyeY); % eye position
                    drawnow   
                    degree_fcenter=[1,-1].*(AllCoordinates.fCenter-vstruct.res/2).*vstruct.degpix;
                    [FixState] = CheckFixation(degree_fcenter, Display.FixationWindow,Xscale,Yscale,ai);
                end
                AllData.trials(save_counter).Fixin = GetSecs;
                %  If subject didn't get to window within 2 seconds, or break
                %  button was pushed, break out of trial
                if FixState == 0
                    wavesoundplay('abort.wav',0.8);
                    break;
                end
                Statecode = 2;
                breaktime = GetSecs;
                %  Eye must stay within fixation window for frame1 time
                while (FixState == 1) & ((GetSecs - breaktime) < frametime(1))
                    eye=inputSingleScan(ai);
                    eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                    eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                    all_eyetime=[all_eyetime,GetSecs];
                    all_eye=[all_eye;[eyeX,eyeY]];
                    set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                    set(hLine(2), 'XData', eyeX, 'YData', eyeY); % eye position
                    drawnow 
                    degree_fcenter=[1,-1].*(AllCoordinates.fCenter-vstruct.res/2).*vstruct.degpix;
                    [FixState] = CheckFixation(degree_fcenter, Display.FixationWindow,Xscale,Yscale,ai);
                end            
                if FixState == 0
                    wavesoundplay('abort.wav',0.8);
                    break;
                end
                Statecode = 3;
                %  Display Fixation plus stimulus                
                Screen(window,'WaitBlanking');                   
                outputSingleScan(DO,[0,0,0,0,1,0,0,1]);
                Screen('CopyWindow',WindowStructure(CurrentClass).frame(1).end,window);
                Screen(window,'Flip');
                outputSingleScan(DO,[0,0,0,0,0,0,0,1]);
                WaveUpdateEyeDisplay(AllCoordinates.cRect(CurrentClass,:,1), FixWindow, AllCoordinates.fRect,vstruct, hLine,'on')
                breaktime = GetSecs;
                %  Check that eye stays within fixation window for frame2
                while (FixState == 1) & ((GetSecs - breaktime) < frametime(2))
                    eye=inputSingleScan(ai);
                    eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                    eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                    all_eyetime=[all_eyetime,GetSecs];
                    all_eye=[all_eye;[eyeX,eyeY]];
                    set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                    set(hLine(2), 'XData', eyeX, 'YData', eyeY); % eye position
                    drawnow 
                    degree_fcenter=[1,-1].*(AllCoordinates.fCenter-vstruct.res/2).*vstruct.degpix;
                    [FixState] = CheckFixation(degree_fcenter, Display.FixationWindow,Xscale,Yscale,ai);
                end
                if FixState == 0
                    wavesoundplay('abort.wav',0.8);
                    break;
                end
                Statecode = 4;
                %  Display fixation only      
%                 if frametime(3) > 0
                    Screen(window,'WaitBlanking');
                    outputSingleScan(DO,[0,0,0,0,1,0,0,1]);
                    Screen('CopyWindow',f,window);
                    Screen(window,'Flip');
                    outputSingleScan(DO,[0,0,0,0,0,0,0,1]);
                    WaveUpdateEyeDisplay(AllCoordinates.fRect, FixWindow, AllCoordinates.fRect,vstruct, hLine,'on')
                    breaktime = GetSecs;
                    %  Make sure eye stays in window for frame3 time
                    while (FixState == 1) & ((GetSecs - breaktime) < frametime(3))
                         eye=inputSingleScan(ai);
                         eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                         eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                         all_eyetime=[all_eyetime,GetSecs];
                         all_eye=[all_eye;[eyeX,eyeY]];
                         set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                         set(hLine(2), 'XData', eyeX, 'YData', eyeY); % eye position
                         drawnow 
                         degree_fcenter=[1,-1].*(AllCoordinates.fCenter-vstruct.res/2).*vstruct.degpix;
                         [FixState] = CheckFixation(degree_fcenter, Display.FixationWindow,Xscale,Yscale,ai);
                    end
                    if FixState == 0
                        wavesoundplay('abort.wav',0.8);
                        break;
                    end        
%                 end
                if frametime(4) ~= 0
                    %  Display 2nd Fixation plus stimulus                
                    Screen(window,'WaitBlanking');                
                    outputSingleScan(DO,[0,0,0,0,1,0,0,1]);
                    Screen('CopyWindow',WindowStructure(CurrentClass).frame(2).end,window);
                    Screen(window,'Flip');
                    outputSingleScan(DO,[0,0,0,0,0,0,0,1]);
                    WaveUpdateEyeDisplay(AllCoordinates.cRect(CurrentClass,:,2), FixWindow, AllCoordinates.fRect,vstruct, hLine,'on')
                    breaktime = GetSecs;
                    %  Check that eye stays within fixation window for frame2
                    while (FixState == 1) & ((GetSecs - breaktime) < frametime(4))
                         eye=inputSingleScan(ai);
                         eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                         eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                         all_eyetime=[all_eyetime,GetSecs];
                         all_eye=[all_eye;[eyeX,eyeY]];
                         set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                         set(hLine(2), 'XData', eyeX, 'YData', eyeY); % eye position
                         drawnow
                         degree_fcenter=[1,-1].*(AllCoordinates.fCenter-vstruct.res/2).*vstruct.degpix;
                         [FixState] = CheckFixation(degree_fcenter, Display.FixationWindow,Xscale,Yscale,ai);
                    end
                    if FixState == 0
                        wavesoundplay('abort.wav',0.8);
                        break;
                    end
                    Statecode = 5;
                    %  Display fixation only
                    Screen(window,'WaitBlanking');
                    outputSingleScan(DO,[0,0,0,0,1,0,0,1]);
                    Screen('CopyWindow',f,window);
                    Screen(window,'Flip');
                    outputSingleScan(DO,[0,0,0,0,0,0,0,1]);
                    WaveUpdateEyeDisplay(AllCoordinates.fRect, FixWindow, AllCoordinates.fRect,vstruct, hLine,'on')
                    breaktime = GetSecs;
                    %  Make sure eye stays in window for frame3 time
                    while (FixState == 1) & ((GetSecs - breaktime) < frametime(5))
                         eye=inputSingleScan(ai);
                         eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                         eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                         all_eyetime=[all_eyetime,GetSecs];
                         all_eye=[all_eye;[eyeX,eyeY]];
                         set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                         set(hLine(2), 'XData', eyeX, 'YData', eyeY); % eye position
                         drawnow 
                         degree_fcenter=[1,-1].*(AllCoordinates.fCenter-vstruct.res/2).*vstruct.degpix;                         
                         [FixState] = CheckFixation(degree_fcenter, Display.FixationWindow,Xscale,Yscale,ai);
                    end
                    if FixState == 0
                        wavesoundplay('abort.wav',0.8);
                        break;
                    end
                    Statecode = 6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Saccading to Target.  Display target and wait for
                    % monkey to saccade to target.
                    FixState = 0;
                    Screen(window,'WaitBlanking');                
                    outputSingleScan(DO,[0,0,0,0,1,0,0,1]);
                    Screen('CopyWindow',WindowStructure(CurrentClass).frame(3).end,window);  
                    Screen(window,'Flip');
                    outputSingleScan(DO,[0,0,0,0,0,0,0,1]);
                    WaveUpdateEyeDisplay(AllCoordinates.cRect(CurrentClass,:,3), FixWindow, AllCoordinates.cRect(CurrentClass,:,3),vstruct, hLine,'on')
                    breaktime = GetSecs;
                    %  Give subject 2 seconds to move to fixation window
                    while (FixState <= 0) & ((GetSecs - breaktime) < Target_aquisition_time)
                         eye=inputSingleScan(ai);
                         eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                         eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                         all_eyetime=[all_eyetime,GetSecs];
                         all_eye=[all_eye;[eyeX,eyeY]];
                         set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                         set(hLine(2), 'XData', eyeX, 'YData', eyeY); % eye position
                         drawnow
                         degree_fcenter=[1,-1].*(AllCoordinates.cRect(CurrentClass,:,3)-vstruct.res/2).*vstruct.degpix;                         
                        [FixState] = CheckFixation(degree_fcenter, Display.TargetWindow,Xscale,Yscale,ai);
                    end                    
                    breaktime = GetSecs;
                    %  Eye must stay within target window for frametime(6)
                    while (FixState == 1) & ((GetSecs - breaktime) < frametime(6))
                         eye=inputSingleScan(ai);
                         eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                         eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                         all_eyetime=[all_eyetime,GetSecs];
                         all_eye=[all_eye;[eyeX,eyeY]];
                         set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                         set(hLine(2), 'XData', eyeX, 'YData', eyeY); % eye position
                         drawnow
                         degree_fcenter=[1,-1].*(AllCoordinates.cRect(CurrentClass,:,3)-vstruct.res/2).*vstruct.degpix;                         
                        [FixState] = CheckFixation(degree_fcenter, Display.TargetWindow,Xscale,Yscale,ai);
                    end            
                    if FixState == 0
                        wavesoundplay('abort.wav',0.8);
                        break;
                    end
                    Statecode = 7;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                end
                %  If this point in the code is reached, the subject completed
                %  the trial successfully and Result is changed from 0 to 1
                Result = 1;
                break
            end
            breaktime = GetSecs;
            Screen(window,'FillRect',black)  % Clear screen
            Screen(window,'Flip');
            outputSingleScan(DO,[0,0,0,0,1,0,0,1]);
            AllData.trials(save_counter).FixOff = GetSecs;           
            outputSingleScan(DO,[0,0,0,0,0,0,0,1]);
            WaveUpdateEyeDisplay(AllCoordinates.fRect, FixWindow, AllCoordinates.fRect,vstruct, hLine,'off')
            AllData.trials(save_counter).EndofTrialtime = GetSecs;
            clc
            AllData.trials(save_counter).Statecode = Statecode;
            if Result == 1
                p_correctcounter = p_correctcounter + 1;
                t_correctcounter(CurrentClass) = t_correctcounter(CurrentClass) + 1;
                p_correct = round(p_correctcounter/(target_error+p_correctcounter)*100);
                t_correct = round(t_correctcounter(CurrentClass)/(t_correctcounter(CurrentClass)+t_errorcounter(CurrentClass))*100);
                AllData.trials(save_counter).Reward = 'Yes';
                correctcounter = correctcounter + 1;
                dataout(outputcounter,1:7) = {outputcounter-blockcounter, CurrentClass,correctcounter, 1,p_correct,GeneralVars.ClassStructure(CurrentClass).Notes,t_correct}
                %  Correct auditory feedback            
                Screen('CopyWindow',r,window); 
                Screen(window,'Flip');
                wavesoundplay('correct.wav',0.6);
                for burst=1:numBurst
                outputSingleScan(DO, [1 0 0 0 0 0 0 1]);
                outputSingleScan(DO, [0 0 0 0 0 0 0 1]);
                WaitSecs(0.75);
                end

                intertrial_interval = intertrial_interval_correct-gate_off_time;
                repeatcounter = repeatcounter + 1;
                IndexHist(CurrentClass) = CurrentClass;
            else
                if Statecode == 6
                    intertrial_interval_error   = 2.5;
                    target_error = target_error + 1;
                    p_correct = round(p_correctcounter/(target_error+p_correctcounter)*100);
                    t_errorcounter(CurrentClass) = t_errorcounter(CurrentClass) + 1;
                elseif Statecode == 1
%                     intertrial_interval_error   = 10;
                else                   
                    intertrial_interval_error   = 2.5;
                end
                t_correct = round(t_correctcounter(CurrentClass)/(t_correctcounter(CurrentClass)+t_errorcounter(CurrentClass))*100);
                AllData.trials(save_counter).Reward = 'No';                
                dataout(outputcounter,1:7) = {outputcounter-blockcounter, CurrentClass, correctcounter, 0,p_correct,GeneralVars.ClassStructure(CurrentClass).Notes,t_correct}                   
                %  Incorrect auditory feedback
                wavesoundplay('wrong.wav',0.6);               
                intertrial_interval = intertrial_interval_error-gate_off_time;
            end
           % waitsecs(subWrong);
                set(hLine(4), 'XData',all_eyetime-trial_start,...
                    'YData', all_eye(:,1));
                set(hLine(5), 'XData',all_eyetime-trial_start,...
                    'YData', all_eye(:,2));
                set(hAxes(2),'YLim', [-15 15],'XLim', [0 sum(datain(1:4))+2*aquisition_time]);
                set(hAxes(3),'YLim', [-15 15],'XLim', [0 sum(datain(1:4))+2*aquisition_time]);
                drawnow
                breaktime = GetSecs;
                AllData.trials(save_counter).eye_time = all_eyetime;
                AllData.trials(save_counter).eye_loc = all_eye;
            IndexTotl = randperm(totaltrials);
            switch MNM
                case 'Match'
                    IndexTotl = IndexTotl(rem(IndexTotl,4) == 1 | rem(IndexTotl,4) == 2);
                case 'NonMatch'
                    IndexTotl = IndexTotl(rem(IndexTotl,4) == 3 | rem(IndexTotl,4) == 0);
            end
            IndexTemp = IndexTotl(~ismember(IndexTotl,IndexHist));
            if ~isempty(IndexTemp)
                CurrentClass = IndexTemp(1)
            end
            outputSingleScan(DO, [0 0 0 0 0 0 0 0]);
            Screen(window,'FillRect',black)  % Clear screen
            Screen(window,'Flip');
            %  Intertrial inverval
            while ((GetSecs - breaktime) < intertrial_interval) & (BreakState ~=1)
                eye=inputSingleScan(ai);
                eyeX = -1*(((eye(1,1)-Xscalecenter)*Xscale));
                eyeY = (((eye(1,2)-Yscalecenter)*Yscale));
                set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                set(hLine(2), 'XData', eyeX, 'YData', eyeY); % eye position
                drawnow
                BreakState = CheckBreakState;
            end
            if (BreakState == 1)
                break;
            end
            trialcounter = trialcounter + 1;
            save_counter = save_counter + 1;
        end
        blockcounter = blockcounter + 1;
    end
catch
    lasterr
end
save(['C:\Users\CCLAB\Documents\MATLAB\Behavioral_Data\' savename],'AllData');
clear
%CleanUp


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WaveUpdateEyeDisplay(StimulusCoordinates, FixWindow, FixPosition, vstruct, hLine,visability)
xStimDisplay = (((StimulusCoordinates(1,1)+StimulusCoordinates(1,3))/2)-(vstruct.res(1)/2))*vstruct.degpix(1);
xWindowPosition = (((FixPosition(1,1)+FixPosition(1,3))/2)-(vstruct.res(1)/2))*vstruct.degpix(1);
yStimDisplay = ((((StimulusCoordinates(1,2)+StimulusCoordinates(1,4))/2)-(vstruct.res(2)/2))*vstruct.degpix(2))*-1;
yWindowPosition = ((((FixPosition(1,2)+FixPosition(1,4))/2)-(vstruct.res(2)/2))*vstruct.degpix(2))*-1;
xWindowDisplay = FixWindow(1,:)+ xWindowPosition;
yWindowDisplay = FixWindow(2,:)+ yWindowPosition;
set(hLine(1),'XData',xStimDisplay,'YData',yStimDisplay,'Visible',visability); % stimulus position
set(hLine(3),'XData',xWindowDisplay,'YData',yWindowDisplay,'Visible',visability);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%function [eyeX, eyeY] = DisplayEye(hAxes, hLine, ai)

%eye=inputSingleScan(ai);
%eyeX = -1*(((eye(1,1)-0)*Xscale));
%eyeY = (((eye(1,2)-0)*Yscale));
%set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);    
%set(hLine(2), 'XData', eyeX, 'YData', eyeY); % eye position
%drawnow


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%,%%%%%%%%%%%%%%%%
function [FixState,BreakState] = CheckFixation(cCenter, WindowRadius,Xscale,Yscale,ai)
%  CheckFixation is a subfunction that inputs rectangular coordinates and
%  duration to check that the mouse coordinates stay within the inputed
%  rectangle for the duration and send back to the main function whether 
%  the subject was successful or errored or clicked the mouse button.  

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

[MouseX, MouseY, Breakbutton] = GetMouse;
 
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

