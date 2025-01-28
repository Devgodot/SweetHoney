extends Node

var touch = true
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if randi_range(0, 100) == 1:
		get_tree().get_root().call_deferred("add_child", preload("res://scenes/bees.tscn").instantiate())
	
func _input(event):
	
	if event is InputEventScreenTouch and touch:
		touch = false
		get_tree().get_root().add_child(preload("res://scenes/drop.tscn").instantiate())
		if !touch:
			await get_tree().create_timer(0.5).timeout
			touch = true
