extends "res://scenes/Character.gd"

signal update_path(enemy)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_UpdatePath_timeout():
	emit_signal("update_path", self)
