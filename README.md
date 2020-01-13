# MultisensoryInteractiveSystems

## Repository Structure

- arduino_code/arduino_code.ino: contains the code used to read data from the sensors and receive messages from PureData to control the actuators.
- pd_osc: implementation of OSC messages in Pure Data, to communicate with Processing
- processing_osc: implementation of the GUI to receive and parse OSC messages from Pure Data in Processing

## Communication

Arduino communicates via the serial protocol to Pure Data ("duplex" mode: Arduino sends and receives data).
Pure Data communicates via OSC messages (using a local network or on localhost (127.0.0.1)) ("simplex" mode: Pure data only sends messages to Processing)

## Brief architecture setup

Researchers' PC is connected directly to the circuit; runs Pure Data and the Arduino IDE to monitor the experiment, along with tools to record and evaluate the performance.
Users' PC displays the GUI, created by Processing; it is connected to the same network of the Researchers' PC.

## Resources

Connection between Pure Data and Arduino realized using the Firmata Firmware and Pduino (@see https://museumexp.wordpress.com/2013/04/23/connecting-arduino-to-pd-pure-data)
Connection between Pure Data and Processing realized using oscP5 and netP5

