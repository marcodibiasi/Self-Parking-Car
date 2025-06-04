extends Node
class_name LinearSpeedPID

# PID gains
var kp: float
var ki: float
var kd: float

# Internal state
var integrator: float = 0.0
var prev_error: float = 0.0
var saturation: float = INF  # default: no limit

func _init(_kp: float, _ki: float, _kd: float, _sat: float = INF) -> void:
	kp = _kp
	ki = _ki
	kd = _kd
	saturation = _sat

func evaluate(delta_t: float, error: float) -> float:
	if delta_t <= 0.0:
		return 0.0

	# Integral term
	integrator += error * delta_t

	# Derivative term
	var derivative = (error - prev_error) / delta_t
	prev_error = error

	# PID output
	var output = kp * error + ki * integrator + kd * derivative

	# Saturation
	output = clamp(output, -saturation, saturation)
	return output

func reset() -> void:
	integrator = 0.0
	prev_error = 0.0
