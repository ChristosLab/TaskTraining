function [window, f, r,WindowStructure, AllCoordinates] = CreateWindowStructNull(Display, vstruct, ClassStructure, MNM)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Streamlining variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stimsize = Display.Stimsize;
targsize = Display.TargSize;
%Blue  = [0,0,255];

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create ClassStructures that have stim coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resolusion=vstruct.res;    % screen resolution
screen_size=vstruct.siz;        % screen size in cm
screen_dis=vstruct.dis;
for m = 1:length(ClassStructure)
    for n = 1:numel(ClassStructure(m).frame)
        XY = ClassStructure(m).frame(n).stim(1).end;%target location in degree;
        vertical_offset=round(screen_dis*atan(XY(2)/180*pi)/(screen_size(2)/2)*(resolusion(2)/2));
        horizontal_offset=round(screen_dis*atan(XY(1)/180*pi)/(screen_size(1)/2)*(resolusion(1)/2));
        XY=[horizontal_offset,vertical_offset];
        XY(2) = XY(2)*-1;
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

AllCoordinates.fCenter = [Display.centerX Display.centerY];
AllCoordinates.fRect = [Display.fX1 Display.fY1 Display.fX2 Display.fY2];
[window] = Screen(2,'OpenWindow',BlackIndex(0),[],32);
f = Screen(window,'OpenOffscreenWindow',BlackIndex(0),[],32); %fix window
Screen(f,'FillRect',WhiteIndex(0),AllCoordinates.fRect);
r = Screen(window,'OpenOffscreenWindow',BlackIndex(0),[],32);  % sync window
% Screen(r,'FillRect',WhiteIndex(0),[0 0 60 50]);
for m  = 1:length(ClassStructures)
    for n = 1:length(ClassStructures(m).frame)
        WindowStructure(m).frame(n).end = Screen(window,'OpenOffscreenwindow', BlackIndex(0), [],32);
%         Screen(WindowStructure(m).frame(n).end,'FillRect',Display.Lum*WhiteIndex(0),ClassStructures(m).frame(n).stim(o).wRect);
%         Screen(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),[0 0 60 50]);
        Screen(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),AllCoordinates.fRect);
    end
end
end