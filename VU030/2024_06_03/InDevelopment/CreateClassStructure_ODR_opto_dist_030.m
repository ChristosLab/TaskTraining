function  [ClassStructure] = CreateClassStructure_ODR_opto_dist_030(stim_eccen, cue_loc, visual_distract)
%  Zhengyang Wang 20231208.
%  Inherited from CreateClassStructure_ODR_opto_dist_030 
% INPUT: stim_eccen
%  stimulus eccentricity in degree. n_cue_loc number of cue locations,
%  normally = 8. cue_loc cue location, 1 for cardinal, 2 for diagonal, 3
%  for both. visual_distract: false - 2 class per cue location; dist = -1
%  reserved for laser; meant to to be used with 0 distractor luminance for
%  frame timing only; can otherwise be used as a reminder. true - 5 class
%  per condition. OUTPUT: ClassStructure. two columns 1st is frame and 2nd
%  is notes. each row in frame is 1x3 struct named stim, with cue @ 1st,
%  dist @ 2nd and target at 3rd (same as cue). For use in WHAF room 030 @
%  VU.
%%
if nargin <3
    visual_distract = false;
end
if nargin < 2
    cue_loc = 3;
end
if nargin < 1 || isempty(stim_eccen)
    stim_eccen= 10;
end
%%
dist = [180 90 45 0 nan];
null_dist = [-1 nan];
switch cue_loc
    case 1  % card
        cues = [0:90:270];
    case 2  % diag
        cues = [45:90:315];
    case 3 % both
        cues = [0:45:315];
end
for j = 1:length(cues)
    if visual_distract
        dist_angle = dist + cues(j);
    else
        dist_angle = null_dist + cues(j);
    end
    for i = 1:length(dist_angle)
        ClassStructure((j-1)*numel(dist_angle)+i).frame(1).stim.end = [stim_eccen*cos(cues(j)/180*pi), stim_eccen*sin(cues(j)/180*pi)];
        if dist_angle(i) - cues(j) ~= -1
            ClassStructure((j-1)*numel(dist_angle)+i).frame(2).stim.end = [stim_eccen*cos(dist_angle(i)/180*pi), stim_eccen*sin(dist_angle(i)/180*pi)];
            ClassStructure((j-1)*numel(dist_angle)+i).laser = false;
            ClassStructure((j-1)*numel(dist_angle)+i).Notes = [num2str(cues(j)) '-' num2str(dist_angle(i))];
        else
            ClassStructure((j-1)*numel(dist_angle)+i).frame(2).stim.end = [stim_eccen*cos(nan/180*pi), stim_eccen*sin(nan/180*pi)];
            ClassStructure((j-1)*numel(dist_angle)+i).laser = true;
            ClassStructure((j-1)*numel(dist_angle)+i).Notes = [num2str(cues(j)) '-' 'laser'];
        end
        ClassStructure((j-1)*numel(dist_angle)+i).frame(3).stim.end = [stim_eccen*cos(cues(j)/180*pi), stim_eccen*sin(cues(j)/180*pi)];
        ClassStructure((j-1)*numel(dist_angle)+i).frame(1).stim.feature = 6;
        ClassStructure((j-1)*numel(dist_angle)+i).frame(2).stim.feature = 6;
        ClassStructure((j-1)*numel(dist_angle)+i).frame(3).stim.feature = 6;
    end
end
end