extends Node

class_name AckermannVehicle

# Parameters
var mass: float
var lin_friction: float
var r_traction: float
var lateral_wheelbase: float

# State
var v: float = 0.0
var w: float = 0.0
var x: float = 0.0
var y: float = 0.0
var theta: float = 0.0

func _init(_mass: float, _lin_friction: float, _r_traction: float, _lateral_wheelbase: float) -> void:
	"""
	Initializes the Ackermann steering model with mass, friction, and wheel geometry.
	"""
	mass = _mass
	lin_friction = _lin_friction
	r_traction = _r_traction
	lateral_wheelbase = _lateral_wheelbase

func evaluate(delta_t: float, torque: float, steering_angle: float) -> void:
	var force = torque / r_traction
	var new_v = v * (1.0 - lin_friction * delta_t / mass) + delta_t * force / mass

	var new_w: float = 0.0
	if steering_angle != 0.0:
		var curvature_radius = lateral_wheelbase / tan(steering_angle)
		new_w = new_v / curvature_radius

	# Update position using previous velocity (v, w)
	x += v * delta_t * cos(theta)
	y += v * delta_t * sin(theta)
	theta += delta_t * w

	# Update velocity and angular velocity
	v = new_v
	w = new_w

func get_pose() -> Vector3:
	"""
	Returns current pose: (x, y, theta)
	"""
	return Vector3(x, y, theta)

func get_speed() -> Vector2:
	"""
	Returns current speeds: (v, w)
	"""
	return Vector2(v, w)
