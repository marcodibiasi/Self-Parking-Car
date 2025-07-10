extends Node
class_name LinearSpeedPID

# PID gains
var proportional_gain: float
var integral_gain: float
var derivative_gain: float

# Internal state
var integrator: float = 0.0
var previous_error: float = 0.0
var saturation_limit: float = INF # default: no limit

func _init(_proportional_gain: float, _integral_gain: float, _derivative_gain: float, _saturation_limit: float = INF) -> void:
	proportional_gain = _proportional_gain
	integral_gain = _integral_gain
	derivative_gain = _derivative_gain
	saturation_limit = _saturation_limit

func evaluate(delta_time: float, error: float) -> float:
	if delta_time <= 0.0:
		return 0.0

	# Integral term
	integrator += error * delta_time

	# Derivative term
	var derivative = (error - previous_error) / delta_time
	previous_error = error

	# PID output
	var output = proportional_gain * error + integral_gain * integrator + derivative_gain * derivative

	# Saturation
	output = clamp(output, -saturation_limit, saturation_limit)
	return output

func reset() -> void:
	integrator = 0.0
	previous_error = 0.0
