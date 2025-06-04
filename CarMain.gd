# Main simulation script to control the Ackermann vehicle
extends Node3D

@export var park: Node3D
@export var firststep_distance = 6.0

# Include the controller and vehicle logic
var vehicle: AckermannVehicle
var LinearSpeedPid: LinearSpeedPID
var AngularPid: AngularPID
var LinearPid: LinearPID
var virtualRobot: StraightLine2DMotion

# Target linear speed (m/s)
var firststep_target = Vector3()
var cartesianCoordinates = Array()

func _ready() -> void:
	# Instantiate vehicle and controller
	vehicle = AckermannVehicle.new(50.0, 0.97, 0.2, 1.0)
	LinearSpeedPid = LinearSpeedPID.new(4.0, 0.5, 0.2, 5.0)     # Guida fluida e reattiva, poco overshoot
	AngularPid = AngularPID.new(1.5, 0.0, 0.05)                 # Sterzo più morbido, meno oscillazione
	LinearPid = LinearPID.new(1.0, 0.0, 0.1)                    # Distanza -> velocità target più reattiva
	virtualRobot = StraightLine2DMotion.new(1.0, 0.5, 0.7)

	
	firststep_target = _calculate_firststep_target(park.position, park.rotation.y)
	
	virtualRobot.start_motion(self.position, firststep_target)
	
func _physics_process(delta: float) -> void:
	var desired_pos = virtualRobot.evaluate(delta)

	# Calcola errore distanza e heading dal target
	var pose = vehicle.get_pose()
	cartesianCoordinates = _cartesian_2polar(self.position, desired_pos)

	# Controllo PID sulla distanza
	var target_speed = LinearPid.evaluate(delta, cartesianCoordinates[0])
	var currentSpeed = vehicle.get_speed().x
	var speed_error = target_speed - currentSpeed
	var torque = LinearSpeedPid.evaluate(delta, speed_error)

	# Controllo PID sull’orientamento
	var desired_heading = cartesianCoordinates[1]
	var heading_error = wrapf(desired_heading - self.rotation.y, -PI, PI)
	var omegaCorrection = AngularPid.evaluate(delta, heading_error)

	var vx = max(currentSpeed, 0.01)
	var steeringAngle = atan(vehicle.lateral_wheelbase * omegaCorrection / vx)
	
	if virtualRobot.virtual_robot.curr_phase == VirtualRobot.motion_phase.TARGET:
		torque = 0.0
		omegaCorrection = 0.0

	# Valuta dinamica veicolo
	vehicle.evaluate(delta, torque, steeringAngle)

	# Aggiorna posizione simulata
	var speed = vehicle.get_speed()
	_update(delta, speed.x, speed.y)



func _update(delta: float, v: float, omega:float) -> void:
	print(self.position, firststep_target)
	self.position.x += v * cos(self.rotation.y) * delta
	self.position.z += v * sin(self.rotation.y) * delta
	self.rotation.y += omega * delta

func _cartesian_2polar(pos: Vector3, target: Vector3) -> Array:
	var distance = sqrt(pow(target.x - pos.x, 2) + pow(target.z - pos.z, 2))
	var heading = atan2(target.z - pos.z, target.x - pos.x)
	
	return [distance, heading]
	
func _calculate_firststep_target(pos: Vector3, r_rad: float) -> Vector3:
	#First step consist in arriving few meters in front of the parking
	var target_x = pos.x + sin(r_rad)*firststep_distance
	var target_z = pos.z + cos(r_rad)*firststep_distance
	
	return Vector3(target_x, 0, target_z)
