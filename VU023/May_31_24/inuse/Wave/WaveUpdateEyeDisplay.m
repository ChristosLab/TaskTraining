function WaveUpdateEyeDisplay(StimulusCoordinates, FixWindow, FixPosition, vstruct, hLine,visability)
xStimDisplay    = (((StimulusCoordinates(1,1)+StimulusCoordinates(1,3))/2)-(vstruct.res(1)/2))*vstruct.degpix(1);
xWindowPosition = (((FixPosition(1,1)+FixPosition(1,3))/2)-(vstruct.res(1)/2))*vstruct.degpix(1);
yStimDisplay    = ((((StimulusCoordinates(1,2)+StimulusCoordinates(1,4))/2)-(vstruct.res(2)/2))*vstruct.degpix(2))*-1;
yWindowPosition = ((((FixPosition(1,2)+FixPosition(1,4))/2)-(vstruct.res(2)/2))*vstruct.degpix(2))*-1;
xWindowDisplay  = FixWindow(1,:)+ xWindowPosition;
yWindowDisplay  = FixWindow(2,:)+ yWindowPosition;
set(hLine(1),'XData',xStimDisplay,'YData',yStimDisplay,'Visible',visability); % stimulus position
set(hLine(3),'XData',xWindowDisplay,'YData',yWindowDisplay,'Visible',visability);
