extends Node


func _input(event: InputEvent):
	if OS.get_name() == "HTML5":
		if event.is_action_pressed("f5"):
			JavaScript.eval("window.location.reload();")

