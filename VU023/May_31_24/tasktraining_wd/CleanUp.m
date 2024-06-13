try
    outputSingleScan(DO,[0,0,0,0,0,0,0,0]);
    WaitSecs(1)
end

Screen('CloseAll')
AllData.endtime = GetSecs;
%[var,var,AllData.eyeabstime,AllData.eyelog] = getdata(ai,ai.SamplesAvailable);
close(hFig)
save(['C:\Users\CCLAB\Documents\Behavioral_Data\' datasin],'AllData');
clear all;
clear global trial_eye_data