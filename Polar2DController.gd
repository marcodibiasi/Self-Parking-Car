extends Node

class_name Polar2DController

var linear: LinearPID
var angular: AngularPID

func _init(KP_linear: float, v_max: float, KP_heading: float, w_max: float) -> void:
	linear = LinearPID.new(KP_linear, 0, 0, v_max)
	angular = AngularPID.new(KP_heading, 0, 0, w_max)

func evaluate(delta_t: float, xt: float, zt: float, current_pose: Vector3) -> Vector2:
	var x = current_pose.x
	var z = current_pose.z
	var theta = current_pose.y  # attenzione: usiamo y come heading (rotazione sull’asse verticale)

	var dx = xt - x
	var dz = zt - z

	var target_heading = atan2(dz, dx)
	var distance = sqrt(dx * dx + dz * dz)
	var heading_error = normalize_angle(target_heading - theta)

	if heading_error > PI / 2 or heading_error < -PI / 2:
		distance = -distance
		heading_error = normalize_angle(heading_error + PI)

	var v_target = linear.evaluate(delta_t, distance)
	var w_target = angular.evaluate(delta_t, heading_error)

	return Vector2(v_target, w_target)

func normalize_angle(angle: float) -> float:
	while angle > PI:
		angle -= TAU
	while angle < -PI:
		angle += TAU
	return angle
