ai = daq.createSession('ni');
Ach=addAnalogInputChannel(ai,'Dev1',[0:2],'Voltage');
Ach(1).TerminalConfig = 'SingleEnded';
Ach(1).Range = [-5.0 5.0];
Ach(2).TerminalConfig = 'SingleEnded';
Ach(2).Range = [-5.0 5.0];
Ach(3).TerminalConfig = 'SingleEnded';
Ach(3).Range = [-5.0 5.0];
lh=addlistener(ai,'DataAvailable',@PlotData);
ai.Rate =500;
ai.DurationInSeconds=30;
function PlotData(src,event)
plot(event.TimeStamps,event.Data);
ylim([-5,5]);
end