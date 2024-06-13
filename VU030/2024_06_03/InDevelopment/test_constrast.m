clear
sca
[window] = Screen(2,'OpenWindow',BlackIndex(0),[],32);
%   fix window
lums = [0 ,3 ,6, 100]./100;
for i = 1:numel(lums)
    f(i) = Screen(window,'OpenOffscreenWindow',WhiteIndex(0) * lums(i),[],32);
end
current_frame = 1;
while true
    if KbCheck
        disp(lums(current_frame))
        Screen('CopyWindow',f(current_frame),window);
        Screen(window,'Flip');
        current_frame = mod(current_frame, 4) + 1;
        current_frame = mod(current_frame, 4) + 1;
        WaitSecs(0.5);
    end
end
