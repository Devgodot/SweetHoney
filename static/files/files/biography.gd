extends Node2D
var obj
var offset = 0
var show_pic = false
# Called when the node enters the scene tree for the first time.
func _ready():
	var size_x = $TextureRect.size.x / 10
	var size_y = $TextureRect.size.y / 10
	
	for x in range(size_x / 4):
		for y in range(size_y / 4):
			var rect = ColorRect.new()
			var material_r = ShaderMaterial.new()
			material_r.shader = preload("res://shaders/kill.tres")
			rect.material = material_r
			
			rect.color = Color.BLACK
			rect.size = Vector2(size_x, size_y)
			rect.position = Vector2(size_x * x, size_y * y)
			rect.add_to_group("hiden_pic")
			$TextureRect.add_child(rect)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if get_tree().has_group("hiden_pic"):
		if !show_pic:
			if offset == 0:
				obj = get_tree().get_nodes_in_group("hiden_pic")[randi_range(0, get_tree().get_nodes_in_group("hiden_pic").size() - 1)]
			if obj:
				offset += 1 * delta
				obj.material.set_shader_parameter("offset", offset)
				if offset >= 1.6:
					
					obj.queue_free()
					obj = null
					offset = 0
		else:
			offset += 1 * delta
			for j in get_tree().get_nodes_in_group("hiden_pic"):
				j.material.set_shader_parameter("offset", offset)
				if offset >= 1.6:
					j.queue_free()
		
