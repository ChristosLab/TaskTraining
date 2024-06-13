%{
%%%%%%%%%using matlab
url='tcp://10.32.133.210:5556';
handle = zeroMQwrapper('StartConnectThread',url);
for i=1:2000
    disp(i);
    zeroMQwrapper('Send',handle,num2str(i));
    WaitSecs(0.5);
end
%}

%%%%%%using python env
if pe.Status == 'Loaded'
    disp('Python is loaded');
else
pyenv('Version', 'C:\Users\CCLAB\anaconda3\envs\zmq\python.exe');
end
for i=1:2000
    disp(i);
    send_network_event(num2str(i));
    WaitSecs(0.5);
end