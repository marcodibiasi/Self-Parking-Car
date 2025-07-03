class_name VirtualRobot

enum motion_phase {ACCEL, CRUISE, DECEL, TARGET}

var path_length: float
var max_vel: float
var acc: float
var decel: float
var curr_vel: float 
var curr_position: float 
var curr_phase: int
var decel_distance: float
var final_rotation: float


func _init(path_length: float, max_vel: float, acc: float, decel: float, f_rotation: float) -> void:
	self.path_length = path_length
	self.max_vel = max_vel
	self.acc = acc
	self.decel = decel
	self.curr_vel = 0
	self.curr_position = 0
	self.curr_phase = VirtualRobot.motion_phase.ACCEL 
	
	self.decel_distance = 0.5 * pow(max_vel, 2) / decel
	var accel_distance = 0.5 * pow(max_vel, 2) / acc
	var total_needed = accel_distance + decel_distance
	
	if path_length < total_needed:
		self.max_vel = sqrt((2 * acc * decel * path_length) / (acc + decel))
		self.decel_distance = 0.5 * pow(self.max_vel, 2) / decel
	
	self.final_rotation = f_rotation

var prev_phase = self.curr_phase  # Salva la fase precedente

func evaluate(delta_t: float) -> void:
	# ACCELERATION PHASE
	if self.curr_phase == VirtualRobot.motion_phase.ACCEL:
		self.curr_position += self.curr_vel * delta_t + 0.5 * self.acc * pow(delta_t, 2)
		self.curr_vel += self.acc * delta_t

		var distance = self.path_length - self.curr_position
		if distance < 0:
			distance = 0

		if self.curr_vel >= self.max_vel:
			self.curr_vel = self.max_vel
			self.curr_phase = VirtualRobot.motion_phase.CRUISE
		elif distance <= self.decel_distance:
			var expected_vel = sqrt(2 * self.decel * distance)
			if expected_vel < self.curr_vel:
				self.curr_phase = VirtualRobot.motion_phase.DECEL

	# CRUISE PHASE
	elif self.curr_phase == VirtualRobot.motion_phase.CRUISE:
		self.curr_position += self.max_vel * delta_t

		var distance = self.path_length - self.curr_position
		if distance <= self.decel_distance:
			self.curr_phase = VirtualRobot.motion_phase.DECEL

	# DECELERATION PHASE
	elif self.curr_phase == VirtualRobot.motion_phase.DECEL:
		var next_pos = self.curr_position + self.curr_vel * delta_t - 0.5 * self.decel * pow(delta_t, 2)
		var next_vel = self.curr_vel - self.decel * delta_t

		if next_vel < 0:
			next_vel = 0

		if next_pos >= self.path_length:
			self.curr_position = self.path_length
			self.curr_vel = 0
			self.curr_phase = VirtualRobot.motion_phase.TARGET
		else:
			self.curr_position = next_pos
			self.curr_vel = next_vel


	# TARGET PHASE
	elif self.curr_phase == VirtualRobot.motion_phase.TARGET:
		print("ATTENZIONEEEEEEEE")
		self.curr_vel = 0.0
		self.curr_position = self.path_length
		
	

	# --- DEBUG: stampa il cambio di fase ---
	#match self.curr_phase:
		#VirtualRobot.motion_phase.ACCEL:
			#print("➡️ Entrata in fase: ACCEL")
		#VirtualRobot.motion_phase.CRUISE:
			#print("➡️ Entrata in fase: CRUISE")
		#VirtualRobot.motion_phase.DECEL:
			#print("➡️ Entrata in fase: DECEL")
		#VirtualRobot.motion_phase.TARGET:
			#print("✅ Fase finale: TARGET raggiunto")
	print(curr_vel)


func get_speed() -> float:
	return self.curr_vel

func get_position() -> float:
	return self.curr_position
