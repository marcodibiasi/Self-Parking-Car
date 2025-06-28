class_name StraightLine2DMotion

var max_vel: float
var acc: float
var decel: float
var start_x: float
var start_z: float
var end_x: float
var end_z: float
var heading: float
var target_distance: float
var final_rotation: float
var virtual_robot: VirtualRobot

func _init(max_vel: float, acc: float, decel: float, f_rotation: float) -> void:
	self.max_vel = max_vel
	self.acc = acc
	self.decel = decel
	self.final_rotation = f_rotation

func start_motion(start: Vector3, end: Vector3) -> void:
	self.start_x = start.x
	self.start_z = start.z
	self.end_x = end.x
	self.end_z = end.z
	
	var dx = self.end_x - self.start_x
	var dz = self.end_z - self.start_z
	
	self.heading = atan2(dz, dx)
	self.target_distance = sqrt(pow(dx, 2) + pow(dz, 2))
	self.virtual_robot = VirtualRobot.new(self.target_distance, self.max_vel, self.acc, self.decel, self.final_rotation)

func evaluate(delta_t: float) -> Vector3:
	self.virtual_robot.evaluate(delta_t)
	var curr_x = self.start_x + self.virtual_robot.get_position() * cos(self.heading)
	var curr_z = self.start_z + self.virtual_robot.get_position() * sin(self.heading)
	return Vector3(curr_x, 0, curr_z)
