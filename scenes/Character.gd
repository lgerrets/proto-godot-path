extends Node2D

class_name Character

enum State {
	IDLE,
	FOLLOW_PATH,
}

var SPEED_MAX = 2
var MASS = 1
var state = State.IDLE
var path_offset
var nearby_characters = []
var desired_direction = Vector2(0, 0)

# Called when the node enters the scene tree for the first time.
func _ready():
	$KinematicBody2D.position = position
	position = Vector2(0,0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var path = $Path2D
	var path_follow = $Path2D/PathFollow2D
	var curr_position = $KinematicBody2D.position
	var new_position
	var new_path_offset
	var baked_length
	match state:
		State.IDLE:
			pass
		State.FOLLOW_PATH:
			new_path_offset = path.curve.get_closest_offset(curr_position)
			new_path_offset += delta * SPEED_MAX * Global.DYNAMICS_FACTOR
			baked_length = path.curve.get_baked_length()
			if new_path_offset > baked_length:
				set_state(State.IDLE)
			else:
				path_offset = new_path_offset
				path_follow.set_offset(path_offset)
				new_position = path_follow.get_position()
				desired_direction = (new_position - curr_position).normalized()
		_:
			assert(false)
	Collisions.compute_next_pos(self, nearby_characters, desired_direction, SPEED_MAX, MASS, delta)

func set_state(o_state):
	state = o_state
	match state:
		State.IDLE:
			desired_direction = Vector2(0, 0)
		State.FOLLOW_PATH:
			pass
		_:
			assert(false)

func set_path(points : PoolVector2Array):
	var path = $Path2D
	path.show()
	var path_follow = $Path2D/PathFollow2D
	path.curve = Curve2D.new()
	var curve = path.curve
	curve.clear_points()
	assert(points[0] == $KinematicBody2D.position)
	for point in points:
		curve.add_point(point)
	path_follow.loop = false
	path_offset = 0
	set_state(State.FOLLOW_PATH)

func _on_RepulsionHitbox_area_entered(area):
	var character = area.get_parent().get_parent()
	nearby_characters.append(character)

func _on_RepulsionHitbox_area_exited(area):
	var character = area.get_parent().get_parent()
	nearby_characters.erase(character)
