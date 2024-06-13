 function Train_ODR_Lab(varargin)
%  Balbir Singh 10-31-19
%  Now user can only break out of the program during intertrial interval
%  only display 8 stimulus in a circle for training 

% VBLSyncTest  %synchronization test
%   Screen('Preference', 'EmulateOldPTB', 0) % Old function used in script
clc
clear all;
close all;
[mousex,mousey] = GetMouse;
warning off all;

%%%%%%%%%%%%%%%%%%%%%%%%%%%
 if nargin<1
    datain(1:4)     = [1.5 0.5 0.5 0.2]; %  Default waiting times for each frame fixation, cue, delay
    datain(5)       = 4;                 %  Trial type
    datain(6)       = 40;                %  Number of blocks
    datain(7)       = 10;                %  Stimulus eccentricity
    datain(8)       = 5;                 %  Radius in degrees of fixation window
    datain(9)       = 6;                 %  Radius in degrees of target window
    datain(10)      = 255;               %  Stimulus Luminance
    gray2           = 250;               % Luminance of second stimulus (for training purposes)
    datasin         = 'TEMP';
    burst_amount    = 3;
    aquisition_time = 2.0;
    
    %%%%%%   Visual Settings  %%%%%%%%%%%%%%%%%%%%%%%
    vstruct.res     = [1280 1024];                     % screen resolution
    vstruct.siz     = [61 46];                         % screen size in cm  %[61 55]
    vstruct.dis     = 68;                              % viewing distance in cm
    vstruct.voltage = 3.5;                             % Analog to degree conversion constant
    vstruct.radius  = datain(7);                       % Stimulus excentricity
    vstruct.angs    = [360 45 90 135 180 225 270 315]; % Stimulus angles
    vstruct.angs2   = [1:8]; 
    vstruct.par     = [200 160];                      % size of the stimuli in pixels
 else
%     %%%% arguments exist from Gui, use them
    dataintemp      = varargin(1);      % varargin is cell and convert to structure
    datain(1:11)    = dataintemp{1,1};
    datasin         = varargin{2};
    vstruct         = varargin{3};
end

%%%% Initialize number of class
correct_class(1:8) = ones(1,8)*0;
errors(1:8)        = 0;
errors2(1:8)       = 0;

%%%%%%% Initialize eye display figure %%%%%%%%%%%
[Figdata, hFig, hAxes, hLine] = WaveInitEyeDisplay;

%%%%%%% Initialize Nidaq board   %%%%%%%%%%%%%%%%%

WaveInitDaq_eye;

%%%%%%%%% Calculate Pixels/Degree constants and coordinates %%%%%%%%%%%%%

[vstruct, Display] = WaveDisplayParams(vstruct, datain);  % make circle 

%%%%%%%%%% Declare Variables %%%%%%%%%%%%%%%%%%%
FixWindowSize(1,:)          = datain(8)*Figdata.xcoord;
FixWindowSize(2,:)          = datain(8)*Figdata.ycoord;
TarWindowSize(1,:)          = datain(9)*Figdata.xcoord;
TarWindowSize(2,:)          = datain(9)*Figdata.ycoord;
totalblocks                 = datain(6);
totaltrials                 = length(vstruct.angs);
consecutive_correct         = 0;
BreakState                  = 0;
outputcounter               = 0;
correctcounter              = 0;
blockcounter                = 1;
intertrial_interval_correct = 2;
intertrial_interval_error   = 2;

%%%%%%%%%% Fixation times in seconds %%%%%%%%%%%%%%%%%%%%
frame1 = datain(1);  %fixation time for fixation point
frame2 = datain(2);  %fixation time for fix + target display
frame3 = datain(3);  %fixation time for target alone display
frame4 = datain(4);  % fixation time on target until reward

%%%%%%%%%% Trial type, 1 = visual, 2 = memory, 3 = No Saccade %%%%%%%%
trialtype = datain(5);
switch trialtype
    case 1
        totalframes = 4;
    case 2
        totalframes = 4;
    case 3
        totalframes = 3;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% %  Declare coordinates of 8 points and fixation point
% %  Coordinates in pixels on 1280/1024 32 bit display
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fCenter  = [Display.centerX,Display.centerY];
fRect    = [Display.fX1,Display.fY1,Display.fX2,Display.fY2];
for n = 1:8
    tCenter(n,:) = Display.pixs(n,:)+[Display.centerX Display.centerY];
    wRect(n,:)   = [Display.X1+(Display.pixs(n,1)),Display.Y1 + ...
                   (Display.pixs(n,2)),Display.X2+(Display.pixs(n,1)),...
                   Display.Y2+(Display.pixs(n,2))];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Generate 8 random integers and * 45 for shuffled degrees for each trial
% % Then generate two opposing random points in the 2nd and 3rd dimension of Seq
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RandYN = rand(totalblocks,8);
for n = 1:totalblocks
    Seq(n,:,1) = vstruct.angs2(randperm(8)); % sample display
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Generate variable to store data to be saved as filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
white    = WhiteIndex(0);
black    = BlackIndex(0);
gray     = datain(10);
[window] = Screen(2,'OpenWindow',black,[],32);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % Make offscreen windows  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
f = Screen(window,'OpenOffscreenWindow',black,[],32);
Screen(f,'FillRect',white,fRect);                      % Fixation

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus + Fixation (sf) and Stimulus alone (s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for n = 1:8
    sf(n)      = Screen(window,'OpenOffscreenWindow',black,[],32);
    Screen(sf(n),'FillRect',white,fRect);
    Screen(sf(n),'FillRect', gray,wRect(n,:));
    s(n)       = Screen(window,'OpenOffscreenWindow',black,[],32); 
    Screen(s(n),'FillRect',gray,wRect(n,:));
    secstim(n) = Screen(window,'OpenOffscreenWindow',black,[],32); 
    Screen(secstim(n),'FillRect',gray2,wRect(n,:));
end
datain(7);

% %%%%%%%%%%%% Main Code %%%%%%%%%%%%%%%%%%%%%%
% %%%%%%% Start Nidaq board   %%%%%%%%%%%%%%%%%
% % AI.addlistener('DataAvailable',@(src,event) src.queueOutputData(data));
% % queueOutputData(AI,data);
% startBackground(AI) ;
startForeground(AI) ;
WaitSecs(.1)
AllData.synctime  = clock;
AllData.starttime = GetSecs;

try
    while (BreakState ~= 1) && (blockcounter <= totalblocks)
        trialcounter                     = 1;
        AllData.block(blockcounter).time = GetSecs;
        outputcounter                    = outputcounter + 1;
        dataout(outputcounter,1:8)       = {'Trial' 'Trial Type' 'Correct' ...
            'Success' 'All %' 'All_delayerror %' 'Current Class %' 'Reaction Time'};
        while (trialcounter <= totaltrials) & (BreakState ~=1)
%             outputSingleScan(AI, [0 0 0 0 0 0 0 1]);
            Deg                   = Seq(blockcounter,trialcounter);
            % %             flushdata(ai) %% don't need for new Niadq
            AllData.outputcounter = outputcounter;
            AllData.block(blockcounter).trial(trialcounter).time   = GetSecs;
            AllData.block(blockcounter).trial(trialcounter).degree = Seq(blockcounter,trialcounter);
            outputcounter = outputcounter + 1;
            while 1
                Statecode  = 1;
                BreakTwice = 0;
                FixState   = 0;
                Result     = 0;
                WaveDisplayStimulus(f, window);          %  Display Fixation
                WaveUpdateEyeDisplay(fRect, FixWindowSize, fRect,vstruct, hLine,'on')
                breaktime  = GetSecs;
                %  Give subject 2 seconds to move to fixation window
                while (FixState <= 0) && ((GetSecs - breaktime) < aquisition_time)
                    [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, AI);    
                    [FixState]   = CheckFixation(fCenter, Display.FixationWindow, AI, vstruct);
                end
                %  If subject didn't get to window within 2 seconds, or break  button was pushed, break out of trial
                if FixState == 0
                    break;
                end
                Statecode = 2;
                breaktime = GetSecs;
                %  Mouse must stay within fixation window for frame1 time
                while (FixState == 1) && ((GetSecs - breaktime) < frame1)
                    [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, AI);
                    [FixState]   = CheckFixation(fCenter, Display.FixationWindow, AI, vstruct);
                end            
                if FixState == 0
                    break;
                end
                
                Statecode = 3;    %  Display Fixation plus stimulus
                WaveDisplayStimulus(sf(Deg), window)
                WaveUpdateEyeDisplay(wRect(Deg,:), FixWindowSize, fRect, vstruct, hLine,'on')                     
                breaktime = GetSecs;
                %  Check that mouse stays within fixation window for frame2 time
                while (FixState == 1) && ((GetSecs - breaktime) < frame2)
                    [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, AI);
                    [FixState]   = CheckFixation(fCenter, Display.FixationWindow, AI, vstruct);
                end
                if FixState == 0
                    break;
                end
                
                Statecode = 4;   %  Depending on the trial, the next frames are differ
                switch trialtype %  Visually guided movement
                    case (1)
                        FixState = 0; 
                        WaveDisplayStimulus(s(Deg), window)   %  Display only stimulus
                        WaveUpdateEyeDisplay(wRect(Deg,:), FixWindowSize, wRect(Deg,:), vstruct, hLine,'on')
                        breaktime = GetSecs;
                        while (FixState == 0) && ((GetSecs - breaktime) < aquisition_time)
                            [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, AI);
                            [FixState]   = CheckFixation(tCenter(Deg,:), Display.FixationWindow, AI, vstruct);
                        end
                        RectionTime = GetSecs-breaktime;
                        if FixState == 0
                            BreakTwice = 1;
                            break;
                        end
                        
                        Statecode = 5;
                        breaktime = GetSecs;
                        %  Check that mouse stays in window for frame3 time
                        while (FixState == 1) && ((GetSecs - breaktime) < frame3)
                            [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, AI);
                            [FixState]   = CheckFixation(tCenter(Deg,:), Display.FixationWindow, AI, vstruct);
                        end
                        if FixState == 0 %  If an error occurred, break out of the switch and the while loop.
                            BreakTwice =1;
                            break;
                        end
                        %  Memory guided movement
                    case(2)
                        FixState = 0;
                        Screen(window,'WaitBlanking');   %  Display an all black screen
                        Screen(window,'FillRect',black);
                        WaveUpdateEyeDisplay(wRect(Deg,:), FixWindowSize, wRect(Deg,:), vstruct, hLine,'on')
                        breaktime = GetSecs;
                        while (FixState == 0) && ((GetSecs - breaktime) < 2) %  Give 2 seconds to get to stimulus window
                            [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, AI);
                            [FixState]   = CheckFixation(tCenter(Deg,:), Display.FixationWindow, AI, vstruct);
                        end
                        RectionTime = GetSecs-breaktime;
                        if FixState == 0
                            BreakTwice = 1;
                            break;
                        end
                        
                        Statecode = 5;   %  Make sure mouse stays in window for frame3 time
                        breaktime = GetSecs;
                        while (FixState == 1) && ((GetSecs - breaktime) < frame3)
                            [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, AI);
                            [FixState]   = CheckFixation(tCenter(Deg,:), Display.FixationWindow, AI, vstruct);
                        end                 
                        if FixState == 0
                            BreakTwice =1;
                            break;
                        end
                        
                    case(3) %  No movement required
                        WaveDisplayStimulus(f, window)   %  Display fixation only
                        WaveUpdateEyeDisplay(fRect, FixWindowSize, fRect, vstruct, hLine,'on')
                        breaktime = GetSecs;
                        while (FixState == 1) && ((GetSecs - breaktime) < frame3) %  Make sure mouse stays in window for frame3 time
                            [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, AI);
                            [FixState]   = CheckFixation(fCenter, Display.FixationWindow, AI, vstruct);
                        end
                        RectionTime = 0;
                        if FixState == 0
                            BreakTwice =1;
                            break;
                        end
                        Result = 1;
                        
                    case(4)   % Saccade to visible, second stimulus (for training purposes)
                        WaveDisplayStimulus(f, window) %  Display fixation only
                        WaveUpdateEyeDisplay(fRect, FixWindowSize, fRect, vstruct, hLine,'on')
                        breaktime = GetSecs;
                        while (FixState == 1) && ((GetSecs - breaktime) < frame3)  % Make sure mouse stays in window for frame3 time
                            [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, AI);
                            [FixState]   = CheckFixation(fCenter, Display.FixationWindow, AI, vstruct);
                        end
                        RectionTime = 0;
                        if FixState == 0
                            BreakTwice =1;
                            break;
                        end
                        
                        
                        Statecode = 7;
                        FixState  = 0;
                        WaveDisplayStimulus(secstim(Deg), window);  %  Display only stimulus
                        WaveUpdateEyeDisplay(wRect(Deg,:), TarWindowSize, wRect(Deg,:), vstruct, hLine,'on')
                        breaktime = GetSecs;
                        while (FixState == 0) && ((GetSecs - breaktime) < aquisition_time)
                            [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, AI);
                            if Deg == 2 || Deg == 8 || Deg ==6
                                [FixState] = CheckFixation(tCenter(Deg,:), Display.TargetWindow +2, AI, vstruct);
                            elseif Deg == 7
                                [FixState] = CheckFixation(tCenter(Deg,:), Display.TargetWindow +1, AI, vstruct);
                            else
                                [FixState] = CheckFixation(tCenter(Deg,:), Display.TargetWindow, AI, vstruct);
                            end
                        end
                       
                        Statecode = 5;
                        breaktime = GetSecs;
                        %  Check that mouse stays in window for frame3 time
                        while (FixState == 1) & ((GetSecs - breaktime) < frame4)
                            [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, AI);
                            [FixState]   = CheckFixation(tCenter(Deg,:), Display.TargetWindow, AI, vstruct);
                        end
                        if FixState == 0  %  If an error occurred, break out of the switch and the while loop.
                            BreakTwice =1;
                            break;
                        end
                end
                if BreakTwice == 1
                    break;
                end
                %  If this point in the code is reached, the subject completed
                %  the trial successfully and Result is changed from 0 to 1
                Result      = 1;
                Statecode   = 6; 
                RectionTime = GetSecs-breaktime;
                break
            end
%             outputSingleScan(AI,[0 0 0 0 0 0 0 0])
            Screen(window,'FillRect',black)  % Clear screen
            
            WaveUpdateEyeDisplay(fRect, FixWindowSize, fRect,vstruct, hLine, 'off')
            if Result == 1
                a=1
                [AllData.block(blockcounter).trial(trialcounter).EyeData(:,1:2), ...
                        AllData.block(blockcounter).trial(trialcounter).EyeData(:,3)] = inputSingleScan(AI);                   
                
                AllData.block(blockcounter).trial(trialcounter).Rewardtime = GetSecs;
                AllData.block(blockcounter).trial(trialcounter).Reward = 'Yes';
                AllData.block(blockcounter).trial(trialcounter).Statecode = Statecode;
                %                 APMSendReward(((blockcounter-1)*8)+trialcounter,1,APMConn)
                clc
                correctcounter = correctcounter + 1;
                correct_class(Seq(blockcounter,trialcounter))=  correct_class(Seq(blockcounter,trialcounter)) +1;
                dataout(outputcounter,1:8) = {((blockcounter-1)*8)+trialcounter, Seq(blockcounter,trialcounter), correctcounter, 1,sum(correct_class)./(sum(correct_class)+sum(errors)),sum(correct_class)./(sum(correct_class)+sum(errors2)), correct_class(Seq(blockcounter,trialcounter))/( correct_class(Seq(blockcounter,trialcounter))+ errors(Seq(blockcounter,trialcounter))),RectionTime}
                %  Correct auditory feedback            
                Snd('Play',[sin(1:500)],[1000]);
                consecutive_correct = consecutive_correct +1;
                for b = 1:burst_amount
                   outputSingleScan(AI, [0 0 0 1 0 0 0 1]);
                   outputSingleScan(AI, [0 0 0 0 0 0 0 1]);
                    WaitSecs(1)
                end
                intertrial_interval = intertrial_interval_correct;
            else
                RectionTime = 0;
                [AllData.block(blockcounter).trial(trialcounter).EyeData]  = inputSingleScan(AI);
                AllData.block(blockcounter).trial(trialcounter).Rewardtime     = GetSecs;
                AllData.block(blockcounter).trial(trialcounter).Reward         = 'No';
                AllData.block(blockcounter).trial(trialcounter).Statecode      = Statecode;
                if Statecode ==5 | Statecode == 7
                    errors(Seq(blockcounter,trialcounter)) = errors(Seq(blockcounter,trialcounter))+1;
                end
                if Statecode ==5 | Statecode == 7 | Statecode == 4
                    errors2(Seq(blockcounter,trialcounter)) = errors2(Seq(blockcounter,trialcounter))+1;
                end
                %                 APMSendReward(((blockcounter-1)*8)+trialcounter,0,APMConn)
                clc
                dataout(outputcounter,1:8) = {((blockcounter-1)*8)+trialcounter, Seq(blockcounter,trialcounter), correctcounter, 0,sum(correct_class)./(sum(correct_class)+sum(errors)), sum(correct_class)./(sum(correct_class)+sum(errors2)),correct_class(Seq(blockcounter,trialcounter))/( correct_class(Seq(blockcounter,trialcounter))+ errors(Seq(blockcounter,trialcounter))),RectionTime}                   
                %  Incorrect auditory feedback
                Snd('Play',[sin(1:500)],[1000]);
                consecutive_correct = 0;
                intertrial_interval = intertrial_interval_error;
            end
            %             APMSendMessage(((blockcounter-1)*8)+trialcounter,Deg,datain(7), trialtype, APMConn)
            set(hLine(4), 'XData',(AllData.block(blockcounter).trial(trialcounter).EyeData(:,3)- ... 
            AllData.block(blockcounter).trial(trialcounter).EyeData(1,3)), ...
            'YData', AllData.block(blockcounter).trial(trialcounter).EyeData(:,2))
            set(hLine(5), 'XData',(AllData.block(blockcounter).trial(trialcounter).EyeData(:,3)- ... 
            AllData.block(blockcounter).trial(trialcounter).EyeData(1,3)), ...
            'YData', AllData.block(blockcounter).trial(trialcounter).EyeData(:,1))
            set(hAxes(2),'YLim', [-10 10])
            set(hAxes(3),'YLim', [-10 10])
            drawnow
            %  Intertrial inverval
            breaktime = GetSecs;
            while ((GetSecs - breaktime) < intertrial_interval) & (BreakState ~=1)
                [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, AI);
                BreakState = CheckBreakState;
            end
            if (BreakState == 1)
                break;
            end
            Snd('Quiet');  %  Clear soundcard buffer
            trialcounter = trialcounter + 1;
        end
        blockcounter = blockcounter + 1;
    end
catch
    lasterr  

end
Screen('CloseAll');


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [eyeX, eyeY] = DisplayEye(Display, hAxes, hLine, AI)

eye = inputSingleScan(AI);
eyeX = (((eye(1,2)-Display.Xscalecenter)*Display.Xscale));
eyeY = (((eye(1,1)-Display.Yscalecenter)*Display.Yscale));
set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);    
set(hLine(2), 'XData', eyeX, 'YData', eyeY*-1); % eye position
drawnow

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FixState,BreakState] = CheckFixation(cCenter, WindowRadius, AI, vstruct)
%  CheckFixation is a subfunction that inputs rectangular coordinates and
%  duration to check that the mouse coordinates stay within the inputed
%  rectangle for the duration and send back to the main function whether 
%  the subject was successful or errored or clicked the mouse button.  

eye = inputSingleScan(AI);
eyeX = (eye(1,2)*vstruct.pixvolt(1))+(vstruct.res(1)/2);
eyeY = (eye(1,1)*vstruct.pixvolt(2))+(vstruct.res(2)/2);

%  Compare distance from mouse coordinates from inputed window center
if ((((cCenter(1,1)-eyeX)*vstruct.degpix(1))^2)+(((cCenter(1,2)-eyeY)*vstruct.degpix(2))^2))^.5 <= WindowRadius
    %  If distance between mouse and window is less than inputted radius,
    %  then mouse is in correct position
    FixState = 1;
else
%      If not then it is outside of the radius
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
