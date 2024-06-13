function turn_off_analog_output(ao)
stop(ao);
release(ao);
queueOutputData(ao, zeros(1, numel(ao.Channels)));
startBackground(ao);
end