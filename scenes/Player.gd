extends "res://scenes/Character.gd"
# original scene > inherit scene > click on child root node > "inherit script"
# alternatively : in parent.gd declare class_name Parent, then here extend Parent

signal update_path(player, desired_destination)

onready var update_path_timer = $UpdatePath

const character_type = CharacterType.PLAYER

var desired_destination

# Called when the node enters the scene tree for the first time.
func _ready():
	MASS = 5
	hp_max = 100
	hp = hp_max

func set_state(o_state):
	.set_state(o_state)
	state = o_state
	match state:
		State.IDLE:
			update_path_timer.stop()
		State.FOLLOW_PATH:
			update_path_timer.start()
		_:
			assert(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_UpdatePath_timeout():
	emit_signal("update_path", self, desired_destination)
