function [window, WindowStructure, AllCoordinates] = CreateWindowStructODR(Display, vstruct, ClassStructure, varargin)
% Based on CreateWindowStruct2% 
% Creates multiple stimuli frames for ODR/DDR tasks
% Displays photo-diode when the second delay ends
% so that subject's reaction time can be measured
% For use in Lab #3
% C. Constantinidis 13-APR-2009
% March/03/2020 WD



stimsize = Display.StimSize;
if length(varargin) == 1
    helplumcue = varargin{1};
else
    helplumcue = 0;
end

for m = 1:length(ClassStructure)
    for n = 1:length(ClassStructure(m).frame)
        XY      = ClassStructure(m).frame(n).stim(1).end .* vstruct.pixdeg;
        XY(2)   = XY(2)*-1;
        tCenter = XY + [Display.centerX Display.centerY];
        ClassStructures(m).frame(n).stim(1).tCenter = tCenter;
        ClassStructures(m).frame(n).stim(1).wRect   = [tCenter(1) - stimsize(1), tCenter(2) - stimsize(2), ...
            tCenter(1) + stimsize(1), tCenter(2) + stimsize(2)];
        AllCoordinates.cRect(m,:,n) = ClassStructures(m).frame(n).stim(1).wRect;
        AllCoordinates.cCenter(m,:,n) = tCenter;
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Window and Offscreen Windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%AllCoordinates.fCenter = [vstruct.res(1)+Display.centerX Display.centerY];
%AllCoordinates.fRect = [vstruct.res(1)+Display.fX1 Display.fY1 vstruct.res(1)+Display.fX2 Display.fY2];
AllCoordinates.fCenter = [Display.centerX Display.centerY];
AllCoordinates.fRect = [Display.fX1 Display.fY1 Display.fX2 Display.fY2];
[window] = Screen(2,'OpenWindow',BlackIndex(0),[],32);

% Fixation screen, white fixation, XQ
WindowStructure(1).f = Screen(window,'OpenOffscreenWindow',BlackIndex(0),[],32);
Screen(WindowStructure(1).f,'FillRect',WhiteIndex(0),AllCoordinates.fRect);

% Stimulus screens
for m  = 1:length(ClassStructures)
    for n = 1:length(ClassStructures(m).frame)
        WindowStructure(m).frame(n).end = Screen(window,'OpenOffscreenwindow', BlackIndex(0), [],32);        
        Screen(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),AllCoordinates.fRect); % fixation point
        Screen(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),ClassStructures(m).frame(n).stim(1).wRect); % stimulus square
        Screen(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),[0 0 60 50]); % Photodiode
    end
    WindowStructure(m).r = Screen(window,'OpenOffscreenWindow',BlackIndex(0),[],32);  % reward screen
    Screen(WindowStructure(m).r,'FillRect',WhiteIndex(0),[0 0 60 50]);
    Screen(WindowStructure(m).r,'FillRect',helplumcue,ClassStructures(m).frame(1).stim(1).wRect); % XZ
end
