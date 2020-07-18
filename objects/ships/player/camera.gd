extends Spatial

export var sensitivity = deg2rad(0.2)  # rad per pixel
var rot = Vector2.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotation.x = clamp(rotation.x - event.relative.y * sensitivity,
						   -PI / 2, PI / 2)
		rotation.y -= event.relative.x * sensitivity
		
	elif event.is_action_pressed("pause"):
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
