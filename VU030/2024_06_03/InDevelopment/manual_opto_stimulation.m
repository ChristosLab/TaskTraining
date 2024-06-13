Screen('Preference', 'VisualDebugLevel', 3);
sca;
close all
clear
WaveInitDaq030; % Creates analogoutput AO.
%
ao_mod_params = struct;
ao_mod_params.mod_type = 'sine'; % Modulation function
ao_mod_params.freq = 5; % Modulation frequncy (Hz)
ao_mod_params.amp = 4.5; % Modulation voltage (V, 0 to max)
ao_mod_params.T = .2;% Laser on duration (second)
%
[window] = Screen(2,'OpenWindow',BlackIndex(0),[],32);
laseronkey = KbName('5');
rewardkey  = KbName('0');
escapekey  = KbName('return');
while true
    [keyIsDown,secs,keyCode]=KbCheck;
    if keyCode(laseronkey)
        queue_analog_output(AO, ao_mod_params);
        startForeground(AO);
    elseif keyCode(escapekey)
        turn_off_analog_output(AO);
        break;
    end
end