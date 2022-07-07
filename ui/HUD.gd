extends CanvasLayer

signal star_game

onready var ShieldBar = $MarginContainer/HBoxContainer/ShieldBar
onready var lives_counter = [$MarginContainer/HBoxContainer/LivesCounter/L1,
$MarginContainer/HBoxContainer/LivesCounter/L2,
$MarginContainer/HBoxContainer/LivesCounter/L3]


var red_bar = preload("res://assets/barHorizontal_red_mid 200.png")
var green_bar = preload("res://assets/barHorizontal_green_mid 200.png")
var yellow_bar = preload("res://assets/barHorizontal_yellow_mid 200.png")

var pause = false

#func _ready():
#	$MarginContainer2/PopupGemeOwer.popup()

func update_shield(value):
	value *= 100
	ShieldBar.texture_progress = green_bar
	if value < 40:
		ShieldBar.texture_progress = red_bar
	elif value < 70:
		ShieldBar.texture_progress = yellow_bar
	ShieldBar.value = value

func show_message(message):
	$MessageLabel.text = message
	$MessageLabel.show()
	$MessageTimer.start()
	
func show_pause(message):
	$MessagePause.text = message
	$MessagePause.show()


func update_score(value):
	$MarginContainer/HBoxContainer/ScoreLabel.text = str(value)


func update_lives(value):
	for item in range(3):
		lives_counter[item].visible = value > item

func game_over():
#	show_message("Конец игры!")
#	yield($MessageTimer,"timeout")
	_on_PopupGemeOwer_about_to_show()
	yield(get_tree().create_timer(1),"timeout")
	$StartButton.show()
	
	

func _on_StartButton_pressed():
	$StartButton.hide()
	emit_signal("star_game")

func _on_MessageTimer_timeout():
	$MessageLabel.hide()
	$MessageLabel.text = ""


func _on_Pause_pressed():
	show_pause("Пауза!")
	pause = not pause
	get_tree().set_pause(pause) 
	if not get_tree().is_paused():
		$MessagePause.hide()
		$MessagePause.text = ""


func _on_Sound_toggled(button_pressed):
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), button_pressed)
	Global.trriger_sound = button_pressed


func _on_LiderBoard_pressed():
	_on_Pause_pressed()



func _on_ReturnButton_pressed():
	get_tree().set_pause(false)
	$MessagePause.text = ""
	$MessagePause.hide()
	$ReturnButton.hide()


func _on_ReturnGameOwerButton_pressed():
	$MarginContainer2/PopupGemeOwer.hide()
	
	
	
func _ready():
	Global.connect("pull_data",self,"set_score",[])


func _on_PopupGemeOwer_about_to_show():
	Global.data_load()
	$MarginContainer2/PopupGemeOwer.popup()
	

func set_score(args):
	if $MarginContainer2/PopupGemeOwer.visible == true:
		if Global.score < args:
			$"MarginContainer2/PopupGemeOwer/LabelRecord".text = "Рекорд: " + str(args)
			$"MarginContainer2/PopupGemeOwer/LabelScore".text = "Очки: " + str(Global.score)
		else:
			$"MarginContainer2/PopupGemeOwer/LabelRecord".text = "Рекорд: " + str(Global.score)
			$"MarginContainer2/PopupGemeOwer/LabelScore".text = "Очки: " + str(Global.score)
			Global.data_save(Global.score)
	else:
		show_message("Рекорд: "+ str(args))
		Global.record = int(args)

