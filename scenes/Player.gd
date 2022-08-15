extends Character
# original scene > inherit scene > click on child root node > "inherit script"
# alternatively : in parent.gd declare class_name Parent, then here extend Parent

# Called when the node enters the scene tree for the first time.
func _ready():
	MASS = 5


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
