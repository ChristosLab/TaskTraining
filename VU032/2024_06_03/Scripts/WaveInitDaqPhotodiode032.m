% Added photodiode feedback into counter channel 0 and 3 for counting the
% rising and fall edges -ZW 4/22/23
ai = daq.createSession('ni');
Ach=addAnalogInputChannel(ai,'Dev1',[0:2],'Voltage');
Ach(1).TerminalConfig = 'SingleEnded';
Ach(1).Range = [-5.0 5.0];
Ach(2).TerminalConfig = 'SingleEnded';
Ach(2).Range = [-5.0 5.0];
Ach(3).TerminalConfig = 'SingleEnded';
Ach(3).Range = [-5.0 5.0];
Cch = addCounterInputChannel(ai,'Dev1',{'ctr0','ctr1'}, 'EdgeCount');
Cch(1).ActiveEdge = 'Rising';
Cch(2).ActiveEdge = 'Falling';
lh=addlistener(ai,'DataAvailable',@saveeyeData);
ai.Rate =500;
ai.DurationInSeconds=40;
ai.NotifyWhenDataAvailableExceeds = 1;

DO=daq.createSession('ni');
Dch=addDigitalChannel(DO,'Dev1','Port0/Line0:7','OutputOnly');

%%
% addpath(genpath('C:\Users\cclab\Documents\MATLAB\Scripts\plugin-GUI-master\Resources\Matlab'));
% url = 'tcp://10.32.133.176:5556'; % or, e.g., //'tcp://10.71.212.19:5556 if GUI runs on another machine...
% tcp_handle = zeroMQwrapper('StartConnectThread',url);
%%
pe = pyenv;
if pe.Status == 'Loaded'
    disp('Python is loaded');
else
    pyenv('Version', ' C:\Apps\Conda\envs\zmq\python.exe');
    disp('Python is loaded');
end
%%

% function saveeyeData(src,event)
% global trial_eye_data
% trial_eye_data=[trial_eye_data;event.Data];
% end
function saveeyeData(src,event)
global trial_eye_data trial_eye_timestamp
trial_eye_data=[trial_eye_data; event.Data];
trial_eye_timestamp=[trial_eye_timestamp; event.TimeStamps];
end

