extends Sprite2D


var regions = [Rect2(223.079, 187.587, 147.874, 149.338), Rect2(625.675, 173.096, 172.13, 167.414), Rect2(617.07,173.202,186.278,172.13), Rect2(881.16,151.981,240.511,221.647), Rect2(1185.335,83.6,320.681,313.607), Rect2(1602.692,60.021,358.408,379.63), Rect2(1600.334,545.758,403.209,405.567), Rect2(1069.796,498.599,478.664,457.442), Rect2(534.541,498.599,516.391,478.664), Rect2(0,425.503,525.823,570.623)]
var regions2 = [Rect2(287.477,631.458,185.78,187.655), Rect2(558.48,348.907,258.648,285.221), Rect2(550.751,6.573,286.993,283.45), Rect2(31.028,23.328,269.277,278.135), Rect2(41.657,347.524,256.876,278.135)]
var x = 0
func _ready():
	randomize()
	var r = randi_range(0, 1)
	var region
	var coldown = 0.06
	
	texture = preload("res://sprite/explosion2.png")
	region = regions2
	coldown = 0.13
	scale = Vector2(1, 1) * randf_range(0.1, 1)
	position = Vector2(randi_range(0, 768), randi_range(0, 1366))
	while region.size() > x:
		region_rect = region[x%region.size()]
		x += 1
		await get_tree().create_timer(coldown).timeout
	queue_free()
