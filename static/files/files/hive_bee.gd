extends Area2D


var SPEED = 200.0
var velocity2 = Vector2(1, 0)
var collecting = false
var go_back = false
var parent_pos
var tween
var base_scale = Vector2(1, 1)
var range_scale = Vector2(0.1, 2)
var dir = 1
func _ready():
	randomize()
	
	var x = position
	var y = ((global_position.y) * 100 / 684) * 0.01
	if y > range_scale.x and y < range_scale.y:
		base_scale = Vector2(abs(y), abs(y))
	SPEED = randi_range(300, 800)
	var pos = -(global_position - Vector2(768 / 2, 1366 / 2)).normalized()
	velocity2 = pos * SPEED
	scale = base_scale
	if pos.x < 0:
		scale = base_scale
	else:
		scale.x = base_scale.x * -1
		dir = -1
func length(Vector:Vector2):
	return sqrt(pow(Vector.x, 2) + pow(Vector.y, 2))
func collect():
	$AnimationPlayer.play("move")
	collecting = true
	await get_tree().create_timer(5).timeout
	collecting = false
	go_back = true
	tween.kill()
	rotation = 0
	if parent_pos.x - global_position.x > 0:
		dir = -1
	else:
		dir = 1
	$AnimationPlayer.play("fly")
	scale.x = base_scale.x * dir
	scale.y = abs(base_scale.y)
	await get_tree().create_timer(0.5).timeout
	var t = get_tree().create_tween()
	t.tween_property(self, "position", parent_pos, (length(parent_pos - global_position) * 100 / SPEED) * 0.01)
	
func _process(delta):
	var y = ((global_position.y) * 100 / 684) * 0.01
	
	if y > range_scale.x and y < range_scale.y:
		base_scale = Vector2(abs(y), abs(y))
	if !collecting:
		rotation = 0
		if !go_back:
			position += velocity2 * delta
			if randi_range(1, 300) == 1:
				velocity2.y *= -1
			if randi_range(1, 300) == 1:
				velocity2.x *= -1
				dir *= -1
		scale.x = base_scale.x * dir
		scale.y = abs(base_scale.y)
	else:
		if randi_range(1, 30) == 1:
			tween = get_tree().create_tween()
			tween.tween_property(self, "rotation", randf_range(0, PI * 2), 1.0)
			
			

func _on_visible_on_screen_notifier_2d_screen_exited():
	queue_free()
