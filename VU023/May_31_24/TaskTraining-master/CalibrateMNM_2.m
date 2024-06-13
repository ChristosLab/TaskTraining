  function ODR(varargin)
%  Travis Meyer 05-19-04
%     Now user can only break out of the program during intertrial interval
global ai APMConn vstruct pixdeg degpix
[mousex,mousey] = getmouse;
warning off all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
if nargin < 1                      %   If there are no arguments given
    datain(1:4) = [1.0 .1 .1 .1];     %  Default waiting times for each frame
    datain(5) = 3;                 %  Trial type
    datain(6) = 10;                %  Number of trials
    datain(7) = 10;                %  Stimulus eccentricity
    datain(8) = 10;                 %  Radius in pixels of fixation window
    datain(9) = 5;                %  Repeat stimulus this many times
    datain(10) = 127;
    datasin = 'GRUeye00000';               %file name
    vstruct.res = [1280 1024];     % screen resolution
    vstruct.siz = [61 46];        % screen size in cm [61 55]
    vstruct.dis = 60;             % viewing distance in cm
    vstruct.ang = 10;
    vstruct.voltage = 3.5;        % Analog to degree conversion constant
else
    % arguments exist from Gui, use them
    dataintemp = varargin(1);      % varargin is cell and convert to structure
    datain(1:11) = dataintemp{1,1};
    datasin = varargin{2};
    vstruct = varargin{3}
end

%  Calculate Pixels/Degree using CalcAngs function
pix=vstruct.siz./vstruct.res; %calculates the size of a pixel in cm
degpix=(2*atan(pix./(2*vstruct.dis))).*(180/pi);
pixdeg=1./degpix;
vstruct.pixvolt = pixdeg*vstruct.voltage;
vstruct.pixeye  = vstruct.res./(vstruct.voltage*20);

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
pixs = [pixsX -pixsY; 0 -pixsY; -pixsX -pixsY; -pixsX 0; -pixsX pixsY; 0 pixsY; pixsX pixsY; pixsX 0; 0 0];
newcoors = [vstruct.ang vstruct.ang;0 vstruct.ang; -vstruct.ang vstruct.ang; -vstruct.ang 0;...
        -vstruct.ang -vstruct.ang; 0 -vstruct.ang; vstruct.ang -vstruct.ang; vstruct.ang 0; 0 0]; 

StimSize = [5 5];                        % size of the stimuli in pixels
FixationWindow = datain(8);
TargetWindow = datain(9);
Xscale = 3.5;
Xscalecenter = 0;
Yscale = 3.5;
Yscalecenter = 0;

centerX = vstruct.res(1,1)/2;            % Calculate the center of the screen (X)
centerY = vstruct.res(1,2)/2;            % Calculate the center of the screen (Y)
X1 = centerX-StimSize(1,1);              % With center pixel, make rectangle around it
X2 = centerX+StimSize(1,1);
Y1 = centerY-StimSize(1,2);
Y2 = centerY+StimSize(1,2);
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
figPos=[(screenSize(3)+5) 40  ...
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

% Create Data subplot.

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
    tCenter(n*45,:) = pixs(n,:)+[centerX centerY];
    wRect(n*45,:) = [X1+(pixs(n,1)),Y1+(pixs(n,2)),X2+(pixs(n,1)),Y2+(pixs(n,2))];
    dRect(n*45,1:2) = [newcoors(n,1) newcoors(n,2)];
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
        totalframes = 3;
end
% Number of Trials
totalblocks = datain(6);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate 8 random integers and * 45 for shuffled degrees for each trial
% Then generate two opposing random points in the 2nd and 3rd dimension of Seq
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


for n = 1:totalblocks
    Seq(n,:,1) = [405 360 45 90 135 180 225 270 315];
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate variable to store data to be saved as filenames
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

white=WhiteIndex(0);
black=BlackIndex(0);
gray = datain(10);
[window] = screen(0,'OpenWindow',black,[],32);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  Make offscreen windows  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus + Fixation (sf) and Stimulus alone (s)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

for n = 45:45:405
    s(n) = SCREEN(window,'OpenOffscreenWindow',black,[],32); 
    screen(s(n),'FillRect',white,wRect(n,:));
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Configure the Nidaq board   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

ai = analoginput('nidaq',1);
addchannel(ai,0);
addchannel(ai,1);
addchannel(ai,2);%xq
ai.Channel.InputRange = [-10 10];
ai.SampleRate = 1000;
ai.InputType = 'SingleEnded';
ai.TriggerRepeat = Inf;
ai.TriggerType = 'Immediate';
ai.SamplesPerTrigger = Inf;
dio = digitalio('nidaq',1);
addline(dio, 0:7, 0, 'Out');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Start Trial
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
filename = ['/DataFiles/',datasin,'.apm'];   % Saves data in the root of the hard disk, to be able to find it easily.


% sendapmfilename(filename)
% pause(.5)
% startrecording
% pause(.1)
%     sendapmmessage
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
totaltrials = 9;
repeatmax = datain(9);
repeatcounter = 0;
BreakState = 0;
outputcounter = 0;
correctcounter = 0;
intertrial_interval = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Code
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
start(ai)
waitsecs(.1)
AllData.synctime = clock;
AllData.starttime = getsecs;
blockcounter = 1;
try
    while (BreakState ~= 1) & (blockcounter <= totalblocks)
        trialcounter = 1;
        AllData.block(blockcounter).time = getsecs;
        outputcounter = outputcounter + 1;
        dataout(outputcounter,1:4) = {'Trial' 'Trial Type' 'Trials Correct' 'Success'};
        while (trialcounter <= totaltrials) & (BreakState ~=1)
            repeatcounter = 1;
%             putvalue(dio, [0 0 0 0 0 0 0 1]);
            Deg = Seq(blockcounter,trialcounter);
            flushdata(ai)
            AllData.outputcounter = outputcounter;
            AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).repeat(repeatcounter).time = getsecs;
            AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).degree = Seq(blockcounter,trialcounter);
            while (repeatcounter <= repeatmax) & (BreakState ~=1)
                outputcounter = outputcounter + 1;
                while 1
                    Statecode = 1;
                    FixState = 0;
                    Result = 0;
                    %  Display Fixation
                    SCREEN(window,'WaitBlanking');   % Wait for the next monitor refresh cycle
                    Screen('CopyWindow',s(Deg),window);   % First frame is fixation window
%                     putvalue(dio, [0 0 0 0 0 0 1 1]);
                    SCREEN(window,'waitBlanking');
%                     putvalue(dio, [0 0 0 0 0 0 0 1])3
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).fixOn=getsecs;
                    xStimDisplay = dRect(Deg,1);
                    yStimDisplay = dRect(Deg,2);
                    xWindowDisplay = (datain(8)*xcoord)+xStimDisplay;
                    yWindowDisplay = (datain(8)*ycoord)+yStimDisplay;
                    set(hLine(1),'XData',xStimDisplay,'YData',yStimDisplay,'Visible', 'on'); % stimulus position
                    set(hLine(3),'XData',xWindowDisplay,'YData',yWindowDisplay);
                    breaktime = getsecs;
                    %  Give subject 2 seconds to move to fixation window
                    while (FixState <= 0) & ((getsecs - breaktime) < 2)
                        eye = getsample(ai);
                        eyeX = (((eye(1,2)-Xscalecenter)*Xscale));
                        eyeY = (((eye(1,1)-Yscalecenter)*Yscale));
                        set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);    
                        set(hLine(2), 'XData', eyeX, 'YData', eyeY*-1); % eye position
                        drawnow    
                        [FixState] = CheckFixation(tCenter(Deg,:), FixationWindow);
                    end
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).fixIn=getsecs;
                    
                    %  If subject didn't get to window within 2 seconds, or break
                    %  button was pushed, break out of trial
                    if FixState == 0
                        break;
                    end
                    Statecode = 2;
                    breaktime = getsecs;
%                     AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).fixIn=breaktime;
%                     [eyeT timeEye]=getsample(ai);
%                     AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).fixInEye=timeEye;
                    %  Mouse must stay within fixation window for frame1 time
                    while (FixState == 1) & ((getsecs - breaktime) < frame1)
                        eye = getsample(ai);
                        eyeX = (((eye(1,2)-Xscalecenter)*Xscale));
                        eyeY = (((eye(1,1)-Yscalecenter)*Yscale));
                        set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);    
                        set(hLine(2), 'XData', eyeX, 'YData', eyeY*-1); % eye position
                        drawnow    
                        [FixState] = CheckFixation(tCenter(Deg,:), FixationWindow);
                    end
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).fixOut=getsecs;

                    if FixState == 0
                        break;
                    end
                    Result = 1;
%                     [eyeT timeEye]=getsample(ai);
%                     AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).fixOutEye=timeEye;
                    break
                end
                %  If this point in the code is reached, the subject completed
                %  the trial successfully and Result is changed from 0 to 1
%                 putvalue(dio, [0 0 0 0 0 0 0 0]);
                Screen(window,'FillRect',black)  % Clear screen
                set(hLine(1),'Visible', 'off'); % stimulus position
                set(hLine(3),'XData',(datain(8)*xcoord)+xStimDisplay,'YData',(datain(8)*ycoord)+yStimDisplay);
                if Result == 1
                    RectionTime = 0;
                    [AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,1:3), ...
                            AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,4)] = getdata(ai,ai.SamplesAvailable);
                    
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).Rewardtime = getsecs;
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).Reward = 'Yes';
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).Statecode = Statecode;
%                     sendapmreward(((blockcounter-1)*8)+trialcounter,1)
                    clc
                    correctcounter = correctcounter + 1;
                    dataout(outputcounter,1:4) = {outputcounter-blockcounter, trialtype, correctcounter, 1}
                    %  Correct auditory feedback            
                    putvalue(dio, [1 0 0 0 0 0 0 0]);
                    SND('Play',[sin(1:500)],[2000]);
                    intertrial_interval = 2;
                    putvalue(dio, [0 0 0 0 0 0 0 0]);
                else
                    RectionTime = 0;
                    [AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,1:3), ...
                            AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,4)] = getdata(ai,ai.SamplesAvailable);
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).Rewardtime = getsecs;
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).Reward = 'No';
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).Statecode = Statecode;
%                     sendapmreward(((blockcounter-1)*8)+trialcounter,0)
                    clc
                    dataout(outputcounter,1:4) = {outputcounter-blockcounter, trialtype, correctcounter, 0}                   
                    %  Incorrect auditory feedback
                    SND('Play',[sin(1:500)],[1000]);
                    intertrial_interval = 2;
                end
%                 sendapmmessage(((blockcounter-1)*8)+trialcounter,Deg,datain(7), trialtype)
%xq 2018 4 23
                set(hLine(4), 'XData',(AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,4)- ... 
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(1,4)), ...
                    'YData', AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,2))
                set(hLine(5), 'XData',(AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,4)- ... 
                    AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(1,4)), ...
                    'YData', AllData.block(blockcounter).trial(trialcounter).repeat(repeatcounter).EyeData(:,1))
                set(hAxes(2),'YLim', [-10 10],'XLim', [0 sum(datain(1:totalframes))])
                set(hAxes(3),'YLim', [-10 10],'XLim', [0 sum(datain(1:totalframes))])
                drawnow
                breaktime = getsecs;
                %  Intertrial inverval
                while ((getsecs - breaktime) < intertrial_interval) & (BreakState ~=1)
                    eye = getsample(ai);
                    eyeX = (((eye(1,2)-Xscalecenter)*Xscale));
                    eyeY = (((eye(1,1)-Yscalecenter)*Yscale));
                    set(hAxes(1), 'XLim', [-25 25],'YLim', [-25 25]);
                    set(hLine(2), 'XData', eyeX, 'YData', eyeY*-1, 'marker', '+')
                    drawnow
                    BreakState = CheckBreakState;
                end
                if (BreakState == 1)
                    break;
                end
                repeatcounter = repeatcounter + 1;
                SND('Quiet');  %  Clear soundcard buffer
            end
            trialcounter = trialcounter + 1;
        end
        blockcounter = blockcounter + 1;
    end
catch
    lasterr
end
putvalue(dio, 0)
waitsecs(1)
% APMMsg=uint32([]);
% APMMsg(1)=uint32(hex2dec('10000')); % Message code
% APMMsg(2)=uint32(0);                % Channel
% APMMsg(3)=uint32(1);                % Message length (number of 32-bit words to follow)
% APMMsg(4)=uint32(0);                % Recording ON/OFF (1/0)
% pnet(APMConn,'write',uint32(APMMsg),'intel');   % Send the array to APM
Screen('CloseAll')
stop(ai)
AllData.endtime = getsecs;
[AllData.eyedata,AllData.eyetime,AllData.eyeabstime,AllData.eyelog] = getdata(ai,ai.SamplesAvailable);
close(hFig)
daqreset
save(['C:\MATLAB6p5\work\Behavioral_Data_Files\' datasin],'AllData')
clear


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function apmstatus = startrecording
    global APMConn
    APMHost = '172.17.11.122';
    APMMsgPort = 2566;
    pnet('closeall');
    pause(0.1);
    APMConn=pnet('tcpconnect',APMHost,APMMsgPort);
    % Send the start recording command
    % Build a message with the standard APM format (see data data file format topic in the APM help file)
    APMMsg=uint32([]);
    APMMsg(1)=uint32(hex2dec('10000')); % Message code
    APMMsg(2)=uint32(0);                % Channel
    APMMsg(3)=uint32(1);                % Message length (number of 32-bit words to follow)
    APMMsg(4)=uint32(1);                % Recording ON/OFF (1/0)
    pnet(APMConn,'write',uint32(APMMsg),'intel');   % Send the array to APM
    pause(0.1);
    ConnStat=pnet(APMConn,'status');
    if ConnStat < 0
       disp('Could Not Connect to APM!')
       apmstatus = 0;
   else
       apmstatus = 1;
   end
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sendapmmessage(trialcounter,Deg,Ecc, trialtype)
global APMConn
    outlength = 4;  % 1 trialnum int + 2 dir double + 2 ecc double + 1 ttype int
    APMMsg=uint32([]);
    APMMsg(1)=uint32(hex2dec('10100')); % Message code
    APMMsg(2)=uint32(0);                % Channel
    APMMsg(3)=uint32(outlength);       % Message length (number of 32-bit words to follow)
    % Send the information as an integer containig the value multiplied by 100
    % This is equivalent to sending a float with two decimal points precision
    APMMsg(4)=uint32(trialcounter);
    APMMsg(5)=uint32(trialtype);
    APMMsg(6)=uint32(Deg*100);
    APMMsg(7)=uint32(Ecc*100);
    % Add here whatever you want to send, and keep in mind to increment the
    % message length to match the number of uint32 in the message
    pnet(APMConn,'write',APMMsg,'intel');   % Send the array to APM
    pause(.1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sendapmreward(trialcounter,reward)
global APMConn
    APMMsg=uint32([]);
    APMMsg(1)=uint32(hex2dec('10101')); % Message code
    APMMsg(2)=uint32(0);                % Channel
    APMMsg(3)=uint32(2);       % Message length (number of 32-bit words to follow)
    % Send the information as an integer containig the value multiplied by 100
    % This is equivalent to sending a float with two decimal points precision
    APMMsg(4)=uint32(trialcounter);
    APMMsg(5)=uint32(reward);
    pnet(APMConn,'write',APMMsg,'intel');   % Send the array to APM
    pause(.1);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function sendapmfilename(filename)
global APMConn
filename
    APMHost = '172.17.11.122';
    APMMsgPort = 2566;
    pnet('closeall');
    pause(0.1);
    APMConn=pnet('tcpconnect',APMHost,APMMsgPort);
    missingBytes=4-mod(length(filename),4);
    if (missingBytes<4)
        filename=[filename uint8(zeros(1,missingBytes))];
    end;
    APMMsg=uint32([]);
    APMMsg(1)=uint32(hex2dec('10002'));  % Message code
    APMMsg(2)=uint32(0);                % Channel
    APMMsg(3)=uint32(length(filename)/4);                % Message length (number of 32-bit words to follow)
    pnet(APMConn,'write',uint32(APMMsg),'intel');   % Send the header to APM
    pnet(APMConn,'write',uint8(filename),'intel');  % Send the string to APM

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [FixState,BreakState] = CheckFixation(cCenter, WindowRadius)
%  CheckFixation is a subfunction that inputs rectangular coordinates and
%  duration to check that the mouse coordinates stay within the inputed
%  rectangle for the duration and send back to the main function whether 
%  the subject was successful or errored or clicked the mouse button.  
global ai Xscalecenter Xscale Yscalecenter Yscale vstruct degpix

eye = getsample(ai);
eyeX = (eye(1,2)*vstruct.pixvolt(1))+(vstruct.res(1)/2);
eyeY = (eye(1,1)*vstruct.pixvolt(2))+(vstruct.res(2)/2);

%  Compare distance from mouse coordinates from inputed window center
if ((((cCenter(1,1)-eyeX)*degpix(1))^2)+(((cCenter(1,2)-eyeY)*degpix(2))^2))^.5 <= WindowRadius
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