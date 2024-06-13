AI                        = daq.createSession('ni');
AI.Rate                   = 500;
ACH                       = addAnalogInputChannel(AI,'Dev1',0:2,'Voltage');
ACH(1).TerminalConfig     = 'SingleEnded';
ACH(1).Range              = [-10.0 10.0];
ACH(2).TerminalConfig     = 'SingleEnded';
ACH(2).Range              = [-10.0 10.0];
ACH(3).TerminalConfig     = 'SingleEnded';
ACH(3).Range              = [-10.0 10.0];
 %AI.ExternalTriggerTimeout = Inf;
 %AI.TriggersPerRun         = Inf;

% DIO = daq.createSession('ni')
% addDigitalChannel(AI,'Dev1','Port0/Line0:7','Outputonly');



% ai.TriggerRepeat = Inf;
% ai.TriggerType = 'Immediate';
% ai.SamplesPerTrigger = Inf;
% dio = digitalio('nidaq',1);
% addline(dio, 0:7, 0, 'Out');


