function queue_jittered_analog_output(ao, ao_mod_params)
stop(ao)
release(ao)
mod_type = ao_mod_params.mod_type;
freq = ao_mod_params.freq;
amp = ao_mod_params.amp;
T = ao_mod_params.T;
T_total = ao_mod_params.T_total;
%
t = 1/ao.Rate:(1/ao.Rate):T;
t_total = 1/ao.Rate:(1/ao.Rate):T_total;
n_t = numel(t);
n_t_total = numel(t_total);
t_onset = randi(n_t_total - n_t);
jittered_data = zeros(size(t_total))';
jittered_ttl  = jittered_data;
switch mod_type
    case 'square'
        data = amp .* repmat([ones(ao.Rate / freq / 2, 1); zeros(ao.Rate / freq / 2, 1)], [T * freq, 1]);
    case 'sine'
        data = amp .* (sin(2* pi * freq .* t - pi/2)'  + 1)/2;
end

if  abs(data(end)) > 1e-4
    error('Incomplete cycle in analog output, aborting.')
end
jittered_data(t_onset:(t_onset + n_t - 1)) = data;
jittered_ttl(t_onset:(t_onset + n_t - 1)) = 5;
jittered_ttl(end) = 0;
queueOutputData(ao,[jittered_data, jittered_ttl]);
% prepare(ao); % prepare(ao) causes undelivered scans to be iremovable
end