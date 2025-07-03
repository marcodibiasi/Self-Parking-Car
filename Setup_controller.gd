extends Node3D
class_name SetupScene

@export var car: Node3D
@export var park: Node3D

@export var field_size = 30
@export var lower_bound = -15
@export var upper_bound = 15

var path: Array

func _ready() -> void:
	car.position = get_non_overlapping_position(field_size + 10, field_size + 10, 10);
	#field_size + 10 so it doesn't overlap with anything
	park.position = get_non_overlapping_position(car.position.x, car.position.z, 10);
	
	car.rotation.y = deg_to_rad(randf_range(0, 360))
	
	var dir = (car.position - park.position).normalized()
	var dir_angle = atan2(dir.x, dir.z)
	park.rotation.y = randf_range(dir_angle - PI / 4, dir_angle + PI / 4)
	
	var firststep_target = _calculate_firststep_target(park.position, park.rotation.y)
	path = get_bezier_trajectory(car.position, firststep_target, car.rotation.y, park.rotation.y, 0.8, 2)
	
	#debug_draw_points(path, 0.2)
	

func get_non_overlapping_position(x: float, z: float, margin: float) -> Vector3: 
	#x:      Ocuppied x, the new position won't overlap with it
	#y:      Ocuppied y, the new position won't overlap with it
	#margin: distance from the occupied position
	var new_x = randf_range(lower_bound, upper_bound)
	new_x = _get_correct_spacing(x, new_x, margin)
	
	var new_z = randf_range(lower_bound, upper_bound)
	new_z = _get_correct_spacing(z, new_z, margin)
	
	return Vector3(new_x, 0, new_z)
	

func _get_correct_spacing(n: float, new_n: float, margin: float) -> float:
	while new_n >= n - margin and new_n <= n + margin:
		new_n = randf_range(lower_bound, upper_bound)
	
	return new_n
	
func get_bezier_trajectory(p1: Vector3, p2: Vector3, angle1: float, angle2: float, strenght: float, res: int) -> Array:
	var trajectory = Array()
	
	var distance = p1.distance_to(p2)
	var curve_strenght = distance * strenght
	
	var dir = (p2 - p1).normalized()
	var dir_angle = atan2(dir.x, dir.z)  # angolo verso p2
	
	# Controllo: se l'angolo punta nella direzione opposta, lo invertiamo
	if abs(angle_diff(angle1, dir_angle)) > PI / 2:
		angle1 += PI
	#if abs(angle_diff(angle2, atan2(-dir.x, -dir.z))) > PI / 2:
		#angle2 += deg_to_rad(90)
	
	
	var control1 = p1 + Vector3(sin(angle1), 0, cos(angle1)) * curve_strenght 
	var control2 = p2 + Vector3(sin(angle2), 0, cos(angle2)) * curve_strenght 
	

	# Genera punti lungo la curva Bézier cubica
	for i in range(res + 1):
		var time_step = i / float(res)
		var pos = bezier_point(p1, control1, control2, p2, time_step)
		trajectory.append(pos)
		
	trajectory.append(park.position)
	return trajectory
	
func bezier_point(p1: Vector3, control1: Vector3, control2: Vector3, p2: Vector3, t: float) -> Vector3:
	var u = 1.0 - t
	return (
		u*u*u * p1 +
		3*u*u*t * control1 +
		3*u*t*t * control2 +
		t*t*t * p2
	)

func angle_diff(a: float, b: float) -> float:
	var diff = fmod((a - b) + PI, TAU)
	if diff < 0:
		diff += TAU
	return diff - PI

func _calculate_firststep_target(pos: Vector3, r_rad: float) -> Vector3:
	var target_x = pos.x + sin(r_rad) * 6.0
	var target_z = pos.z + cos(r_rad) * 6.0
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
		
		#if i > 0:
			#draw_line_immediate(points[i-1], point)
		#i+=1
		#
#func draw_line_immediate(p1: Vector3, p2: Vector3, color: Color = Color.RED):
	#var mesh = ImmediateMesh.new()
	#mesh.surface_begin(Mesh.PRIMITIVE_TRIANGLES)
	#mesh.surface_set_color(color)
	#mesh.surface_add_vertex(p1)
	#mesh.surface_add_vertex(p2)
	#mesh.surface_end()
	#
	#var mesh_instance = MeshInstance3D.new()
	#mesh_instance.mesh = mesh
	#add_child(mesh_instance)
