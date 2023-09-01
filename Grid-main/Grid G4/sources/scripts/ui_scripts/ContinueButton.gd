extends Button


func stopped():
	text = "STOPPED"


func started():
	text = "STARTED"


func _on_button_down():
	if text == "STARTED":
		stopped()
	elif text == "STOPPED":
		started()
