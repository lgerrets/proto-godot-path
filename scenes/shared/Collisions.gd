extends Node

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _compute_repulsion_force(node : Node, other_nodes : Array):
	var force = Vector2(0, 0)
	var collision_shape = node.get_node("KinematicBody2D/CollisionShape2D")
	var repulsion_shape = node.get_node("KinematicBody2D/RepulsionHitbox/CollisionShape2D")
	var other_collision_shape
	var other_repulsion_shape
	var coef
	var unit_direction
	var d2
	for other_node in other_nodes:
		other_collision_shape = other_node.get_node("KinematicBody2D/CollisionShape2D")
		other_repulsion_shape = other_node.get_node("KinematicBody2D/RepulsionHitbox/CollisionShape2D")
		coef = repulsion_shape.shape.radius - collision_shape.shape.radius + other_repulsion_shape.shape.radius - other_collision_shape.shape.radius
		coef = pow(coef, 2)
		assert (collision_shape.global_position != other_collision_shape.global_position)
		unit_direction = (collision_shape.global_position - other_collision_shape.global_position).normalized()
		d2 = collision_shape.global_position.distance_to(other_collision_shape.global_position)
		d2 += - collision_shape.shape.radius - other_collision_shape.shape.radius
		d2 = pow(d2, 2)
		force += unit_direction * coef / (0.000001 + d2)
	return force

func compute_next_pos(node : Character, nearby_characters : Array, apply_direction : Vector2, speed_max : float, mass : float, delta : float):
	var desired_direction = apply_direction
	var velocity = desired_direction.normalized() * node.SPEED_MAX * node.DYNAMICS_FACTOR
	var force = _compute_repulsion_force(node, node.nearby_characters) * node.DYNAMICS_FACTOR
	velocity += delta * force / node.MASS
	var body = node.get_node("KinematicBody2D")
	var collision_infos = body.move_and_collide(velocity * delta)
	pass
