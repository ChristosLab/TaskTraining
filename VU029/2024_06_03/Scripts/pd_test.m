pd_ = [0];
ts_ = [0];
figure;
hold on
l_ = plot(ts_, pd_, '-');
t0 = GetSecs;
while 1
Screen('CopyWindow',r,window)
Screen(window,'Flip');
t_ = GetSecs();
while GetSecs - t_ < 0.2
    ss_ = inputSingleScan(ai);
    pd_ = [pd_, ss_(4)];
    ts_  = [ts_, GetSecs - t0];
    l_.YData = pd_((max(1, end - 499)):end);
    l_.XData = ts_((max(1, end - 499)):end);
    xlim([ts_(max(1, end - 499)), ts_(end)]);
    drawnow
end
Screen('CopyWindow',window_queue{end},window)
Screen(window,'Flip');
t_ = GetSecs();
while GetSecs - t_ < 0.2
    ss_ = inputSingleScan(ai);
    pd_ = [pd_, ss_(4)];
    ts_  = [ts_, GetSecs - t0];
    l_.YData = pd_((max(1, end - 499)):end);
    l_.XData = ts_((max(1, end - 499)):end);
    xlim([ts_(max(1, end - 499)), ts_(end)]);
    drawnow
end

end