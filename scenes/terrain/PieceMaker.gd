extends Node

const PieceScene = preload("res://scenes/terrain/Piece.tscn")
const PieceTileScene = preload("res://scenes/terrain/PieceTile.tscn")
const WallScene = preload("res://scenes/Wall.tscn")

const tile_rows = 7
const tile_cols = 7

var tile_w
var tile_h

enum Shape {
	SINGLE,
	O,
	L,
}

static func create_piece() -> Node2D:
	var piece = PieceScene.instance()
	var tiles = piece.get_node("Tiles")
	var shape = randi() % len(Shape)
	if Global.DEBUG:
		shape = Shape.SINGLE # TODO temporary
	piece.shape = shape
	piece.grid_pos = Vector2(2, 8)
	var relative_positions
	match shape:
		Shape.SINGLE:
			relative_positions = [
				Vector2( 0, 0),
			]
		Shape.L:
			relative_positions = [
				Vector2(-1,-1),
				Vector2(-1, 0),
				Vector2(-1, 1),
				Vector2( 0, 1),
			]
		Shape.O:
			relative_positions = [
				Vector2(-1,-1),
				Vector2( 0,-1),
				Vector2(-1, 0),
				Vector2( 0, 0),
			]
		_:
			assert(false)
	var tile
	for relative_position in relative_positions:
		tile = PieceTileScene.instance()
		tile.initialize(relative_position, Vector2(tile_cols, tile_rows))
		if randf() < 0.5:
			var wall = WallScene.instance()
			wall.position.x = PieceMaker.tile_w * int(tile_cols / 2) / tile_cols
			wall.position.y = PieceMaker.tile_h * int(tile_rows / 2) / tile_rows
			tile.add_child(wall)
		tiles.add_child(tile)
	
	piece.position.y = - 200
	return piece

# Called when the node enters the scene tree for the first time.
func _ready():
	var rect_shape = PieceTileScene.instance().get_node("ToRescale/Sprite").get_rect().size
	tile_w = rect_shape.x * tile_cols
	tile_h = rect_shape.y * tile_rows
	Global.logger("Tiles have pixel size " + str(Vector2(tile_w, tile_h)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
