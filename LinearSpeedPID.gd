class_name LinearSpeedPID

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
func evaluate(vel_error: float, delta_t: float) -> float:
	self.integral += vel_error * delta_t
	var derivative = (vel_error - self.prev_error) / delta_t if delta_t > 0 else 0.0
	self.prev_error = vel_error

	var motor_command  = self.Kp * vel_error + self.Ki * self.integral + self.Kd * derivative
	return motor_command 
