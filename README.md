# Conveyor-Belt

________________________________________
Project Report: Smart Conveyor Belt System
Course: CSEN 605: Digital System Design
Project Option: E - Conveyor Belt System

________________________________________
1. Project Idea & Overview
The objective of this project was to design and implement an automated Smart Conveyor Belt System using an FPGA (Intel MAX 10 on DE10-Lite board). The system is designed to simulate a real-world industrial environment with three core goals:
1.	Automation: The belt remains stationary to save energy and only starts moving when a product is placed on it (detected via a touch sensor).
2.	Safety: An obstacle detection system immediately halts the motor and triggers an audible alarm if a blockage or human hand is detected in the path.
3.	Monitoring: The system counts the number of products processed and displays the count in real-time on a 7-segment display. A reset feature allows the operator to clear the count.
________________________________________
2. Sensors and Components Used
The project integrates digital logic (VHDL) with physical sensors and actuators.
•	FPGA Board: Terasic DE10-Lite (Intel MAX 10 10M50DAF484C7G).
•	Sensors:
o	1x Capacitive Touch Sensor: Acts as the "Product Sensor" to trigger the start of the conveyor.
o	1x IR Obstacle Sensor: Detects blockages for the emergency stop system.
o	1x IR Counting Sensor: Detects products passing a specific point to increment the counter.
•	Actuators:
o	1x DC Gear Motor (3V-6V): Drives the conveyor belt mechanism.
o	1x Active Buzzer: Provides audio feedback during emergency stops.
•	Driver Circuit:
o	1x Transistor: Acts as a switch to drive the motor using the FPGA's control signal.
•	User Interface:
o	1x Push Button: Used as a manual reset for the product counter.
o	7-Segment Display (On-board): Visualizes the product count (using HEX5).
________________________________________
3. Implementation Details
A. VHDL Logic & Code Structure
The system was implemented using VHDL with a modular design condensed into a single behavioral architecture for stability. The design features:
1.	Synchronous Finite State Machine (FSM):
o	IDLE State: Motor is OFF. Logic waits for the product_sensor to be Active and obstacle_sensor to be Clear.
o	MOVING State: Motor is ON. Logic monitors continuously for obstacles (Transition to EMERGENCY_STOP) or product removal (Transition back to IDLE).
o	EMERGENCY_STOP State: Motor is OFF, Buzzer is ON. The system remains locked in this state until the obstacle is physically removed.
2.	Signal Conditioning (Debouncing & Edge Detection):
o	Raw signals from mechanical buttons and sensors are noisy. We implemented a Debouncer that waits for 50,000 clock cycles (1ms) of stability before accepting a signal change.
o	To prevent "machine-gun counting" (where one object counts as 50 items), we implemented Rising/Falling Edge Detection. The counter increments specifically on the falling edge of the product signal (when the product passes/leaves the sensor).
3.	Hardware Abstraction:
o	Configuration constants were used to easily toggle between Active-High and Active-Low logic for different sensor types.
B. Circuit & Wiring
The system is powered directly via the FPGA board's on-board voltage supply pins.
•	Motor Driver: The FPGA sends a logic signal to the Base of the transistor. The Collector connects to the Motor (-) and the Emitter connects to Ground. The Motor (+) connects to the FPGA board's 5V (VCC) pin.
•	Power Source: The system utilizes the FPGA's internal 5V and 3.3V rails to power the sensors and the motor, eliminating the need for an external battery pack. Ground connections are shared across the board's GND pins.
C. Pin Assignments (DE10-Lite)
The VHDL ports were mapped to the physical FPGA pins using the Quartus Pin Planner. The 7-segment display logic was mapped to HEX5.
Port Name	Direction	FPGA Pin	Description
clk	Input	PIN_P11	50 MHz On-board Clock
clear_btn	Input	PIN_B8	Push Button (Reset)
product_sensor	Input	PIN_V8	GPIO Pin (Touch Sensor)
count_sensor	Input	PIN_V9	GPIO Pin (Counting Sensor)
obstacle_sensor	Input	PIN_W10	GPIO Pin (Obstacle Sensor)
motor_out	Output	PIN_AB3	GPIO Pin (Motor Control)
buzzer_out	Output	PIN_AB2	GPIO Pin (Buzzer Control)
segments_out[0]	Output	PIN_N20	HEX5 Segment A
segments_out[1]	Output	PIN_N19	HEX5 Segment B
segments_out[2]	Output	PIN_M20	HEX5 Segment C
segments_out[3]	Output	PIN_N18	HEX5 Segment D
segments_out[4]	Output	PIN_L18	HEX5 Segment E
segments_out[5]	Output	PIN_K20	HEX5 Segment F
segments_out[6]	Output	PIN_J20	HEX5 Segment G
________________________________________
4. Results
The project was verified through both ModelSim simulation and physical hardware testing.
1.	Simulation: The testbench (tb_conveyor.vhd) successfully demonstrated the FSM transitions. We verified that the motor signal goes high only when the product signal is active and immediately drops low when the obstacle signal triggers. The counter logic was proven to increment only once per pulse event.
2.	Physical Prototype:
o	Functionality: The belt runs smoothly when triggered and stops instantly when an object blocks the IR sensor path.
o	Safety: The buzzer successfully activates during the obstacle state, providing clear audio feedback.
o	Counting: The 7-segment display (HEX5) accurately counts objects placed on the belt without skipping or double-counting, thanks to the edge-detection logic.

