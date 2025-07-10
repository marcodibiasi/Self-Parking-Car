extends Node

class_name AckermannVehicle

# Parameters
var mass: float
var linear_friction: float
var traction_radius: float
var lateral_wheelbase: float

# State
var linear_velocity: float = 0.0
var angular_velocity: float = 0.0
var position_x: float = 0.0
var position_y: float = 0.0
var orientation_theta: float = 0.0

func _init(_mass: float, _linear_friction: float, _traction_radius: float, _lateral_wheelbase: float) -> void:
	"""
	Initializes the Ackermann steering model with mass, friction, and wheel geometry.
	"""
	mass = _mass
	linear_friction = _linear_friction
	traction_radius = _traction_radius
	lateral_wheelbase = _lateral_wheelbase

func evaluate(delta_time: float, torque: float, steering_angle: float) -> void:
	var force = torque / traction_radius
	var new_linear_velocity = linear_velocity * (1.0 - linear_friction * delta_time / mass) + delta_time * force / mass

	var new_angular_velocity: float = 0.0
	if steering_angle != 0.0:
		var curvature_radius = lateral_wheelbase / tan(steering_angle)
		new_angular_velocity = new_linear_velocity / curvature_radius

	# Update position using previous velocity (linear_velocity, angular_velocity)
	position_x += linear_velocity * delta_time * cos(orientation_theta)
	position_y += linear_velocity * delta_time * sin(orientation_theta)
	orientation_theta += delta_time * angular_velocity

	# Update velocity and angular velocity
	linear_velocity = new_linear_velocity
	angular_velocity = new_angular_velocity

func get_pose() -> Vector3:
	"""
	Returns current pose: (x, y, theta)
	"""
	return Vector3(position_x, position_y, orientation_theta)

func get_speed() -> Vector2:
	"""
	Returns current speeds: (v, w)
	"""
	return Vector2(linear_velocity, angular_velocity)
