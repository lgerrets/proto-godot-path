extends Node2D

onready var example_player = $Player
onready var example_enemy = $Enemies/Enemy

var a_star : AStar2D
var a_star_max_point_id = 1

const GRID_RES = 32
const CAM_SPEED = 12

var grid_segments = []
var placing_piece = null

onready var debug_ui = $Camera2D/DebugUI
onready var layout = $Layout

# Called when the node enters the scene tree for the first time.
func _ready():
	var max_radius = 0
	var temp_radius
	for character in [example_player, example_enemy]:
		if character != null:
			temp_radius = character.body.get_node("CollisionShape2D").shape.radius
			max_radius = max(temp_radius, max_radius)
	
	a_star = AStar2D.new()
	var prev_line_idxes = null
	var n_points = Vector2(
		int($Layout/End.position.x - $Layout/Start.position.x) / GRID_RES,
		int($Layout/End.position.y - $Layout/Start.position.y) / GRID_RES
	)
	build_astar($Layout/Start.global_position, n_points, max_radius)
		
	$Player.connect("update_path", self, "update_player_path")
	
	# spawn enemies
	
	spawn_enemies()
	update_enemies_path()
	
	$Camera2D.make_current()
	
	if not Global.DEBUG:
		$Camera2D/DebugUI.hide()
	
	spawn_piece()

func spawn_piece():
	placing_piece = PieceMaker.create_piece()
	layout.add_child(placing_piece)

class AstarNode:
	var point_idx : int # index for AStar
	var grid_pos : Vector2 # coordinates in the grid (eg column x row y)
	var point : Vector2 # classic 2D coordinates, as in global_position
	
	static func point_if_in_bounds(grid_pos : Vector2, start : Vector2, n_points : Vector2):
		var valid = true
		valid = valid and (grid_pos.x < n_points.x)
		valid = valid and (grid_pos.y < n_points.y)
		valid = valid and (grid_pos.x >= 0)
		valid = valid and (grid_pos.y >= 0)
		
		var ret
		if not valid:
			ret = null
		else:
			ret = AstarNode.new()
			ret.grid_pos = grid_pos
			ret.point = start + GRID_RES * grid_pos
			ret.point_idx = grid_pos.x + grid_pos.y * n_points.x
		return ret

func build_astar(start : Vector2, n_points : Vector2, max_radius : float):
	var start_point_idx = a_star_max_point_id
	assert(a_star_max_point_id >= a_star.get_available_point_id()) # we should assert that it's above any point id
	var curr_node = AstarNode.point_if_in_bounds(Vector2(0,0), start, n_points)
	assert(curr_node != null)
	a_star.add_point(curr_node.point_idx, curr_node.point, 1.0)
	var closed_list = {}
	var open_list = {curr_node.point_idx : curr_node}
	var neigh
	while len(open_list) > 0:
		var curr_node_idx = open_list.keys()[0]
		curr_node = open_list[curr_node_idx]
		for delta in [
			Vector2(-1,-1), Vector2(0,-1), Vector2(1,-1),
			Vector2(-1,0), Vector2(1,0),
			Vector2(-1,1), Vector2(0,1), Vector2(1,1),
		]:
			if not does_circle_collide_during_motion(curr_node.point, delta * GRID_RES, max_radius):
				neigh = AstarNode.point_if_in_bounds(curr_node.grid_pos + delta, start, n_points)
				if (neigh != null):
					if not (neigh.point_idx in closed_list) and not (neigh.point_idx in open_list):
						open_list[neigh.point_idx] = neigh
						a_star.add_point(neigh.point_idx, neigh.point, 1.0)
					if curr_node.point_idx == 0:
						pass
					a_star.connect_points(curr_node.point_idx, neigh.point_idx)
					grid_segments.append([curr_node.point_idx, neigh.point_idx])
		open_list.erase(curr_node_idx)
		closed_list[curr_node_idx] = curr_node
	a_star_max_point_id += n_points.x * n_points.y
	
	
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
	
	if placing_piece != null:
		if Input.is_action_pressed("piece_right"):
			placing_piece.position.x += placing_piece.tile_w
		if Input.is_action_pressed("piece_left"):
			placing_piece.position.x -= placing_piece.tile_w
		if Input.is_action_pressed("piece_down"):
			placing_piece.position.y += placing_piece.tile_h
		if Input.is_action_pressed("piece_up"):
			placing_piece.position.y -= placing_piece.tile_h
	
	if Global.DEBUG:
		var x = debug_ui.get_node("TextEdit").text
		var y = debug_ui.get_node("TextEdit2").text
		x = int(x)
		y = int(y)
		debug_ui.get_node("Sprite").position.x = x
		debug_ui.get_node("Sprite").position.y = y
	
func update_enemies_path():
	for enemy in $Enemies.get_children():
		update_enemy_path(enemy)

func update_enemy_path(enemy):
	var path = compute_path(enemy.body.position, $Player.body.position, false, enemy.body.get_node("CollisionShape2D").shape.radius)
	if path == null:
		return
	enemy.set_path(path)
	update()

func update_player_path(player, desired_destination):
	var path = compute_path(player.body.position, desired_destination, false, player.body.get_node("CollisionShape2D").shape.radius)
	if path == null:
		if Global.DEBUG:
			debug_ui.get_node("RichTextLabel").show()
		return
	else:
		if Global.DEBUG:
			debug_ui.get_node("RichTextLabel").hide()
	$Player.set_path(path)
	update()

func _on_Bg_button_up():
	var mouse_pos = get_global_mouse_position()
	$Player.desired_destination = mouse_pos
	update_player_path($Player, mouse_pos)

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
	var point_idx
	var other_point_idx
	if Global.DEBUG:
		for grid_segment in grid_segments:
			point_idx = grid_segment[0]
			other_point_idx = grid_segment[1]
			draw_line(a_star.get_point_position(point_idx), a_star.get_point_position(other_point_idx), Color.red, 1, true)
		draw_polyline($Player/Path2D.curve.get_baked_points(), Color(0.3,1,1,0.5), 3, true)
		for enemy in $Enemies.get_children():
			draw_polyline(enemy.get_node("Path2D").curve.get_baked_points(), Color(1,0.6,0.1,0.5), 3, true)
		


		
