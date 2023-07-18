extends Node2D

export (PackedScene) var Rock
export (PackedScene) var Enemy

var level = 0
var _dir = Vector2(0,0)
var screensize = Vector2()


func _ready():
    randomize()
    screensize = get_viewport().get_visible_rect().size
    $Background.set_size(screensize)
    $Player.screensize = screensize
    
    Global.connect("set_game_pause",self,"_off_Pause")
    Global.connect("close_full_screen",self,"_off_Pause")
    
    
    for  i in range(9):
        spawn_rock(3)

func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
        Global.tab_Open()
        
    if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
        Global.tab_Close()


func _process(delta):
    if Global.playing and $Rocks.get_child_count() == 0:
        new_level()

func _input(event):
    if event.is_action_pressed('pause'):
        if not Global.playing:
            return
        get_tree().paused = not get_tree().paused
        if get_tree().paused:
            $HUD/MessagePause.text = "Пауза!"
            $HUD/MessagePause.show()
        else:
            $HUD/MessagePause.text = ""
            $HUD/MessagePause.hide()

func game_over():
    Global.playing = false
    get_node("Player/CollisionShape2D").call_deferred("set", "disabled", true)
    $Player.set_position(Vector2(512,200))
    $HUD.game_over()
    $Music.stop()
    $EnemyTimer.stop()
    for i in range(5):
        spawn_rock(6)
    for x in get_children():
        if x.is_in_group('enemies'):
            x.queue_free()
            
    Global._show_interstitial()

func show_ads()->void:
    if OS.has_feature("JavaScript"):
#		if $Timer.is_stopped():
        Global._show_interstitial()
#			$Timer.start(61)


func new_game():
    $Music.play()
    for rock in $Rocks.get_children():
        rock.queue_free()
    level = 9
    Global.score = 9586
    $HUD.update_score(Global.score)
    $Player.start()
    $Player.set_position(Vector2(512,200))
    $HUD.show_message("Приготовиться!")
    yield($HUD/MessageTimer,"timeout")
    Global.playing = true
    new_level()

func new_level():
    $LevelupSound.play()
    level += 1
    if level > 1:
        show_ads()
    
    
    if Global.score>Global.record:
        Global.data_save(Global.score)
        
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
    Global.score += size * 10
    $HUD.update_score(Global.score)
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
