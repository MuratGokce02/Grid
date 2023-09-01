extends Timer


func timer():
	if is_stopped():
		start()
	else:
		stop()
