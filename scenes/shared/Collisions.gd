extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _compute_repulsion_force(node : Node, other_nodes : Array):
	var force = Vector2(0, 0)
	var collision_shape = node.body.get_node("CollisionShape2D")
	var repulsion_shape = node.body.get_node("RepulsionHitbox/CollisionShape2D")
	var other_collision_shape
	var other_repulsion_shape
	var coef
	var unit_direction
	var d2
	for other_node in other_nodes:
		other_collision_shape = other_node.body.get_node("CollisionShape2D")
		other_repulsion_shape = other_node.body.get_node("RepulsionHitbox/CollisionShape2D")
		coef = repulsion_shape.shape.radius - collision_shape.shape.radius + other_repulsion_shape.shape.radius - other_collision_shape.shape.radius
		coef = pow(coef, 2)
		assert (collision_shape.global_position != other_collision_shape.global_position)
		unit_direction = (collision_shape.global_position - other_collision_shape.global_position).normalized()
		d2 = collision_shape.global_position.distance_to(other_collision_shape.global_position)
		d2 += - collision_shape.shape.radius - other_collision_shape.shape.radius
		d2 = max(0, d2)
		d2 = pow(d2, 2)
		force += unit_direction * coef / (0.000001 + d2)
	return force

func compute_next_pos(node : Character, nearby_characters : Array, apply_direction : Vector2, speed_max : float, mass : float, delta : float):
	var desired_direction = apply_direction
	var vel = desired_direction.normalized() * speed_max
	var force = _compute_repulsion_force(node, node.nearby_characters) * Global.DYNAMICS_FACTOR
	force *= delta / node.MASS
	vel += force
	var body = node.body
	var d_pos = vel * delta
	d_pos = d_pos.clamped(5) # fixes bodies clipping into one another or getting ejected
	check_collision_clip(node, nearby_characters)
#	var collision_infos = body.move_and_collide(d_pos, true, true, true)
#	if (collision_infos == null) or (collision_infos.get_travel().length() > 1):
#		collision_infos = body.move_and_collide(d_pos, true, true, false)
#		check_collision_clip(node, nearby_characters)
	d_pos = body.move_and_slide(d_pos)
	body.position += d_pos
	check_collision_clip(node, nearby_characters)

func check_collision_clip(node : Character, nearby_characters : Array):
	if Global.DEBUG:
		var collision_shape = node.body.get_node("CollisionShape2D")
		var other_collision_shape
		var distance
		for character in nearby_characters:
			other_collision_shape = character.body.get_node("CollisionShape2D")
			distance = collision_shape.global_position.distance_to(other_collision_shape.global_position)
#			assert(distance > 30) # I'm commenting this because anyway as the player I can easily unclip from an enemy...
