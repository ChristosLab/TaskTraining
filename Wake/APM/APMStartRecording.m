function [APMConn, apmstatus] = APMStartRecording
% APMHost = '172.17.11.27';
APMHost = '169.254.244.188'; %215.92';
% APMHost = '169.254.107.197';
% APMHost = '169.2545.204'; 
% APMHost = '169.254.252.100';  
% APMHost = '169.254.174.119';
% APMHost = '169.254.112.108';
APMMsgPort = 2566;
pnet('closeall');
pause(0.1);
APMConn=pnet('tcpconnect',APMHost,APMMsgPort);
% Send the start recording command
% Build a message with the standard APM format (see data data file format topic in the APM help file)
APMMsg=uint32([]);
APMMsg(1)=uint32(hex2dec('10000')); % Message code
APMMsg(2)=uint32(0);                % Channel
APMMsg(3)=uint32(1);                % Message length (number of 32-bit words to follow)
APMMsg(4)=uint32(1);                % Recording ON/OFF (1/0)
pnet(APMConn,'write',uint32(APMMsg),'intel');   % Send the array to APM
pause(0.1);
ConnStat=pnet(APMConn,'status');
if ConnStat < 0
    disp('Could Not Connect to APM!')
    apmstatus = 0;
else
    apmstatus = 1;
end
