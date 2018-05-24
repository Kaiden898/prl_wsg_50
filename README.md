#ROS package prl_wsg_50
original code from ROS package for Schunk WSG-50 Gripper downloaded 05/2018
Forked from: [https://code.google.com/p/wsg50-ros-pkg](https://code.google.com/p/wsg50-ros-pkg)

Modifications of this repository:
Reading back state with high rates, open-loop control via topics, catkinized, modifications for hydro.
Existing features are not discussed here - see original Wiki: [https://code.google.com/p/wsg50-ros-pkg/wiki/wsg_50](https://code.google.com/p/wsg50-ros-pkg/wiki/wsg_50)

Todo: Restructure code


## Node wsg\_50\_ip (was: wsg\_50_tcp)

### Parameters
* *ip*: IP address of gripper
* *port*: Port of gripper
* *local_port*: Local port for UDP
* *protocol*: udp or tcp (default)
* *com_mode*: polling (default), script or auto_update. See communication modes below.
* *rate*: Polling rate in Hz.
* *grasping_force*: Set grasping force limit on startup


### Services
See [https://code.google.com/p/wsg50-ros-pkg/wiki/wsg_50](https://code.google.com/p/wsg50-ros-pkg/wiki/wsg_50). Services currently block the reception of state updates.

/wsg_50_driver/ack 					/wsg_50_driver/move_incrementally <br/>
/wsg_50_driver/get_loggers 			/wsg_50_driver/release<br/>
/wsg_50_driver/grasp 				/wsg_50_driver/set_acceleration<br/>
/wsg_50_driver/graspForce 			/wsg_50_driver/set_force<br/>
/wsg_50_driver/homing				/wsg_50_driver/set_logger_level<br/>
/wsg_50_driver/move 				/wsg_50_driver/stop<br/>

* */wsg_50_driver/ack [no parameters]* 
	Acknoledge an error condition.

* */wsg_50_driver/get_loggers [no parameters]*
	
* */wsg_50_driver/grasp [object width (mm), speed (mm/s)]*
	Grasps the object with givin width and speed. Object must be released before moving
	the grippers fingers.

* */wsg_50_driver/graspForce [force to grasp with (N), speed (mm/s)]*
	Grasps object with given force and speed. Minus soft limit must be set to allow gripping.
	Refer to WSG 50 "Mounting and Operating Manual" and the "Command Set Reference Manual" 
	for setting the minus soft limit.Object must be released before moving
	the grippers fingers.

* */wsg_50_driver/homing [no parameters]*
	Sets up reference for gripper finger position.

* */wsg_50_driver/move [width (mm), speed (mm/s)]*
	Moves the fingers to the specified width at the given speed. Fingers cannot be blocked.

* */wsg_50_driver/move_incrementally []*

* */wsg_50_driver/release [width (mm), speed (mm/s)]*
	Releases the object being held and moves to the given position at the given speed.

* */wsg_50_driver/set_acceleration []*
	Sets the acceleration for movment of the gripper fingers.

* */wsg_50_driver/set_force [force (N)]*
	Sets the force the gripper will grasp an object at.

* */wsg_50_driver/set_logger_level [no parameters]*

* */wsg_50_driver/stop [no parameters]*

### Topics
* *~/goal\_position [IN, wsg_50_common/Cmd]*, in modes script, auto_update:<br/>
Position goal; send target position in mm and speed
* *~/goal\_speed [IN, std_msgs/Float32]*, in mode script:<br/>
Velocity goal (in mm/s); positive values open the gripper
* *~/moving [OUT, std_msgs/Bool]*, in modes script, auto_update:<br/>
Signals a change in the motion state for position control. Can be used to wait for the end of a gripper movement. Does not work correctly yet for velocity control, since the gripper state register does not directly provide this information.
* *~/state [OUT, std_msgs/State]:*<br/>
State information (opening width, speed, forces). Note: Not all fields are available with all communication modes.
* */joint_states [OUT, sensor_msgs/JointState]:*<br/>
Standard joint state message
* */left_dsa_marker_array []*<br/>
	Contains an array of markers corresponding to the left dsa finger sensor layout. The markers change
	color based on the pressure applied to the sensor.  
* */right_dsa_marker_array []*<br/>
	Contains an array of markers corresponding to the right dsa finger sensor layout. The markers change
	color based on the pressure applied to the sensor. 
* */left_dsa_marker_array []*<br/>
	Contains an array of integers corresponding to the left dsa finger sensor layout. The value is associated to the amount of pressure applied to the sensor and ranges from 0 to 3895. 
* */right_dsa_marker_array []*<br/>
	Contains an array of integers corresponding to the right dsa finger sensor layout. The value is associated to the amount of pressure applied to the sensor and ranges from 0 to 3895.



### Communication modes (closed-loop control)
Select by *com_mode* parameter.

* **Polling**<br />
Gripper state is polled regularly using built-in commands (original implementaion). Service calls (e.g. move) block polling as long as the gripper moves. The topic interface is not available. Up to 15 Hz could be reached with the WSG-50 hardware revision 2.

* **Script**<br />
Allows for closed-loop control with a custom script (see below) that supports up to 2 FMF finger. Gripper state is read synchronously with the specified rate. Up to 30 Hz could be reached with the WSG-50 hardware revision 2. The gripper can be controlled asynchronously by sending position or velocity goals to the topics listed above. Commands will be sent with the next read command in the timer callback timer_cb().<br />
The service interface can still be used - yet, they are blocking the gripper communication. There are no state updates while the gripper is moved by a service. 

* **Auto_update**<br>
Requests periodic updates of the gripper state (position, speed, force; less data than with the script). Up to 140 Hz could be reached with the WSG-50 hardware revision 2. All responses of the gripper must be received by a reading thread which also publishes the ROS messages. Therefore, most commands in functions.cpp cannot be used. Position targets are sent asynchronously to the gripper using the built-in commands.<br />
The services are disabled.

#### Gripper script
The script *cmd_measure.lua* must be running on the gripper for the script mode. It allows for non-blocking position and velocity control and responds with the current position, speed, motor force and up to two FMF finger forces. The custom commands 0xB0 (read only), 0xB1 (read, goal position and speed), 0xB2 (read, goal speed) are used. Tested with firmware version 2.6.4. There have been minor API changes since 1.x.


## Node wsg\_50_can

Remains unchanged; new features not implemented here. 