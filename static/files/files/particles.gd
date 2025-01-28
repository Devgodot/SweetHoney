extends Control
@export var position_r : Rect2
var _size = Vector2(30, 30)
@export var waite_time = 1
# Called when the node enters the scene tree for the first time.

func _ready():
	pass
func create_particles():
	
	var rigid = preload("res://scenes/flower.tscn").instantiate()
	
	rigid.position = Vector2(randi_range(position_r.position.x, position_r.position.x + position_r.size.x), randi_range(position_r.position.y, position_r.position.y + position_r.size.y))
	add_child(rigid)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if randi() % waite_time == 0:
		create_particles()
	
