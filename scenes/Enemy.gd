extends "res://scenes/Character.gd"

class_name Enemy

signal update_path(enemy)

const character_type = CharacterType.ENEMY
const HIT_RANGE = 70
const HIT_DAMAGE = 20
const HIT_TIME = 1.5

onready var update_path_timer = $UpdatePath

# Called when the node enters the scene tree for the first time.
func _ready():
	SPEED_MAX = 2 * Global.DYNAMICS_FACTOR
	hp_max = 40
	hp = hp_max
	
	var n_frames
	var target_speed
	hit_timer.wait_time = HIT_TIME
	for key in Character.dir_to_anim_hit.values():
		n_frames = animated_sprite.frames.get_frame_count(key)
		target_speed = n_frames / HIT_TIME
		animated_sprite.frames.set_animation_speed(key, target_speed)

func my_process(delta):
	if action_state == ActionState.IDLE:
		var maybe_player = find_closest_player(HIT_RANGE)
		if maybe_player != null:
			set_action_state(ActionState.HITTING)
	
	.my_process(delta)

func find_closest_player(search_range):
	var closest_dist = search_range + 1
	var player = null
	for character in nearby_characters:
		if (character.character_type == CharacterType.PLAYER):
			var dist = body.position.distance_to(character.body.position)
			if dist < closest_dist:
				closest_dist = dist
				player = character
	return player

func _on_UpdatePath_timeout():
	emit_signal("update_path", self)

func _on_HitTimer_timeout():
	var maybe_player = find_closest_player(HIT_RANGE)
	if maybe_player != null:
		maybe_player.set_d_hp(- HIT_DAMAGE)
	set_action_state(ActionState.IDLE)
	emit_signal("update_path", self)
