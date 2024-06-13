% RecordODR_030
% Based on TrainODR_030.
clear
close all
% warning off all
sca;
daqreset;
% clc
Screen('Preference', 'VisualDebugLevel', 3);
% Screen('OpenWindow', 2, BlackIndex(0));
%%  Version info
version = 'RecordODR_Opto_030_v0.4' ; % after code changes, change version
%   Fixed bug: Added default value of variable "currentGoodStim" at
%   beginning of each trial. Previously, a break in fixation during a
%   potentially valid trial (Statecode < 3) counted towards a true valid
%   trial. No longer "prepare" AO, since the prepared output cannot be
%   released. 2023_06_13 -ZW
%%  Define feature classes
n_class = 8;
stim_radius = 10; % degrees
%   The stimuli are described on a R-hand Cartesian coordinate system in
%   units of degrees of viewing angle
for i = 1:n_class
    current_degree = (i - 1)*360/n_class;
    GeneralVars.ClassStructure(i).frame(1).stim.end = stim_radius.*[cos(current_degree/180*pi), sin(current_degree/180*pi)];
    GeneralVars.ClassStructure(i).frame(2).stim.end = stim_radius.*[cos(current_degree/180*pi), sin(current_degree/180*pi)];
    GeneralVars.ClassStructure(i).Notes = num2str(current_degree);
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datain(1:4) = [1 .5 3 .2];    %  Default waiting times for each frame [fixation. cue delay1 sample delay2]
datain(5) = 3;                 %  Trial type
datain(6) = 16;                %  Number of blocks
datain(7) = 10;                %  Stimulus eccentricity
datain(8) = 3;                 %  Radius in degree of fixation window
datain(9) = 6;                 %  Radius in degree of target window
datain(10) = 100;               %  Stimulus luminance as percentage (1 - 100) of color depth (typically 0 - 255)
datain(11) = 0;                %  Helper luminance as percentage (1 - 100) of color depth (typically 0 - 255)
numBurst = 2;
% OutputFileNames = {'test_UNI0113'};
% disp('using default values')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Visual Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vstruct.res = [1920 1080];    % screen resolution
vstruct.siz = [94 53];        % screen size in cm
vstruct.dis = 69;             % viewing distance in cm
vstruct.radius = datain(7);   % Stimulus excentricity
intertrial_interval_correct = 3;
intertrial_interval_error   = 3;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Laser Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
laser_frame = 1;
ao_mod_params = struct;
ao_mod_params.mod_type = 'sine'; % Modulation function
ao_mod_params.freq = 2.5; % Modulation frequncy (Hz)
ao_mod_params.amp = 4.5; % Modulation voltage (V, 0 to max)
ao_mod_params.T = 0.4; % Laser on duration (second)
ao_mod_params.T_delay = 0.5;  % Laser delay duration (second)
if ao_mod_params.T + ao_mod_params.T_delay > datain(laser_frame)
    error('Laser delay plus on duration too long!')
end
ao_mod_params_sham = ao_mod_params;
ao_mod_params_sham.amp = 0; % Stops real modulating signal; keeps indicator TTL
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Name Output File
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OutputFileNames = fileoutdlg({'Behavior output file',}, 'Output Files',[1 30],{'test_'});
if isempty(OutputFileNames)
    return;
else
    save_name = OutputFileNames{1};
end

go = 1;
filenamecheck = ['C:\Users\cclab\Documents\MATLAB\beh\' save_name '.mat'];
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

WaveInitDaq030
WaitSecs(0.1);
outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Calculate Pixels/Degree constants and coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[vstruct, Display] = WaveDisplayParams_030(vstruct, datain);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Declare Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FixWindowSize(1,:) = datain(8)*Figdata.xcoord;
FixWindowSize(2,:) = datain(8)*Figdata.ycoord;
TargWindowSize(1,:) = datain(9)*Figdata.xcoord;
TargWindowSize(2,:) = datain(9)*Figdata.ycoord;

totalblocks = datain(6);
BreakState = 0;
output_counter = 0;
save_counter = 1;
correctcounter = 0;
gate_off_time = .1;
fix_aquisition = 1;
target_aquisition = 0.6;
black = BlackIndex(0);
ReactionTime = 0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixation times in seconds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus Windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[window, f, r, WindowStructure, AllCoordinates] = CreateWindowStructODR_030(Display, vstruct, GeneralVars.ClassStructure);

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
AllData.parameters.script = char(fread(fopen([mfilename, '.m'])))';
AllData.parameters.laser_frame = laser_frame;
AllData.parameters.ao_mod_params = ao_mod_params;
AllData.synctime = clock;
AllData.starttime = GetSecs;
%channel 8 on for duration of whole trial
%channel 1 on and off for every reward burst
%channel 5 on and off every stimuli appearance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
outputSingleScan(DO,[0,1,0,0,0,0,0,0]); %   DO1 on NIDAQ remains high for the whole sessions -ZW
send_network_event(save_name);
WaitSecs(2);
% try

%  Session variables definition
n_stim_class = zeros(1, n_class); % No. of valid stim trials per class
n_control_class = zeros(1, n_class); % No. of valid control trials per class
prevClass = 0;
prevResult = 0;
prevStim = 0;
nextStim = 0;
%   Max lead time allowed between window copying and fixation on
aqusition_time_queue  = [fix_aquisition; 0; 0; target_aquisition];
%
finishStatecode = sum(aqusition_time_queue > 0) + numel(aqusition_time_queue) + 1;
laserStatecode  = sum(aqusition_time_queue(1:laser_frame) > 0) + numel(aqusition_time_queue(1:laser_frame)) + 1;
%  Session start
output_counter = output_counter + 1;
block_counter = 1;
dataout(output_counter,1:7) = {'Trial' 'Class #' 'Correct' ...
    'Success' '%' 'Notes','State'};

while (BreakState ~= 1) && (~(all(n_stim_class >= totalblocks) && all(n_control_class >= totalblocks)))
    currentStimDelivered = 0;
    currentGoodStim      = 0;
    %   Decide current trial class and stimulation based on trial history
    if prevResult && (output_counter > 1)
        currentStim = decide_stim(n_stim_class, n_control_class, prevClass, prevStim);
    else
        currentStim = 0;
    end
%     [CurrentClass, nextStim] = decide_class_stim(n_stim_class, n_control_class, currentStim);
    CurrentClass = decide_class(n_stim_class, n_control_class, currentStim);
    if currentStim
        queue_delayed_analog_output(AO, ao_mod_params);
    else
        queue_delayed_analog_output(AO, ao_mod_params_sham);
    end
    %   New instance of eye data
    outputSingleScan(DO,[0,1,0,0,0,0,1,0]);
    AllData.trials(save_counter).time = GetSecs;
    AllData.trials(save_counter).Class = CurrentClass;
    AllData.output_counter = output_counter;
    output_counter = output_counter + 1;
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
    frame_time_queue      = datain(1: 4);
    %   Off-screen windows to be copied for each frame
    window_queue          = {f; WindowStructure(CurrentClass).frame(1).end; ...
        f; WindowStructure(CurrentClass).frame(2).end};

    %              UpdateEyeDisplay(AllCoordinates.fRect, FixWindowSize, AllCoordinates.fRect,vstruct, hLine,'off')

    eye_display_queue         = {...
        AllCoordinates.fRect, FixWindowSize; ...
        AllCoordinates.fRect, FixWindowSize; ...
        AllCoordinates.fRect, FixWindowSize; ...
        AllCoordinates.cRect(CurrentClass, :, 2), TargWindowSize};
    %   Audio to be played (if any) at the time of window copying (e.g. fixon.wav)
    audio_queue           = {'', []; '', []; '', []; '', []};
    %   Requred fixation window center and size in visual degrees (and thus in
    %   R-hand coordinates)
    eye_target_queue      = {...
        [0, 0], [Display.FixationWindow]; ... % Fixation epoch
        [0, 0], [Display.FixationWindow]; ... % Cue epoch
        [0, 0], [Display.FixationWindow]; ... % Delay epochs
        GeneralVars.ClassStructure(CurrentClass).frame(1).stim(1).end, [Display.TargetWindow]};    % Target epoch
    timestamp_queue = [];
    Statecode = 0;
    FixState = 0;
    Result = 0;
    Statecode = Statecode + 1;
    %%  Core loop
    for frame_idx = 1:numel(window_queue)
        %   Step 1: Display current window
        outputSingleScan(DO,[0,1,0,0,1,0,1,0]);
        Screen('CopyWindow',window_queue{frame_idx},window);
        Screen(window,'Flip');
        %   Screen updating timestamps ('CueOn', 'TargetOn' etc.)
        timestamp_queue(Statecode) = GetSecs;
        outputSingleScan(DO,[0,1,0,0,0,0,1,0]);
        %                 wavesoundplay(audio_queue{frame_idx, 1}, audio_queue{frame_idx, 1});
        UpdateEyeDisplay(eye_display_queue{frame_idx, 1}, eye_display_queue{frame_idx, 2}, eye_display_queue{frame_idx, 1},vstruct, hLine,'on')
        %
        %   Step 2: Aquire fixation (if allowed)
        breaktime = GetSecs;
        if aqusition_time_queue(frame_idx) > 0
            FixState = 0;
            while (FixState <= 0) && ((GetSecs - breaktime) < aqusition_time_queue(frame_idx))
                DisplayEye(Display, hAxes, hLine);
                [FixState] = CheckFixation(eye_target_queue{frame_idx, 1}, eye_target_queue{frame_idx, 2}, Display);
            end
            if (FixState == 0)
                break;
            end
            %   Aquiring new fixation means +1 Statecode
            Statecode = Statecode + 1;
            %   Fixation in timestamps
            timestamp_queue(Statecode) = GetSecs;
        end
        %
        %   Step3: Maintain fixation
        if frame_idx == laser_frame
            startBackground(AO);
            currentStimDelivered = 1;
        end
        breaktime = GetSecs;
        while (FixState == 1) && ((GetSecs - breaktime) < frame_time_queue(frame_idx))
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
    if Statecode == finishStatecode
        Result = 1;
        %     wavesoundplay('correct.wav',0.6);
    elseif Statecode == finishStatecode - 2 % Not moving to target location
        Result = 0;
        %     wavesoundplay('wrong.wav',0.6);
    else %  Aborted trial before target epoch
        Result = 0;
        %         wavesoundplay('abort.wav',0.8);
    end
    if Statecode >= laserStatecode % Finished laser frame
        currentGoodStim = 1;
    end
    % End-of-trial screen
    breaktime = GetSecs;
    outputSingleScan(DO,[0,1,0,0,1,0,1,0]);
    Screen('CopyWindow',r,window);
    Screen(window,'Flip');
    outputSingleScan(DO,[0,1,0,0,0,0,1,0]);
    UpdateEyeDisplay(eye_display_queue{frame_idx, 1}, eye_display_queue{frame_idx, 2}, eye_display_queue{frame_idx, 1},vstruct, hLine,'off')
    AllData.trials(save_counter).EndofTrialtime = GetSecs;  %end of trial time, same as fixoff time in passive task
    AllData.trials(save_counter).timestamp_queue = timestamp_queue;
    AllData.trials(save_counter).Statecode = Statecode;
    outputSingleScan(DO, [0 1 0 0 0 0 0 0]);
    if Result == 1
        AllData.trials(save_counter).Reward = 'Yes';
        correctcounter = correctcounter + 1;
        dataout(output_counter,1:7) = {output_counter - block_counter, CurrentClass,correctcounter, 1,ReactionTime,GeneralVars.ClassStructure(CurrentClass).Notes,Statecode}
        for burst=1:numBurst
            outputSingleScan(DO, [1 1 0 0 0 0 0 0]);
            WaitSecs(0.45);
            outputSingleScan(DO, [0 1 0 0 0 0 0 0]);
            WaitSecs(0.1);
        end
        intertrial_interval = intertrial_interval_correct-gate_off_time;
    else
        AllData.trials(save_counter).Reward = 'No';
        dataout(output_counter,1:7) = {output_counter - block_counter, CurrentClass, correctcounter, 0,ReactionTime,GeneralVars.ClassStructure(CurrentClass).Notes,Statecode}
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
    %   Opto logging
    if prevResult && currentGoodStim % valid trial
        if currentStim
            n_stim_class(prevClass) = n_stim_class(prevClass) + 1
        else
            n_control_class(prevClass) = n_control_class(prevClass) + 1
        end
    end
    prevClass = CurrentClass;
    prevResult = Result;
    AllData.trials(save_counter).StimDelivered = currentStim * currentStimDelivered;
    prevStim  = AllData.trials(save_counter).StimDelivered; % Only interleave trials with delivered stimulation

    %
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
    save_counter = save_counter + 1;
end
% catch
%     lasterror
% end
outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
save(['C:\Users\cclab\Documents\MATLAB\beh\' save_name], 'AllData');
turn_off_analog_output(AO);
send_network_event([save_name, '_end_of_session']);
%%
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
%%
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
%%
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
%%
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
%%
function [BreakState] = CheckBreakState

[~, ~, Breakbutton] = GetMouse;

%  Check for mouse click
if any(Breakbutton)
    Breakbuttons = 0;
    disp('Program paused, click once for continue, twice to exit')
    WaitSecs(1)
    while 1
        Breakbuttons = GetClicks;
        if Breakbuttons == 1
            BreakState = 0;
            Breakbuttons;
            return
        elseif Breakbuttons > 1
            BreakState = 1;
            Breakbuttons;
            return
        end
    end
else
    BreakState = 0;
end
end
%%
function [opt_class, next_stim] = decide_class_stim(n_stim_class, n_control_class, current_trial_stim)
all_class = 1:numel(n_stim_class);
if current_trial_stim % class(t) is forced to be paired with stim(t + 1) = 0
    opt_class = randsample(all_class(n_control_class == min(n_control_class)), 1);
    next_stim = 0;
else % Allow both stim(t + 1) = 0 and stim(t + 1) = 1
    cat_n_class = [n_stim_class, n_control_class];
    cat_all_class = [all_class, all_class];
    cat_all_stim  = [ones(size(n_stim_class)), zeros(size(n_control_class))];
    classes_to_pick = cat_all_class(cat_n_class == min(cat_n_class));
    stims_to_pick   = cat_all_stim(cat_n_class == min(cat_n_class));
    rand_idx = randi(numel(classes_to_pick));
    opt_class = classes_to_pick(rand_idx);
    next_stim = stims_to_pick(rand_idx);
end
end

%%
function opt_class = decide_class(n_stim_class, n_control_class, current_trial_stim)
all_class = 1:numel(n_stim_class);
if current_trial_stim % class(t) is forced to be paired with stim(t + 1) = 0
    opt_class = randsample(all_class(n_control_class == min(n_control_class)), 1);
else % Allow both stim(t + 1) = 0 and stim(t + 1) = 1
    cat_n_class = [n_stim_class, n_control_class];
    cat_all_class = [all_class, all_class];
    opt_class = randsample(cat_all_class(cat_n_class == min(cat_n_class)), 1);
end
end
%%
function opt_stim = decide_stim(n_stim_class, n_control_class, prev_trial_class, prev_trial_stim)
if prev_trial_stim || (n_stim_class(prev_trial_class) > n_control_class(prev_trial_class))
    opt_stim = 0;
else
    opt_stim = 1;
end
end
