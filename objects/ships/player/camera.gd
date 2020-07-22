extends Camera

func _on_Player_thrust_activated():
	$ScreenShake3D.start(15, 0.05)
	#func start(frequency=15, amplitude=16, priority=0, duration=-1.0):

func _on_Player_thrust_deactivated():
	$ScreenShake3D.stop()
