extends KinematicBody2D

enum State {
	IDLE,
	FOLLOW_PATH,
}

const MAX_SPEED = 300
var state = State.IDLE
var path_offset
var speed = MAX_SPEED

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match state:
		State.IDLE:
			pass
		State.FOLLOW_PATH:
			var path_follow = $Path2D/PathFollow2D
			path_offset += delta*speed
			path_follow.set_offset(path_offset)
			var new_position = path_follow.get_position()
			if position == new_position:
				set_state(State.IDLE)
			else:
				position = new_position
		_:
			assert(false)

func _physics_process(delta):
	pass

func set_state(o_state):
	state = o_state

func set_path(points : PoolVector2Array):
	var path = $Path2D
	path.show()
	var path_follow = $Path2D/PathFollow2D
	var curve = path.curve
	curve.clear_points()
	assert(points[0] == position)
	for point in points:
		curve.add_point(point)
	path_follow.loop = false
	path_offset = 0
	set_state(State.FOLLOW_PATH)
