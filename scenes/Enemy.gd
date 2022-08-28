extends "res://scenes/Character.gd"

class_name Enemy

signal update_path(enemy)

const character_type = CharacterType.ENEMY
const HIT_RANGE = 200
const HIT_DAMAGE = 20

onready var update_path_timer = $UpdatePath

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func my_process(delta):
	if action_state == ActionState.IDLE:
		var maybe_player = find_closest_player(HIT_RANGE)
		if maybe_player != null:
			set_action_state(ActionState.HITTING)
	
	.my_process(delta)
	Global.logger(str(update_path_timer.time_left) + " " + str(hit_timer.time_left))

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
		maybe_player.hp -= HIT_DAMAGE
	emit_signal("update_path", self)
