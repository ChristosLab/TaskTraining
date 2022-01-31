function APMSendReward(trialcounter,reward, APMConn)
APMMsg=uint32([]);
APMMsg(1)=uint32(hex2dec('10101')); % Message code
APMMsg(2)=uint32(0);                % Channel
APMMsg(3)=uint32(2);       % Message length (number of 32-bit words to follow)
APMMsg(4)=uint32(trialcounter);
APMMsg(5)=uint32(reward);
pnet(APMConn,'write',APMMsg,'intel');   % Send the array to APM
pause(.1);
