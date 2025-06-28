extends Node3D

@export var car: Node3D
@export var park: Node3D

@export var field_size = 25
@export var lower_bound = -12
@export var upper_bound = 12

func _ready() -> void:
	car.position = get_non_overlapping_position(field_size + 10, field_size + 10, 4);
	#field_size + 10 so it doesn't overlap with anything
	
	park.position = get_non_overlapping_position(car.position.x, car.position.z, 8);
	
	car.rotate_y(deg_to_rad(randf_range(0, 360)))
	park.rotate_y(deg_to_rad(randf_range(0, 360)))
	

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
