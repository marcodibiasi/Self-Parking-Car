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

func _init(path_length: float, max_vel: float, acc: float, decel: float) -> void:
	self.path_length = path_length
	self.max_vel = max_vel
	self.acc = acc
	self.decel = decel
	self.curr_vel = 0
	self.curr_position = 0
	self.curr_phase = VirtualRobot.motion_phase.ACCEL 
	self.decel_distance = 0.5 * pow(max_vel, 2) / decel

func evaluate(delta_t: float) -> void: 
	#print(curr_phase, ", ", decel_distance)
	print(delta_t)
	
	#ACCELERATION PHASE
	if self.curr_phase == VirtualRobot.motion_phase.ACCEL:
		self.curr_position = self.curr_position + (self.curr_vel * delta_t) + (self.acc * pow(delta_t, 2) * 0.5)
		self.curr_vel = self.curr_vel + self.acc * delta_t
		#uniformly accelerated motion
		
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

	#CRUISE PHASE
	elif self.curr_phase == VirtualRobot.motion_phase.CRUISE:
		self.curr_position = self.curr_position + self.max_vel * delta_t
		
		var distance = self.path_length - self.curr_position
		if distance <= self.decel_distance:
			self.curr_phase = VirtualRobot.motion_phase.DECEL

	#DECELERATION PHASE
	elif self.curr_phase == VirtualRobot.motion_phase.DECEL:
		self.curr_position = self.curr_position + (self.curr_vel * delta_t) - (self.decel * pow(delta_t, 2) * 0.5)
		var vel = self.curr_vel - self.decel * delta_t
		if vel >= 0:
			self.curr_vel = vel
		#uniformly decelerated motion
		
		if self.curr_position >= self.path_length:
			self.curr_vel = 0
			self.curr_position = self.path_length
			self.curr_phase = VirtualRobot.motion_phase.TARGET

	#TARGET PHASE
	elif self.curr_phase == VirtualRobot.motion_phase.TARGET:
		self.curr_vel = 0
		self.curr_position = self.path_length

func get_speed() -> float:
	return self.curr_vel

func get_position() -> float:
	return self.curr_position
