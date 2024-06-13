function  [ClassStructure] = CreateClassStructure_ODR_dist_only_023(stim_eccen, cue_loc)
%  Zhengyang Wang migrated for use in lab 23 on Feb.22.2022 (w/o photodiode
%  events).

%  Junda Zhu 20220217.
%  For use in an Oculomotor Delayed Response task with a DISTractor after the cue
%  distractor location: 0, 45, 90, 180 degree from cue location, or null
%  INPUT: stim_eccen stimulus eccentricity in degree. n_cue_loc number of
%  cue locations, normally = 8. cue_loc cue location, 1 for cardinal, 2 for
%  diagonal, 3 for both.
%  OUTPUT: ClassStructure. two columns 1st is frame and 2nd is notes. each
%  row in frame is 1x3 struct named stim, with cue @ 1st, dist @ 2nd and target at 3rd (same as cue). 
%  For use in WHAF room 030 @ VU.
%%
if nargin < 2
    cue_loc = 3;
end
if nargin < 1 || isempty(stim_eccen)
    stim_eccen= 10;
end
%%
dist = [180 90 45];
switch cue_loc
    case 1  % card
        cues = [0:90:270];
    case 2  % diag
        cues = [45:90:315];
    case 3 % both
        cues = [0:45:315];
end
for j = 1:length(cues)
    dist_angle = dist + cues(j);
    for i = 1:length(dist_angle)
        ClassStructure((j-1)*3+i).frame(1).stim.end = [stim_eccen*cos(cues(j)/180*pi), stim_eccen*sin(cues(j)/180*pi)];
        ClassStructure((j-1)*3+i).frame(2).stim.end = [stim_eccen*cos(dist_angle(i)/180*pi), stim_eccen*sin(dist_angle(i)/180*pi)];
        ClassStructure((j-1)*3+i).frame(3).stim.end = [stim_eccen*cos(cues(j)/180*pi), stim_eccen*sin(cues(j)/180*pi)];
        ClassStructure((j-1)*3+i).frame(1).stim.feature = 6;
        ClassStructure((j-1)*3+i).frame(2).stim.feature = 6;
        ClassStructure((j-1)*3+i).frame(3).stim.feature = 6;
        ClassStructure((j-1)*3+i).Notes = [num2str(cues(j)) '-' num2str(dist_angle(i))];
    end
end
%     save(['C:\MATLAB6p5\work\ODRdist\classODRdistVar_' num2str(j)],'ClassStructure');
%     clear ClassStructure;
end