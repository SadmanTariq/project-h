extends Spatial

export var active_max = 16
export var active_min = 10
export var active_period = 1.5

export var inactive_max = 1.2
export var inactive_min = 0
export var inactive_period = 3

export var transition_time = 1

export var thruster_material_index = 3

var _active = false
var _cur_strength = inactive_max
var _transition_speed = 0.0
var _transitioning = false
var _time = 0.0

func _activate():
	if !_active:
		_active = true
		_start_transition()

func _deactivate():
	if _active:
		_active = false
		_start_transition()

func _start_transition():
	var target = active_min if _active else inactive_max
	_transition_speed = (target - _get_emit()) / transition_time
	_transitioning = true

func _set_emit(strength):
	$Ship.mesh.surface_get_material(thruster_material_index).emission_energy = strength

func _get_emit() -> float:
	return $Ship.mesh.surface_get_material(thruster_material_index).emission_energy 

func _ranged_cos(x, mini, maxi, period):
	return abs(cos(2 * PI * x / period)) * (maxi - mini) / 2 + (maxi + mini) / 2

func _process(delta):
	_time += delta
	if _transitioning:
		var target = active_min if _active else inactive_max
		var current = _get_emit()
		if (_active and current >= target) or (!_active and current <= target):
			_time = 0.0
			_transitioning = false
		else:
			_set_emit(current + _transition_speed * delta)
		return
	
	if _active:
		_set_emit(_ranged_cos(_time, active_max, active_min, active_period))
	else:
		_set_emit(_ranged_cos(_time, inactive_min, inactive_max, inactive_period))
	
