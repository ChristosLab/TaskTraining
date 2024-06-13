function turn_off_analog_output_hang(ao)
stop(ao);
queueOutputData(ao, zeros(ao.Rate/10, numel(ao.Channels)));
startForeground(ao);
end