function PassiveMNM_lab3(varargin)
%10_12_2021 version
[mousex,mousey] = GetMouse;
warning off all
Screen('closeall');
daqreset;
clc
load('C:\Users\CCLAB\Documents\MATLAB\inuse\Feature_classes.mat');
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1                      %  If there are no arguments given
    datain(1:4) = [1 .5 1.5 .5];    %  Default waiting times for each frame [fixation. cue delay1 sample delay2]
    datain(5) = 3;                 %  Trial type
    datain(6) = 10;                %  Number of blocks
    datain(7) = 0;                %  Stimulus eccentricity
    datain(8) = 3.5;                 %  Radius in degree of fi1xation window
    datain(9) = 7.5;                 %  Radius in degree of target window
    datain(10) = 100;              %  Luminance
    datain(11)=1.5;  %second delay
    datasin = 'fiona';
    numBurst=1;

   % disp('using default values')
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %   Visual Settings
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    vstruct.res = [1920 1080];    % screen resolution
    vstruct.siz = [103 57.5];        % screen size in cm
    vstruct.dis = 69;             % viewing distance in cm
    vstruct.radius = datain(7);   % Stimulus excentricity
else
    % arguments exist from Gui, use them
    dataintemp = varargin(1);      % varargin is cell and convert to structure
    datain(1:11) = dataintemp{1,1};
    MNM = varargin{4};
    datasin = varargin{2};
    vstruct = varargin{3};
end
MNM = 'Both';
Xscale = 3.5;
Xscalecenter = 0;
Yscale = 3.5;
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
global trial_eye_data trial_eye_timestamp
WaveInitDaq2
%outputSingleScan(DO,[1,1,1,1,1,1,1,1]);
WaitSecs(0.1);
outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
outputSingleScan(ao,[0,0]);
outputSingleScan(DO,[0,1,0,0,0,0,0,0]);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Calculate Pixels/Degree constants and coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[vstruct, Display] = WaveDisplayParams(vstruct, datain);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Declare Variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

version = 'PassiveMNM 13Oct21' ; % after code changes, change version
%filename = ['/DataFiles/Elv/',datasin,'.apm'];
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
aquisition_time = 4;
Target_aquisition_time = 0.5;
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
    frametime = GeneralVars.ClassStructure(1).frametime; % Must add frametime(6) for target.
    using_new_classes = 1;
catch
    using_new_classes = 0;
    frametime = [datain(1) datain(2) datain(3) datain(4) datain(11)];  %fixation time for fixation point
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus Windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

[window, f, r, WindowStructure, AllCoordinates] = CreateWindowStruct5(Display, vstruct, GeneralVars.ClassStructure,MNM);
WaitSecs(0.3);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Save Parameters
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%outputSingleScan(ao,0);
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
%channel 8 on for duration of whole trial
%channel 1 on and off for every reward burst
%channel 5 on and off every stimuli appearance
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%try
    while (BreakState ~= 1) & (blockcounter <= totalblocks)
        trialcounter = 1;
        repeatcounter = 1;
        outputcounter = outputcounter + 1;
        dataout(outputcounter,1:7) = {'Trial' 'Class #' 'Correct' ...
                'Success' '%' 'Notes','State'};
        IndexHist = zeros(1,totaltrials);
        IndexTotl = randperm(length(GeneralVars.ClassStructure));
        switch MNM
            case 'Match'
                IndexTotl = IndexTotl(rem(IndexTotl,4) == 1 | rem(IndexTotl,4) == 2);
            case 'NonMatch'
                IndexTotl = IndexTotl(rem(IndexTotl,4) == 3 | rem(IndexTotl,4) == 0);
        end
        CurrentClass = IndexTotl(1);
        while (repeatcounter <= totaltrials) & (BreakState ~=1) 
            trial_eye_data      = [];
            trial_eye_timestamp = [];
            WaitSecs(gate_off_time);
            startBackground(ai);
           % flushdata(ai)
            trial_num_bit1=floor(save_counter/40);
            trial_num_bit2=mod(save_counter,40);
            outputSingleScan(ao,[-5+0.25*trial_num_bit1,-5+0.25*trial_num_bit2]);
            outputSingleScan(DO,[0,1,0,0,0,0,1,0]);
           % outputSingleScan(ao,-5+0.02*save_counter);
            AllData.trials(save_counter).time = GetSecs;
            AllData.trials(save_counter).Class = CurrentClass;
            AllData.outputcounter = outputcounter;
            outputcounter = outputcounter + 1;
        %    if using_new_classes
        %        frametime = GeneralVars.ClassStructure(CurrentClass).frametime;
        %    end  
            all_eye=[];
            all_eyetime=[];
            trial_start=GetSecs;
            while 1
                Statecode = 1;
                FixState = 0;
                Result = 0;
                %  Display Fixation
               % Screen(window,'WaitBlanking');
                outputSingleScan(DO,[0,1,0,0,1,0,1,0]);
                Screen('CopyWindow',f,window);
                Screen(window,'Flip');
                %AllData.trials(save_counter).FixOn = GetSecs;
                AllData.trials(save_counter).Trialstart = GetSecs;
                outputSingleScan(DO,[0,1,0,0,0,0,1,0]);
      %          wavesoundplay('fix_on.wav',0.4);
                WaveUpdateEyeDisplay(AllCoordinates.fRect, FixWindow, AllCoordinates.fRect,vstruct, hLine,'on')
                breaktime = GetSecs;
                %  Give subject 2 seconds to move to fixation window
                while (FixState <= 0) & ((GetSecs - breaktime) < aquisition_time)
                    DisplayEye(hAxes, hLine, Xscale, Yscale, ai); 
                    degree_fcenter=[1,-1].*(AllCoordinates.fCenter-vstruct.res/2).*vstruct.degpix;
                    [FixState] = CheckFixation(degree_fcenter, Display.FixationWindow,Xscale,Yscale,ai);
                end
                %  If subject didn't get to window within 2 seconds, or break
                %  button was pushed, break out of trial
                AllData.trials(save_counter).Fixin = GetSecs; %time animal start fixaiton, only make sense when statecode>1
                if FixState == 0
                    wavesoundplay('abort.wav',0.8);
                    break;
                end
                Statecode = 2;
                breaktime = GetSecs;
                %  Eye must stay within fixation window for frame1 time
                while (FixState == 1) & ((GetSecs - breaktime) < frametime(1))
                    DisplayEye(hAxes, hLine, Xscale, Yscale, ai);
                    degree_fcenter=[1,-1].*(AllCoordinates.fCenter-vstruct.res/2).*vstruct.degpix;
                    [FixState] = CheckFixation(degree_fcenter, Display.FixationWindow,Xscale,Yscale,ai);
                end            
                if FixState == 0
                    wavesoundplay('abort.wav',0.8);
                    break;
                end
                Statecode = 3;
                %  Display Fixation plus stimulus                
             %   Screen(window,'WaitBlanking');                   
                outputSingleScan(DO,[0,1,0,0,1,0,1,0]);
                Screen('CopyWindow',WindowStructure(CurrentClass).frame(1).end,window); 
                Screen(window,'Flip');
                AllData.trials(save_counter).Cueon = GetSecs;
                outputSingleScan(DO,[0,1,0,0,0,0,1,0]);
                WaveUpdateEyeDisplay(AllCoordinates.cRect(CurrentClass,:,1), FixWindow, AllCoordinates.fRect,vstruct, hLine,'on')
                breaktime = GetSecs;
                %  Check that eye stays within fixation window for frame2
                while (FixState == 1) & ((GetSecs - breaktime) < frametime(2))
                    DisplayEye(hAxes, hLine, Xscale, Yscale, ai);
                    degree_fcenter=[1,-1].*(AllCoordinates.fCenter-vstruct.res/2).*vstruct.degpix;
                    [FixState] = CheckFixation(degree_fcenter, Display.FixationWindow,Xscale,Yscale,ai);
                end
                if FixState == 0
                    wavesoundplay('abort.wav',0.8);
                    break;
                end
                Statecode = 4;
                %  Display fixation only                
               % Screen(window,'WaitBlanking');
                outputSingleScan(DO,[0,1,0,0,1,0,1,0]);
                Screen('CopyWindow',f,window);
                Screen(window,'Flip');
                outputSingleScan(DO,[0,1,0,0,0,0,1,0]);
                WaveUpdateEyeDisplay(AllCoordinates.fRect, FixWindow, AllCoordinates.fRect,vstruct, hLine,'on')
                breaktime = GetSecs;
                %  Make sure eye stays in window for frame3 time
                while (FixState == 1) & ((GetSecs - breaktime) < frametime(3))
                         DisplayEye(hAxes, hLine, Xscale, Yscale, ai);
                         degree_fcenter=[1,-1].*(AllCoordinates.fCenter-vstruct.res/2).*vstruct.degpix;
                         [FixState] = CheckFixation(degree_fcenter, Display.FixationWindow,Xscale,Yscale,ai);
                end
                if FixState == 0
                    wavesoundplay('abort.wav',0.8);
                    break;
                end                
                if frametime(4) ~= 0
                    %  Display 2nd Fixation plus stimulus                
                   % Screen(window,'WaitBlanking');                
                    outputSingleScan(DO,[0,1,0,0,1,0,1,0]);
                    Screen('CopyWindow',WindowStructure(CurrentClass).frame(2).end,window); 
                    Screen(window,'Flip');
                    AllData.trials(save_counter).Sampleon = GetSecs;
                    outputSingleScan(DO,[0,1,0,0,0,0,1,0]);
                    WaveUpdateEyeDisplay(AllCoordinates.cRect(CurrentClass,:,2), FixWindow, AllCoordinates.fRect,vstruct, hLine,'on')
                    breaktime = GetSecs;
                    %  Check that eye stays within fixation window for frame2
                    while (FixState == 1) & ((GetSecs - breaktime) < frametime(4))
                         DisplayEye(hAxes, hLine, Xscale, Yscale, ai);
                         degree_fcenter=[1,-1].*(AllCoordinates.fCenter-vstruct.res/2).*vstruct.degpix;
                         [FixState] = CheckFixation(degree_fcenter, Display.FixationWindow,Xscale,Yscale,ai);
                    end
                    if FixState == 0
                        wavesoundplay('abort.wav',0.8);
                        break;
                    end
                    Statecode = 5;
                    %  Display fixation only
                   % Screen(window,'WaitBlanking');
                    outputSingleScan(DO,[0,1,0,0,1,0,1,0]);
                    Screen('CopyWindow',f,window);
                    Screen(window,'Flip');
                    outputSingleScan(DO,[0,1,0,0,0,0,1,0]);
                    WaveUpdateEyeDisplay(AllCoordinates.fRect, FixWindow, AllCoordinates.fRect,vstruct, hLine,'on')
                    breaktime = GetSecs;
                    %  Make sure eye stays in window for frame3 time
                    while (FixState == 1) & ((GetSecs - breaktime) < frametime(5))
                    DisplayEye(hAxes, hLine, Xscale, Yscale, ai);
                    degree_fcenter=[1,-1].*(AllCoordinates.fCenter-vstruct.res/2).*vstruct.degpix;
                    [FixState] = CheckFixation(degree_fcenter, Display.FixationWindow,Xscale,Yscale,ai);
                    end
                    if FixState == 0
                        wavesoundplay('abort.wav',0.8);
                        break;
                    end
                    Statecode = 6;
                end
                %  If this point in the code is reached, the subject completed
                %  the trial successfully and Result is changed from 0 to 1
                Result = 1;
                break
            end
            breaktime = GetSecs;
            outputSingleScan(DO,[0,1,0,0,1,0,1,0]);
            AllData.trials(save_counter).FixOff = GetSecs;  %fixation off time 
            Screen('CopyWindow',r,window);
            Screen(window,'Flip');
            outputSingleScan(DO,[0,1,0,0,0,0,1,0]);
            WaveUpdateEyeDisplay(AllCoordinates.fRect, FixWindow, AllCoordinates.fRect,vstruct, hLine,'off')
            AllData.trials(save_counter).EndofTrialtime = GetSecs;  %end of trial time, same as fixoff time in passive task
            clc
            AllData.trials(save_counter).Statecode = Statecode;
            if Result == 1
                AllData.trials(save_counter).Reward = 'Yes';
                correctcounter = correctcounter + 1;
                dataout(outputcounter,1:7) = {outputcounter-blockcounter, CurrentClass,correctcounter, 1,ReactionTime,GeneralVars.ClassStructure(CurrentClass).Notes,Statecode}
                %  Correct auditory feedback            
                wavesoundplay('correct.wav',0.6);
              for burst=1:numBurst
                outputSingleScan(DO, [1 1 0 0 0 0 1 0]);
                outputSingleScan(DO, [0 1 0 0 0 0 1 0]);
                WaitSecs(0.75);
              end

                intertrial_interval = intertrial_interval_correct-gate_off_time;
                repeatcounter = repeatcounter + 1;
                IndexHist(CurrentClass) = CurrentClass;
            else
                AllData.trials(save_counter).Reward = 'No';                
                dataout(outputcounter,1:7) = {outputcounter-blockcounter, CurrentClass, correctcounter, 0,ReactionTime,GeneralVars.ClassStructure(CurrentClass).Notes,Statecode}                   
                %  Incorrect auditory feedback
%                 if Statecode > 3
%                     putvalue(dio, [0 0 0 1 0 0 0 1]);
%                     putvalue(dio, [0 0 0 0 0 0 0 1]);
%                 end
                wavesoundplay('wrong.wav',0.6);               
                intertrial_interval = intertrial_interval_error-gate_off_time;
            end
         %   waitsecs(subWrong);
                all_eye     = trial_eye_data;
                all_eyetime = trial_eye_timestamp;
                stop(ai);
                set(hLine(4), 'XData',all_eyetime,...
                    'YData', all_eye(:,1));
                set(hLine(5), 'XData',all_eyetime,...
                    'YData', all_eye(:,2));
                set(hAxes(2),'YLim', [-15 15],'XLim', [0 sum(datain(1:4))+2*aquisition_time]);
                set(hAxes(3),'YLim', [-15 15],'XLim', [0 sum(datain(1:4))+2*aquisition_time]);
                drawnow
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
            outputSingleScan(DO, [0 1 0 0 0 0 0 0]);
            outputSingleScan(ao,[0,0]);
     %       outputSingleScan(ao,0);
            Screen(window,'FillRect',black)  % Clear screen
            %  Intertrial inverval
            while ((GetSecs - breaktime) < intertrial_interval) & (BreakState ~=1)
                eye=inputSingleScan(ai);
                eyeX = (((eye(1,1)-Xscalecenter)*Xscale));
                eyeY = -1*(((eye(1,2)-Yscalecenter)*Yscale));
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
%catch
%    lasterr
%end
outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
save(['C:\Users\CCLAB\Documents\MATLAB\Behavioral_Data\' savename],'AllData');
%clear 
%CleanUp

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function WaveUpdateEyeDisplay(StimulusCoordinates, FixWindow, FixPosition, vstruct, hLine,visability)
xStimDisplay = (((StimulusCoordinates(1,1)+StimulusCoordinates(1,3))/2)-(vstruct.res(1)/2))*vstruct.degpix(1);
xWindowPosition = (((FixPosition(1,1)+FixPosition(1,3))/2)-(vstruct.res(1)/2))*vstruct.degpix(1);
yStimDisplay = ((((StimulusCoordinates(1,2)+StimulusCoordinates(1,4))/2)-(vstruct.res(2)/2))*vstruct.degpix(2))*-1;
yWindowPosition = ((((FixPosition(1,2)+FixPosition(1,4))/2)-(vstruct.res(2)/2))*vstruct.degpix(2))*-1;
xWindowDisplay = FixWindow(1,:)+ xWindowPosition;
yWindowDisplay = FixWindow(2,:)+ yWindowPosition;
set(hLine(1),'XData',xStimDisplay,'YData',yStimDisplay,'Visible',visability); 
set(hLine(3),'XData',xWindowDisplay,'YData',yWindowDisplay,'Visible',visability);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [eyeX, eyeY] = DisplayEye(hAxes, hLine, Xscale, Yscale, ai)
global trial_eye_data
% trial_eye_data
% eye=inputSingleScan(ai);
if isempty(trial_eye_data)
    eye =[0, 0];
else
    eye = trial_eye_data(end, :);

end
eyeX = (((eye(1,1)-0)*Xscale));
eyeY = -1*(((eye(1,2)-0)*Yscale));
set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);    
set(hLine(2), 'XData', eyeX, 'YData', eyeY); % eye position
drawnow


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FixState,BreakState] = CheckFixation(cCenter, WindowRadius,Xscale,Yscale,ai)
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
eyeX = (((eye(1,1)-0)*Xscale));
eyeY = -1*(((eye(1,2)-0)*Yscale));

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