class_name PathFollower

var path: Array = []
var current_segment = 0
var virtual_robot: StraightLine2DMotion

var max_vel: float
var acc: float
var decel: float
var final_rotation: float

var finished: bool = false

var segment_start: Vector3
var segment_end: Vector3

func _init(max_vel: float, acc: float, decel: float, final_rotation: float) -> void:
	self.max_vel = max_vel
	self.acc = acc
	self.decel = decel
	self.final_rotation = final_rotation
	virtual_robot = StraightLine2DMotion.new(max_vel, acc, decel, final_rotation)

func start_path(path_points: Array) -> void:
	if path_points.size() < 2:
		push_error("Path too short!")
		return
	
	path = path_points
	current_segment = 0
	
	segment_start = path[0]
	segment_end = path[1]
	
	virtual_robot.start_motion(segment_start, segment_end)

func evaluate(delta_t: float) -> Vector3:
	if finished:
		return path[-1]
		
	# aggiorna la posizione virtuale lungo il segmento
	virtual_robot.evaluate(delta_t)
	var pos = virtual_robot.evaluate(delta_t)
	
	# calcola distanza rimanente nel segmento
	var dist_to_end = pos.distance_to(segment_end)
	
	# Se vicino alla fine segmento, passa al prossimo
	if dist_to_end < 0.01:
		current_segment += 1
		print(current_segment)
		if current_segment >= path.size() - 1:
			# fine percorso, torna fine segmento
			finished = true
			virtual_robot.virtual_robot.curr_phase = virtual_robot.virtual_robot.motion_phase.TARGET
			return segment_end
		
		# aggiorna segmento e ricomincia profilo moto
		segment_start = path[current_segment]
		segment_end = path[current_segment + 1]
		virtual_robot.start_motion(segment_start, segment_end)
		pos = virtual_robot.evaluate(delta_t)
	
	return pos
