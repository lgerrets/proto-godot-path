extends Node2D

class_name Piece

var shape
# var tile_w # let's use PieceMaker.tile_* instead
# var tile_h
var grid_pos # position in the grid layout

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_tiles() -> Array:
	return $Tiles.get_children()

func move(direction : int):
	var d_pos = Global.dir_to_dpos(direction)
	position += d_pos * Vector2(PieceMaker.tile_w, PieceMaker.tile_h)
	grid_pos += d_pos

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
