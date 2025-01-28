extends Node2D

var regions = [Rect2(251.892,468.825,109.965,104.501), Rect2(52.09,389.474,130.564,169.539), Rect2(270.346,38.705,130.564,196.821), Rect2(435.987,28.961,114.974,241.641), Rect2(667.885,299.833,103.282,270.872)]
# Called when the node enters the scene tree for the first time.
func _ready():
	position = get_global_mouse_position() 
	var x = 0
	var tween = get_tree().create_tween()
	tween.tween_property($Sprite2D, "position:y", 30, 0.5)
	while regions.size() > x:
		$Sprite2D.region_rect = regions[x%regions.size()]
		x += 1
		await get_tree().create_timer(0.10).timeout
	queue_free()
