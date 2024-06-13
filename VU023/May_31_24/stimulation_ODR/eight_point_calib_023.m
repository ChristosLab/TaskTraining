% TrainODR_023
clear
close all
% warning off all
sca;
daqreset;
% clc
Screen('Preference', 'VisualDebugLevel', 3);
% Screen('OpenWindow', 2, BlackIndex(0));
%%  Version info
version = 'eight_point_calib_023_v0.10_12_14_21' ; % after code changes, change version
%   eight_point_calib_023_v0.10_12_14_21
%   - A new breaktime update is added at the onset fixation maintanence of
%     for each frame ** Actual fixation time in previous versions thus
%     started from frame flip instead of fixation in
%%  Define feature classes
n_class = 8;
stim_radius = 10; % degrees
%   The stimuli are described on a R-hand Cartesian coordinate system in
%   units of degrees of viewing angle
for i = 1:n_class
    current_degree = (i - 1)*360/n_class;
    GeneralVars.ClassStructure(i).frame(1).stim.end = stim_radius.*[cos(current_degree/180*pi), sin(current_degree/180*pi)];
    GeneralVars.ClassStructure(i).Notes = num2str(current_degree);
end
%   Add the center cue
GeneralVars.ClassStructure(n_class + 1).frame(1).stim.end = [0, 0];
GeneralVars.ClassStructure(n_class + 1).Notes = 'center';
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datain(1:4) = [1 0 0 0];    %  Default waiting times for each frame [fixation. cue delay1 sample delay2]
datain(5) = nan;                 %  Trial type
datain(6) = 5;                %  Number of blocks
datain(7) = nan;                %  Stimulus eccentricity
datain(8) = 5;                 %  Radius in degree of fixation window
datain(9) = nan;                 %  Radius in degree of target window
datain(10) = 100;               %  Stimulus luminance as percentage (1 - 100) of color depth (typically 0 - 255)
datain(11) = nan;                %  Helper luminance as percentage (1 - 100) of color depth (typically 0 - 255)
numBurst = 2;

% disp('using default values')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Visual Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vstruct.res = [1920 1080];    % screen resolution
vstruct.siz = [103 57.5];        % screen size in cm
vstruct.dis = 69;             % viewing distance in cm
vstruct.radius = datain(7);   % Stimulus excentricity
intertrial_interval_correct = 2;
intertrial_interval_error   = 2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Name Output File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OutputFileNames = fileoutdlg({'Behavior output file',}, 'Output Files',[1 30],{'test_'});
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
if ~go
    return
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize eye display figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[Figdata, hFig, hAxes, hLine] = InitEyeDisplay;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialize Nidaq board   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

global trial_eye_data trial_eye_timestamp

WaveInitDaqWang
%outputSingleScan(DO,[1,1,1,1,1,1,1,1]);
WaitSecs(0.1);
outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Calculate Pixels/Degree constants and coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[vstruct, Display] = WaveDisplayParams_023(vstruct, datain);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Declare Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FixWindowSize(1,:) = datain(8)*Figdata.xcoord;
FixWindowSize(2,:) = datain(8)*Figdata.ycoord;
TargWindowSize(1,:) = datain(9)*Figdata.xcoord;
TargWindowSize(2,:) = datain(9)*Figdata.ycoord;

totalblocks = datain(6);
BreakState = 0;
outputcounter = 0;
save_counter = 1;
correctcounter = 0;
fixation_counter = 0;
blockcounter = 1;
gate_off_time = .1;
fix_aquisition = 1;
target_aquisition = 0; 
black = BlackIndex(0);
ReactionTime = 0;
totaltrials = numel(GeneralVars.ClassStructure);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixation times in seconds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus Windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[window, f, r, WindowStructure, AllCoordinates] = CreateWindowStructCalib_023(Display, vstruct, GeneralVars.ClassStructure);

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
AllData.parameters.FixAquisition = fix_aquisition;
AllData.parameters.TargetAquisition = target_aquisition;
AllData.synctime = clock;
AllData.starttime = GetSecs;
%channel 8 on for duration of whole trial
%channel 1 on and off for every reward burst
%channel 5 on and off every stimuli appearance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
WaitSecs(10);
% try
    while (BreakState ~= 1) & (blockcounter <= totalblocks)
        trialcounter = 1;
        repeatcounter = 1;
        outputcounter = outputcounter + 1;
        dataout(outputcounter,1:7) = {'Trial' 'Class #' 'Correct' ...
            'Success' '%' 'Notes','State'};
        IndexHist = zeros(1,totaltrials);
        IndexTotl = randperm(length(GeneralVars.ClassStructure));
        CurrentClass = IndexTotl(1);
        
        while (repeatcounter <= totaltrials) & (BreakState ~=1)
            %   New instance of eye data
            outputSingleScan(DO,[0,0,0,0,0,0,1,0]);
            AllData.trials(save_counter).time = GetSecs;
            AllData.trials(save_counter).Class = CurrentClass;
            AllData.outputcounter = outputcounter;
            outputcounter = outputcounter + 1;
            trial_eye_data      = [];
            trial_eye_timestamp = [];
            startBackground(ai);
            WaitSecs(gate_off_time)
            %   Start new listener session on NIDAQ
            %   trial_eye_data
            all_eye=[];
            all_eyetime=[];
            trial_start=GetSecs;
            %%  Trial loop paramters
            %                       {'Fixation'; 'Cue'; 'Delay'; 'Target'}
            %   Required duration of fixation
            frame_time_queue      = datain(1);
            %   Off-screen windows to be copied for each frame
            window_queue          = {WindowStructure(CurrentClass).frame(1).end};
                                 
%              UpdateEyeDisplay(AllCoordinates.fRect, FixWindowSize, AllCoordinates.fRect,vstruct, hLine,'off')

            eye_display_queue         = {... 
                AllCoordinates.cRect(CurrentClass, :, 1), FixWindowSize};
            %   Audio to be played (if any) at the time of window copying (e.g. fixon.wav)
            audio_queue           = {'fix_on.wav', 0.5};
            %   Max lead time allowed between window copying and fixation on
            aqusition_time_queue  = [fix_aquisition];
            %   Requred fixation window center and size in visual degrees (and thus in
            %   R-hand coordinates)
            eye_target_queue      = {...
                GeneralVars.ClassStructure(CurrentClass).frame(1).stim(1).end, [Display.FixationWindow]};    % Target epoch
            timestamp_queue = [];
            Statecode = 0;
            FixState = 0;
            Result = 0;
            Statecode = Statecode + 1;
            %%  Core loop
            for frame_idx = 1:numel(window_queue)
                %   Step 1: Display current window
                outputSingleScan(DO,[0,0,0,0,1,0,1,0]);
                Screen('CopyWindow',window_queue{frame_idx},window);
                Screen(window,'Flip');
                %   Screen updating timestamps ('CueOn', 'TargetOn' etc.)
                timestamp_queue(Statecode) = GetSecs;
                outputSingleScan(DO,[0,0,0,0,0,0,1,0]);
                wavesoundplay(audio_queue{frame_idx, 1}, audio_queue{frame_idx, 2});
                UpdateEyeDisplay(eye_display_queue{frame_idx, 1}, eye_display_queue{frame_idx, 2}, eye_display_queue{frame_idx, 1},vstruct, hLine,'on')
                %
                %   Step 2: Aquire fixation (if allowed)
                breaktime = GetSecs;
                if aqusition_time_queue(frame_idx) > 0
                    FixState = 0;
                    while (FixState <= 0) & ((GetSecs - breaktime) < aqusition_time_queue(frame_idx))
                        DisplayEye(Display, hAxes, hLine);
                    [FixState] = CheckFixation(eye_target_queue{frame_idx, 1}, eye_target_queue{frame_idx, 2}, Display);
                    end
                    if (FixState == 0)
                        break;
                    end
                    %   Aquiring new fixation means +1 Statecode
                    Statecode = Statecode + 1
                    %   Fixation in timestamps
                    timestamp_queue(Statecode) = GetSecs
                end
                %
                %   Step3: Maintain fixation
                breaktime = GetSecs;
                while (FixState == 1) & ((GetSecs - breaktime) < frame_time_queue(frame_idx))
                    DisplayEye(Display, hAxes, hLine);
                    [FixState] = CheckFixation(eye_target_queue{frame_idx, 1}, eye_target_queue{frame_idx, 2}, Display);
                end
                if (FixState == 0)
                    break;
                end
                % Successful maintanance of fixation means +1 Statecode
                Statecode = Statecode + 1;
            end
            %%
            finishStatecode = sum(aqusition_time_queue > 0) + numel(aqusition_time_queue) + 1;
            if Statecode == finishStatecode
                Result = 1;
                fixation_counter = fixation_counter + 1;
                %     wavesoundplay('correct.wav',0.6);
            elseif Statecode == finishStatecode - 2 % Not moving to target location
                Result = 0;
                fixation_counter = fixation_counter + 1;
            elseif Statecode == finishStatecode - 1 % Not staying in target window for long enough
                Result = 0;
                fixation_counter = fixation_counter + 1;
                %     wavesoundplay('wrong.wav',0.6);
            else %  Aborted trial before target epoch
                Result = 0;
                %         wavesoundplay('abort.wav',0.8);
            end
            % End-of-trial screen
            breaktime = GetSecs;
            outputSingleScan(DO,[0,0,0,0,1,0,1,0]);
            Screen('CopyWindow',r,window);
            Screen(window,'Flip');
            outputSingleScan(DO,[0,0,0,0,0,0,1,0]);
            UpdateEyeDisplay(eye_display_queue{frame_idx, 1}, eye_display_queue{frame_idx, 2}, eye_display_queue{frame_idx, 1},vstruct, hLine,'off')
            AllData.trials(save_counter).EndofTrialtime = GetSecs;  %end of trial time, same as fixoff time in passive task
            AllData.trials(save_counter).timestamp_queue = timestamp_queue;
%             clc
            AllData.trials(save_counter).Statecode = Statecode;
            if Result == 1
                AllData.trials(save_counter).Reward = 'Yes';
                correctcounter = correctcounter + 1;
                dataout(outputcounter,1:7) = {outputcounter-blockcounter, CurrentClass,correctcounter, 1, correctcounter/fixation_counter,GeneralVars.ClassStructure(CurrentClass).Notes,Statecode}
                for burst=1:numBurst
                    outputSingleScan(DO, [1 0 0 0 0 0 1 0]);
                    outputSingleScan(DO, [0 0 0 0 0 0 1 0]);
                    WaitSecs(0.75);
                end
                intertrial_interval = intertrial_interval_correct-gate_off_time;
                repeatcounter = repeatcounter + 1;
                IndexHist(CurrentClass) = CurrentClass;
            else
                AllData.trials(save_counter).Reward = 'No';
                dataout(outputcounter,1:7) = {outputcounter-blockcounter, CurrentClass, correctcounter, 0,correctcounter/fixation_counter,GeneralVars.ClassStructure(CurrentClass).Notes,Statecode}
                intertrial_interval = intertrial_interval_error-gate_off_time;
            end
            %   Logging NIDAQ listener output
            all_eye     = trial_eye_data;
            all_eyetime = trial_eye_timestamp;
            %   Stops and flushes the NIDAQ listener until the next
            %   trial
            %   all_eyetime now starts at 0 each trial
            eyeX = (((all_eye(:,1)-Display.Xscalecenter).*Display.Xscale));
            eyeY = (((all_eye(:,2)-Display.Yscalecenter).*Display.Yscale));
            set(hLine(4), 'XData',all_eyetime,...
                'YData', eyeX);
            set(hLine(5), 'XData',all_eyetime,...
                'YData', eyeY);
            set(hAxes(2),'YLim', [-15 15],'XLim', [0 sum(datain(1:4)) + fix_aquisition + target_aquisition]);
            set(hAxes(3),'YLim', [-15 15],'XLim', [0 sum(datain(1:4)) + fix_aquisition + target_aquisition]);
            drawnow
            %   Remaining trial shuffling
            IndexTotl = randperm(totaltrials);
            IndexTemp = IndexTotl(~ismember(IndexTotl,IndexHist));
            if ~isempty(IndexTemp)
                CurrentClass = IndexTemp(1)
            end
            outputSingleScan(DO, [0 0 0 0 0 0 0 0]);
            Screen(window,'FillRect',black)  % Clear screen
            %  Intertrial inverval
            while ((GetSecs - breaktime) < intertrial_interval) & (BreakState ~=1)
                DisplayEye(Display, hAxes, hLine);
                BreakState = CheckBreakState;
            end
            %   Do not log eye data until end of trial
            all_eye     = trial_eye_data;
            all_eyetime = trial_eye_timestamp;
            AllData.trials(save_counter).eye_time = all_eyetime;
            AllData.trials(save_counter).eye_loc = all_eye;
            stop(ai);
            if (BreakState == 1)
                break;
            end
            trialcounter = trialcounter + 1;
            save_counter = save_counter + 1;
        end
        blockcounter = blockcounter + 1;
    end
% catch
%     lasterror
% end
save(['C:\Users\CCLAB\Documents\MATLAB\Behavioral_Data\' savename],'AllData');
% clear
%CleanUp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [Figdata, hFig, hAxes, hLine] = InitEyeDisplay
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
    'Position'          , [0.08 0.3 0.55 0.55], ...
    'Parent'            , hFig, ...
    'XLim'              , [-20 20], ...
    'YLim'              , [-20 20] ...
    );
i=1:33;
Figdata.xcoord(i)=cos(i*pi/16);
Figdata.ycoord(i)=sin(i*pi/16);
hLine(3) = plot(1*Figdata.xcoord,1*Figdata.ycoord,'Parent',hAxes(1)); % fixation window
hLine(2) = line('XData',0,'YData',0,'marker','+');  % eye position
hLine(1) = line('XData',0,'YData',0,'marker','s'); % stimulus position
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

Figdata.figure = hFig;
Figdata.axes = hAxes;
Figdata.line = hLine;
set(hFig,'Visible','on');
end
%
function UpdateEyeDisplay(StimulusCoordinates, FixWindow, FixPosition, vstruct, hLine,visability)
xStimDisplay = (((StimulusCoordinates(1,1)+StimulusCoordinates(1,3))/2)-(vstruct.res(1)/2))*vstruct.degpix(1);
xWindowPosition = (((FixPosition(1,1)+FixPosition(1,3))/2)-(vstruct.res(1)/2))*vstruct.degpix(1);
yStimDisplay = ((((StimulusCoordinates(1,2)+StimulusCoordinates(1,4))/2)-(vstruct.res(2)/2))*vstruct.degpix(2))*-1;
yWindowPosition = ((((FixPosition(1,2)+FixPosition(1,4))/2)-(vstruct.res(2)/2))*vstruct.degpix(2))*-1;
xWindowDisplay = FixWindow(1,:)+ xWindowPosition;
yWindowDisplay = FixWindow(2,:)+ yWindowPosition;
set(hLine(1),'XData',xStimDisplay,'YData',yStimDisplay,'Visible',visability);
set(hLine(3),'XData',xWindowDisplay,'YData',yWindowDisplay,'Visible',visability);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine)
global trial_eye_data
% trial_eye_data
% eye=inputSingleScan(ai);
if isempty(trial_eye_data)
    eye =[0, 0];
else
    eye = trial_eye_data(end, :);

end
eyeX = (((eye(1,1)-Display.Xscalecenter)*Display.Xscale));
eyeY = (((eye(1,2)-Display.Yscalecenter)*Display.Yscale));
set(hAxes(1), 'XLim', [-20 20],'YLim', [-20 20]);
set(hLine(2), 'XData', eyeX, 'YData', eyeY); % eye position
drawnow
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FixState] = CheckFixation(cCenter, WindowRadius, Display)
%  CheckFixation is a subfunction that inputs rectangular coordinates and
%  duration to check that the mouse coordinates stay within the inputed
%  rectangle for the duration and send back to the main function whether
%  the subject was successful or errored or clicked the mouse button.
global trial_eye_data
% trial_eye_data
% eye=inputSingleScan(ai);
if isempty(trial_eye_data)
    eye =[0, 0];
else
    eye = trial_eye_data(end, :);

end
eyeX = (((eye(1,1)-Display.Xscalecenter)*Display.Xscale));
eyeY = (((eye(1,2)-Display.Yscalecenter)*Display.Yscale));

%  Compare distance from mouse coordinates from inputed window center
if (((cCenter(1,1)-eyeX)^2)+((cCenter(1,2)-eyeY)^2))^.5 <= WindowRadius
    %  If distance between mouse and window is less than inputted radius,
    %  then mouse is in correct position
    FixState = 1;
else
    %  If not then it is outside of the radius
    FixState = 0;
end
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
end