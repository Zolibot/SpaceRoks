extends Node2D

export (PackedScene) var Rock
export (PackedScene) var Enemy

var level = 0
var score = 0
var playing = false
var _dir = Vector2(0,0)
var screensize = Vector2()


func _ready():
	randomize()
	screensize = get_viewport().get_visible_rect().size
	$Background.set_size(screensize)
	$Player.screensize = screensize
	
	YandexSdk.connect("show_full_screen",self,"_on_Pause_pressed")
	YandexSdk.connect("close_full_screen",self,"_off_Pause")
	
	
	for  i in range(9):
		spawn_rock(3)

func _process(delta):
	if playing and $Rocks.get_child_count() == 0:
		new_level()

func _input(event):
	if event.is_action_pressed('pause'):
		if not playing:
			return
		get_tree().paused = not get_tree().paused
		if get_tree().paused:
			$HUD/MessagePause.text = "Пауза!"
			$HUD/MessagePause.show()
		else:
			$HUD/MessagePause.text = ""
			$HUD/MessagePause.hide()

func game_over():
	playing = false
	get_node("Player/CollisionShape2D").call_deferred("set", "disabled", true)
	$HUD.game_over()
	$Music.stop()
	$EnemyTimer.stop()
	for i in range(5):
		spawn_rock(6)
	for x in get_children():
		if x.is_in_group('enemies'):
			x.queue_free()
			
	show_ads()

func show_ads()->void:
	if OS.has_feature("JavaScript"):
		YandexSdk.ShowFullScreenAds()


func new_game():
	$Music.play()
	for rock in $Rocks.get_children():
		rock.queue_free()
	level = 0
	score = 0
	$HUD.update_score(score)
	$Player.start()
	$HUD.show_message("Приготовиться!")
	yield($HUD/MessageTimer,"timeout")
	playing = true
	new_level()

func new_level():
	$LevelupSound.play()
	level += 1
	if level > 1:
		show_ads()
		
	$HUD.show_message("Волна %s" % level)
	
	if level < 15:
		for i in range(level):
			if level >= 8:
				spawn_rock(5)
			elif level >= 5:
				spawn_rock(4)
			else:
				spawn_rock(3)
	else:
		for i in range(15):
			if level >= 12:
				spawn_rock(5)
			elif level >= 10:
				spawn_rock(4)
			else:
				spawn_rock(3)

	$EnemyTimer.wait_time = rand_range(5,10)
	$EnemyTimer.start()


func spawn_rock(size,pos = null, vel = null):
	if !pos:
		$RockPath/RockSpawn.set_offset(randi())
		pos = $RockPath/RockSpawn.position
	if !vel:
		vel = Vector2(1,0).rotated(rand_range(0,2*PI)) * rand_range(100,150)
	var r = Rock.instance()
	r.screensize = screensize
	r.start(pos,vel,size)
	r.connect("exploded",self,"_on_Rock_exploded")
	$Rocks.add_child(r)


func _on_Rock_exploded(size,radius,pos,vel):
	score += size * 10
	$HUD.update_score(score)
	$ExplodeSound.play()
	if size<=1:
		return
	var d = [-1,1]
	for offset in d:
		var dir = (pos - $Player.position).normalized().tangent() * offset
		var newpos = pos + dir * radius
		var newvel = dir * vel.length() * 1.1
		spawn_rock(size-1,newpos,newvel)


func _on_Player_shoot(bullet,pos,dir):
	var b = bullet.instance()
	b.start(pos,dir)
	add_child(b)


func _on_EnemyTimer_timeout():
	var e = Enemy.instance()
	add_child(e)
	e.target = $Player
	e.connect('shoot',self,'_on_Player_shoot')
	$EnemyTimer.wait_time = rand_range(20,40)
	$EnemyTimer.start()
	
#########################	

func _off_Pause()->void:
	get_tree().set_pause(true)
	$HUD/ReturnButton.show()



func _on_Pause_pressed()->void:
	$HUD._on_Pause_pressed()
	$HUD/ReturnButton.show()
	$HUD/MarginContainer.grab_focus()
