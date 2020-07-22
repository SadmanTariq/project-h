class_name Planet
extends StaticBody

# Density = 10000 kg per cubic metre
export var mass := 5.2 * pow(10, 14)
export var rot_period = 120.0

func _physics_process(delta):
	var rot_speed = 2.0 * PI / rot_period
	$Planet.rotate_y(rot_speed * delta)
