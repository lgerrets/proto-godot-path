extends Node

const DEBUG = 1
const LOG_LEVEL = 2

const DYNAMICS_FACTOR = 50

func logger(msg):
	if LOG_LEVEL > 1:
		print(msg)

func error(msg):
	if LOG_LEVEL > 0:
		print(msg)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
