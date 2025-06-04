extends Node3D

func _ready():
	position = Vector3(
		randf_range(6, 6),
		0,
		randf_range(-6, 6)
	)
	
	rotation.y = deg_to_rad(randf_range(0, 360))
