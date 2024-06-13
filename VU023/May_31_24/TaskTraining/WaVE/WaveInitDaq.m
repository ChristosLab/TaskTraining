AI = daq.createSession('ni');
AI.Rate =500;
Ach=addAnalogInputChannel(AI,'Dev1',0,'Voltage');
Ach(1).TerminalConfig = 'SingleEnded';
Ach(1).Range = [-5.0 5.0];
Ach(2).TerminalConfig = 'SingleEnded';
Ach(2).Range = [-5.0 5.0];
Ach(3).TerminalConfig = 'SingleEnded';
Ach(3).Range = [-5.0 5.0];

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
% AI.ExternalTriggerTimeout =Inf;
% AI.TriggersPerRun =1;
% AI.IsContinuous = true;
% AI.addlistener('DataAvailable',@(src,event) plot(event.TimeStamps, event.Data));
 
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