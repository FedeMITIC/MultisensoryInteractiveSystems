# MultisensoryInteractiveSystems

## Repository Structure

- arduino_code/arduino_code.ino: contains the code used to read data from the sensors and receive messages from PureData to control the actuators.
- pd: implementation of OSC messages in Pure Data, to communicate with Processing
- processing: implementation of the GUI to receive and parse OSC messages from Pure Data in Processing

## Circuit design & components  

The circuit is powered through a Teensy 3.6 via USB. Its power consumption had been estimated to be around 0.61W, considering wires and the breadboard as ideal components.  

It is based on the following main components:  
1. 1 x Teensy 3.6  
2. 1 x BNO055 IMU by Bosch  
3. 2x 5mm Vibration Motor - 20mm Type (Model No. 304-116) by Precision Microdrives  

## Software Architecture

The software is written using C++ for Teensy, Pure Data for Pure Data and Java (Processing) for Processing; the communication between the three languages is established with two channels:  

1. Feedforward channel: from Teensy to PD via USB Serial, from PD to Processing via the network interface (OSC Messages)
2. Feedback    channel: -- UPDATE -- @see related issue

## Test Setup

The participant has a screen in front of them; this screen displays the virtual board and ball. The circuit, built on top of the wooden plank, is directly connected to the researcher's PC. 1 camera for recording the session is present. In addition to it, also the screens of the computers are recorded using screen capture tools.

## Acknowledgements     

Arduino2PD thanks to: http://hacklab.recyclism.com/workshops/arduino-to-pd-serial/  

