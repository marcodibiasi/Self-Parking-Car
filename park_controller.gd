extends Node3D

@export var park: Node3D
@export var firststep_distance = 6.0
#distance to parking spot before reverse

var firststep_target = Vector3()
var current_speed := 0.0
var previous_position = Vector3()

var trajectory_generator = StraightLine2DMotion.new(1.0, 0.5, 1.0)
var linear_PID = LinearPID.new(0.2, 0.5, 0.0)
var angular_PID = AngularPID.new(1.2, 0.1, 0.1)
var linear_speed_PID = LinearSpeedPID.new(0.3, 0.0, 0.1)

func _ready() -> void:
	previous_position = self.position
	firststep_target = _calculate_firststep_target(park.position, park.rotation.y)
	
	var rotation_target = park.rotation.y
	
	### DEBUG
	var debug_drawer = get_node("../Target") 
	debug_drawer.set_target(firststep_target)
	debug_drawer.draw_target()
	### DEBUG
	
	trajectory_generator.start_motion(self.position, firststep_target)

#standard function to cycle
func _process(delta: float) -> void:
	#print(position, ", ", firststep_target)
	#print(position.distance_to(firststep_target))
	
	var curr_position = trajectory_generator.evaluate(delta)
	var rho = _cartesian_2polar(curr_position, firststep_target)[0]
	var heading_2target = _cartesian_2polar(curr_position, firststep_target)[1]
	
	var linear_speed = linear_PID.evaluate(rho, delta)
	if linear_speed >= 2.0:
		linear_speed = 2.0
	#linear_speed = clamp(linear_speed, 0, 2.0)
	
	var heading_error = wrapf(heading_2target - self.rotation.y, -PI, PI)
	var angular_speed = angular_PID.evaluate(heading_error, delta)
	
	var displacement = self.position - previous_position
	current_speed = displacement.length() / delta
	var speed_error = linear_speed - current_speed
	var motor_command = linear_speed_PID.evaluate(speed_error, delta)
	
	if linear_speed > 0:
		self.position += Vector3(cos(self.rotation.y), 0, sin(self.rotation.y)) * linear_speed * delta
		self.rotation.y += angular_speed * delta
	
	previous_position = self.position

func _calculate_firststep_target(pos: Vector3, r_rad: float) -> Vector3:
	#First step consist in arriving few meters in front of the parking
	var target_x = pos.x + sin(r_rad)*firststep_distance
	var target_z = pos.z + cos(r_rad)*firststep_distance
	
	return Vector3(target_x, 0, target_z)


func _cartesian_2polar(pos: Vector3, target: Vector3) -> Array:
	var distance = sqrt(pow(target.x - pos.x, 2) + pow(target.z - pos.z, 2))
	var heading = atan2(target.z - pos.z, target.x - pos.x)
	
	return [distance, heading]
