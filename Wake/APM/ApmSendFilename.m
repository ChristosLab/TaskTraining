function [APMConn] = ApmSendFilename(filename, APMConn)
% APMHost = '172.17.11.27';
APMHost = '169.254.244.188';
% APMHost = '169.254.107.197';
% APMHost = '169.254.174.119';
% APMHost = '169.254.25.204'; %
% APMHost = '169.254.112.108';
% APMHost = '169.254.252.100'; % 
APMMsgPort = 2566;
pnet('closeall');
pause(0.1);
APMConn=pnet('tcpconnect',APMHost,APMMsgPort);
missingBytes=4-mod(length(filename),4);
if (missingBytes<4)
    filename=[filename uint8(zeros(1,missingBytes))];
end;
APMMsg=uint32([]);
APMMsg(1)=uint32(hex2dec('10002'));  % Message code
APMMsg(2)=uint32(0);                % Channel
APMMsg(3)=uint32(length(filename)/4);                % Message length (number of 32-bit words to follow)
pnet(APMConn,'write',uint32(APMMsg),'intel');   % Send the header to APM
pnet(APMConn,'write',uint8(filename),'intel');  % Send the string to APM
