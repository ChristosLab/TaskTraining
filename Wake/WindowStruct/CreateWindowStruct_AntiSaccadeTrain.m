function [window, f, r,WindowStructure, AllCoordinates] = CreateWindowStruct(Display, vstruct, ClassStructure,SizeofStim,gray2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Changes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4-20-05, changed line 28, for n = 1:2 instead of 1:3 because we no longer
%  use targets and an error was occuring when n == 3, TM
% 8-20-05, changed line 28, for n = 1:2 to n = 1:3 because we're now using
% targets, TM

% XQ 2011-May-1
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus Features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                               %Pixels
Stimulus(1).Feature = imread('Circle.BMP');    % 4813
Stimulus(2).Feature = imread('Diamond.BMP');   % 4900
Stimulus(3).Feature = imread('H.BMP');         % 4810
Stimulus(4).Feature = imread('Number.BMP');    % 4880
Stimulus(5).Feature = imread('Plus.BMP');      % 4818
Stimulus(6).Feature = imread('Square.BMP');    % 4900
Stimulus(7).Feature = imread('Triangle.BMP');  % 4900
Stimulus(8).Feature = imread('Y.BMP');         % 4808

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Streamlining variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

stimsize = Display.StimSize *SizeofStim*0.71;
targsize = [5 5];
Blue  = [0,0,255];
% Green 123 = blue-255
% Green 162 = red 255
% Yellow = G-140,140 == Red-255

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create ClassStructures that have stim coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
breaktime = getsecs;
for m = 1:length(ClassStructure)
    for n = 1:length(ClassStructure(m).frame) % only 2 frame
        XY = ClassStructure(m).frame(n).stim(1).end .* vstruct.pixdeg;
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
breaktime = getsecs;
AllCoordinates.fCenter = [Display.centerX Display.centerY];
AllCoordinates.fRect = [Display.fX1 Display.fY1 Display.fX2 Display.fY2];
[window] = screen(0,'OpenWindow',BlackIndex(0),[],32);
f = SCREEN(window,'OpenOffscreenWindow',BlackIndex(0),[],32);
% screen(f,'FillRect',WhiteIndex(0),AllCoordinates.fRect);(f,'FillRect',[0 255 0],fRect);
screen(f,'FillRect',[0 255 0],AllCoordinates.fRect);
r = SCREEN(window,'OpenOffscreenWindow',BlackIndex(0),[],32);  % Reward Window
screen(r,'FillRect',WhiteIndex(0),[0 0 60 50]);
for m  = 1:length(ClassStructures)
    for n = 1:length(ClassStructures(m).frame)
        WindowStructure(m).frame(n).end = SCREEN(window,'OpenOffscreenwindow', BlackIndex(0), [],32);
        o = 1;
        if n == 1;
            SCREEN(WindowStructure(m).frame(n).end,'FillRect',[0 255 0],AllCoordinates.fRect);
            %             SCREEN(WindowStructure(m).frame(n).end,'PutImage',Stimulus(ClassStructure(m).frame(n).stim(o).feature).Feature ...
            %                 ,ClassStructures(m).frame(n).stim(o).wRect);
            SCREEN(WindowStructure(m).frame(n).end, 'FillRect',WhiteIndex(0)...
                ,ClassStructures(m).frame(n).stim(o).wRect);
            SCREEN(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),[0 0 60 50]);
        else
            %          SCREEN(WindowStructure(m).frame(n).end,'FillRect',[0 255 0],AllCoordinates.fRect);
            SCREEN(WindowStructure(m).frame(n).end,'FillRect',gray2 ...
                ,ClassStructures(m).frame(n).stim(o).wRect);
            SCREEN(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),[0 0 60 50]);
        end
    end
end
