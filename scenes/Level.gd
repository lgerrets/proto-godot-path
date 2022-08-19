extends Node2D

onready var example_player = $Player
onready var example_enemy = $Enemies/Enemy

var a_star : AStar2D
const GRID_RES = 32
const CAM_SPEED = 12

var grid_segments = []

# Called when the node enters the scene tree for the first time.
func _ready():
	var max_radius = 0
	var temp_radius
	for character in [example_player, example_enemy]:
		if character != null:
			temp_radius = character.get_node("KinematicBody2D/CollisionShape2D").shape.radius
			max_radius = max(temp_radius, max_radius)
	
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
			var other_point_idx
			var connects_to_principal_component = false
			a_star.add_point(point_idx, pos, weight_scale)			
			# does connect to left ?
			if (len(curr_line_idxes) > 0) and not does_circle_collide_during_motion(pos, Vector2(- GRID_RES, 0), max_radius):
				other_point_idx = curr_line_idxes[-1]
				if other_point_idx != null:
					a_star.connect_points(point_idx, other_point_idx)
					grid_segments.append([point_idx, other_point_idx])
					connects_to_principal_component = true
			if (prev_line_idxes != null):
				# does connect to top ?
				if not does_circle_collide_during_motion(pos, Vector2(0, - GRID_RES), max_radius):
					other_point_idx = prev_line_idxes[grid_x_idx]
					if other_point_idx != null:
						a_star.connect_points(point_idx, other_point_idx)
						grid_segments.append([point_idx, other_point_idx])
						connects_to_principal_component = true
				# does connect to top-left ?
				if (len(curr_line_idxes) > 0) and not does_circle_collide_during_motion(pos, Vector2(- GRID_RES, - GRID_RES), max_radius):
					other_point_idx = prev_line_idxes[grid_x_idx-1]
					if other_point_idx != null:
						a_star.connect_points(point_idx, other_point_idx)
						grid_segments.append([point_idx, other_point_idx])
						connects_to_principal_component = true
				# does connect to top-right ?
				if (len(curr_line_idxes) < len(prev_line_idxes) - 1) and not does_circle_collide_during_motion(pos, Vector2(GRID_RES, - GRID_RES), max_radius):
					other_point_idx = prev_line_idxes[grid_x_idx+1]
					if other_point_idx != null:
						a_star.connect_points(point_idx, other_point_idx)
						grid_segments.append([point_idx, other_point_idx])
						connects_to_principal_component = true
			if connects_to_principal_component or ((grid_x == $Layout/Start.position.x) and (grid_y == $Layout/Start.position.y)):
				curr_line_idxes.append(point_idx)
			else:
				a_star.remove_point(point_idx)
				curr_line_idxes.append(null)
			grid_x_idx += 1
			grid_x += GRID_RES
		prev_line_idxes = curr_line_idxes
		grid_y += GRID_RES
		
	# spawn enemies
	
	spawn_enemies()
	update_enemies_path()
	
	$Camera2D.make_current()
	
	if not Global.DEBUG:
		$DebugUI.hide()
	
func spawn_enemies():
	for enemy in $Enemies.get_children():
		enemy.connect("update_path", self, "update_enemy_path")

func is_point_in_walls(pos : Vector2):
	assert(false) # let's use does_circle_collide_during_motion
	var space = get_world_2d().get_direct_space_state()
	var results = space.intersect_point(pos, 32, [], 2147483647)
	
	for result in results:
		var collider_id = result["collider_id"]
		if collider_id in $Layout/Walls.get_children():
			return true
	return false

func is_line_in_walls(from : Vector2, to : Vector2):
	assert(false) # let's use does_circle_collide_during_motion
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
	assert(false) # let's use does_circle_collide_during_motion
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

func does_circle_collide_during_motion(pos : Vector2, motion : Vector2, radius : float):
	var space = get_world_2d().get_direct_space_state()
	var query = Physics2DShapeQueryParameters.new()
	var circle_shape = CircleShape2D.new()
	circle_shape.radius = radius
	query.transform.origin = pos
	query.set_shape(circle_shape)
	query.set_motion(motion)
	query.set_collision_layer(2)
	var results = space.collide_shape(query, 32)
	
	return len(results) > 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("camera_right"):
		$Camera2D.position.x += CAM_SPEED
	if Input.is_action_pressed("camera_left"):
		$Camera2D.position.x -= CAM_SPEED
	if Input.is_action_pressed("camera_down"):
		$Camera2D.position.y += CAM_SPEED
	if Input.is_action_pressed("camera_up"):
		$Camera2D.position.y -= CAM_SPEED
	if Global.DEBUG:
		var x = $DebugUI/TextEdit.text
		var y = $DebugUI/TextEdit2.text
		x = int(x)
		y = int(y)
		$DebugUI/Sprite.position.x = x
		$DebugUI/Sprite.position.y = y

func update_enemies_path():
	for enemy in $Enemies.get_children():
		update_enemy_path(enemy)

func update_enemy_path(enemy):
	var path = compute_path(enemy.get_node("KinematicBody2D").position, $Player/KinematicBody2D.position, false, enemy.get_node("KinematicBody2D/CollisionShape2D").shape.radius)
#		$Player/KinematicBody2D.global_position
	if path == null:
		return
	enemy.set_path(path)
	update()

func _on_Bg_button_up():
	var mouse_pos = get_global_mouse_position()
	var path = compute_path($Player/KinematicBody2D.position, mouse_pos, false, $Player/KinematicBody2D/CollisionShape2D.shape.radius)
	if path == null:
		if Global.DEBUG:
			$DebugUI/RichTextLabel.show()
		return
	else:
		if Global.DEBUG:
			$DebugUI/RichTextLabel.hide()
	$Player.set_path(path)
	update()

func compute_path(from : Vector2, to : Vector2, add_noise : bool, collision_radius : float):
	### build the path : from -> grid_from -> grid_to -> to
	var a_star_to_id = a_star.get_closest_point(to)
	var a_star_to = a_star.get_point_position(a_star_to_id)
	var a_star_from_id = a_star.get_closest_point(from)
	var a_star_from = a_star.get_point_position(a_star_from_id)
	if does_circle_collide_during_motion(a_star_to, to - a_star_to, collision_radius): # or does_circle_collide_during_motion(a_star_from, from - a_star_from, collision_radius)
		return null
	var is_connected = a_star.are_points_connected(a_star_from_id, a_star_to_id)
	var path = a_star.get_point_path(a_star_from_id, a_star_to_id)
	if a_star_from_id != a_star_to_id:
		if len(path) == 0: # No path found ! Is the network a unique connected component ?
			return null
	path.insert(0, Vector2(from))
	path.append(Vector2(to))
	
	### remove intermediate points by bisections
	var from_point_idx = 0
	while from_point_idx < len(path) - 2:
		var to_point_idx_test = len(path) - 1
		while to_point_idx_test > from_point_idx + 1:
			if does_circle_collide_during_motion(path[from_point_idx], path[to_point_idx_test] - path[from_point_idx], collision_radius):
				pass
			else:
				for _dummy in range(to_point_idx_test - from_point_idx - 1):
					path.remove(from_point_idx+1)
				break
			to_point_idx_test -= 1
		from_point_idx += 1
	
	### often times, points at indexes 1 and -2 can be moved along x or y axis for a better path
	# TODO
	
	## add some noise
	assert(not add_noise) # not supported yet, TODO for enemies
	
	return path

func _draw():
	if Global.DEBUG:
		for grid_segment in grid_segments:
			var point_idx = grid_segment[0]
			var other_point_idx = grid_segment[1]
			draw_line(a_star.get_point_position(point_idx), a_star.get_point_position(other_point_idx), Color.red, 1, true)
		draw_polyline($Player/Path2D.curve.get_baked_points(), Color(0.3,1,1,0.5), 3, true)
		for enemy in $Enemies.get_children():
			draw_polyline(enemy.get_node("Path2D").curve.get_baked_points(), Color(1,0.6,0.1,0.5), 3, true)
		


