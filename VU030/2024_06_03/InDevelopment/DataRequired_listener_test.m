clear
daqreset
WaveInitDaq030
global data_current
data_current = [];
stop(AO)
release(AO)
AO.IsContinuous = 1;
lh_ao = addlistener(AO,'DataRequired', @queue_part_data);
queueOutputData(AO, zeros([1000, 2]));
startBackground(AO)
%%
add_data_current(AO)
%%
function add_data_current(AO)
global data_current
data_to_add = sin(2*pi*(1/AO.Rate:1/AO.Rate:10))';
data_current = [data_to_add, ones(size(data_to_add))];
end
%%
function queue_part_data(src,event)
global data_current
if isempty(data_current)
    1
    src.queueOutputData(zeros(100, 2))
else
    2
    src.queueOutputData(data_current);
    data_current = [];
%     src.queueOutputData(data_current(1:min(end, 2), :));
%     data_current(1:min(end, 2), :) = [];
end
end