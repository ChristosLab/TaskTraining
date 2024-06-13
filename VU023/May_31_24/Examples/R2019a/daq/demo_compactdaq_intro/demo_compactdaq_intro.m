%% Getting Started with NI Devices
%
% This example shows how to get started with NI devices from the command
% line using the session based interface.

% Copyright 2010-2014 The MathWorks, Inc.

%% Discover Available Devices 
% Use the |daq.getDevices| command to display a list of devices available
% to your machine and MATLAB(R).
daq.getDevices

%% Learn Device Details
% To learn more about an individual device, click the name of the device in
% the list in the Command window, or access the device in the array returned 
% by |daq.getDevices| command.
d = daq.getDevices;
% d(2)

%% Acquire Data
% To acquire data:
%
% # Create a session describing the operation to perform
% # Add input channels to the session
% # Start the acquisition
%

%%
% The |daq.createSession| command creates a session.  The session contains
% information describing the hardware, scan rate, duration, and other
% properties associated with the acquisition.  Create a session, and assign
% it to a variable.
s = daq.createSession('ni')

%%
% By default, the session is configured for 1000 scans per second
% and a duration of one second.  For the purposes of this example, accept these
% defaults.
%
% The |addAnalogInputChannel| command attaches an analog input channel to
% the session.  You can add more than one channel to a session. For the
% purposes of this example, add just one.
addAnalogInputChannel(s,'cDAQ1Mod1',0,'Voltage');
s

%%
% The |startForeground| command starts the acquisition and returns the
% results.
data = s.startForeground();

%%
% You've acquired 1000 scans.  Plot the acquired data:
plot(data)

%% Change Default Properties of the Acquisition
% By default, sessions run for one second at 1000 scans per second.  To
% acquire at a higher rate for a longer time, change the |Rate| and
% |DurationInSeconds| properties.
s.Rate = 5000;
s.DurationInSeconds = 2;
s

%%
% Run the acquisition and plot the acquired data:
data = s.startForeground();
plot(data)
