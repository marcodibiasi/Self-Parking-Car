class_name AngularPID

var Kp := 2.0
var Ki := 0.0
var Kd := 0.1

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
func evaluate(heading_error: float, delta_t: float) -> float:
	self.integral += heading_error * delta_t
	var derivative = (heading_error - self.prev_error) / delta_t if delta_t > 0 else 0.0
	self.prev_error = heading_error

	var angular_command = self.Kp * heading_error + self.Ki * self.integral + self.Kd * derivative
	return angular_command
