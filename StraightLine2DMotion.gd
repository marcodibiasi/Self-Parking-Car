class_name StraightLine2DMotion
extends Node

var max_velocity: float 
var acceleration: float 
var deceleration: float 
var start_position_x: float 
var start_position_z: float 
var end_position_x: float 
var end_position_z: float 
var heading_angle: float 
var target_distance: float
var final_rotation: float
var virtual_robot_instance: VirtualRobot 

func _init(_max_velocity: float, _acceleration: float, _deceleration: float, _final_rotation: float) -> void: 
	max_velocity = _max_velocity
	acceleration = _acceleration
	deceleration = _deceleration
	final_rotation = _final_rotation
	virtual_robot_instance = VirtualRobot.new(target_distance, max_velocity, acceleration, deceleration, final_rotation) # Initialized here for safety, though 'target_distance' might be 0 at this point. Will be correctly set in start_motion.

func start_motion(start_vector: Vector3, end_vector: Vector3) -> void: 
	start_position_x = start_vector.x
	start_position_z = start_vector.z
	end_position_x = end_vector.x
	end_position_z = end_vector.z
	
	var delta_x = end_position_x - start_position_x
	var delta_z = end_position_z - start_position_z
	
	heading_angle = atan2(delta_z, delta_x)
	target_distance = sqrt(pow(delta_x, 2) + pow(delta_z, 2))
	# Re-initialize virtual_robot_instance with correct target_distance
	virtual_robot_instance = VirtualRobot.new(target_distance, max_velocity, acceleration, deceleration, final_rotation)

func evaluate(delta_time: float) -> Vector3: 
	virtual_robot_instance.evaluate(delta_time)
	var current_x = start_position_x + virtual_robot_instance.get_position() * cos(heading_angle)
	var current_z = start_position_z + virtual_robot_instance.get_position() * sin(heading_angle)
	return Vector3(current_x, 0, current_z)
