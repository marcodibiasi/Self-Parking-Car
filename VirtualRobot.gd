class_name VirtualRobot
extends Node # Added 'extends Node' based on common Godot class structure, assuming it was omitted by mistake.

enum motion_phase {ACCEL, CRUISE, DECEL, TARGET}

var path_length: float
var max_velocity: float # Changed from max_vel
var acceleration: float # Changed from acc
var deceleration: float # Changed from decel
var current_velocity: float # Changed from curr_vel
var current_position: float # Changed from curr_position
var current_phase: int # Changed from curr_phase
var deceleration_distance: float # Changed from decel_distance
var final_rotation: float


func _init(_path_length: float, _max_velocity: float, _acceleration: float, _deceleration: float, _final_rotation: float) -> void: # Parameters updated
	path_length = _path_length
	max_velocity = _max_velocity
	acceleration = _acceleration
	deceleration = _deceleration
	current_velocity = 0
	current_position = 0
	current_phase = VirtualRobot.motion_phase.ACCEL # Changed from curr_phase
	
	deceleration_distance = 0.5 * pow(max_velocity, 2) / deceleration # Changed from decel_distance, max_vel, decel

# var prev_phase = self.curr_phase # Commented out as it's not used and causes an error due to direct assignment outside a function.
								# If needed, it should be part of a function or initialized within _init.

func evaluate(delta_time: float) -> void: # Parameter updated
	# ACCELERATION PHASE
	if current_phase == VirtualRobot.motion_phase.ACCEL: # Using current_phase
		current_position += current_velocity * delta_time + 0.5 * acceleration * pow(delta_time, 2) # Using current_position, current_velocity, acceleration
		current_velocity += acceleration * delta_time # Using current_velocity, acceleration

		var distance = path_length - current_position # Using path_length, current_position
		if distance < 0:
			distance = 0

		if current_velocity >= max_velocity: # Using current_velocity, max_velocity
			current_velocity = max_velocity # Using current_velocity, max_velocity
			current_phase = VirtualRobot.motion_phase.CRUISE # Using current_phase
		elif distance <= deceleration_distance: # Using deceleration_distance
			var expected_velocity = sqrt(2 * deceleration * distance) # Using deceleration
			if expected_velocity < current_velocity: # Using current_velocity
				current_phase = VirtualRobot.motion_phase.DECEL # Using current_phase

	# CRUISE PHASE
	elif current_phase == VirtualRobot.motion_phase.CRUISE: # Using current_phase
		current_position += max_velocity * delta_time # Using current_position, max_velocity

		var distance = path_length - current_position # Using path_length, current_position
		if distance <= deceleration_distance: # Using deceleration_distance
			current_phase = VirtualRobot.motion_phase.DECEL # Using current_phase

	# DECELERATION PHASE
	elif current_phase == VirtualRobot.motion_phase.DECEL: # Using current_phase
		var next_position = current_position + current_velocity * delta_time - 0.5 * deceleration * pow(delta_time, 2) # Using current_position, current_velocity, deceleration
		var next_velocity = current_velocity - deceleration * delta_time # Using current_velocity, deceleration

		if next_velocity < 0:
			next_velocity = 0

		if next_position >= path_length: # Using path_length
			current_position = path_length # Using current_position, path_length
			current_velocity = 0 # Using current_velocity
			current_phase = VirtualRobot.motion_phase.TARGET # Using current_phase
		else:
			current_position = next_position # Using current_position
			current_velocity = next_velocity # Using current_velocity


	# TARGET PHASE
	elif current_phase == VirtualRobot.motion_phase.TARGET: # Using current_phase
		print("ATTENZIONEEEEEEEE")
		current_velocity = 0.0 # Using current_velocity
		current_position = path_length # Using current_position, path_length
		
	

	# --- DEBUG: stampa il cambio di fase ---
	#match self.current_phase: # Using current_phase
		#VirtualRobot.motion_phase.ACCEL:
			#print("➡️ Entrata in fase: ACCEL")
		#VirtualRobot.motion_phase.CRUISE:
			#print("➡️ Entrata in fase: CRUISE")
		#VirtualRobot.motion_phase.DECEL:
			#print("➡️ Entrata in fase: DECEL")
		#VirtualRobot.motion_phase.TARGET:
			#print("✅ Fase finale: TARGET raggiunto")
	#print(current_velocity) # Using current_velocity


func get_speed() -> float:
	return current_velocity # Using current_velocity

func get_position() -> float:
	return current_position # Using current_position
