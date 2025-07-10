extends Node3D
class_name SetupScene

@export var car_node: Node3D 
@export var park_node: Node3D 

@export var field_size = 30
@export var lower_bound = -15
@export var upper_bound = 15

var path: Array

func _ready() -> void:
	car_node.position = get_non_overlapping_position(field_size + 10, field_size + 10, 10); 
	#field_size + 10 so it doesn't overlap with anything
	park_node.position = get_non_overlapping_position(car_node.position.x, car_node.position.z, 10); 
	
	car_node.rotation.y = deg_to_rad(randf_range(0, 360)) 
	
	var dir = (car_node.position - park_node.position).normalized() 
	var dir_angle = atan2(dir.x, dir.z)
	park_node.rotation.y = randf_range(dir_angle - PI / 4, dir_angle + PI / 4) 
	
	var first_step_target = _calculate_first_step_target(park_node.position, park_node.rotation.y) 
	path = get_bezier_trajectory(car_node.position, first_step_target, car_node.rotation.y, park_node.rotation.y, 0.6, 2) 
	
	#debug_draw_points(path, 0.2)
	

func get_non_overlapping_position(occupied_x: float, occupied_z: float, margin: float) -> Vector3: 
	#occupied_x:      Ocuppied x, the new position won't overlap with it
	#occupied_z:      Ocuppied y, the new position won't overlap with it
	#margin: distance from the occupied position
	var new_x = randf_range(lower_bound, upper_bound)
	new_x = _get_correct_spacing(occupied_x, new_x, margin)
	
	var new_z = randf_range(lower_bound, upper_bound)
	new_z = _get_correct_spacing(occupied_z, new_z, margin)
	
	return Vector3(new_x, 0, new_z)
	

func _get_correct_spacing(n_value: float, new_n_value: float, margin: float) -> float: 
	while new_n_value >= n_value - margin and new_n_value <= n_value + margin:
		new_n_value = randf_range(lower_bound, upper_bound)
	
	return new_n_value
	
func get_bezier_trajectory(point1: Vector3, point2: Vector3, angle1: float, angle2: float, strength: float, resolution: int) -> Array: 
	var trajectory = Array()
	
	var distance = point1.distance_to(point2)
	var curve_strength = distance * strength 
	
	var dir = (point2 - point1).normalized()
	var dir_angle = atan2(dir.x, dir.z) # angolo verso point2
	
	# Controllo: se l'angolo punta nella direzione opposta, lo invertiamo
	if abs(angle_diff(angle1, dir_angle)) > PI / 2:
		angle1 += PI
	
	var control1 = point1 + Vector3(sin(angle1), 0, cos(angle1)) * curve_strength 
	var control2 = point2 + Vector3(sin(angle2), 0, cos(angle2)) * curve_strength 
	

	# Genera punti lungo la curva Bézier cubica
	for i in range(resolution + 1): 
		var time_step = i / float(resolution) 
		var pos = bezier_point(point1, control1, control2, point2, time_step)
		trajectory.append(pos)
		
	trajectory.append(park_node.position) 
	return trajectory
	
func bezier_point(point1: Vector3, control1: Vector3, control2: Vector3, point2: Vector3, t_value: float) -> Vector3: 
	var u = 1.0 - t_value 
	return (
		u*u*u * point1 +
		3*u*u*t_value * control1 + 
		3*u*t_value*t_value * control2 + 
		t_value*t_value*t_value * point2 
	)

func angle_diff(angle_a: float, angle_b: float) -> float: 
	var diff = fmod((angle_a - angle_b) + PI, TAU)
	if diff < 0:
		diff += TAU
	return diff - PI

func _calculate_first_step_target(position: Vector3, rotation_radians: float) -> Vector3: 
	var target_x = position.x + sin(rotation_radians) * 7.0
	var target_z = position.z + cos(rotation_radians) * 7.0
	return Vector3(target_x, 0, target_z)

func debug_draw_points(points: Array, size := 0.1, color := Color.RED):
	var i = 0
	for point in points:
		var sphere = MeshInstance3D.new()
		sphere.mesh = SphereMesh.new()
		sphere.mesh.radius = size
		sphere.material_override = StandardMaterial3D.new()
		sphere.material_override.albedo_color = color
		sphere.global_position = point
		add_child(sphere)
