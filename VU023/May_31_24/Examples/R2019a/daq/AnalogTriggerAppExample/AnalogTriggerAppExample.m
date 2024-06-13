%% Analog Trigger App
%
% This example shows how to create an analog-triggered data acquisition app
% by using Data Acquisition Toolbox(TM) and App Designer. 
%
% Data Acquisition Toolbox provides functionality for acquiring measurement
% data from a DAQ device or audio soundcard. For certain applications, an
% analog-triggered acquisition that starts capturing or logging data based
% on a condition in the analog signal being measured is recommended.
% Software-analog triggered acquisition enables you to capture only a
% segment of interest out of a continuous stream of measurement data. For
% example, you can capture an audio recording when the signal level passes
% a certain threshold.
%
% This example app shows how to implement these operations:
%
% * Discover available DAQ devices and select which device to use.
% * Configure device acquisition parameters.
% * Display a live plot in the app UI during acquisition.
% * Perform a triggered data capture based on a programmable trigger
% condition.
% * Save captured data to a MATLAB(R) base workspace variable.
% * Control the operating modes of the app by defining app states in code.
%
% <<../analog_trigger_app_screenshot.png>>
% 
% By default, the app will open in design mode in App Designer. To run the
% app click the Run button or execute the app from the command line:
% 
%   AnalogTriggerApp

%% Requirements
% This example app requires:
% 
% * MATLAB R2019a or later
% * Data Acquisition Toolbox
% * A supported DAQ device or sound card. For example, any National
% Instruments or Measurement Computing device that supports analog input
% |Voltage| or |IEPE| measurements and background acquisition.
% * Corresponding hardware support package and device drivers
%
%% Analog Trigger Condition 
% The analog trigger capture is specified by the trigger level, trigger
% condition, trigger delay, and capture duration which are defined as in
% the figure below. A negative trigger delay means pre-trigger data will be
% captured.
% 
% <<../analog_trigger_figure.png>>
%
%% Controlling the App Operation
% When creating an app that has complex logic, consider the various states
% that correspond to the operating modes of the app. For this app, the app
% logic is implemented in MATLAB code and the following app states are
% used:
% 
% * DeviceSelection
% * Configuration
% * Acquisition (Buffering, ReadyForCapture, Capture, LookingForTrigger, CapturingData, CaptureComplete)
%
% You can use a Stateflow chart to visualize, organize, and control the app
% states as illustrated in the "Analog Trigger App by Using Stateflow
% Charts" example.
%

% Copyright 2019 The MathWorks, Inc.

