function [vstruct, Display] = WaveDisplayParams_030(vstruct, datain)
% version for spatial task - JZ
pix=vstruct.siz./vstruct.res; %calculates the size of a pixel in cm
vstruct.degpix = atan(pix./vstruct.dis).*(180/pi);
vstruct.pixdeg = 1./vstruct.degpix;
%vstruct.pixvolt = vstruct.pixdeg*vstruct.voltage;

stim_degsize = 1;
Display.Stimsize = [round(stim_degsize*vstruct.pixdeg) round(stim_degsize*vstruct.pixdeg)];   %stim size in pixel
Display.FixSize = [3 3]; %fixation point size in pixels
Display.Lum  = datain(10:numel(datain))./100;   % Can be more than 2 values - JZ 20220217
Display.FixationWindow = datain(8);
Display.TargetWindow = datain(9);
% 
%   [Xscale, Yscale, Xscalecenter, Yscalecenter] converts voltage ouput
%   from ISCAN to visual degrees (by approximating a linear relationship
%   between x and tan(x) when x is small). The following formula
%   corresponds to P.O.R calibration procedures in ISCAN as followed:
%       - Calibration points at (L-hand coordinates) 
%         [x, y] for x, y = [100, 255, 410] on a 0-to-511 grid
%       - Visual target at: (R-hand coordinates, see
%       manual_9points_calibrate.m)
%         [x, y] for x = [-10, 0, 10]  
%                    y = [10, 0, -10] 
%          degrees by pixels per degree

%   Voltage values recorded on NI DAQ in 30 on 01/09/22. - ZW
x_real_volt_range = [-4.5797, 4.5206];
y_real_volt_range = [-4.5809, 4.5196];

Display.Xscale = 20*512/(410 - 100)/diff(x_real_volt_range);
Display.Xscalecenter = mean(x_real_volt_range);
Display.Yscale = -20*512/(410 - 100)/diff(y_real_volt_range);
Display.Yscalecenter = mean(y_real_volt_range);

Display.centerX = vstruct.res(1,1)/2;            % Calculate the center of the screen (X)
Display.centerY = vstruct.res(1,2)/2;            % Calculate the center of the screen (Y)


Display.fX1 = Display.centerX-Display.FixSize(1,1);              % With center pixel, make rectangle around it
Display.fX2 = Display.centerX+Display.FixSize(1,1);
Display.fY1 = Display.centerY-Display.FixSize(1,2);
Display.fY2 = Display.centerY+Display.FixSize(1,2);