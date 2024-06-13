global trial_eye_data trial_eye_timestamp
trial_eye_data      = [];
trial_eye_timestamp = [];
WaveInitDaq
ai.DurationInSeconds=100;
startBackground(ai);
breaktime = GetSecs;
while GetSecs - breaktime < ai.DurationInSeconds
end
%%
mean(trial_eye_data, 1)
save('room_30_iscan_analog_outout_voltage_calibration_h0_v0.mat', "trial_eye_timestamp", "trial_eye_data");
%%
global trial_eye_data trial_eye_timestamp
trial_eye_data      = [];
trial_eye_timestamp = [];
WaveInitDaq
ai.DurationInSeconds=100;
startBackground(ai);
breaktime = GetSecs;
while GetSecs - breaktime < ai.DurationInSeconds
end
%%
mean(trial_eye_data, 1)
save('room_30_iscan_analog_outout_voltage_calibration_h511_v511.mat', "trial_eye_timestamp", "trial_eye_data");