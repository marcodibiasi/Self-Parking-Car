extends Node
class_name AngularPID

# PID gains for angular control
var proportional_gain: float
var integral_gain: float
var derivative_gain: float

# Internal state
var integrator: float = 0.0
var previous_error: float = 0.0
var saturation_limit: float = INF

func _init(_proportional_gain: float, _integral_gain: float, _derivative_gain: float, _saturation_limit: float = INF) -> void:
	proportional_gain = _proportional_gain
	integral_gain = _integral_gain
	derivative_gain = _derivative_gain
	saturation_limit = _saturation_limit

func evaluate(delta_time: float, angular_error: float) -> float:
	if delta_time <= 0.0:
		return 0.0

	# Integral term: Accumulates error over time. Useful for eliminating steady-state errors.
	integrator += angular_error * delta_time

	# Derivative term: Estimates the future error by looking at the rate of change of the current error.
	var derivative = (angular_error - previous_error) / delta_time
	previous_error = angular_error

	# PID output: Sum of proportional, integral, and derivative terms.
	var output = proportional_gain * angular_error + integral_gain * integrator + derivative_gain * derivative

	# Saturation: Limits the output command to a specified maximum and minimum value.
	output = clamp(output, -saturation_limit, saturation_limit)
	
	return output

func reset() -> void:
	integrator = 0.0
	previous_error = 0.0
