extends Node
class_name LinearPID

# PID gains
var kp: float
var ki: float
var kd: float

# Internal state
var integrator: float = 0.0
var prev_error: float = 0.0
var saturation: float = INF  # Max allowed velocity output

func _init(_kp: float, _ki: float, _kd: float, _sat: float = INF) -> void:
	kp = _kp
	ki = _ki
	kd = _kd
	saturation = _sat

func evaluate(delta_t: float, position_error: float) -> float:
	if delta_t <= 0.0:
		return 0.0

	# Accumulo integrale
	integrator += position_error * delta_t

	# Derivata
	var derivative = (position_error - prev_error) / delta_t
	prev_error = position_error

	# Output: una velocità target
	var output = kp * position_error + ki * integrator + kd * derivative

	# Saturazione della velocità
	output = clamp(output, -saturation, saturation)
	return output

func reset() -> void:
	integrator = 0.0
	prev_error = 0.0
