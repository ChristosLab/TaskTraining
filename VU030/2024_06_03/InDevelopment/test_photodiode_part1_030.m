clear
close all
% warning off all
sca;
daqreset;
Screen('Preference', 'VisualDebugLevel', 3);
n_class = 8;
stim_radius = 10; % degrees
%   The stimuli are described on a R-hand Cartesian coordinate system in
%   units of degrees of viewing angle
for i = 1:n_class
    current_degree = (i - 1)*360/n_class;
    GeneralVars.ClassStructure(i).frame(1).stim.end = stim_radius.*[cos(current_degree/180*pi), sin(current_degree/180*pi)];
    GeneralVars.ClassStructure(i).frame(2).stim.end = stim_radius.*[cos(current_degree/180*pi), sin(current_degree/180*pi)];
    GeneralVars.ClassStructure(i).Notes = num2str(current_degree);
end
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
datain(1:4) = [1 0.5 3.0 .2];    %  Default waiting times for each frame [fixation. cue delay1 sample delay2]
datain(5) = 3;                 %  Trial type
datain(6) = 50;                %  Number of blocks
datain(7) = 0;                %  Stimulus eccentricity
datain(8) = 100;                 %  Radius in degree of fixation window
datain(9) = 100;                 %  Radius in degree of target window
datain(10) = 100;               %  Stimulus luminance as percentage (1 - 100) of color depth (typically 0 - 255)
datain(11) = 0;                %  Helper luminance as percentage (1 - 100) of color depth (typically 0 - 255)
numBurst = 5;
% OutputFileNames = {'test_UNI0113'};
% disp('using default values')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   Visual Settings
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
vstruct.res = [1920 1080];    % screen resolution
vstruct.siz = [94 53];        % screen size in cm
vstruct.dis = 69;             % viewing distance in cm
vstruct.radius = datain(7);   % Stimulus excentricity
intertrial_interval_correct = 3;
intertrial_interval_error   = 3;
%%
DI=daq.createSession('ni');
Dch=addDigitalChannel(DI,'Dev1','Port0/Line0:1','InputOnly');
DI.Rate = 500;
DI.DurationInSeconds = 1000;
DI.NotifyWhenDataAvailableExceeds = 1;
lh=addlistener(DI,'DataAvailable',@savephotodiode);
%%
global photo_data photo_timestamp
startBackground(DI);
%%
figure;
while  1
    plot(photo_timestamp, photo_data)
end
%%

%%
function savephotodiode(src,event)
global photo_data photo_timestamp
photo_data=[photo_data; event.Data];
photo_timestamp=[photo_timestamp; event.TimeStamps];
end
