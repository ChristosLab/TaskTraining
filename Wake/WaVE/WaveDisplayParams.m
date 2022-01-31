function [vstruct, Display] = WaveDisplayParams(vstruct, datain)

pix=vstruct.siz./vstruct.res; %calculates the size of a pixel in cm
vstruct.degpix=(2*atan(pix./(2*vstruct.dis))).*(180/pi);
vstruct.pixdeg=1./vstruct.degpix;
vstruct.pixvolt = vstruct.pixdeg*vstruct.voltage;

vstruct.radius = datain(7);
radians = (vstruct.angs*0.0174532925)';   % convert degrees to radians
coors(:,1) = cos(radians)*vstruct.radius;   % Calculate all x coordinates
coors(:,2) = sin(radians)*vstruct.radius;   % Calculate all y coordinates
vstruct.pixs(:,1) = vstruct.pixdeg(1,1)*coors(:,1);         % Convert x degs to pixels
vstruct.pixs(:,2) = vstruct.pixdeg(1,2)*coors(:,2);         % Convert y degs to pixels
Display.pixs(1:1:8,:) = vstruct.pixs(8:-1:1,:);     % Invert the pixels to clockwise order


Display.StimSize = [round(vstruct.pixdeg(1)*(200/140)*1) round(vstruct.pixdeg(2)*(200/140)*1)];   % (100/70)               % size of the stimuli in pixels
% Display.StimSize = [round(vstruct.pixdeg(1)*1) round(vstruct.pixdeg(2)*1)];   % (100/70)               % size of the stimuli in pixels
Display.FixSize = [5 5];
Display.Lum  = datain(10)/100;
Display.FixationWindow = datain(8);
Display.TargetWindow = datain(9);
Display.Xscale = vstruct.voltage;
Display.Xscalecenter = 0;
Display.Yscale = vstruct.voltage;
Display.Yscalecenter = 0;

Display.centerX = vstruct.res(1,1)/2;            % Calculate the center of the screen (X)
Display.centerY = vstruct.res(1,2)/2;            % Calculate the center of the screen (Y)
Display.X1 = Display.centerX-Display.StimSize(1,1);              % With center pixel, make rectangle around it
Display.X2 = Display.centerX+Display.StimSize(1,1);
Display.Y1 = Display.centerY-Display.StimSize(1,2);
Display.Y2 = Display.centerY+Display.StimSize(1,2);

Display.fX1 = Display.centerX-Display.FixSize(1,1);              % With center pixel, make rectangle around it
Display.fX2 = Display.centerX+Display.FixSize(1,1);
Display.fY1 = Display.centerY-Display.FixSize(1,2);
Display.fY2 = Display.centerY+Display.FixSize(1,2);
