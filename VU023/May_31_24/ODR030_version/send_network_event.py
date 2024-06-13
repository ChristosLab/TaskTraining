import zmq
import sys
context = zmq.Context()
socket = context.socket(zmq.REQ)
socket.connect("tcp://10.32.133.210:5556")
for event in sys.argv[1:]:
    socket.send_string(f"{event:s}")
    print(f"Sent event: {event:s}")
    message = socket.recv
	