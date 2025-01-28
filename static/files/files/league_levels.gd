extends Control


var save_path = "user://data.cfg"
var part = 4
var max_score = 0
var score = 0
var speed = 8000
var levels = []
# Called when the node enters the scene tree for the first time.
func _ready():
	randomize()
	#var request = HTTPRequest.new()
	#add_child(request)
	#request.timeout = 3
	#request.request(UpdateData.protocol+UpdateData.subdomin+"/download?filename=gifts.tscn", UpdateData.get_header())
	#var d = await request.request_completed
	#var file = FileAccess.open("user://gifts.tscn", FileAccess.WRITE)
	#file.store_buffer(d[3])
	#file.close()

	part = load_game("part_league", save_path, 0)
	var r = HTTPRequest.new()
	add_child(r)
	r.timeout = 3
	r.request(UpdateData.protocol+UpdateData.subdomin+"/auth/random_levels?part="+str(part), UpdateData.get_header())
	levels = UpdateData.get_json((await r.request_completed)[3])
	r.queue_free()
	max_score = levels.total_score
	add_level_btn2()
func save_tiles():
	var tile = $TileMap.get_used_cells(1)
	var file = FileAccess.open("res://files/league_levels_"+str(part)+".dat", FileAccess.WRITE)
	file.store_var(tile)
	file.close()
func load_tiles():
	$TileMap.clear_layer(1)
	var file = FileAccess.open("res://files/league_levels_"+str(part)+".dat", FileAccess.READ)
	var tiles = file.get_var()
	for pos in tiles:
		$TileMap.set_cell(1, pos, 0, Vector2i(0, 0), 0)
func _process(delta):
	
	if $TextureRect2/TextureRect.position.y < 280 and $TextureRect2/TextureRect.position.y > 170:
		$TextureRect3/TextureRect2.anchor_top = 0.46 - ((1 - (($TextureRect2/TextureRect.position.y - 170) * 100 / 90) * 0.01) * 0.35)
	else:
		if $TextureRect2/TextureRect.position.y >= 280:
			$TextureRect3/TextureRect2.anchor_top = 0.46
		if $TextureRect2/TextureRect.position.y <= 170:
			$TextureRect3/TextureRect2.anchor_top = 0.11
func _physics_process(delta):
	if get_tree().has_group("acceleration"):
		for btn in get_tree().get_nodes_in_group("acceleration"):
			var accelerometer_data = Input.get_accelerometer()
			var acceleration = Vector2(accelerometer_data.x, -accelerometer_data.y)
			var velocity = acceleration.normalized() * speed * delta
			btn.apply_impulse(velocity)
func save(_name, num, path):
	var confige = ConfigFile.new()
	confige.load(path)
	confige.set_value("user", _name, num)
	confige.save(path)
func load_game(_name, path, defaulte = null):
	var confige = ConfigFile.new()
	confige.load(path)
	return confige.get_value("user", _name, defaulte)
func choice_levels():
	var levels = load_game("levels_league_" + str(part + 1), "user://files.cfg", [])
	var levels2 = []
	var num = 20
	if levels.size() > 0:
		if typeof(levels[0]) != TYPE_ARRAY:
			if levels.size() > num:
				var list = choice_num(range(len(levels)), num)
				for x in list:
					levels2.append(levels[x])
			else:
				levels2 = levels
		else:
			var list = []
			for l in levels:
				if !l.is_empty():
					list.append(l)
			var r = num / list.size()
			var delta = num - (list.size() * r)
			var list2 = []
			for l in list:
				for lv in l:
					list2.append(lv)
			if list2.size() <= num:
				levels2 = list2
			else:
				for l in list:
					if l.size() <= r:
						for lv in l:
							levels2.append(lv)
					else:
						for x in range(r):
							var random = randi_range(0, l.size() - 1)
							levels2.append(l[random])
							l.erase(l[random])
				if levels2.size() < num:
					delta = num - levels2.size()
					list2 = []
					for l in list:
						for lv in l:
							if !levels2.has(lv):
								list2.append(lv)
					for x in range(delta):
						var random = randi_range(0, list2.size() - 1)
						levels2.append(list2[random])
						list2.erase(list2[random])
	if (levels2 != load_game("random_level" + str(part), "user://files.cfg", [])) or (typeof(load_game("state_levels"+ str(part), save_path, [1, 0])[0]) != TYPE_ARRAY):
		var list = []
		for x in range(len(levels2)):
			list.append([1, 0])
		save("state_levels" + str(part), list, save_path)
	save("random_level" + str(part), levels2, "user://files.cfg")
func choice_num(_range, num):
	randomize()
	var list = []
	for x in _range:
		list.append(x)
	var list2 = []
	for x in range(num):
		var z = randi_range(0, len(list) - 1)
		list2.append(list[z])
		list.remove_at(z)
	return list2

func add_level_btn():
	var levels = load_game("random_level" + str(part), "user://files.cfg", [])
	var tilemap = $TileMap.get_used_cells(1)

	for x in range(len(levels)):
		var btn = $Button2.duplicate()
		btn.text = str(x + 1)
		btn.show()
		btn.global_position = (tilemap[x] * Vector2i($TileMap.tile_set.tile_size.x * 0.75, $TileMap.tile_set.tile_size.y)) + ($TileMap.tile_set.tile_size / 2) - (Vector2i(btn.size) / 2) - Vector2i(0, ((tilemap[x].x % 2) - 1) * $TileMap.tile_set.tile_size.y / 2) 
		btn.pressed.connect(_on_level_btn_pressed.bind(x))
		if load_game("state_levels" + str(part), save_path, [1])[x] == 0:
			btn.disabled = true
		$levels.add_child(btn)
func add_level_btn2():

	for x in range(levels.level_data.size()):
		var btn = $RigidBody2D.duplicate()
		btn.get_node("Button").text = str(x + 1)
		btn.show()
		var material2 = ShaderMaterial.new()
		material2.shader = preload("res://shaders/kill.gdshader")
		btn.get_node("Button").material = material2
		btn.sleeping = false
		btn.freeze = false
		
		btn.get_node("Button").pressed.connect(_on_level_btn_pressed.bind(levels.level_data[x].id))
		$levels.add_child(btn)
		if levels.level_data[x].state != 0:
			btn.gravity_scale = 1
			btn.set_collision_layer_value(1, false)
			btn.set_collision_mask_value(1, false)
			btn.rotation = deg_to_rad(-30)
			btn.lock_rotation = true
			btn.get_node("Button").disabled = true
			btn.get_node("Area2D").area_entered.connect(on_honey_entered.bind(btn, levels.level_data[x].score))
			btn.global_position = Vector2(randi_range(110, 600), 1000)
		else:
			if x < $pins.get_children().size():
				btn.global_position = $pins.get_child(x).global_position
				btn.z_index = $pins.get_child(x).z_index
				var pin = PinJoint2D.new()
				pin.global_position=$pins.get_child(x).global_position
				pin.set_node_a(btn.get_path())
				pin.node_b = $pins.get_child(x).get_path()
				add_child(pin)
			btn.add_to_group("acceleration")
		
func on_honey_entered(Area, btn:RigidBody2D, _score):
	var x = 0
	btn.sleeping = true
	btn.gravity_scale = 0
	score += _score
	var s = preload("res://scenes/score.tscn").instantiate()
	s.global_position = btn.global_position
	if _score > 0:
		s.get_node("Label").text = "+" + str(_score)
		s.get_node("Label").add_theme_color_override("font_color", Color.GREEN)
	if _score < 0:
		$AnimationPlayer2.play("heat")
		s.get_node("Label").text = str(_score)
		s.get_node("Label").add_theme_color_override("font_color", Color.RED)
	if _score == 0:
		s.get_node("Label").text = str(_score)
		s.get_node("Label").add_theme_color_override("font_color", Color.BLACK)
	add_child(s)
	var tween = get_tree().create_tween()

	tween.tween_property($TextureRect2/TextureRect, "position:y", 640 - (((score * 100 / max_score) * 0.01) * 470), 1.2)
	tween.play()
	$Label.text = str(score) + " / " + str(max_score)
	btn.get_node("Button/CPUParticles2D").emitting = true
	while x <= 100:
		btn.get_node("Button/CPUParticles2D").position.y = 100 - x
		btn.get_node("Button/CPUParticles2D").position.x = 67 - (x * 0.01) * 30
		btn.get_node("Button").material.set_shader_parameter("frame", x)
		btn.get_node("Button").position.y = -60 + x
		x += 1
		await get_tree().create_timer(.001).timeout
	
	btn.queue_free()
	await s.get_node("AnimationPlayer").animation_finished
	s.queue_free()
func _on_level_btn_pressed(lv):
	save("league_level", lv, save_path)
	Exit.change_scene("res://scenes/league.tscn", true, 1)

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		Exit.change_scene("res://scenes/league_parts.tscn", true, 1)
func _on_button_pressed():
	Exit.change_scene("res://scenes/league_parts.tscn", true, 1)
