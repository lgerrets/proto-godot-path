extends Node2D

class_name Character

enum State {
	IDLE,
	FOLLOW_PATH,
}

var SPEED_MAX = 2 * Global.DYNAMICS_FACTOR
var MASS = 1
var state = State.IDLE
var path_offset
var nearby_characters = []
var desired_direction = Vector2(0, 0)
var curr_position
var last_position = Vector2(0,0)

onready var body = $KinematicBody2D
onready var animated_sprite : AnimatedSprite = body.get_node("AnimatedSprite")

const dir_to_anim = {
	Global.Direction.UP : "walk_up",
	Global.Direction.RIGHT : "walk_right",
	Global.Direction.DOWN : "walk_down",
	Global.Direction.LEFT : "walk_left",
	Global.Direction.IDLE : "idle",
}

# Called when the node enters the scene tree for the first time.
func _ready():
	body.position = position
	curr_position = position
	last_position = position
	position = Vector2(0,0)
	animated_sprite.play("walk_down")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var path = $Path2D
	var path_follow = $Path2D/PathFollow2D
	last_position = curr_position
	curr_position = body.position
	var new_position
	var new_path_offset
	var baked_length
	match state:
		State.IDLE:
			pass
		State.FOLLOW_PATH:
			new_path_offset = path.curve.get_closest_offset(curr_position)
			new_path_offset += delta * SPEED_MAX
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
	
	# set animation
	var dpos = curr_position - last_position
	var curr_direction = Global.dpos_to_dir(dpos)
	var max_dpos_length = delta * SPEED_MAX
	animated_sprite.speed_scale = dpos.length() / max_dpos_length
	animated_sprite.play(dir_to_anim[curr_direction])

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
	assert(points[0] == body.position)
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
