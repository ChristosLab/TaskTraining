function [window, f, r,WindowStructure, AllCoordinates] = CreateWindowStruct_CMT_mix(Display, vstruct, ClassStructure,numtargets,dist_lum)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Changes %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 4-20-05, changed line 28, for n = 1:2 instead of 1:3 because we no longer
%  use targets and an error was occuring when n == 3, TM
% 8-20-05, changed line 28, for n = 1:2 to n = 1:3 because we're now using
% targets, TM
% 11-4-14, Modified for training in active task for Lab 3 MR

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus Features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
                                               %Pixels
Stimulus(1).Feature = imread('A1.BMP');    % 4813
%temp=Stimulus(1).Feature;
%temp(:,:,[1,3])=0;%%%%%%%%%%%%%%%%%%%%%%%%%%%circle to green color
%Stimulus(1).Feature=Stimulus(1).Feature-gray*(Stimulus(1).Feature-temp);
Stimulus(2).Feature = imread('D1.BMP');   % 4900
%temp=Stimulus(2).Feature;
%temp(:,:,[1,2])=0;%%%%%%%%%%%%%%%%%%%%%%%%%%%diamond to blue color
%Stimulus(2).Feature=Stimulus(2).Feature-gray*(Stimulus(2).Feature-temp);
Stimulus(3).Feature = imread('D11.BMP');         % 4810
%Stimulus(4).Feature = imread('Number.BMP');    % 4880
Stimulus(4).Feature = imread('C1.BMP');
Stimulus(5).Feature = imread('A11.BMP');      % 4818
Stimulus(6).Feature = imread('B1.BMP');    % 4900
Stimulus(7).Feature = imread('B11.BMP');  % 4900
Stimulus(8).Feature = imread('C11.BMP');
%Stimulus(8).Feature = imread('Y.BMP');         % 4808
% Stimulus(9).Feature = imread('Adrian.BMP');
% Stimulus(10).Feature = imread('Daniel.BMP');
% Stimulus(11).Feature = imread('Banana.BMP');
% Stimulus(12).Feature = imread('Orange.BMP');
% Stimulus(13).Feature = imread('Elvis.BMP');
% Stimulus(14).Feature = imread('Keith.BMP');
% Stimulus(15).Feature = imread('Pear.BMP');
% Stimulus(16).Feature = imread('Pineapple.BMP');
% Stimulus(17).Feature = imread('Travis.BMP');
% Stimulus(18).Feature = imread('Xuelian.BMP');
% Stimulus(19).Feature = imread('Strawberries.BMP');
% Stimulus(20).Feature = imread('Watermelon.BMP');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Streamlining variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scale=1/4;
for i=1:length(ClassStructure) %shape
    for j=1:2  %frame
        if j==2
          for s=1:2 %target up or down
            stimsize(i,j,s,:)=scale*flip(size(Stimulus(ClassStructure(i).frame(j).stim(s).feature).Feature,[1,2]));
          end
        else
            stimsize(i,j,1,:)=scale*flip(size(Stimulus(ClassStructure(i).frame(j).stim(1).feature).Feature,[1,2]));
        end
    end
end
%stimsize = Display.StimSize;
%targsize = Display.StimSize;
% targsize = [5 5];
Blue  = [0,0,255];
% Green 123 = blue-255
% Green 162 = red 255
% Yellow = G-140,140 == Red-255

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create ClassStructures that have stim coordinates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
resolusion=vstruct.res;    % screen resolution
screen_size=vstruct.siz;        % screen size in cm
screen_dis=vstruct.dis; 

breaktime = GetSecs;
for m = 1:length(ClassStructure)
    for n = 1:2 % stimuli location for cue chocie period
        %%%%%%%%%%%%%cue location%%%%%%%%%%%%%%%%%%%%
        XY = ClassStructure(m).frame(n).stim(1).end;%target location in degree in three epochs;
        vertical_offset=round(screen_dis*atan(XY(2)/180*pi)/(screen_size(2)/2)*(resolusion(2)/2));
        horizontal_offset=round(screen_dis*atan(XY(1)/180*pi)/(screen_size(1)/2)*(resolusion(1)/2));
       % XY=XY+[horizontal_offset,vertical_offset];%target location in pixel;
        XY=[horizontal_offset,vertical_offset]; 
        XY(2) = XY(2)*-1;
        tCenter = XY + [Display.centerX Display.centerY];
        ClassStructures(m).frame(n).stim(1).tCenter = tCenter;
        ClassStructures(m).frame(n).stim(1).wRect   = [tCenter(1) - stimsize(m,n,1,1), tCenter(2) - stimsize(m,n,1,2), ...
                tCenter(1) + stimsize(m,n,1,1), tCenter(2) + stimsize(m,n,1,2)];
        %%%%%%%%%%%%%choice location%%%%%%%%%%%%%%%%%%%%
        if n == 2
            for o = 1:2
                XY = ClassStructure(m).frame(n).stim(o).end;
                vertical_offset=round(screen_dis*atan(XY(2)/180*pi)/(screen_size(2)/2)*(resolusion(2)/2));
                horizontal_offset=round(screen_dis*atan(XY(1)/180*pi)/(screen_size(1)/2)*(resolusion(1)/2));
                %XY=XY+[horizontal_offset,vertical_offset];%target location in pixel;
                XY=[horizontal_offset,vertical_offset]; 
                XY(2) = XY(2)*-1;
                tCenter = XY + [Display.centerX Display.centerY];
                ClassStructures(m).frame(n).stim(o).tCenter = tCenter;
                ClassStructures(m).frame(n).stim(o).wRect   = [tCenter(1) - stimsize(m,n,o,1), tCenter(2) - stimsize(m,n,o,2), ...
                        tCenter(1) + stimsize(m,n,o,1), tCenter(2) + stimsize(m,n,o,2)];
            end            
            AllCoordinates.cRect(m,:,n) = ClassStructures(m).frame(n).stim(1).wRect;
            AllCoordinates.cCenter(m,:,n) = ClassStructures(m).frame(n).stim(1).tCenter;
        else
            AllCoordinates.cRect(m,:,n) = ClassStructures(m).frame(n).stim(1).wRect;
            AllCoordinates.cCenter(m,:,n) = ClassStructures(m).frame(n).stim(1).tCenter;
        end
    end
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Create Window and Offscreen Windows
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
breaktime = GetSecs;
AllCoordinates.fCenter = [Display.centerX Display.centerY];
AllCoordinates.fRect = [Display.fX1 Display.fY1 Display.fX2 Display.fY2];
[window] = Screen(2,'OpenWindow',BlackIndex(0),[],32);
f = Screen(window,'OpenOffscreenWindow',BlackIndex(0),[],32);
%Screen(f,'FillRect',WhiteIndex(0),AllCoordinates.fRect);
Screen(f,'FillRect',[255,0,0],AllCoordinates.fRect);
r = Screen(window,'OpenOffscreenWindow',BlackIndex(0),[],32);  % Reward Window
Screen(r,'FillRect',WhiteIndex(0),[0 0 60 50]);
lum=[1,dist_lum]; %transparency for numtargets
for m  = 1:length(ClassStructures)
    for n = 1:length(ClassStructures(m).frame)
        WindowStructure(m).frame(n).end = Screen(window,'OpenOffscreenwindow', BlackIndex(0), [],32);
        if n < 2
            for o = 1:length(ClassStructures(m).frame(n))
                %Screen(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),AllCoordinates.fRect);
                Screen(WindowStructure(m).frame(n).end,'PutImage',Stimulus(ClassStructure(m).frame(n).stim(o).feature).Feature ...
                    ,ClassStructures(m).frame(n).stim(o).wRect);              
                Screen(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),[0 0 60 50]);
                Screen(WindowStructure(m).frame(n).end,'FillRect',[255,0,0],AllCoordinates.fRect);
            end
        else            
            for o = 1:numtargets % Display either the first (correct) or both choice targets in the class
            % Screen(WindowStructure(m).frame(n).end,'FillRect',lum(o)*eval(ClassStructure(m).frame(n).stim(o).color),ClassStructures(m).frame(n).stim(o).wRect);               
            if ClassStructure(m).frame(1).stim.feature==8 || ClassStructure(m).frame(1).stim.feature==4
            Screen(WindowStructure(m).frame(n).end,'PutImage',lum(o)*Stimulus(ClassStructure(m).frame(n).stim(o).feature).Feature ...
                    ,ClassStructures(m).frame(n).stim(o).wRect);  
            else
            Screen(WindowStructure(m).frame(n).end,'PutImage',1*Stimulus(ClassStructure(m).frame(n).stim(o).feature).Feature ...
                    ,ClassStructures(m).frame(n).stim(o).wRect);      
            end
            Screen(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),[0 0 60 50]);      
            end
        end
    end
end
end