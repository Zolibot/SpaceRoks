extends Area2D


export (int) var speed = 300
var velocity = Vector2()


func start(pos,dir):
    position = pos
    velocity = Vector2(speed,0).rotated(dir)
    rotation = dir

func _process(delta):
    position += velocity * delta


func _on_VisibilityNotifier2D_screen_exited():
    queue_free()


func _on_EnemyBullet_body_entered(body):
    if body.is_in_group("rocks"):
        body.explode()
    if body.name == 'Player':
        body.shield -= 15
    queue_free()


func _on_EnemyBullet_body_exited(body):
    pass # Replace with function body.
