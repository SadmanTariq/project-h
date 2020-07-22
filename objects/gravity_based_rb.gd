class_name GravityBasedRb
extends RigidBody

var parent: Planet

func _ready():
	if $".." is Planet:
		parent = $".."

func _physics_process(delta):
	if parent == null:
		if $".." is Planet:
			parent = $".."
		else:
			return
	apply_central_impulse(_get_gravity_force() * delta)

func _get_gravity_force() -> Vector3:
	var to_parent = parent.global_transform.origin - global_transform.origin
	var magnitude = Constants.BIG_G * parent.mass * mass / to_parent.length_squared()
	var force = to_parent.normalized() * magnitude
	return force
