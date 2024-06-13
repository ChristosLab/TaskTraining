function ActiveODR_wdlab3(varargin)
%  Christos Constantinidis, Ph.D.
%  18-APR-2009
%edited 2/25/2020 by Wenhao for lab 3 ephys system

clear global trial_eye_data
[mousex,mousey] = GetMouse;
warning off all
Screen('closeall');
daqreset;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Initialize Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
version = 'ODRLab3 Feb-25-2020 WD'; 

datain(1:4) = [2.0 0.5 1.5 0.5];  %  Default waiting times for each frame [1 0.5 1.5 0.2]
datain(5) = 4;                  %  Trial type
datain(6) = 20;                 %  Number of blocks
datain(7) = 10;                 %  Stimulus eccentricity
datain(8) = 3;                  %  Radius in degrees of Fixation Window
datain(9) = 6;                  %  Radius in degrees of target window
datain(10) = 255;               %  Stimulus luminance (0-255)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  for training purpose, XZ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
helplumcue= 0;                 %  white fixation,cue stimulus luminance in the end to help [0 255], XZ
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
burst_amount = 1;
Target_aquisition_time = 0.6;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Load External Protocol
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load('C:\Users\CCLAB\Documents\MATLAB\tasktraining_wd\classODR8stim_10deg.mat'); % place stimuli at 10 degrees eccentricity instead of 12

SwitchClass_both     = [1:length(ClassStructure)];

if(nargin>0)
    burst_amount = varargin{1};
    if(nargin>1)
        datain(8) = varargin{2};
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Visual Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vstruct.res = [1920 1080];    % screen resolution
vstruct.siz = [103 57.5];        % screen size in cm  %[61 55]
vstruct.dis = 69;             % viewing distance in cm
vstruct.voltage = 3.5;        % Analog to degree conversion constant
vstruct.radius = datain(7);   % Stimulus excentricity
vstruct.angs = [360 45 90 135 180 225 270 315];  % Stimulus angles

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%             Name Output File 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

OutputFileNames = fileoutdlg({'Behavior output file',}, 'Output Files',[1 30],{'GRU00x_xx'});
if isempty(OutputFileNames)
    return;
else
    datasin = OutputFileNames{1};
end

go = 1;
filenamecheck = ['C:\Users\CCLAB\Documents\Behavioral_Data\' datasin '.mat'];
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


%%%%%%%%%%%%%%%%%%%%%% Training Variables %%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This section allows you to control whether they are in blocks or randomly
% intermixed.  To do it in blocks, choose MNM = 'Both' at the top of the
% script, and under case 'Both' that cvar_max = 2, and SwitchClass = [X X]
% is uncommented.  The monkey starts off with these classes.  Then when the
% switchthreshold is met, the classes are switched 'see below around lines
% 388.

realtrials = length(SwitchClass_both);%totalclasses or total trials in one block?;
SwitchClass = SwitchClass_both;  %classes 1-8

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize eye display figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Figdata, hFig, hAxes, hLine] = WaveInitEyeDisplay;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialize Nidaq board   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

WaveInitDaq

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Calculate Pixels/Degree constants and coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[vstruct, Display] = WaveDisplayParamsODR(vstruct, datain);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Declare Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
FixWindowSize(1,:) = datain(8)*Figdata.xcoord; %fix size used for showing in figure
FixWindowSize(2,:) = datain(8)*Figdata.ycoord;
TarWindowSize(1,:) = datain(9)*Figdata.xcoord;
TarWindowSize(2,:) = datain(9)*Figdata.ycoord;
totalblocks = datain(6);
totaltrials =  length(ClassStructure); %totalclasses or total trials in one block?;
BreakState = 0;
outputcounter = 1; %as long as trials start count into this
save_counter = 1;
correctcounter = 0;
blockcounter = 1;
gate_off_time = 1;
intertrial_interval_correct = 2;
intertrial_interval_error   = 3;
aquisition_time = 2;            %  Give subject 2 second to move to fixation window
black = BlackIndex(0);
ReactionTime = 0;
subWrong = 1;
target_error = 0;
p_correct = 0;
p_correctcounter = 0;
t_correctcounter(1:totaltrials) = 0;
t_errorcounter(1:totaltrials) = 0;
switch_correct = 0;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Fixation times in seconds
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
frametime = [datain(1:4)]; % only use 4: fix , cue , cuedelay, target

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus Windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[window, WindowStructure, AllCoordinates] = CreateWindowStructODR(Display, vstruct, ClassStructure, helplumcue);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
AllData.parameters.Display = Display;% Display: fix and stim center locations, lumniance and size of fix and sitm
AllData.version = version;
AllData.ClassStructure = ClassStructure;
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
AllData.parameters.Target_aquisition_time= Target_aquisition_time;
AllData.parameters.helplumcue = helplumcue;                 
AllData.synctime = clock;
AllData.starttime = GetSecs;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%window: return black background window screen
%WindwoStructure: return fixation window screen
%AllCoordinates: required eye location in each frame
% vstruct: pixel center location of stims
% Display: fix and stim center locations, lumniance and size of fix and sitm
%try
    while (BreakState ~= 1) && (blockcounter <= totalblocks)
        trialcounter = 1;
       % outputcounter = outputcounter + 1;
        repeatcounter = 1;
        dataout(outputcounter,1:7) = {'Trial' 'Class #' 'CorrectCounter' ...
                'Statecode' 'Correct %' ,'Notes', 'Class Correct %'}
        IndexHist = [];%zeros(1,totaltrials); XQ
        IndexTotl = randperm(length(ClassStructure));
        CurrentClass = IndexTotl(1);  %can repeat?
        
        while (repeatcounter <= realtrials) && (BreakState ~=1)%XQ 2010 nov 29
            
            startBackground(ai);
            WaitSecs(gate_off_time);
            wavesoundplay('fix_on.wav',0.4);
            global trial_eye_data;
            outputSingleScan(DO,[0,0,0,0,1,0,0,0]);
            AllData.trials(save_counter).time = GetSecs;
            AllData.trials(save_counter).Class =  CurrentClass;
            AllData.outputcounter = outputcounter;
            outputcounter = outputcounter + 1;
            
            while 1
                Statecode = 1;
                FixState = 0;
                Result = 0;
                %  Display Fixation
                Screen(window,'WaitBlanking');
                outputSingleScan(DO,[0,0,0,0,1,0,1,0]);
                Screen('CopyWindow',WindowStructure(1).f,window); %XQ
                Screen(window,'Flip');  %show fixation
                AllData.trials(save_counter).FixOn = GetSecs;
                outputSingleScan(DO,[0,0,0,0,1,0,0,0]);
                WaveUpdateEyeDisplay(AllCoordinates.fRect, FixWindowSize, AllCoordinates.fRect,vstruct, hLine,'on')
                breaktime = GetSecs;
                %  Give subject 2 seconds to move to fixation window
                while (FixState <= 0) && ((GetSecs - breaktime) < aquisition_time)
                    [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine);
                    disp(eyeX);
                    disp(eyeY);
                    [FixState] = CheckFixation(AllCoordinates.fCenter, Display.FixationWindow,vstruct);
                end
                %  If subject didn't get to window within 2 seconds, or break
                %  button was pushed, break out of trial
                if FixState == 0
                    stop(ai);
                    wavesoundplay('abort.wav',0.8);
                    break;
                end
                
                Statecode = 2;
                breaktime = GetSecs;
                % Eye must stay within fixation window for frametime(1) time
                while (FixState == 1) && ((GetSecs - breaktime) < frametime(1)) %fixation period
                    [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine);
                    [FixState] = CheckFixation(AllCoordinates.fCenter, Display.FixationWindow,vstruct);
                end
                if FixState == 0
                    stop(ai);
                    wavesoundplay('abort.wav',0.8);
                    break;
                end
                
                Statecode = 3;
                %  Display Fixation plus cue
                Screen(window,'WaitBlanking');  %is there a flash?
                outputSingleScan(DO,[0,0,0,0,1,0,1,0]);
                Screen('CopyWindow',WindowStructure(CurrentClass).frame(1).end,window); %copy correponding screen to current display, window structure contains fixation/fixation+stim
                Screen(window,'Flip');
                outputSingleScan(DO,[0,0,0,0,1,0,0,0]);
                WaveUpdateEyeDisplay(AllCoordinates.cRect(CurrentClass,:,1), FixWindowSize, AllCoordinates.fRect, vstruct, hLine,'on')
                breaktime = GetSecs;
                %  Check that eye stays within fixation window for frametime(2)
                while (FixState == 1) && ((GetSecs - breaktime) < frametime(2))
                    [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine);
                    [FixState] = CheckFixation(AllCoordinates.fCenter, Display.FixationWindow,vstruct); %pass target fixation window
                end
                if FixState == 0
                    stop(ai);
                    wavesoundplay('abort.wav',0.8);
                    break;
                end  
                
                Statecode = 4;                               
                % Delay Period. Display fixation only
                Screen(window,'WaitBlanking');
                outputSingleScan(DO,[0,0,0,0,1,0,1,0]);
                Screen('CopyWindow',WindowStructure(1).f,window);
                Screen(window,'Flip');
                %                 Screen('CopyWindow',WindowStructure(1).f,window);
                outputSingleScan(DO,[0,0,0,0,1,0,0,0]);
                WaveUpdateEyeDisplay(AllCoordinates.fRect, FixWindowSize, AllCoordinates.fRect, vstruct, hLine,'on')
                breaktime = GetSecs;
                %  Make sure eye stays in fix window for frametime(3) time
                while (FixState == 1) && ((GetSecs - breaktime) < frametime(3))
                    [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine);
                    [FixState] = CheckFixation(AllCoordinates.fCenter, Display.FixationWindow,vstruct);
                end
                if FixState == 0
                    stop(ai);
                    wavesoundplay('abort.wav',0.8);
                    break;
                end
                

                Statecode = 6;  % to make consistency
                %Saccade to remembered location of stimulus
                FixState = 0;              
                Screen(window,'WaitBlanking');
                outputSingleScan(DO,[0,0,0,0,1,0,1,0]);
                Screen('CopyWindow',WindowStructure(CurrentClass).r,window); %show reward screen with potential helper stim
                Screen(window,'Flip');
                AllData.trials(save_counter).FixationPointOff = GetSecs;
                outputSingleScan(DO,[0,0,0,0,1,0,0,0]);
                WaveUpdateEyeDisplay(AllCoordinates.cRect(CurrentClass,:,1), TarWindowSize, AllCoordinates.cRect(CurrentClass,:,1), vstruct, hLine,'on') %XQ
                breaktime = GetSecs;
                %  Give subject 0.6 seconds to move to fixation window
                while (FixState <= 0) && ((GetSecs - breaktime) < Target_aquisition_time) 
                    [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine);
                    [FixState] = CheckFixation(AllCoordinates.cRect(CurrentClass,:,1), Display.TargetWindow,vstruct);%set fixation target window to be the same as stim location
                end
                ReactionTime = GetSecs-breaktime;
                if FixState == 0
                    stop(ai);
                    break;
                end
                breaktime = GetSecs;
                %  Eye must stay within target window for frame6
                while (FixState == 1) && ((GetSecs - breaktime) < frametime(4))
                    [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine);
                    [FixState] = CheckFixation(AllCoordinates.cCenter(CurrentClass,:,1), Display.TargetWindow,vstruct); %XQ
                end
                if FixState == 0
                    stop(ai);
                    break;
                end
                Statecode = 7;
                
                %  If this point in the code is reached, the subject completed
                %  the trial successfully and Result is changed from 0 to 1
                Result = 1;
                break
            end
            breaktime = GetSecs;
            Screen(window,'FillRect',black)  % Clear screen
            outputSingleScan(DO,[0,0,0,0,1,0,1,0]);
            AllData.trials(save_counter).FixOff = GetSecs;
            outputSingleScan(DO,[0,0,0,0,1,0,0,0]);
            WaveUpdateEyeDisplay(AllCoordinates.fRect, FixWindowSize, AllCoordinates.fRect,vstruct, hLine, 'off')
            AllData.trials(save_counter).EndofTrialtime = GetSecs;
            clc
            AllData.trials(save_counter).Statecode = Statecode;
            if Result == 1
                p_correctcounter = p_correctcounter + 1;%
                t_correctcounter(CurrentClass) = t_correctcounter(CurrentClass) + 1;% tm
                p_correct = round(p_correctcounter/(target_error+p_correctcounter)*100);% tm
                t_correct = round(t_correctcounter(CurrentClass)/(t_correctcounter(CurrentClass)+t_errorcounter(CurrentClass))*100);% tm
                AllData.trials(save_counter).Reward = 'Yes';% tm
                correctcounter = correctcounter + 1;
                dataout(outputcounter,1:7) = {outputcounter-blockcounter, CurrentClass,correctcounter, Statecode,p_correct,ClassStructure(CurrentClass).Notes,t_correct}
                %  Correct auditory feedback
                % Screen('CopyWindow',WindowStructure(1).r,window);
                %Snd('Play',sin(1:4000),8000); %correct sound 0.5s 1200Hz
                wavesoundplay('correct.wav',0.6)
                for b = 1:burst_amount
                    outputSingleScan(DO,[1,0,0,0,1,0,1,0]);
                    outputSingleScan(DO,[0,0,0,0,1,0,0,0]);
                    WaitSecs(1)
                end
                intertrial_interval = intertrial_interval_correct - gate_off_time;
                repeatcounter = repeatcounter + 1;
                IndexHist(CurrentClass) = CurrentClass;
                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                switch_correct = switch_correct + 1;

                %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%                
                
            else
                if Statecode == 6 
                    target_error = target_error + 1;
                    p_correct = round(p_correctcounter/(target_error+p_correctcounter)*100);
                    t_errorcounter(CurrentClass) = t_errorcounter(CurrentClass) + 1;
                end
                t_correct = round(t_correctcounter(CurrentClass)/(t_correctcounter(CurrentClass)+t_errorcounter(CurrentClass))*100);
                AllData.trials(save_counter).Reward = 'No';
                ReactionTime = 0;
                dataout(outputcounter,1:7) = {outputcounter-blockcounter, CurrentClass, correctcounter,Statecode,p_correct,ClassStructure(CurrentClass).Notes,t_correct}
                
                %  Incorrect auditory feedback 0.5s 250Hz
                %Snd('Play',sin(1:800),1600);
                wavesoundplay('wrong.wav',0.6);
                intertrial_interval = intertrial_interval_error - gate_off_time;
            end
            
            AllData.trials(save_counter).ReactionTime = ReactionTime;% XQ
            WaitSecs(subWrong);
       %     [AllData.trials(save_counter).EyeData(:,1:2), ...
       %     AllData.trials(save_counter).EyeData(:,3)] = getdata(ai,ai.SamplesAvailable);
            [AllData.trials(save_counter).EyeData(:,1:3)]=trial_eye_data;
            clear global trial_eye_data;
            stop(ai);
            %set(hLine(4), 'XData',(AllData.trials(save_counter).EyeData(:,3)- ...
            %    AllData.trials(save_counter).EyeData(1,3)), ...
            %    'YData', AllData.trials(save_counter).EyeData(:,2))
            plot(2*[1:length(AllData.trials(save_counter).EyeData(:,2))], ...
                AllData.trials(save_counter).EyeData(:,2)','Parent',hAxes(2));
            ylim([-10,10]);
            %set(hLine(5), 'XData',(AllData.trials(save_counter).EyeData(:,3)- ...
            %    AllData.trials(save_counter).EyeData(1,3)), ...
            %    'YData', AllData.trials(save_counter).EyeData(:,1))
            plot(2*[1:length(AllData.trials(save_counter).EyeData(:,1))], ...
                 AllData.trials(save_counter).EyeData(:,1)','Parent',hAxes(3));
            ylim([-10,10]);
            set(hAxes(2),'YLim', [-10 10])
            set(hAxes(3),'YLim', [-10 10])
            drawnow
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            %           Only use Class in SwitchClass Variable, make sure
            %           monkey make all correct classes for each location
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
            IndexTotl = randperm(realtrials);
            IndexTemp = IndexTotl(~ismember(SwitchClass(IndexTotl),IndexHist));
            if ~isempty(IndexTemp)
                CurrentClass = SwitchClass(IndexTemp(1))
            end
            
            %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%            
            
            outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
            Screen(window,'FillRect',black)  % Clear screen  end
            
            %  Intertrial inverval
            while ((GetSecs - breaktime) < intertrial_interval) && (BreakState ~=1)
                % [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine);
                BreakState = CheckBreakState;
            end
            if (BreakState == 1)
                break;
            end
            Snd('Quiet');  %  Clear soundcard buffer
            trialcounter = trialcounter + 1;
            save_counter = save_counter + 1;
        end
        blockcounter = blockcounter + 1;
    end
%catch
  %  lasterr
  %  Statecode
%end
%CleanUp
try
    outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
    WaitSecs(1)
end

Screen('CloseAll')
AllData.endtime = GetSecs;
close(hFig)
save(['C:\Users\CCLAB\Documents\Behavioral_Data\' datasin],'AllData');
clear all;
clear global trial_eye_data

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine)

%eye = inputSingleScan(ai);
global trial_eye_data;
eye=trial_eye_data(end,:);
eyeX = (((eye(1)-Display.Xscalecenter)*Display.Xscale));
eyeY = (((eye(2)-Display.Yscalecenter)*Display.Yscale));
set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
set(hLine(2), 'XData', eyeX, 'YData', eyeY*-1); % eye position
drawnow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FixState] = CheckFixation(cCenter, WindowRadius, vstruct)
%  CheckFixation is a subfunction that inputs rectangular coordinates and
%  duration to check that the mouse coordinates stay within the inputed
%  rectangle for the duration and send back to the main function whether
%  the subject was successful or errored or clicked the mouse button.

%eye = inputSingleScan(aiRT);
global trial_eye_data;
eye=trial_eye_data(end,:);
eyeX = (eye(1)*vstruct.pixvolt(1))+(vstruct.res(1)/2);
eyeY = (eye(2)*vstruct.pixvolt(2))+(vstruct.res(2)/2);

%  Compare distance from mouse coordinates from inputed window center
if ((((cCenter(1,1)-eyeX)*vstruct.degpix(1))^2)+(((cCenter(1,2)-eyeY)*vstruct.degpix(2))^2))^.5 <= WindowRadius
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