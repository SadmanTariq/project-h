class_name Ship
extends GravityBasedRb

signal thrust_activated
signal thrust_deactivated

export var thrust = 30.0
export var torque = 1000.0

var thrust_active = false setget _set_thrust_active
var _pitch_torque = 0
var _roll_torque = 0
var _yaw_torque = 0

func _set_thrust_active(value):
	if thrust_active == value:
		return
	thrust_active = value
	if thrust_active:
		emit_signal("thrust_activated")
	else:
		emit_signal("thrust_deactivated")

func _ready():
	._ready()
	if parent != null:
		_stabilize_orbit()

func _physics_process(delta):
	apply_central_impulse(_get_impulse(delta))
	apply_torque_impulse(_get_torque_impulse(delta))

func _get_torque_impulse(delta) -> Vector3:
	var torque_vec := Vector3()
	
	var basis = transform.basis
	var right   = basis.x
	var down    = -basis.y
	var forward = -basis.z
	
	torque_vec += right   * _pitch_torque
	torque_vec += down    * _yaw_torque
	torque_vec += forward * _roll_torque
	
	return torque_vec.normalized() * torque * delta

func _get_impulse(delta) -> Vector3:
	if thrust_active:
		return -transform.basis.z.normalized() * thrust * delta
	else:
		return Vector3()

func _stabilize_orbit():
	var r = transform.origin.length()
	linear_velocity.x = sqrt(Constants.BIG_G * parent.mass / r)
