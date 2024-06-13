function [window, f, r,WindowStructure, AllCoordinates] = CreateWindowStruct_gabor_geometry(Display, vstruct, ClassStructure, MNM,contrast,num_stim)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Stimulus Features
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
image_contrast=contrast;
                                               %Pixels
Stimulus(1).Feature = image_contrast*imread('gabor_0.BMP');    
Stimulus(2).Feature = image_contrast*imread('gabor_45.BMP');   
Stimulus(3).Feature = image_contrast*imread('gabor_90.BMP');    
Stimulus(4).Feature = image_contrast*imread('gabor_135.BMP');   
Stimulus(5).Feature = image_contrast*imread('gabor_180.BMP');   
Stimulus(6).Feature = image_contrast*imread('gabor_225.BMP');    
Stimulus(7).Feature = image_contrast*imread('gabor_270.BMP');  
Stimulus(8).Feature = image_contrast*imread('gabor_315.BMP');         
Stimulus(9).Feature = image_contrast*imread('Y.BMP');   
Stimulus(10).Feature = image_contrast*imread('Circle.BMP');  
Stimulus(11).Feature = image_contrast*imread('H.BMP');         
Stimulus(12).Feature = image_contrast*imread('Plus.BMP');    
Stimulus(13).Feature = image_contrast*imread('Square.BMP');   
Stimulus(14).Feature = image_contrast*imread('Diamond.BMP');    
Stimulus(15).Feature = image_contrast*imread('Number.BMP');   
Stimulus(16).Feature = image_contrast*imread('Triangle.BMP');   

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Streamlining variables
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
scale=2/5;
for i=1:length(ClassStructure)
    for j=1:num_stim
    stimsize(i,j,:)=scale*flip(size(Stimulus(ClassStructure(i).frame(j).stim.feature).Feature,[1,2]));
    end
end
%stimsize = Display.Stimsize;
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
    if m==44
        disp('debug');
    end
    for n = 1:num_stim % window for cue sample and chocie period
        XY = ClassStructure(m).frame(n).stim(1).end;%target location in degree;
        vertical_offset=round(screen_dis*atan(XY(2)/180*pi)/(screen_size(2)/2)*(resolusion(2)/2));
        horizontal_offset=round(screen_dis*atan(XY(1)/180*pi)/(screen_size(1)/2)*(resolusion(1)/2));
       % XY=XY+[horizontal_offset,vertical_offset];%target location in pixel;
        XY=[horizontal_offset,vertical_offset]; 
        XY(2) = XY(2)*-1;
        tCenter = XY + [Display.centerX Display.centerY];
        ClassStructures(m).frame(n).stim(1).tCenter = tCenter;
        ClassStructures(m).frame(n).stim(1).wRect   = [tCenter(1) - stimsize(m,n,1), tCenter(2) - stimsize(m,n,2), ...
                tCenter(1) + stimsize(m,n,1), tCenter(2) + stimsize(m,n,2)];

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
%Screen(f,'FillRect',WhiteIndex(0),AllCoordinates.fRect);
Screen(f,'FillRect',[255,0,0],AllCoordinates.fRect);
r = Screen(window,'OpenOffscreenWindow',BlackIndex(0),[],32);  % sync window
% Screen(r,'FillRect',WhiteIndex(0),[0 0 60 50]);
for m  = 1:length(ClassStructures)
    for n = 1:length(ClassStructures(m).frame)
        WindowStructure(m).frame(n).end = Screen(window,'OpenOffscreenwindow', BlackIndex(0), [],32);

            for o = 1:length(ClassStructures(m).frame(n))
          %     Screen(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),AllCoordinates.fRect);
                Screen(WindowStructure(m).frame(n).end,'PutImage',Stimulus(ClassStructure(m).frame(n).stim(o).feature).Feature ...
                ,ClassStructures(m).frame(n).stim(o).wRect);
                Screen(WindowStructure(m).frame(n).end,'FillRect',[255,0,0],AllCoordinates.fRect);
                if n == 1
                    Screen(WindowStructure(m).frame(n).end,'FillRect',WhiteIndex(0),[0 0 60 50]);
                end
            end

    end
end
end