extends Node
class_name AngularPID

# PID gains for angular control
var kp: float
var ki: float
var kd: float

# Internal state
var integrator: float = 0.0
var prev_error: float = 0.0
var saturation: float = INF  # Max steering command or equivalent

func _init(_kp: float, _ki: float, _kd: float, _sat: float = INF) -> void:
	kp = _kp
	ki = _ki
	kd = _kd
	saturation = _sat

func evaluate(delta_t: float, angular_error: float) -> float:
	if delta_t <= 0.0:
		return 0.0

	# Integral term
	integrator += angular_error * delta_t

	# Derivative term
	var derivative = (angular_error - prev_error) / delta_t
	prev_error = angular_error

	# PID output
	var output = kp * angular_error + ki * integrator + kd * derivative

	# Saturation (limit steering command, for example)
	output = clamp(output, -saturation, saturation)
	
	return output

func reset() -> void:
	integrator = 0.0
	prev_error = 0.0
