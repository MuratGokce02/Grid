extends Timer


signal stopped
signal started


func timer_start():
		start()
		emit_signal("started")

func timer_stop():
		stop()
		emit_signal("stopped")

func reverse():
	if is_stopped():
		timer_start()
	else:
		timer_stop()
