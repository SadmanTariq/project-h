class_name Player
extends Ship

func _input(event):
	if event.is_action_pressed("thrust"):
		_set_thrust_active(true)
	elif event.is_action_released("thrust"):
		_set_thrust_active(false)

func _physics_process(delta):
	._physics_process(delta)
	_get_torque()
	
func _get_torque():
	_pitch_torque = 0.0
	if Input.is_action_pressed("pitch_pos"):
		_pitch_torque += 1.0
	if Input.is_action_pressed("pitch_neg"):
		_pitch_torque -= 1.0
	
	_yaw_torque = 0.0
	if Input.is_action_pressed("yaw_pos"):
		_yaw_torque += 1.0
	if Input.is_action_pressed("yaw_neg"):
		_yaw_torque -= 1.0

	_roll_torque = 0.0
	if Input.is_action_pressed("roll_pos"):
		_roll_torque += 1.0
	if Input.is_action_pressed("roll_neg"):
		_roll_torque -= 1.0
