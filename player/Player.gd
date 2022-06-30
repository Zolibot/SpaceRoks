extends RigidBody2D

signal shield_chenged
signal shoot
signal dead
signal lives_changed
var lives = 0 setget set_lives

export (int) var max_shield
export (float) var shield_regen

export (PackedScene) var Bullet
export (float) var fire_rate
export (int) var engine_power
export (int) var spin_power

enum {INIT,ALIVE,INVULNERABLE,DEAD}



var shield = 0 setget set_shield
var can_shoot = true
var screensize = Vector2()
var thrust = Vector2()
var rotation_dir = 0
var state = null




func _ready():
	$GunTimer.wait_time = fire_rate
	screensize = get_viewport().get_visible_rect().size
	change_state(INIT)

func set_shield(value):
	if value>max_shield:
		value = max_shield
	shield = value
	emit_signal("shield_chenged",shield/max_shield)
	if shield<=0:
		self.lives -= 1
	pass

func set_lives(value):
	self.shield = max_shield
	lives = value
	emit_signal("lives_changed",lives)

func start():
	self.shield = max_shield
	$Sprite.show()
	self.lives = 3
	change_state(ALIVE)

func change_state(new_stage):
	match new_stage:
		INIT:
			get_node("CollisionShape2D").call_deferred("set", "disabled", true)
			$Sprite.modulate.a = 0.5
		ALIVE:
			get_node("CollisionShape2D").call_deferred("set", "disabled", false)
			$Sprite.modulate.a = 1.0
		INVULNERABLE:
			get_node("CollisionShape2D").call_deferred("set", "disabled", true)
			$Sprite.modulate.a = 0.5
			$InvulnerabilityTimer.start()
		DEAD:
			get_node("CollisionShape2D").call_deferred("set", "disabled", true)
			$Sprite.hide()
			$EngineSound.stop()
			linear_velocity = Vector2(0,0)
			emit_signal("dead")
	state = new_stage

func get_input():
	$Exhaust.emitting = false
	thrust = Vector2()
	if state in [DEAD,INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = Vector2(engine_power,0)
		$Exhaust.emitting = true
		if not $EngineSound.playing:
			$EngineSound.play()
	else:
		$EngineSound.stop()
	rotation_dir = 0
	if Input.is_action_pressed("rotate_right"):
		rotation_dir += 1
	if Input.is_action_pressed("rotate_left"):
		rotation_dir -= 1
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()

func shoot():
	if state == INVULNERABLE:
		return
	emit_signal("shoot",Bullet,$Muzzle.global_position,rotation)
	can_shoot = false
	$LaserSound.play()
	$GunTimer.start()
	pass


func _process(delta):
	self.shield += shield_regen * delta
	get_input()

func _physics_process(delta):
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(spin_power * rotation_dir)

func _integrate_forces(physics_state):
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(spin_power * rotation_dir)
	var xform = physics_state.get_transform()
	if state == INIT:
		xform = Transform2D(0, screensize/2)
	if xform.origin.x > screensize.x:
		xform.origin.x = 0
	if xform.origin.x < 0:
		xform.origin.x = screensize.x
	if xform.origin.y > screensize.y:
		xform.origin.y = 0
	if xform.origin.y < 0:
		xform.origin.y = screensize.y
	physics_state.set_transform(xform)


func _on_GunTimer_timeout():
	can_shoot = true

func _on_InvulnerabilityTimer_timeout():
	change_state(ALIVE)

func _on_AnimationPlayer_animation_finished(anim_name):
	$Explosion.hide()


func _on_Player_body_entered(body):
	if state != DEAD:
		if body.is_in_group("rocks"):
			body.explode()
			$Explosion.show()
			$Explosion/AnimationPlayer.play("explosion")
			self.shield -= body.size * 25
			if lives <= 0:
				change_state(DEAD)
			else:
				change_state(INVULNERABLE)
