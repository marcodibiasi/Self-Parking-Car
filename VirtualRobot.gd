class_name VirtualRobot
extends Node 

enum motion_phase {ACCEL, CRUISE, DECEL, TARGET}

var path_length: float
var max_velocity: float 
var acceleration: float 
var deceleration: float 
var current_velocity: float 
var current_position: float 
var current_phase: int 
var deceleration_distance: float 
var final_rotation: float


func _init(_path_length: float, _max_velocity: float, _acceleration: float, _deceleration: float, _final_rotation: float) -> void: 
	path_length = _path_length
	max_velocity = _max_velocity
	acceleration = _acceleration
	deceleration = _deceleration
	current_velocity = 0
	current_position = 0
	current_phase = VirtualRobot.motion_phase.ACCEL 
	
	deceleration_distance = 0.5 * pow(max_velocity, 2) / deceleration 

func evaluate(delta_time: float) -> void: 
	# ACCELERATION PHASE
	if current_phase == VirtualRobot.motion_phase.ACCEL: 
		current_position += current_velocity * delta_time + 0.5 * acceleration * pow(delta_time, 2) 
		current_velocity += acceleration * delta_time 

		var distance = path_length - current_position 
		if distance < 0:
			distance = 0

		if current_velocity >= max_velocity: 
			current_velocity = max_velocity 
			current_phase = VirtualRobot.motion_phase.CRUISE 
		elif distance <= deceleration_distance: 
			var expected_velocity = sqrt(2 * deceleration * distance) 
			if expected_velocity < current_velocity: 
				current_phase = VirtualRobot.motion_phase.DECEL 

	# CRUISE PHASE
	elif current_phase == VirtualRobot.motion_phase.CRUISE: 
		current_position += max_velocity * delta_time 

		var distance = path_length - current_position 
		if distance <= deceleration_distance: 
			current_phase = VirtualRobot.motion_phase.DECEL 

	# DECELERATION PHASE
	elif current_phase == VirtualRobot.motion_phase.DECEL: 
		var next_position = current_position + current_velocity * delta_time - 0.5 * deceleration * pow(delta_time, 2) 
		var next_velocity = current_velocity - deceleration * delta_time 

		if next_velocity < 0:
			next_velocity = 0

		if next_position >= path_length: 
			current_position = path_length 
			current_velocity = 0 
			current_phase = VirtualRobot.motion_phase.TARGET 
		else:
			current_position = next_position 
			current_velocity = next_velocity 


	# TARGET PHASE
	elif current_phase == VirtualRobot.motion_phase.TARGET: 
		print("ATTENZIONEEEEEEEE")
		current_velocity = 0.0 
		current_position = path_length 
		
	

	# --- DEBUG: stampa il cambio di fase ---
	#match self.current_phase: 
		#VirtualRobot.motion_phase.ACCEL:
			#print("➡️ Entrata in fase: ACCEL")
		#VirtualRobot.motion_phase.CRUISE:
			#print("➡️ Entrata in fase: CRUISE")
		#VirtualRobot.motion_phase.DECEL:
			#print("➡️ Entrata in fase: DECEL")
		#VirtualRobot.motion_phase.TARGET:
			#print("✅ Fase finale: TARGET raggiunto")
	#print(current_velocity) 


func get_speed() -> float:
	return current_velocity 

func get_position() -> float:
	return current_position 
