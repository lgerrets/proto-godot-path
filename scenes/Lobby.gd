extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	_on_Button_button_up() # TODO TEMP

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_Button_button_up():
	get_tree().change_scene("res://scenes/Level.tscn")
