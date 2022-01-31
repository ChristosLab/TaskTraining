function TrainAntiSaccadeLab2(varargin)
%  Changes to code
%  04-01-05, Changed frame1-frame4 to one variable frametime(1-4). TM
%  04-11-05, Changed AllData structure to save trials as a vector. TM
%  04-15-05, Added code to allow the use of either the old class structure,
%   without frametime, or the new class structure.
%  08-18-05, Adding Target and saccade sections.
%  10-26-05, moved gateofftime to begining of trial loop (before flushingAllCoordinates
%  ai), made subWrong a constant 1, and moved FixOff to right after the
%  last TTL pulse at the end of the trial, TM
%  Sep-09-08, add 'SizeofStim' to control stimulus size.
%  May-1-11, XQ, AntiSaccade task
% fix->cue->delay->saccade to opposite location of cue
% prefrences: ClassAntiSaccade
% green fixation
% Statecode == 4 | Statecode == 5 % 2 types errors
% 17-JUN-2019 cc Modified for training in lab 2

% use protocol named "ClassAntiSaccadeCircle" mat file
% save behavior file for overlap to make sure after several weeks
% training, monkeys behavior are stable, then recording can start

% Reaction time = TargetIn - CueOff?


[mousex,mousey] = getmouse;
warning off all
clc
% load('C:\MATLAB6p5\work\preferences\GeneralVars.mat') % if using WaveGui
SizeofStim = 0.74;% XQ, size 2 degree
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1                      %  If there are no arguments given
    datain(1:4) = [1 0.1 0 0.1];   %  Default waiting times for each frame
    datain(5) = 3;                 %  Trial type
    datain(6) = 50;                %  Number of blocks
    datain(7) = 10;                %  Stimulus eccentricity
    datain(8) = 3.6;               %  Radius in degrees of fixation window
    datain(9) = 9;                 %  Radius in degrees of target window
    datain(10) = 255;              %  Luminance of cue stimulus
    gray2 = 230;                   %  Luminance of target (off during recording)
%     datasin = 'temp';
%     MNM = 'Match';
   
    burst_amount = 2;
    aquisition_time = 6;          % fixation aquisition time
    Target_aquisition_time = 3.6;          % target aquisition time
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Visual Settings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    vstruct.res = [1280 1024];    % screen resolution
    vstruct.siz = [61 46];        % screen size in cm
    vstruct.dis = 60;             % viewing distance in cm
    vstruct.voltage = 3.5;        % Analog to degree conversion constant
    vstruct.radius = datain(7);   % Stimulus excentricity
    vstruct.angs = [1:8];  % Stimulus Classes
else
    % arguments exist from Gui, use them
    dataintemp = varargin(1);      % varargin is cell and convert to structure
    datain(1:11) = dataintemp{1,1};
%     MNM = varargin{4};
    datasin = varargin{2};
    vstruct = varargin{3};
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initialize eye display figure
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[Figdata, hFig, hAxes, hLine] = WaveInitEyeDisplay;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Initialize Nidaq board   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% WaveInitDaq

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Calculate Pixels/Degree constants and coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[vstruct, Display] = WaveDisplayParams(vstruct, datain);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Declare Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

version = 'AntiSaccaderainLAB2 June-17-2018' ; % after code changes, change version
rand('state',sum(100*clock));
screen('closeall');daqreset % clear screen and NiDaq card from previous use
OutputFileNames = fileoutdlg({'APM and Behavior output file',}, 'Output Files',[1 30],{'TRI_beh000_0'}); % XQ
if isempty(OutputFileNames)
    return;
else
    APMname = OutputFileNames{1};
    APMpath = ['C:/DataFiles/Elv/'];
    datasin = OutputFileNames{1};
    filename = strcat(APMpath,OutputFileNames{1},'.apm');
    BehaviorName = OutputFileNames{1};
    %     BehaviorPath = ['C:\Data\'];
    BehaviorPath = ['C:\MATLAB6p5\work\Behavioral_Data_Files\'];
    
    go = 1;
    filenamecheck = ['C:\MATLAB6p5\work\Behavioral_Data_Files\' datasin '.mat'];
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
    if  go ~= 1
        return
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%              Load External Protocol
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[protocolname, loadpath] = uigetfile('C:\MATLAB6p5\work\preferences\*.mat','Load Protocol',100,100); % ClassAntisaccade
if protocolname == 0
    return
else
    load(protocolname);
    GeneralVars.ClassStructure = ClassStructure;
end

% filename = ['/DataFiles/ELV/',datasin,'.apm'];
FixWindowSize(1,:) = datain(8)*Figdata.xcoord;
FixWindowSize(2,:) = datain(8)*Figdata.ycoord;
TargWindowSize(1,:) = datain(9)*Figdata.xcoord;
TargWindowSize(2,:) = datain(9)*Figdata.ycoord;
totalblocks = datain(6);
totaltrials = length(GeneralVars.ClassStructure);
realtrials = totaltrials;

BreakState = 0;
outputcounter = 0;
save_counter = 1;
correctcounter = 0;
blockcounter = 1;
gate_off_time = 1;
intertrial_interval_correct = 2.5;
intertrial_interval_error   = 2.5;
% aquisition_time = 2;
% Target_aquisition_time = .5;
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
    using_new_classes = 0;
    frametime = [datain(1) datain(2) datain(3) datain(4)];  %fixation time for fixation point
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus Windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[window, f, r, WindowStructure, AllCoordinates] = CreateWindowStruct_AntiSaccadeTrain(Display, vstruct, GeneralVars.ClassStructure,SizeofStim,gray2);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% APM Setup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%    APMConn = APMSendFilename(filename);
%    APMStartRecording
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %  Initialize Nidaq board   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    WaveInitDaq

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start(ai)
waitsecs(.1)

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
AllData.starttime = getsecs;


Nclass = length(vstruct.angs);
for n = 1:totalblocks
    Seq(n,:,1) = vstruct.angs(randperm(Nclass)); % sample display
end

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
        IndexHist = zeros(1,totaltrials);
        IndexTotl = randperm(length(GeneralVars.ClassStructure));
%         CurrentClass = IndexTotl(1);
        while (trialcounter <= realtrials) & (BreakState ~=1)    
            CurrentClass = Seq(blockcounter,trialcounter)
            waitsecs(gate_off_time)
            flushdata(ai)
            putvalue(dio, [0 0 0 0 0 0 0 1]);
            AllData.trials(save_counter).time = getsecs;
            AllData.trials(save_counter).Class = CurrentClass;
            AllData.outputcounter = outputcounter;
            outputcounter = outputcounter + 1;
            if using_new_classes
                frametime = GeneralVars.ClassStructure(CurrentClass).frametime;
            end                
            while 1
                Statecode = 1;
                FixState = 0;
                Result = 0;
                %  Display Fixation
                screen(window,'WaitBlanking');
                %putvalue(dio, [1 0 0 0 0 0 0 1]);                
                Screen('CopyWindow',f,window);
                AllData.trials(save_counter).FixOn = getsecs;
                %putvalue(dio, [0 0 0 0 0 0 0 1]);
                WaveUpdateEyeDisplay(AllCoordinates.fRect, FixWindowSize, AllCoordinates.fRect,vstruct, hLine,'on')
                breaktime = getsecs;
                %  Give subject 2 seconds to move to fixation window
                while (FixState <= 0) & ((getsecs - breaktime) < aquisition_time)
                    [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, ai);    
                    [FixState] = CheckFixation(AllCoordinates.fCenter, Display.FixationWindow, ai, vstruct);
                end
                %  If subject didn't get to window within 2 seconds, or break
                %  button was pushed, break out of trial
                if FixState == 0
                    break;
                end
                Statecode = 2;
                breaktime = getsecs;
                AllData.trials(save_counter).FixIn = breaktime; % jun-15-2011
               
                %  Eye must stay within fixation window for frame1 time
                while (FixState == 1) & ((getsecs - breaktime) < frametime(1))
                    [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, ai);
                    [FixState] = CheckFixation(AllCoordinates.fCenter, Display.FixationWindow, ai, vstruct);
                end            
                if FixState == 0
                    break;
                end
                Statecode = 3;
                %  Display Fixation plus stimulus                
                screen(window,'WaitBlanking');                   
                %putvalue(dio, [1 0 0 0 0 0 0 1]);
                Screen('CopyWindow',WindowStructure(CurrentClass).frame(1).end,window);                         
                 AllData.trials(save_counter).CueOn = getsecs;%xq jun-14-2011
                %putvalue(dio, [0 0 0 0 0 0 0 1]);
                WaveUpdateEyeDisplay(AllCoordinates.cRect(CurrentClass,:,1), FixWindowSize, AllCoordinates.fRect,vstruct, hLine,'on')
                breaktime = getsecs;
                %  Check that eye stays within fixation window for frame2
                while (FixState == 1) & ((getsecs - breaktime) < frametime(2))
                    [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, ai);
                    [FixState] = CheckFixation(AllCoordinates.fCenter, Display.FixationWindow, ai, vstruct);
                end
                if FixState == 0
                    break;
                end
                Statecode = 4;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                    % Saccading to Target.  Display target and wait for
                    % monkey to saccade to target.
                    FixState = 0;
                    screen(window,'WaitBlanking');
                    %putvalue(dio, [1 0 0 0 0 0 0 1]);
                    Screen('CopyWindow',WindowStructure(CurrentClass).frame(2).end,window);
                    AllData.trials(save_counter).CueOff = getsecs;    %XQ jun-14-2011  stimuli off time
                    %putvalue(dio, [0 0 0 0 0 0 0 1]);
                    WaveUpdateEyeDisplay(AllCoordinates.cRect(CurrentClass,:,2), TargWindowSize, AllCoordinates.cRect(CurrentClass,:,2),vstruct, hLine,'on')
                    breaktime = getsecs;
                    %  Give subject 2 seconds to move to Target window
                    while (FixState <= 0) & ((getsecs - breaktime) < Target_aquisition_time)
                        [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, ai);
                        [FixState] = CheckFixation(AllCoordinates.cRect(CurrentClass,:,2), Display.TargetWindow, ai, vstruct);
                    end
                    breaktime = getsecs;
                    if FixState == 0
                        break;
                    end
                    Statecode = 5;
                    %  Eye must stay within target window for frametime(4)
                    AllData.trials(save_counter).TargetIn = getsecs;    %XQ eye arrive target
                    while (FixState == 1) & ((getsecs - breaktime) < frametime(4))
                        [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, ai);
                        [FixState] = CheckFixation(AllCoordinates.cRect(CurrentClass,:,2), Display.TargetWindow, ai, vstruct);
                    end
                    if FixState == 0
                        break;
                    end
                    Statecode = 6;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

                %  If this point in the code is reached, the subject completed
                %  the trial successfully and Result is changed from 0 to 1
                Result = 1;
                break
            end
            breaktime = getsecs;
            Screen(window,'FillRect',black)  % Clear screen
            %putvalue(dio, [1 0 0 0 0 0 0 1]);
            AllData.trials(save_counter).FixOff = getsecs;           
            %putvalue(dio, [0 0 0 0 0 0 0 1]);
            WaveUpdateEyeDisplay(AllCoordinates.fRect, FixWindowSize, AllCoordinates.fRect,vstruct, hLine,'off')
            AllData.trials(save_counter).EndofTrialtime = getsecs;
            clc
            AllData.trials(save_counter).Statecode = Statecode;
            if Result == 1
                p_correctcounter = p_correctcounter + 1;
                t_correctcounter(CurrentClass) = t_correctcounter(CurrentClass) + 1;
                p_correct = round(p_correctcounter/(target_error+p_correctcounter)*100);
                t_correct = round(t_correctcounter(CurrentClass)/(t_correctcounter(CurrentClass)+t_errorcounter(CurrentClass))*100);
                AllData.trials(save_counter).Reward = 'Yes';
                %APMSendReward(outputcounter-blockcounter,1,APMConn)
                correctcounter = correctcounter + 1;
                dataout(outputcounter,1:7) = {outputcounter-blockcounter, CurrentClass,correctcounter, 1,p_correct,GeneralVars.ClassStructure(CurrentClass).Notes,t_correct}
                %  Correct auditory feedback            
%                 Screen('CopyWindow',r,window); 
                SND('Play',[sin(1:500)],[2000]);
                for b = 1:burst_amount
                putvalue(dio, [1 0 0 0 0 0 0 1]);
                putvalue(dio, [0 0 0 0 0 0 0 1]);
                 waitsecs(1)
             end
                intertrial_interval = intertrial_interval_correct-gate_off_time;
                repeatcounter = repeatcounter + 1;
                IndexHist(CurrentClass) = CurrentClass;
            else
                if Statecode == 4 | Statecode == 5 % 2 types errors
                    intertrial_interval_error   = 2.5;
                    target_error = target_error + 1;
                    p_correct = round(p_correctcounter/(target_error+p_correctcounter)*100);
                    t_errorcounter(CurrentClass) = t_errorcounter(CurrentClass) + 1;
%                 elseif Statecode == 1
%                     intertrial_interval_error   = 10;
                else                   
                    intertrial_interval_error   = 2.5;
                end
                t_correct = round(t_correctcounter(CurrentClass)/(t_correctcounter(CurrentClass)+t_errorcounter(CurrentClass))*100);
                AllData.trials(save_counter).Reward = 'No';                
                %APMSendReward(outputcounter-blockcounter,0,APMConn)               
                dataout(outputcounter,1:7) = {outputcounter-blockcounter, CurrentClass, correctcounter, 0,p_correct,GeneralVars.ClassStructure(CurrentClass).Notes,t_correct}                   
                %  Incorrect auditory feedback
                SND('Play',[sin(1:500)],[1000]);                
                intertrial_interval = intertrial_interval_error-gate_off_time;
            end
            waitsecs(subWrong);
            [AllData.trials(save_counter).EyeData(:,1:2), ...
                    AllData.trials(save_counter).EyeData(:,3)] = getdata(ai,ai.SamplesAvailable);
            %APMSendMessage(outputcounter-blockcounter,CurrentClass, APMConn)
            set(hLine(4), 'XData',(AllData.trials(save_counter).EyeData(:,3)- ... 
                AllData.trials(save_counter).EyeData(1,3)), ...
                'YData', AllData.trials(save_counter).EyeData(:,2))
            set(hLine(5), 'XData',(AllData.trials(save_counter).EyeData(:,3)- ... 
                AllData.trials(save_counter).EyeData(1,3)), ...
                'YData', AllData.trials(save_counter).EyeData(:,1))
            set(hAxes(2),'YLim', [-10 10])
            set(hAxes(3),'YLim', [-10 10])
            drawnow
            IndexTotl = randperm(totaltrials);
            IndexTemp = IndexTotl(~ismember(IndexTotl,IndexHist));
%             if ~isempty(IndexTemp)
%                 CurrentClass = IndexTemp(1)
%             end
            putvalue(dio, [0 0 0 0 0 0 0 0]);
            Screen(window,'FillRect',black)  % Clear screen
            %  Intertrial inverval
            while ((getsecs - breaktime) < intertrial_interval) & (BreakState ~=1)
%                 [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, ai);
                BreakState = CheckBreakState;
            end
            if (BreakState == 1)
                break;
            end
            SND('Quiet');  %  Clear soundcard buffer
            trialcounter = trialcounter + 1;
            save_counter = save_counter + 1;
        end
        blockcounter = blockcounter + 1;
    end
catch
    lasterr
end
CleanUp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, ai);

eye = getsample(ai);
eyeX = (((eye(1,2)-Display.Xscalecenter)*Display.Xscale));
eyeY = (((eye(1,1)-Display.Yscalecenter)*Display.Yscale));
set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);    
set(hLine(2), 'XData', eyeX, 'YData', eyeY*-1); % eye position
drawnow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FixState,BreakState] = CheckFixation(cCenter, WindowRadius, ai, vstruct)
%  CheckFixation is a subfunction that inputs rectangular coordinates and
%  duration to check that the mouse coordinates stay within the inputed
%  rectangle for the duration and send back to the main function whether 
%  the subject was successful or errored or clicked the mouse button.  

eye = getsample(ai);
eyeX = (eye(1,2)*vstruct.pixvolt(1))+(vstruct.res(1)/2);
eyeY = (eye(1,1)*vstruct.pixvolt(2))+(vstruct.res(2)/2);

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
    waitsecs(1)
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
