function APMSendMessage(trialcounter,Statenum, APMConn)
outlength = 2;  % 1 trialnum int + 2 dir double + 2 ecc double
APMMsg=uint32([]);
APMMsg(1)=uint32(hex2dec('10100')); % Message code
APMMsg(2)=uint32(0);                % Channel
APMMsg(3)=uint32(outlength);       % Message length (number of 32-bit words to follow)
% Send the information as an integer containig the value multiplied by 100
% This is equivalent to sending a float with two decimal points precision
APMMsg(4)=uint32(trialcounter);
APMMsg(5)=uint32(Statenum*100);
% Add here whatever you want to send, and keep in mind to increment the
% message length to match the number of uint32 in the message
pnet(APMConn,'write',APMMsg,'intel');   % Send the array to APM
pause(.1);
