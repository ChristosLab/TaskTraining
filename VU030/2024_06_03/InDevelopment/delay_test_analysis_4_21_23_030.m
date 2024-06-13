%% run1
oe_folder = 'Z:\Users\wangz56\delay_test_30\run1';
mat_file = 'C:\Users\cclab\Documents\MATLAB\beh\delay_test_30_run_1.mat';
plot_delay_test(oe_folder, mat_file);
%% run2
oe_folder = 'Z:\Users\wangz56\delay_test_30\run2';
mat_file = 'C:\Users\cclab\Documents\MATLAB\beh\delay_test_30_run_2.mat';
plot_delay_test(oe_folder, mat_file);
%% run3
oe_folder = 'Z:\Users\wangz56\delay_test_30\run3';
mat_file = 'C:\Users\cclab\Documents\MATLAB\beh\delay_test_30_run_3.mat';
plot_delay_test(oe_folder, mat_file);
%% run4
oe_folder = 'Z:\Users\wangz56\delay_test_30\run4';
mat_file = 'C:\Users\cclab\Documents\MATLAB\beh\delay_test_30_run_4.mat';
plot_delay_test(oe_folder, mat_file);
%% run5
oe_folder = 'Z:\Users\wangz56\delay_test_30\run5';
mat_file = 'C:\Users\cclab\Documents\MATLAB\beh\delay_test_30_run_5.mat';
plot_delay_test(oe_folder, mat_file);
%% run6
oe_folder = 'Z:\Users\wangz56\delay_test_30\run6';
mat_file = 'C:\Users\cclab\Documents\MATLAB\beh\delay_test_30_run_6.mat';
plot_delay_test(oe_folder, mat_file);
%% run7
oe_folder = 'Z:\Users\wangz56\delay_test_30\run7';
mat_file = 'C:\Users\cclab\Documents\MATLAB\beh\delay_test_30_run_7.mat';
plot_delay_test(oe_folder, mat_file);
%% run8
oe_folder = 'Z:\Users\wangz56\delay_test_30\run8';
mat_file = 'C:\Users\cclab\Documents\MATLAB\beh\delay_test_30_run_8.mat';
plot_delay_test(oe_folder, mat_file);
%%
function plot_delay_test(oe_folder, mat_file)
cs = readNPY(fullfile(oe_folder, '\TTL_1\channel_states.npy'));
ts = readNPY(fullfile(oe_folder, '\TTL_1\timestamps.npy'));
load(mat_file, 't');
%%
fs = 30000;
pd_on = ts(cs == 1);
pd_off = ts(cs == -1);
if numel(pd_off) < numel(pd_on)
    pd_off(numel(pd_on)) = pd_on(end) + fs;
end
pd_events = fix_photodiode_gap([pd_on, pd_off], fs);
ttl_on = ts(cs == 2);
pd_on = pd_events(:, 1);
pd_delay = (double(pd_on - ttl_on))/fs * 1000;
[cdf_p_pd_delay, cdf_x_pd_delay] = ecdf(pd_delay);
figure('Units','inches', 'Position', [2 2 5, 5])
ax = subplot(3, 1, [1, 2]);
hold on
histogram(ax, pd_delay, 50);
yl = ylim;
plot(cdf_x_pd_delay(floor(end/2)) + [0, 0], yl)
text(cdf_x_pd_delay(floor(end/2)), yl(2) * 0.8, sprintf('Median = %.1f', cdf_x_pd_delay(floor(end/2))))
plot(cdf_x_pd_delay(floor(end * 0.95)) + [0, 0], yl)
text(cdf_x_pd_delay(floor(end * 0.95)), yl(2) * 0.8, sprintf('95%% = %.1f', cdf_x_pd_delay(floor(end * 0.95))))
plot(cdf_x_pd_delay(ceil(end/2 * 0.05)) + [0, 0], yl)
text(cdf_x_pd_delay(ceil(end/2 * 0.05)), yl(2) * 0.8, sprintf('5%% = %.1f', cdf_x_pd_delay(ceil(end/2 * 0.05))))
xlabel('Photodiode - TTL (ms)')
ylabel('Count')
subplot(3, 1, 3);
plot(pd_delay);
% plot(t(:, 5) - t(:, 4), (double(pd_on - ttl_on))/fs, '.')
ylabel('Photodiode - TTL (ms)')
xlabel('Trials')
sgtitle('WH030 display delay test')
print(gcf, fullfile(oe_folder, 'display_delay'), '-r400', '-dpng')
end
%%
%%
function photodiode_time_event_out = fix_photodiode_gap(photodiode_time_event, fs)
%   The FHC synchronizer outputs a single pulse of a fixed width when the
%   pixels light up across a certain threshold at the beginning of each
%   frame (@ ~60 Hz, specific to monitor specs). When the timing of
%   luminance crossing jitters on each frame, successive pulses could have
%   no overlap resulting in gaps in "photodiode_event_time".
%   FIX_PHOTODIODE_GAP removes gaps samller than the duration of a frame.
gap_threshold = 1 / 60 *fs;
photodiode_time_event_gap = photodiode_time_event(2:end, 1) - photodiode_time_event(1:end - 1, 2);
gap_to_delete             = find(photodiode_time_event_gap < gap_threshold);
photodiode_time_event_on_new  = photodiode_time_event(:, 1);
photodiode_time_event_off_new = photodiode_time_event(:, 2);
photodiode_time_event_on_new(gap_to_delete + 1) = [];
photodiode_time_event_off_new(gap_to_delete)    = [];
photodiode_time_event_out                       = [photodiode_time_event_on_new, photodiode_time_event_off_new];
if ~isempty(gap_to_delete)
warning('%d out of %d gaps deleted from photodiode events\n', numel(gap_to_delete), size(photodiode_time_event, 1))
end
end