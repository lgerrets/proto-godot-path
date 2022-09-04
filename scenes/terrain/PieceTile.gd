extends Node2D

var astar_nodes_on_borders = {
	Global.Direction.UP: [],
	Global.Direction.RIGHT: [],
	Global.Direction.DOWN: [],
	Global.Direction.LEFT: [],
}

var relative_grid_pos


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func initialize(o_relative_grid_pos : Vector2, rescale : Vector2):
	relative_grid_pos = o_relative_grid_pos
	get_node("ToRescale").scale.x = rescale.x
	get_node("ToRescale").scale.y = rescale.y
	position.x = PieceMaker.tile_w * o_relative_grid_pos.x
	position.y = PieceMaker.tile_h * o_relative_grid_pos.y


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
