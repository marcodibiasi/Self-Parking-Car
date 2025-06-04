class_name DebugDrawer extends MeshInstance3D

var target = Vector3()
	
func set_target(target: Vector3) -> void:
	self.target = target

func draw_target() -> void:
	mesh = SphereMesh.new()
	mesh.radius = 0.3
	mesh.height = 0.3
	global_transform.origin = target
