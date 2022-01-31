ai = analoginput('nidaq',1);
addchannel(ai,0);
addchannel(ai,1);
% addchannel(ai,2);%xq
ai.Channel.InputRange = [-10 10];
ai.SampleRate = 500;
ai.InputType = 'SingleEnded';
ai.TriggerRepeat = Inf;
ai.TriggerType = 'Immediate';
ai.SamplesPerTrigger = Inf;
dio = digitalio('nidaq',1);
addline(dio, 0:7, 0, 'Out');
