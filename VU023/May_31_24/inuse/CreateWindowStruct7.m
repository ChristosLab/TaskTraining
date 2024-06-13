function [window, f, r,WindowStructure, AllCoordinates] = CreateWindowStruct5(Display, vstruct, ClassStructure, MNM,contrast)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus Features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
image_contrast=contrast;
                                               %Pixels
Stimulus(1).Feature = image_contrast*imread('Circle.BMP');    % 4813
Stimulus(2).Feature = image_contrast*imread('Diamond.BMP');   % 4900
Stimulus(3).Feature = image_contrast*imread('H.BMP');         % 4810
Stimulus(4).Feature = image_contrast*imread('Number.BMP');    % 4880
Stimulus(5).Feature = image_contrast*imread('Plus.BMP');      % 4818
Stimulus(6).Feature = image_contrast*imread('Square.BMP');    % 4900
Stimulus(7).Feature = image_contrast*imread('Triangle.BMP');  % 4900
Stimulus(8).Feature = image_contrast*imread('Y.BMP');         % 4808
% Stimulus(1).Feature = imread('Adrian.BMP');
% Stimulus(2).Feature = imread('Daniel.BMP');
% Stimulus(3).Feature = imread('Banana.BMP');
% Stimulus(4).Feature = imread('Orange.BMP');
% Stimulus(5).Feature = imread('Elvis.BMP');
% Stimulus(6).Feature = imread('Keith.BMP');
% Stimulus(7).Feature = imread('Pear.BMP');
% Stimulus(8).Feature = imread('Pineapple.BMP');
% Stimulus(17).Feature = imread('Travis.BMP');
% Stimulus(18).Feature = imread('Xuelian.BMP');
% Stimulus(19).Feature = imread('Strawberries.BMP');
% Stimulus(20).Feature = imread('Watermelon.BMP');

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
switch MNM
    case 'Match'
        M_or_NM = 1;
        switchTarget = repmat([1 0 1 0],1,length(ClassStructure)/4);
        Red   = [0 0 0]; %[0,0,255];
       % Red   = [0,0,255];
        Green = [0,255,0];          
    case 'NonMatch'
        M_or_NM = 1;
        switchTarget = repmat([0 1 0 1],1,length(ClassStructure)/4);
        Red   = [0,0,255];
        Green = [0 0 0]; % [0,123,0];
       % Green=[0,255,0];
    case 'Both'
        M_or_NM = 0;
        switchTarget = rem(1:length(ClassStructure),4);
        Red   = [0,0,255];
        Green = [0,255,0];
        
end

for m = 1:length(ClassStructure)
    for n = 1:3 % window for cue sample and chocie period
        XY = ClassStructure(m).frame(n).stim(1).end;%target location in degree;
        vertical_offset=round(screen_dis*atan(XY(2)/180*pi)/(screen_size(2)/2)*(resolusion(2)/2));
        horizontal_offset=round(screen_dis*atan(XY(1)/180*pi)/(screen_size(1)/2)*(resolusion(1)/2));
       % XY=XY+[horizontal_offset,vertical_offset];%target location in pixel;
        XY=[horizontal_offset,vertical_offset]; 
        XY(2) = XY(2)*-1;
        tCenter = XY + [Display.centerX Display.centerY];
        ClassStructures(m).frame(n).stim(1).tCenter = tCenter;
        ClassStructures(m).frame(n).stim(1).wRect   = [tCenter(1) - stimsize(1), tCenter(2) - stimsize(2), ...
                tCenter(1) + stimsize(1), tCenter(2) + stimsize(2)];
        if n == 3
            for o = 1:2
                XY = ClassStructure(m).frame(n).stim(o).end;
                vertical_offset=round(screen_dis*atan(XY(2)/180*pi)/(screen_size(2)/2)*(resolusion(2)/2));
                horizontal_offset=round(screen_dis*atan(XY(1)/180*pi)/(screen_size(1)/2)*(resolusion(1)/2));
                %XY=XY+[horizontal_offset,vertical_offset];%target location in pixel;
                XY=[horizontal_offset,vertical_offset]; 
                XY(2) = XY(2)*-1;
                tCenter = XY + [Display.centerX Display.centerY];
                ClassStructures(m).frame(n).stim(o).tCenter = tCenter;
                ClassStructures(m).frame(n).stim(o).wRect   = [tCenter(1) - targsize(1), tCenter(2) - targsize(2), ...
                        tCenter(1) + targsize(1), tCenter(2) + targsize(2)];
            end            
            AllCoordinates.cRect(m,:,n) = ClassStructures(m).frame(n).stim(1).wRect;
            AllCoordinates.cCenter(m,:,n) = tCenter;
        else
            AllCoordinates.cRect(m,:,n) = ClassStructures(m).frame(n).stim(1).wRect;
            AllCoordinates.cCenter(m,:,n) = tCenter;
        end
    end
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Window and Offscreen Windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

AllCoordinates.fCenter = [Display.centerX Display.centerY];
AllCoordinates.fRect = [Display.fX1 Display.fY1 Display.fX2 Display.fY2];
[window] = Screen(2,'OpenWindow',BlackIndex(0),[],32);
f = Screen(window,'OpenOffscreenWindow',BlackIndex(0),[],32); %fix window
%Screen(f,'FillRect',WhiteIndex(0),AllCoordinates.fRect);
Screen(f,'FillRect',[255,0,0],AllCoordinates.fRect);
r = Screen(window,'OpenOffscreenWindow',BlackIndex(0),[],32);  % sync window
Screen(r,'FillRect',WhiteIndex(0),[0 0 60 50]);
for m  = 1:length(ClassStructures)
    for n = 1:length(ClassStructures(m).frame)
        WindowStructure(m).frame(n).end = Screen(window,'OpenOffscreenwindow', BlackIndex(0), [],32);
        if n < 3  
            for o = 1:length(ClassStructures(m).frame(n))
                Screen(WindowStructure(m).frame(n).end,'PutImage',Stimulus(ClassStructure(m).frame(n).stim(o).feature).Feature ...
                ,ClassStructures(m).frame(n).stim(o).wRect);
                %Screen(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),AllCoordinates.fRect);
                Screen(WindowStructure(m).frame(n).end,'FillRect',[255,0,0],AllCoordinates.fRect);
              %  Screen(WindowStructure(m).frame(n).end,'PutImage',Stimulus(6).Feature ...
              %      ,ClassStructures(m).frame(n).stim(o).wRect); 
                Screen(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),[0 0 60 50]);
            end
        else            
            
            Screen(WindowStructure(m).frame(n).end,'PutImage',Stimulus(ClassStructure(m).frame(n).stim(o).feature).Feature ...
                ,ClassStructures(m).frame(n).stim(o).wRect);
            Screen(WindowStructure(m).frame(n).end,'FillRect',Display.Lum*WhiteIndex(0),ClassStructures(m).frame(n).stim(o).wRect);
            Screen(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),[0 0 60 50]);
        end
    end
end
end