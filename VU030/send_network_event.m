function send_network_event(event)
%EVENT - string
pyrunfile(['send_network_event.py ', event]);
end