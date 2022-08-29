extends Node

const PieceScene = preload("res://scenes/terrain/Piece.tscn")
const PieceTileScene = preload("res://scenes/terrain/PieceTile.tscn")
const WallScene = preload("res://scenes/Wall.tscn")

const tile_rows = 7
const tile_cols = 7

enum Shape {
	O,
	L,
}

static func create_piece() -> Node2D:
	var rect_shape = PieceTileScene.instance().get_node("Sprite").get_rect().size
	var tile_w = rect_shape.x * tile_cols
	var tile_h = rect_shape.y * tile_rows

	var piece = PieceScene.instance()
	var tiles = piece.get_node("Tiles")
	var shape = randi() % len(Shape)
	piece.shape = shape
	piece.tile_w = tile_w
	piece.tile_h = tile_h
	var relative_positions
	match shape:
		Shape.L:
			relative_positions = [
				[-1,-1],
				[-1, 0],
				[-1, 1],
				[ 0, 1],
			]
		Shape.O:
			relative_positions = [
				[-1,-1],
				[ 0,-1],
				[-1, 0],
				[ 0, 0],
			]
		_:
			assert(false)
	var tile
	for relative_position in relative_positions:
		tile = PieceTileScene.instance()
		tile.get_node("Sprite").scale.x = tile_cols
		tile.get_node("Sprite").scale.y = tile_rows
		tile.position.x = tile_w * relative_position[0]
		tile.position.y = tile_h * relative_position[1]
		if randf() < 0.5:
			var wall = WallScene.instance()
			wall.position.x = tile_w * int(tile_cols / 2) / tile_cols
			wall.position.y = tile_h * int(tile_rows / 2) / tile_rows
			tile.add_child(wall)
		tiles.add_child(tile)
	
	piece.position.y = - 200
	return piece

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
