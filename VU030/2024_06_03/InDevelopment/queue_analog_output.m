function queue_analog_output(ao, ao_mod_params)
stop(ao);
release(ao);
mod_type = ao_mod_params.mod_type;
freq = ao_mod_params.freq;
amp = ao_mod_params.amp;
T = ao_mod_params.T;
%
t = 0:(1/ao.Rate):T;
switch mod_type
    case 'square'
        data = amp .* repmat([ones(ao.Rate / freq / 2, 1); zeros(ao.Rate / freq / 2, 1)], [T * freq, 1]);
    case 'sine'
        data = amp .* (sin(2* pi * freq .* t - pi/2)'  + 1)/2;
end

ttl = ones(size(data)) * 5;
ttl(end) = 0;

if  abs(data(end)) > 1e-4
    warning('Incomplete cycle in analog output, aborting.')
    return
end
queueOutputData(ao,[data, ttl]);
% prepare(ao)
end