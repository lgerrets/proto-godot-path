extends Node2D

var a_star : AStar2D
const GRID_RES = 32

var grid_segments = []

# Called when the node enters the scene tree for the first time.
func _ready():
	a_star = AStar2D.new()
	var prev_line_idxes = null
	var grid_y = $Layout/Start.position.y
	while grid_y < $Layout/End.position.y:
		var grid_x = $Layout/Start.position.x
		var curr_line_idxes = []
		var grid_x_idx = 0
		while grid_x < $Layout/End.position.x:
			var point_idx = a_star.get_available_point_id()
			var weight_scale = 1 # must be >= 1 ; we could use this param to simulate speed buff/debuff AoE
			var pos = Vector2(grid_x, grid_y)
			if is_close_to_walls(pos, 1):
				point_idx = null
			else:
				a_star.add_point(point_idx, pos, weight_scale)
				var other_point_idx
				if len(curr_line_idxes) > 0:
					other_point_idx = curr_line_idxes[-1]
					if other_point_idx != null:
						a_star.connect_points(point_idx, other_point_idx)
						grid_segments.append([point_idx, other_point_idx])
				if prev_line_idxes != null:
					other_point_idx = prev_line_idxes[grid_x_idx]
					if other_point_idx != null:
						a_star.connect_points(point_idx, other_point_idx)
						grid_segments.append([point_idx, other_point_idx])
	#				if len(curr_line_idxes) > 0:
	#					other_point_idx = prev_line_idxes[grid_x_idx-1]
	#					if not is_line_in_walls(pos, a_star.get_point_position(other_point_idx)):
	#						a_star.connect_points(point_idx, other_point_idx)
	#						grid_segments.append([point_idx, other_point_idx])
			curr_line_idxes.append(point_idx)
			grid_x_idx += 1
			grid_x += GRID_RES
		prev_line_idxes = curr_line_idxes
		grid_y += GRID_RES

func is_point_in_walls(pos : Vector2):
	var space = get_world_2d().get_direct_space_state()
	var results = space.intersect_point(pos, 32, [], 2147483647)
	
	for result in results:
		var collider_id = result["collider_id"]
		if collider_id in $Layout/Walls.get_children():
			return true
	return false

func is_line_in_walls(from : Vector2, to : Vector2):
	var space = get_world_2d().get_direct_space_state()
	var segment = Physics2DShapeQueryParameters.new()
	var segment_shape = SegmentShape2D.new()
	segment_shape.a = from
	segment_shape.b = to
	segment.set_shape(segment_shape)
	var results = space.intersect_shape(segment, 32)
	
	for result in results:
		var collider = result["collider"]
		if collider in $Layout/Walls.get_children():
			return true
	return false

func is_close_to_walls(pos : Vector2, radius : float):
	var space = get_world_2d().get_direct_space_state()
	var circle = Physics2DShapeQueryParameters.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = radius
	circle.transform.origin = pos
	circle.set_shape(circle_shape)
	var results = space.intersect_shape(circle, 32)
	
	for result in results:
		var collider = result["collider"]
		if collider in $Layout/Walls.get_children():
			return true
	return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Bg_button_up():
	var mouse_pos = get_global_mouse_position()
	var path = compute_path($PlayableCharacter.position, mouse_pos, false)
	if path == null:
		return
	$PlayableCharacter.set_path(path)
	if Global.DEBUG:
		update()

func compute_path(from : Vector2, to : Vector2, add_noise : bool):
	### build the path : from -> grid_from -> grid_to -> to
	var a_star_to_id = a_star.get_closest_point(to)
	var a_star_to = a_star.get_point_position(a_star_to_id)
	var a_star_from_id = a_star.get_closest_point(from)
	var a_star_from = a_star.get_point_position(a_star_from_id)
	if is_line_in_walls(to, a_star_to) or is_line_in_walls(from, a_star_from):
		return null
	var path = a_star.get_point_path(a_star_from_id, a_star_to_id)
	if a_star_from_id != a_star_to_id:
		assert(len(path) > 0)
	path.insert(0, from)
	path.append(to)
	
	### remove intermediate points by bisections
#	var from_point_idx = 0
#	while from_point_idx < len(path) - 1:
#		var to_point_idx_min = from_point_idx + 2
#		var to_point_idx_max = len(path) - 1
#		while to_point_idx_min <= to_point_idx_max:
#			var to_point_idx_test = int(to_point_idx_min + to_point_idx_max) / 2
#			if is_line_in_walls(a_star.get_point_position(path[from_point_idx], path[to_point_idx_test])):
#				to_point_idx_max = to_point_idx_test - 1 # we can't go further
#				# ... interrupted dev because it's not actually the most accurate algo (but it has good perf)
	var from_point_idx = 0
	while from_point_idx < len(path) - 2:
		var to_point_idx_test = len(path) - 1
		while to_point_idx_test > from_point_idx + 1:
			if is_line_in_walls(path[from_point_idx], path[to_point_idx_test]):
				pass
			else:
				for _dummy in range(to_point_idx_test - from_point_idx - 1):
					path.remove(from_point_idx+1)
				break
			to_point_idx_test -= 1
		from_point_idx += 1
	
	## add some noise
	assert(not add_noise) # not supported yet, TODO for enemies
	
	return path

func _draw():
	if Global.DEBUG:
		draw_polyline($PlayableCharacter/Path2D.curve.get_baked_points(), Color.aquamarine, 5, true)
		for grid_segment in grid_segments:
			var point_idx = grid_segment[0]
			var other_point_idx = grid_segment[1]
			draw_line(a_star.get_point_position(point_idx), a_star.get_point_position(other_point_idx), Color.red, 1, true)

