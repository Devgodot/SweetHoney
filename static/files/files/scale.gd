extends Button

func _ready():
	size.x = get_child(0).size.x * 2.58
	size.y = size.x / 2.75
	scale = (custom_minimum_size * 100 / size) * 0.01
	if scale.x < 0.5:
		scale = Vector2.ONE * 0.5
		size = Vector2(1400, 500)
		$Label.autowrap_mode = 3
		$Label.custom_minimum_size.x = 466
	$PointLight2D.scale /= scale
	$PointLight2D.position = (size / 2)
