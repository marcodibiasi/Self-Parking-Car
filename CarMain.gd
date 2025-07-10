# Main simulation script to control the Ackermann vehicle
extends Node3D

@export var park: Node3D
@export var first_step_distance = 7.0 

# Include the controller and vehicle logic
var vehicle: AckermannVehicle
var linear_speed_pid: LinearSpeedPID 
var angular_pid: AngularPID 
var linear_pid: LinearPID 
var virtual_robot: StraightLine2DMotion 
var path_follower: PathFollower 
@onready var setup_scene: SetupScene = $"../Scene Manager" 

# Target linear speed (m/s)
var first_step_target = Vector3() 
var cartesian_coordinates = Array() 
var aligning_to_final_angle := false 


# Variabili per debug
var current_linear_velocity = 0.0 
var current_angular_velocity = 0.0 
var steering_angle = 0.0 

func _ready() -> void:
	# Instantiate vehicle and controller
	vehicle = AckermannVehicle.new(50.0, 0.97, 0.2, 1.0)
	
	linear_speed_pid = LinearSpeedPID.new(1.5, 0.0, 0.0, 2.5)
	angular_pid = AngularPID.new(0.5, 0.0, 0.15)
	linear_pid = LinearPID.new(0.6, 0.0, 0.0)
	
	path_follower = PathFollower.new(1.5, 0.5, 0.3, park.rotation.y)
	
	path_follower.start_path(setup_scene.path)


func _physics_process(delta: float) -> void:
	# Valuta la posizione desiderata del robot virtuale
	var desired_pos = path_follower.evaluate(delta)
	
	cartesian_coordinates = _cartesian_to_polar(self.position, desired_pos) 
	var is_reverse = cartesian_coordinates[0] < 0.0
	
	if path_follower.finished:
		var speed = vehicle.get_speed()
		var brake = -speed.x * 12.0
		var current_linear_speed = speed.x 
		var current_angular_speed = speed.y 
		
		if abs(current_linear_speed) < 0.01 and abs(current_angular_speed) < 0.01:
			print("Veicolo completamente fermo.")
			return
		
		vehicle.evaluate(delta, brake, 0.0)
		_update(delta, current_linear_speed, current_angular_speed) 
		return
	
	# Controllo della velocità lineare (avanzamento)
	var target_speed = linear_pid.evaluate(delta, cartesian_coordinates[0]) 
	var current_speed = vehicle.get_speed().x 
	var speed_error = target_speed - current_speed
	var torque = linear_speed_pid.evaluate(delta, speed_error) 
	
	# Calcola l'errore di orientamento rispetto al desired_heading
	var heading_error = wrapf(cartesian_coordinates[1] - self.rotation.y, -PI, PI)
	
	# per la retromarcia
	if is_reverse:
		heading_error = -heading_error
	
	var omega_correction = angular_pid.evaluate(delta, heading_error) 
	
	#Calcola l'angolo di sterzata per il veicolo Ackermann
	var vx = max(abs(current_speed), 0.01) # Use current_speed
	
	# calcolo e saturazione
	steering_angle = atan(vehicle.lateral_wheelbase * omega_correction / vx)
	if steering_angle > deg_to_rad(35):
		steering_angle = deg_to_rad(35)
	if steering_angle < -deg_to_rad(35):
		steering_angle = -deg_to_rad(35)
		
	# Aggiorna posizione simulata
	var speed = vehicle.get_speed()
	var current_linear_speed_for_update = speed.x 
	var current_angular_speed_for_update = speed.y 
		
	# Valuta la dinamica del veicolo
	vehicle.evaluate(delta, torque, steering_angle)
	_update(delta, current_linear_speed_for_update, current_angular_speed_for_update) 

func _update(delta_time: float, linear_vel: float, angular_vel:float) -> void: 
	self.position.x += linear_vel * sin(self.rotation.y) * delta_time
	self.position.z += linear_vel * cos(self.rotation.y) * delta_time
	self.rotation.y += angular_vel * delta_time

func _calculate_desired_heading(target_pos: Vector3, current_pos: Vector3) -> float: 
	var delta_x = target_pos.x - current_pos.x
	var delta_z = target_pos.z - current_pos.z
	return atan2(delta_x, delta_z)

func _calculate_first_step_target(current_pos: Vector3, rotation_rad: float) -> Vector3: 
	var target_x = current_pos.x + sin(rotation_rad) * first_step_distance
	var target_z = current_pos.z + cos(rotation_rad) * first_step_distance
	return Vector3(target_x, 0, target_z)
	
func _cartesian_to_polar(current_pos: Vector3, target_pos: Vector3) -> Array: 
	var delta_x = target_pos.x - current_pos.x
	var delta_z = target_pos.z - current_pos.z
	var distance = sqrt(delta_x * delta_x + delta_z * delta_z)

	var direction = atan2(delta_x, delta_z)
	var theta = self.rotation.y
	var heading_error = wrapf(direction - theta, -PI, PI)

	# Se il target è dietro, attiva la retromarcia
	if abs(heading_error) > PI / 2:
		distance *= -1.0
		direction = wrapf(direction + PI, -PI, PI)

	return [distance, direction]
