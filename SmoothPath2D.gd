class_name PathFollower
extends Node 

var path_points: Array = [] 
var current_segment_index = 0 
var virtual_robot: StraightLine2DMotion

var max_velocity: float 
var acceleration: float 
var deceleration: float 
var final_rotation: float

var finished: bool = false

var segment_start_point: Vector3 
var segment_end_point: Vector3 

func _init(_max_velocity: float, _acceleration: float, _deceleration: float, _final_rotation: float) -> void: 
	max_velocity = _max_velocity
	acceleration = _acceleration
	deceleration = _deceleration
	final_rotation = _final_rotation
	virtual_robot = StraightLine2DMotion.new(max_velocity, acceleration, deceleration, final_rotation)

func start_path(points_array: Array) -> void: 
	if points_array.size() < 2:
		push_error("Path too short!")
		return
	
	path_points = points_array
	current_segment_index = 0
	
	segment_start_point = path_points[0]
	segment_end_point = path_points[1]
	
	virtual_robot.start_motion(segment_start_point, segment_end_point)

func evaluate(delta_time: float) -> Vector3: 
	if finished:
		return path_points[-1] 
		
	# aggiorna la posizione virtuale lungo il segmento
	var position = virtual_robot.evaluate(delta_time)
	
	# calcola distanza rimanente nel segmento
	var distance_to_end = position.distance_to(segment_end_point) 
	
	# Se vicino alla fine segmento, passa al prossimo
	if distance_to_end < 0.2 and not finished:
		current_segment_index += 1
		print(current_segment_index)
		if current_segment_index >= path_points.size() - 1:
			finished = true
			virtual_robot.virtual_robot_instance.current_phase = virtual_robot.virtual_robot_instance.motion_phase.TARGET
			return segment_end_point
		
		segment_start_point = path_points[current_segment_index]
		segment_end_point = path_points[current_segment_index + 1]
		virtual_robot.start_motion(segment_start_point, segment_end_point)
	
	return position
