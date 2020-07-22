extends Node

var _amplitude: float
var _priority := 0

onready var camera: Camera = $".."

func start(frequency=15, amplitude=16, priority=0, duration=-1.0):
	if priority < _priority:
		return
		
	_priority = priority
	_amplitude = amplitude
	
	$Frequency.start(1.0 / frequency)
	if duration >= 0:
		$Duration.start(duration)
	else:
		$Duration.stop()
	
	_new_shake()

func stop():
	_reset()
	$Frequency.stop()

func _new_shake():
	var rand = Vector2(rand_range(-_amplitude, _amplitude),
					   rand_range(-_amplitude, _amplitude))
	
	$HTween.interpolate_property(camera, "h_offset", camera.h_offset, rand.x,
								$Frequency.wait_time, Tween.TRANS_QUART,
								Tween.EASE_IN_OUT)
	$HTween.start()
	
	$VTween.interpolate_property(camera, "v_offset", camera.v_offset, rand.y,
								$Frequency.wait_time, Tween.TRANS_QUART,
								Tween.EASE_IN_OUT)
	$VTween.start()
	
func _reset():
	$HTween.interpolate_property(camera, "h_offset", camera.h_offset, 0.0,
								$Frequency.wait_time, Tween.TRANS_QUART,
								Tween.EASE_IN_OUT)
	$HTween.start()
	
	$VTween.interpolate_property(camera, "v_offset", camera.v_offset, 0.0,
								$Frequency.wait_time, Tween.TRANS_QUART,
								Tween.EASE_IN_OUT)
	$VTween.start()
	
	_priority = 0


func _on_Frequency_timeout():
	_new_shake()

func _on_Duration_timeout():
	stop()
