extends Node2D


var velocity = Vector2(1, 1)
var speed = 600
func _ready():
	$VisibleOnScreenNotifier2D.screen_exited.connect(_on_visible_on_screen_notifier_2d_screen_exited)
	randomize()
	var r = randi_range(1, 4)
	var x = Vector2(0, 0)
	match r:
		1:
			x = Vector2(0, randi_range(0, 2000))
		2:
			x = Vector2(1000, randi_range(0, 2000))
		3:
			x = Vector2(randi_range(0, 1000), 0)
		4:
			x = Vector2(randi_range(0, 1000), 2000)
	position = x
	scale *= randf_range(0.5, 1.3)
	speed = randi_range(300, 800)
	var pos = (position - Vector2(500,  1000)).normalized()
	velocity = -pos * speed

	if pos.x < 0:
		scale.x *= -1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity * delta
	if randi_range(1, 300) == 1:
		velocity.y *= -1
	if randi_range(1, 300) == 1:
		velocity.x *= -1
		scale.x *= -1


func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
	
