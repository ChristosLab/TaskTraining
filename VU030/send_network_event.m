function send_network_event(event)
%EVENT - string
% Added double quotation marks to allow blank spaces in event - ZW 20220916
pyrunfile(['send_network_event.py ', '"', event, '"']);
end