class_name LinearPID

var Kp := 1.0
var Ki := 0.0
var Kd := 0.0

var integral := 0.0
var prev_error := 0.0

func _init(kp: float, ki: float, kd: float) -> void:
	self.Kp = kp
	self.Ki = ki
	self.Kd = kd

func reset():
	self.integral = 0.0
	self.prev_error = 0.0

#rho is the distance from the target given from the polar coordinates
func evaluate(rho: float, delta_t: float) -> float:
	var error = rho
	self.integral += error * delta_t
	var derivative = (error - self.prev_error) / delta_t if delta_t > 0 else 0.0
	self.prev_error = error

	var v_command = self.Kp * error + self.Ki * self.integral + self.Kd * derivative
	return v_command
