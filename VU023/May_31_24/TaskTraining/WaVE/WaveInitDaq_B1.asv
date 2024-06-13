AI                    = daq.createSession('ni');
AI.Rate               = 500;
ACH                   = addAnalogInputChannel(AI,'Dev1',0:2,'Voltage');
ACH(1).TerminalConfig = 'SingleEnded';
ACH(1).Range          = [-10.0 10.0];
ACH(2).TerminalConfig = 'SingleEnded';
ACH(2).Range          = [-10.0 105.0];
ACH(3).TerminalConfig = 'SingleEnded';
ACH(3).Range          = [-5.0 5.0];
AI.ExternalTriggerTimeout =Inf;
AI.TriggersPerRun =Inf;
% AI.IsContinuous = true;
AI.addlistener('DataAvailable',@(src,event) plot(event.TimeStamps, event.Data));
%  AI.TriggersPerRun
data=AI.inputSingleScan

% AI.TriggersPerRun
AI.startBackground;


Ach(1).TerminalConfig = 'SingleEnded';
Ach(1).Range = [-5.0 5.0];

% 
% In a typical workflow, 
%      (1) Discover hardware devices using daq.getDevices
%      (2) Create a daq Session using daq.createSession
%      (3) Add device channels
%      (4) Add device connections
%      (5) Set session and channel properties
%      (6) Perform on demand operations using inputSingleScan/outputSingleScan
%      (7) Perform clocked operations using startForeground/startBackground
%  



% 
data =AI.inputSingleScan;
AI.DurationInSeconds=50;
[data,time]=AI.startBackground;
h=animatedline;
x=time;
for k=1:25000
    y=data(k);
    addpoints(h,x(k),y);
    drawnow
end


  

% AI.addTriggerConnection('External','Dev1/PFI0','StartTrigger');

% DIO= daq.createSession('ni');
% addDigitalChannel(DIO,'dev1','Port0/Line0:7','OutputOnly');
% % 
% openExample('daq/AnalogTriggerAppExample')


%      s.IsContinuous = true;
%      data = sin(linspace(0, 2*pi, 1001));
%      data(end) = [];
%      s.queueOutputData(data);
%      lh = s.addlistener('DataRequired', ...
%         @(src,event) src.queueOutputData(data));
%      s.startBackground();
%      delete(lh);
%      s = daq.createSession('ni');                      % Create session
%        s.addAnalogInputChannel('Dev3',0,'Voltage'); % Add an analog input
%        data = s.startForeground();                       % Acquire data
%        plot(data)
% 
%   lh = AI.addlistener('DataAvailable', ...
%           @(src,event) plot(event.TimeStamps, event.Data));
%       AI.startBackground();
%       delete(lh);
% % ai.TriggerRepeat = Inf;
% % ai.TriggerType = 'Immediate';
% % ai.SamplesPerTrigger = Inf;
% 
% startForeground(S);
% 
% S.Connections(1).TriggerCondition = 'RisingEdge';
% s.ExternalTriggerTimeout = 1000;
% 
% S.TriggersPerRun = 2;
% 
% 
% 
% [data,timeStamps,triggerTime] = S.startForeground();
% plot(timeStamps,data,'.')
% S.Triggers


ai = analoginput('nidaq',1);
addchannel(ai,0);
addchannel(ai,1);
addchannel(ai,2);%xq
ai.Channel.InputRange = [-10 10];
ai.SampleRate = 500;
ai.InputType = 'SingleEnded';
ai.TriggerRepeat = Inf;
ai.TriggerType = 'Immediate';
ai.SamplesPerTrigger = Inf;
dio = digitalio('nidaq',1);
addline(dio, 0:7, 0, 'Out');

