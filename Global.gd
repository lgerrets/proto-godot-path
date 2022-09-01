extends Node

const DEBUG = 1
const LOG_LEVEL = 2

const DYNAMICS_FACTOR = 50

enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT,
	IDLE,
}

func logger(msg):
	if LOG_LEVEL > 1:
		print(msg)

func error(msg):
	if LOG_LEVEL > 0:
		print(msg)

func dpos_to_dir(dpos):
	if dpos.length() == 0:
		return Direction.IDLE
	elif abs(dpos.x) > abs(dpos.y):
		if dpos.x > 0:
			return Direction.RIGHT
		else:
			return Direction.LEFT
	else:
		if dpos.y > 0:
			return Direction.DOWN
		else:
			return Direction.UP

class Queue:
	var max_size
	var arr = []

	func _init(o_max_size):
		max_size = o_max_size
	
	func push(val):
		arr.append(val)
		if len(arr) > max_size:
			arr.pop_front()
	
	func get(idx):
		return arr[idx]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
