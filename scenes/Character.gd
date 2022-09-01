extends Node2D

class_name Character

enum State {
	IDLE,
	FOLLOW_PATH,
}

enum ActionState {
	IDLE,
	HITTING,
}

enum CharacterType {
	PLAYER,
	ENEMY,
}

const MIN_DPOS_TO_RENDER = 3 # this is a trick to get rid off wiggly characters eg when they are stuck against a wall

var SPEED_MAX = 2 * Global.DYNAMICS_FACTOR
var MASS = 1
var state = State.IDLE
var action_state = ActionState.IDLE
var path_offset
var nearby_characters = []
var desired_direction = Vector2(0, 0)
var curr_body_position
var last_body_position = Vector2(0,0)
var last_render_positions = Global.Queue.new(2)
var hp
var hp_max
var max_dpos_length = 1
var can_update_animation_dir = true

onready var body = $KinematicBody2D
onready var hit_timer = $HitTimer
onready var render_node = $Render
onready var hp_bar : ProgressBar = render_node.get_node("HpBar")
onready var animated_sprite : AnimatedSprite = render_node.get_node("AnimatedSprite")

const dir_to_anim_walk = {
	Global.Direction.UP : "walk_up",
	Global.Direction.RIGHT : "walk_right",
	Global.Direction.DOWN : "walk_down",
	Global.Direction.LEFT : "walk_left",
	Global.Direction.IDLE : "idle",
}

const dir_to_anim_hit = {
	Global.Direction.UP : "hit_left",
	Global.Direction.RIGHT : "hit_left",
	Global.Direction.DOWN : "hit_left",
	Global.Direction.LEFT : "hit_left",
	Global.Direction.IDLE : "hit_left",
}

# Called when the node enters the scene tree for the first time.
func _ready():
	body.position = position
	curr_body_position = position
	last_body_position = position
	position = Vector2(0,0)
	animated_sprite.play("walk_down")
	hp_bar.visible = false
	for idx in range(last_render_positions.max_size):
		last_render_positions.push(Vector2.ZERO)

func _process(delta):
	my_process(delta)
	
func my_process(delta):
	var path = $Path2D
	var path_follow = $Path2D/PathFollow2D
	last_render_positions.push(render_node.position)
	var new_position
	var new_path_offset
	var baked_length
	match state:
		State.IDLE:
			pass
		State.FOLLOW_PATH:
			new_path_offset = path.curve.get_closest_offset(curr_body_position)
			new_path_offset += delta * SPEED_MAX
			baked_length = path.curve.get_baked_length()
			if new_path_offset > baked_length:
				set_state(State.IDLE)
			else:
				path_offset = new_path_offset
				path_follow.set_offset(path_offset)
				new_position = path_follow.get_position()
				desired_direction = (new_position - curr_body_position).normalized()
		_:
			assert(false)
	
	max_dpos_length = delta * SPEED_MAX
	update_animation()

func _physics_process(delta):
	curr_body_position = body.position
	Collisions.compute_next_pos(self, nearby_characters, desired_direction, SPEED_MAX, MASS, delta)
	last_body_position = curr_body_position
	curr_body_position = body.position
	var tent_render_position = body.position.round()
	if tent_render_position.distance_to((last_render_positions.get(-1) + last_render_positions.get(-2))/2) >= MIN_DPOS_TO_RENDER:
		render_node.position = tent_render_position

func update_animation():
	# set animation
	var dpos = curr_body_position - last_body_position
	var curr_direction = Global.dpos_to_dir(dpos)
	match action_state:
		ActionState.IDLE:
			try_to_play_animation(dir_to_anim_walk[curr_direction])
			if max_dpos_length == 0:
				animated_sprite.speed_scale = 1
			else:
				animated_sprite.speed_scale = dpos.length() / max_dpos_length
		ActionState.HITTING:
			animated_sprite.speed_scale = 1
			try_to_play_animation(dir_to_anim_hit[curr_direction])
		_:
			assert(false)

func try_to_play_animation(animation_name):
	if (animation_name != animated_sprite.animation) and can_update_animation_dir:
		animated_sprite.play(animation_name)
		start_animation_timer()

func set_state(o_state):
	can_update_animation_dir = true
	
	state = o_state
	
	match state:
		State.IDLE:
			desired_direction = Vector2(0, 0)
		State.FOLLOW_PATH:
			pass
		State.HITTING:
			pass
		_:
			assert(false)
	
	update_animation()

func set_action_state(o_state):
	action_state = o_state
	match action_state:
		ActionState.IDLE:
			hit_timer.set_paused(true)
		ActionState.HITTING:
			hit_timer.set_paused(false)
			hit_timer.start()
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
	can_update_animation_dir = true

func _on_RepulsionHitbox_area_entered(area):
	var character = area.get_parent().get_parent()
	nearby_characters.append(character)

func _on_RepulsionHitbox_area_exited(area):
	var character = area.get_parent().get_parent()
	nearby_characters.erase(character)

func set_d_hp(d_hp):
	hp = min(hp_max, hp + d_hp)
	if hp < hp_max:
		hp_bar.value = max(0, 100 * hp / hp_max)
		hp_bar.visible = true
	else:
		hp_bar.visible = false

func start_animation_timer():
	can_update_animation_dir = false
	$AnimationTimer.start()

func _on_AnimationTimer_timeout():
	can_update_animation_dir = true
