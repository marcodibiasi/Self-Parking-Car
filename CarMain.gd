# Main simulation script to control the Ackermann vehicle
extends Node3D

@export var park: Node3D
@export var firststep_distance = 12.0

# Include the controller and vehicle logic
var vehicle: AckermannVehicle
var LinearSpeedPid: LinearSpeedPID
var AngularPid: AngularPID
var LinearPid: LinearPID
var virtualRobot: StraightLine2DMotion
var pathFollower: PathFollower
@onready var setupScene: SetupScene = $"../Scene Manager"

# Target linear speed (m/s)
var firststep_target = Vector3()
var cartesianCoordinates = Array()
var aligning_to_final_angle := false


# Variabili per debug
var v = 0.0
var w = 0.0
var steeringAngle = 0.0

func _ready() -> void:
	# Instantiate vehicle and controller
	vehicle = AckermannVehicle.new(50.0, 0.97, 0.2, 1.0)
	#LinearSpeedPid = LinearSpeedPID.new(2.0, 0.0, 0.55, 3.0)
	#AngularPid = AngularPID.new(0.5, 0.02, 0.06)
	#LinearPid = LinearPID.new(1.0, 0.0, 0.05)
	
	LinearSpeedPid = LinearSpeedPID.new(1.5, 0.0, 0.0, 2.5)
	AngularPid = AngularPID.new(0.5, 0.0, 0.15)
	LinearPid = LinearPID.new(0.6, 0.0, 0.0)
	
	#virtualRobot = StraightLine2DMotion.new(2.0, 0.5, 0.3, park.rotation.y)
	pathFollower = PathFollower.new(1.5, 0.5, 0.5, park.rotation.y)
	
	pathFollower.start_path(setupScene.path)

	# Calcola il target iniziale
	firststep_target = _calculate_firststep_target(park.position, park.rotation.y)
	
	# Avvia il movimento del robot virtuale
	#virtualRobot.start_motion(self.position, firststep_target)
	
	# disegna il target
	var debug_drawer = get_node("../Target") 
	debug_drawer.set_target(firststep_target)
	#debug_drawer.draw_target()


func _physics_process(delta: float) -> void:
	# Valuta la posizione desiderata del robot virtuale
	#var desired_pos = virtualRobot.evaluate(delta)
	var desired_pos = pathFollower.evaluate(delta)
	
	cartesianCoordinates = _cartesian_2polar(self.position, desired_pos)
	var is_reverse = cartesianCoordinates[0] < 0.0
	
	var distance_to_final_target = self.position.distance_to(firststep_target)
	
	
	#if virtualRobot.virtual_robot.curr_phase == virtualRobot.virtual_robot.motion_phase.TARGET:
		#vehicle.evaluate(delta, 0.0, 0.0)
		#return
		
	if (pathFollower.finished and 
	pathFollower.virtual_robot.virtual_robot.curr_phase ==
	virtualRobot.virtual_robot.motion_phase.TARGET):
		vehicle.evaluate(delta, 0.0, 0.0)
		return
		
	 #--- Controllo della velocità lineare (avanzamento) ---
	var target_speed = LinearPid.evaluate(delta, cartesianCoordinates[0])
	var currentSpeed = vehicle.get_speed().x
	var speed_error = target_speed - currentSpeed
	var torque = LinearSpeedPid.evaluate(delta, speed_error)
	
	# Calcola l'errore di orientamento rispetto al desired_heading
	var heading_error = wrapf(cartesianCoordinates[1] - self.rotation.y, -PI, PI)
	
	# per la retromarcia
	if is_reverse:
		heading_error = -heading_error
		
	var omegaCorrection = AngularPid.evaluate(delta, heading_error)
	
	#Calcola l'angolo di sterzata per il veicolo Ackermann
	var vx = max(abs(currentSpeed), 0.01)  # assicura segno positivo
	#if abs(currentSpeed) < 0.5:
		#steeringAngle = 0.0
	#else:
		#steeringAngle = atan(vehicle.lateral_wheelbase * omegaCorrection / vx)
		
	# calcolo e saturazione
	steeringAngle = atan(vehicle.lateral_wheelbase * omegaCorrection / vx)
	if steeringAngle > deg_to_rad(35):
		steeringAngle = deg_to_rad(35)
	if steeringAngle < -deg_to_rad(35):
		steeringAngle = -deg_to_rad(35)
		
	# Valuta la dinamica del veicolo
	vehicle.evaluate(delta, torque, steeringAngle)
	
	# Aggiorna posizione simulata
	var speed = vehicle.get_speed()
	var v_current = speed.x
	var w_current = speed.y
	_update(delta, v_current, w_current)
	
	# Variabili per debug
	v = v_current
	w = w_current

func _update(delta: float, v: float, omega:float) -> void:
	self.position.x += v * sin(self.rotation.y) * delta
	self.position.z += v * cos(self.rotation.y) * delta
	self.rotation.y += omega * delta

func _calculate_desired_heading(target: Vector3, pos: Vector3) -> float:
	var delta_x = target.x - pos.x
	var delta_z = target.z - pos.z
	return atan2(delta_x, delta_z)

func _calculate_firststep_target(pos: Vector3, r_rad: float) -> Vector3:
	var target_x = pos.x + sin(r_rad) * firststep_distance
	var target_z = pos.z + cos(r_rad) * firststep_distance
	return Vector3(target_x, 0, target_z)
	
func _cartesian_2polar(pos: Vector3, target: Vector3) -> Array:
	var delta_x = target.x - pos.x
	var delta_z = target.z - pos.z
	var distance = sqrt(delta_x * delta_x + delta_z * delta_z)

	var direction = atan2(delta_x, delta_z)
	var theta = self.rotation.y
	var heading_error = wrapf(direction - theta, -PI, PI)

	# Se il target è dietro, attiva la retromarcia
	if abs(heading_error) > PI / 2:
		distance *= -1.0
		direction = wrapf(direction + PI, -PI, PI)

	return [distance, direction]
