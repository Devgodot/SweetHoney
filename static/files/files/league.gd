extends Control
var target_word = []
var word
var text = ""
var true_answer = false
var answered = false
var drag = true
var level = 1
var error = 3
var unlock_level = 1
var max_size = 150
var data = {}
var words = []
var rotate_words = false
var back_rotate_words = false
var stop_rotate_words = false
var speed_rotate = 0
var save_path = "user://data.cfg"
var w_answer_list = []
var table_box = []
var score = 0
var part = 0
var collide = false
var table_word_r = []
var table_word_c = []
var menu_open = false
var max_level = 1
var ques_menu = false
var speed = 0
var back_speed = 0
var end_game = false
var answer_request = []
func update_score(num=0):
	score = load_game("score", 0)
	score += num
	save("score", score)
	$Label2.text = str(score)
func find_word(box, x, y):
	if data.state == 0:
		answer_request[x][y] = box.text
	
	box.get_child(0).emitting = true
func help(state, _score, id):
	randomize()
	var result = await UpdateData.purchase(id)
	if result:
		update_score()
		$PopupMenu.hide()
		if state == 0:
			var words2 = []
			if data.state == 0:
				for x in range(data.answers.size()):
					for y in range(data.answers[x].length()):
						words2.append(Vector2(x, y))
						for a in w_answer_list:
							if x == a.x and y == a.y:
								words2.erase(Vector2(x, y))
				if words2.size() > 0:
					var z = randi_range(0, words2.size() - 1)
					var x = words2[z].x
					var y = words2[z].y
					var hbox = get_tree().get_nodes_in_group("answer"+str(x))[0]
					hbox.get_child(y).get_child(0).text = data.answers[x][data.answers[x].length() - 1 - y]
					find_word(hbox.get_child(y).get_child(0), x, y)
					w_answer_list.append(Vector2(x, y))
				
			if data.state == 1:
				for box in table_box:
					words2.append(box)
					if get_tree().get_nodes_in_group("answer_"+str(box.x)+"_"+str(box.y))[0].text != "":
						words2.erase(box)
				if words2.size() > 0:
					var z = randi_range(0, len(words2) - 1)
					var x = words2[z].x
					var y = words2[z].y
					var box = get_tree().get_nodes_in_group("answer_"+str(x)+"_"+str(y))[0]
					box.text = data.data[x][y]
					find_word(box,x,y)
			if words2.size() == 1:
				$satan/AnimationPlayer.play("fall")
				$bee/AnimatedSprite2D.play("default")
				$bee/AnimationPlayer.play("true_answer")
				await get_tree().create_timer(1.5).timeout
				end(data.score)
		if state == 1:
			true_answer_animation()
			var words_list = []
			var words_r_list = []
			var words_c_list = []
			if data.state == 0:
				for x in range(data.answers.size()):
					var hbox = get_tree().get_nodes_in_group("answer"+str(x))[0]
					words_list.append(x)
					var a = true
					for box in hbox.get_children():
						if box.get_child(0).text == "":
							a = false
					if a:
						words_list.erase(x)
				if words_list.size() > 0:
					var z = randi_range(0, len(words_list) - 1)
					var x = words_list[z]
					var hbox = get_tree().get_nodes_in_group("answer"+str(x))[0]
					for y in range(hbox.get_children().size()):
						hbox.get_child(y).get_child(0).text = data.answers[x][data.answers[x].length() - 1 - y]
						find_word(hbox.get_child(y).get_child(0),x, y)
						w_answer_list.append(Vector2(x, y))
			if data.state == 1:
				
				for x in range(data.answers[0].size()):
					var boxs = get_tree().get_nodes_in_group("answer_r_"+str(x))
					var a = false
					words_r_list.append(x)
					for box in boxs:
						if box.text == "":
							a = true
					if !a:
						words_r_list.erase(x)
				for x in range(data.answers[1].size()):
					var boxs = get_tree().get_nodes_in_group("answer_c_"+str(x))
					words_c_list.append(x)
					var a = false
					for box in boxs:
						if box.text == "":
							a = true
					if !a:
						words_c_list.erase(x)
				if words_c_list.size() > 0 and words_r_list.size() > 0:
					var r = randi_range(0, 1)
					if r == 0:
						var z = randi_range(0, len(words_r_list) - 1)
						var x = words_r_list[z]
						var boxs = get_tree().get_nodes_in_group("answer_r_"+str(x))
						for y in range(boxs.size()):
							boxs[y].text = data.answers[0][data.answers[0].size() - x - 1][data.answers[0][data.answers[0].size() - x - 1].length() - y - 1]
							find_word(boxs[y], x, y)
							w_answer_list.append(Vector2(x, y))
					if r == 1:
						var z = randi_range(0, len(words_c_list) - 1)
						var x = words_c_list[z]
						var boxs = get_tree().get_nodes_in_group("answer_c_"+str(x))
						for y in range(boxs.size()):
							boxs[y].text = data.answers[1][x][y]
							find_word(boxs[y], x, y)
							w_answer_list.append(Vector2(x, y))
				elif words_c_list.size() > 0 and words_r_list.size() == 0:
					var z = randi_range(0, len(words_c_list) - 1)
					var x = words_c_list[z]
					var boxs = get_tree().get_nodes_in_group("answer_c_"+str(x))
					for y in range(boxs.size()):
						boxs[y].text = data.answers[1][x][y]
						find_word(boxs[y], x, y)
						w_answer_list.append(Vector2(x, y))
				elif words_r_list.size() > 0 and words_c_list.size() == 0:
					var z = randi_range(0, len(words_r_list) - 1)
					var x = words_r_list[z]
					var boxs = get_tree().get_nodes_in_group("answer_r_"+str(x))
					for y in range(boxs.size()):
						boxs[y].text = data.answers[0][data.answers[0].size() - x - 1][data.answers[0][data.answers[0].size() - x - 1].length() - y - 1]
						find_word(boxs[y], x, y)
						w_answer_list.append(Vector2(x, y))
			if words_list.size() == 1:
				$satan/AnimationPlayer.play("fall")
				$bee/AnimatedSprite2D.play("default")
				$bee/AnimationPlayer.play("true_answer")
				await get_tree().create_timer(1.5).timeout
				end(data.score)
			if (words_c_list.size() == 0 and words_r_list.size() == 1) or (words_c_list.size() == 1 and words_r_list.size() == 0):
				$satan/AnimationPlayer.play("fall")
				$bee/AnimatedSprite2D.play("default")
				$bee/AnimationPlayer.play("true_answer")
				await get_tree().create_timer(1.5).timeout
				end(data.score)
		if state == 2:
			speed = 0
			if data.state == 0:
				for x in range(data.answers.size()):
					var hbox = get_tree().get_nodes_in_group("answer"+str(x))[0]
					for y in range(hbox.get_children().size()):
						find_word(hbox.get_child(y).get_child(0), x, y)
						hbox.get_child(y).get_child(0).text = data.answers[x][data.answers[x].length() - 1 - y]
			if data.state == 1:
				for box in table_box:
					get_tree().get_nodes_in_group("answer_"+str(box.x)+"_"+str(box.y))[0].text = data.data[box.x][box.y]
					find_word(get_tree().get_nodes_in_group("answer_"+str(box.x)+"_"+str(box.y))[0], box.x, box.y)
			$satan/AnimationPlayer.play("fall")
			$bee/AnimatedSprite2D.play("default")
			$bee/AnimationPlayer.play("true_answer")
			await get_tree().create_timer(2).timeout
			end(data.score)
		if state == 4 or state == 9:
			true_answer_animation()
		if state == 3:
			var list = []
			for option in get_tree().get_nodes_in_group("options"):
				if option.get("metadata/num") != data.correct_answer - 1:
					list.append(option)
			for x in range(2):
				var y = randi_range(0, len(list) - 1)
				list[y].disabled = true
				list[y].add_theme_stylebox_override("disabled", preload("res://styles/test_btn_f.tres"))
				list.remove_at(y)
			$PopupMenu/MarginContainer/VBoxContainer.get_child(1).disabled = true
		if state == 5:
			test_button(data.correct_answer - 1)
		if state == 6:
			var list = []
			for option in get_tree().get_nodes_in_group("choice_option"):
				if !option.sellected and !option.show_state:
					if !option.correct:
						list.append(option)
			var y = randi_range(0, len(list) - 1)
			list[y].show_state = true
			list[y].get_node("Label").mouse_filter = MOUSE_FILTER_IGNORE
			list[y].get_node("Label").modulate = Color.RED
			list.remove_at(y)
			if list.size() == 0:
				$PopupMenu/MarginContainer/VBoxContainer.get_child(1).disabled = true
		if state == 7:
			var list = []
			for option in get_tree().get_nodes_in_group("choice_option"):
				if !option.sellected and !option.show_state:
					if option.correct:
						list.append(option)
			var y = randi_range(0, len(list) - 1)
			list[y].show_state = true
			list[y].get_node("Label").mouse_filter = MOUSE_FILTER_IGNORE
			list[y].get_node("Label").modulate = Color.GREEN
			list.remove_at(y)
			if list.size() == 0:
				$PopupMenu/MarginContainer/VBoxContainer.get_child(1).disabled = true
		if state == 8:
			var x = 0
			for option in get_tree().get_nodes_in_group("choice_option"):
				if option.sellected:
					x += 1
			for option in get_tree().get_nodes_in_group("choice_option"):
				if !option.sellected and !option.show_state and x < 3:
					if option.correct:
						x += 1
						option.show_state = true
						option.get_node("Label").mouse_filter = MOUSE_FILTER_IGNORE
						option.get_node("Label").modulate = Color.GREEN
						await get_tree().create_timer(0.2).timeout
			$PopupMenu/MarginContainer/VBoxContainer.get_child(2).disabled = true
		if state == 10:
			var list = []
			for option in get_tree().get_nodes_in_group("left_col"):
				if !option.checked:
					list.append(option)
			for option in list:
				if get_tree().get_nodes_in_group("right_col")[int(option.correct_sellect.split("_")[1])].checked:
					list.erase(option)
			var y = randi_range(0, len(list) - 1)
			if list[y].target:
				list[y].target.target = null
			list[y].match_options(int(data.answers[list[y].num].split("_")[1]), 1)
			list[y].add_theme_stylebox_override("normal", preload("res://styles/test_btn_t.tres"))
			var noise = NoiseTexture2D.new()
			noise.noise = list[y].get_node("Line2D").texture.noise
			noise.color_ramp = preload("res://styles/match_option_t.tres")
			list[y].get_node("Line2D").texture = noise
			list[y]._on_texture_button_pressed()
			list.remove_at(y)
			if list.size() == 0:
				$PopupMenu/MarginContainer/VBoxContainer.get_child(1).disabled = true
		if state == 11:
			var list = []
			var list2 = []
			for option in get_tree().get_nodes_in_group("left_col"):
				if !option.checked:
					list.append(option)
			for option in get_tree().get_nodes_in_group("left_col"):
				if option.checked:
					list2.append(option)
			for option in list:
				if option.target:
					option.target.target = null
				option.match_options(int(data.answers[option.num].split("_")[1]), 1)
				option.add_theme_stylebox_override("normal", preload("res://styles/test_btn_t.tres"))
				var noise = NoiseTexture2D.new()
				noise.noise = option.get_node("Line2D").texture.noise
				noise.color_ramp = preload("res://styles/match_option_t.tres")
				option.get_node("Line2D").texture = noise
				option._on_texture_button_pressed()
			for option in list2:
				if option.target:
					option.target.target = null
				option.match_options(int(data.answers[option.num].split("_")[1]))
				option.add_theme_stylebox_override("normal", preload("res://styles/test_btn_f.tres"))
				var noise = NoiseTexture2D.new()
				noise.noise = option.get_node("Line2D").texture.noise
				noise.color_ramp = preload("res://styles/match_option_f.tres")
				option.get_node("Line2D").texture = noise
				option._on_texture_button_pressed()
		if state == 12:
			var first_n = get_tree().get_nodes_in_group("first_name")
			var last_n = get_tree().get_nodes_in_group("last_name")
			var w
			var array = []
			var array2 = []
			for child in first_n:
				if child.text == "":
					array.append(child)
			for child in last_n:
				if child.text == "":
					array.append(child)
			for child in array:
				array2.append(child.get_meta("text"))
			w = array2[randi_range(0, array2.size() - 1)]
			for child in array:
				if child.get_meta("text") == w:
					child.text = w
			for child in $GridContainer.get_children():
				if child.text == w:
					child.disabled = true
		if state == 13:
			$biography.show_pic = true
			$biography.offset = 0
			$PopupMenu/MarginContainer/VBoxContainer.get_child(2).disabled = true
		
	else:
		$AnimationPlayer.play("score")
	
	

func save(_name, num):
	UpdateData.save(_name, num)
func load_game(_name, defaulte = null):
	return UpdateData.load_game(_name, defaulte)
func load_game2(_name, defaulte = null):
	var confige = ConfigFile.new()
	confige.load("user://files.cfg")
	return confige.get_value("user", _name, defaulte)
func _ready():
	
	set_process(false)
	$bee/AnimationPlayer.get_animation("true_answer").set_loop_mode(1)
	update_score()
	part = load_game("part_league", 0)
	level = load_game("league_level", 0)
	data = await UpdateData.load_level_by_id(level, part)
	if data.state == 0:
		var ans = data.answers
		var list = []
		for t in ans:
			list.append(t.length())
		var list2 = []
		var _size = list.size()
		for t in range(_size):
			list2.append(list.min())
			list.erase(list.min())
		var list3 = []
		for l in list2:
			for t in ans:
				if t.length() == l:
					list3.append(t)
					ans.erase(t)
					break
		var list4 = []
		var r = list2.size()
		if list2.size() > 6:
			r = (list2.size() / 2) + (list2.size() % 2)
			
		for l in range(r):
			if list2.size() > l + r:
				list4.append(list2[l] + list2[l + r])
		if list2.size() >= 5:
			max_size = 120
		elif  list2.size() > 6:
			max_size = ((8 - list4.max()) * 5) + 120
		data.answers = list3
		var vgrid = VGrid.new()
		vgrid.add_theme_constant_override("separation", 50)
		vgrid.layout_direction = Control.LAYOUT_DIRECTION_RTL
		vgrid.rows = r
	match part:
		0:
			$TextureRect2.texture = preload("res://sprite/Untitled56-4.png")
			$AnimationPlayer3.play("state1")
			
		1:
			$AnimationPlayer3.play("state1")
			$TextureRect2.texture = preload("res://sprite/Untitled56-4.png")
			
		2:
			$AnimationPlayer3.play("state2")
			$AnimationPlayer2.play("question")
			$TextureRect2.texture = preload("res://sprite/Untitled8-1.png")
		3:
			$AnimationPlayer3.play("state4")
			$AnimationPlayer2.play("question")
			$TileMap.show()
		4:
			$TextureRect2.texture = preload("res://sprite/vasl.png")
			$AnimationPlayer3.play("state3")
			$AnimationPlayer2.play("question")

	speed = ($satan.global_position.x - ($bee.global_position.x - 125)) / data.time
	$TextureRect3/Line2D.position = -$TextureRect3.global_position
	if data.state == 0:
		for x in range(data.answers.size()):
			var list = await add_answer(data.answers[x].length(), x)
			answer_request.append(list)
	elif data.state >= 1:
		add_answer(1, 0)
	if data.state <= 1:
		for x in range(data.words.size()):
			add_words(data.words[x], (360 / data.words.size()) * x)
		words = data.words
		if words.size() < 20:
			$TextureRect3/Line2D.width = 30 - words.size()
		else:
			$TextureRect3/Line2D.width = 2
	var quess = data.ques.split("؟")
	
	for x in range(quess.size()-1):
		$Node2D/Panel/PersianLabel.text += str(x+1) + "_" + quess[x] + "؟" + "\n"
	
	if quess.size() == 1 and part >= 2 and part != 5:
		$Node2D/Control/Label.show()
		$AnimationPlayer2.play("hide")
		$Node2D/Control/Label.text = data.ques
	
	set_process(true)
	
func add_words(_name, degross):
	var label = preload("res://scenes/Label.tscn").instantiate()
	var node = Node2D.new()
	label.size2 = 80 - (words.size() * 2)
	label.size = Vector2(.7 * label.size2, label.size2 + 1)
	label.text = _name
	
	label.mouse_hover.connect(_on_Label_mouse_hover)
	label.mouse_exit.connect(_on_Label_mouse_exit)
	label.position = -label.size / 2
	node.add_child(label)
	var pivot = Vector2(0, .5).rotated(deg_to_rad(degross))
	var size2 = ($TextureRect3.size / 2)
	node.position = -(pivot * size2)

	$TextureRect3/words.add_child(node)
func add_answer(num, count):
	var l = []
	var q = []
	if data.state == 0:
		$VBoxContainer/ScrollContainer/GridBoxContainer.columns = 1
		$VBoxContainer/ScrollContainer/GridBoxContainer.add_theme_constant_override("h_separation", 180)
		$VBoxContainer/ScrollContainer/GridBoxContainer.add_theme_constant_override("v_separation", 90)
		var hbox = HBoxContainer.new()
		var list = []
		for x in range(num):
			list.append("")
			var c = Control.new()
			var box = preload("res://scenes/box_word2.tscn").instantiate()
			box.custom_minimum_size = Vector2.ONE * max_size
			box.label_settings.font_size = 60 * (max_size / 100.0)
			box.get_child(0).position = Vector2(max_size / 2, max_size)
			c.add_child(box)
			hbox.add_child(c)
			
		hbox.add_theme_constant_override("separation", 80)
		hbox.add_to_group("answer"+str(count))
		$VBoxContainer/ScrollContainer/GridBoxContainer.add_child(hbox)
		if count == data.answers.size() - 1:
			$VBoxContainer/ScrollContainer/GridBoxContainer.add_child(Control.new())
		return list
	elif data.state == 1:
		$VBoxContainer/ScrollContainer/GridBoxContainer.layout_direction = LAYOUT_DIRECTION_LTR
		$VBoxContainer/ScrollContainer.layout_direction = LAYOUT_DIRECTION_LTR
		$VBoxContainer/ScrollContainer/GridBoxContainer.columns = data.data.size() + 1
		max_size = ((8 - data.data.size()) * 5) + 120
		$VBoxContainer/ScrollContainer/GridBoxContainer.add_theme_constant_override("v_separation" , 0)
		$VBoxContainer/ScrollContainer/GridBoxContainer.add_theme_constant_override("h_separation" , 0)
		for x in range(data.data.size()):
			var list = []
			for y in range(data.data[x].size()):
				list.append("")
				var control = Control.new()
				var box = preload("res://scenes/box_word2.tscn").instantiate()
				box.custom_minimum_size = Vector2.ONE * max_size
				box.label_settings.font_size = 60 * (max_size / 100.0)
				box.get_child(0).position = Vector2(max_size / 2, max_size)
				control.custom_minimum_size = box.custom_minimum_size
				for c in range(data.answers[2].size()):
					if x == 0 and y == 0 and "_00_" in data.answers[2][c]:
						box.add_to_group("answer_c_"+str(c))
						l.append([Vector2(x, y), c])
					elif ("_" + str(y + (x * data.data[x].size())) + "_") in data.answers[2][c]:
						l.append([Vector2(x, y), c])
						box.add_to_group("answer_c_"+str(c))
				for r in range(data.answers[3].size()):
					if x == 0 and y == 0 and "_00_" in data.answers[3][r]:
						box.add_to_group("answer_r_"+str(r))
						q.append([Vector2(x, y), r])
					elif ("_" + str(y + (x * data.data[x].size())) + "_") in data.answers[3][r]:
						box.add_to_group("answer_r_"+str(r))
						q.append([Vector2(x, y), r])
				if data.data[x][y] != " ":
					control.add_child(box)
					table_box.append(Vector2(x, y))
					box.add_to_group("answer_"+str(x)+"_"+str(y))
				$VBoxContainer/ScrollContainer/GridBoxContainer.add_child(control)
				if y == data.data[x].size() - 1:
					$VBoxContainer/ScrollContainer/GridBoxContainer.add_child(Control.new())
			answer_request.append(list)
		for y in range(data.answers[3].size()):
			var z = []
			for x in range(q.size()):
				if q[x][1] == y:
					z.append(q[x][0])
			table_word_r.append(z)
		for y in range(data.answers[2].size()):
			var z = []
			for x in range(l.size()):
				if l[x][1] == y:
					z.append(l[x][0])
			table_word_c.append(z)
			
	elif data.state == 2:
		$VBoxContainer/ScrollContainer/GridBoxContainer.layout_direction = LAYOUT_DIRECTION_LTR
		$VBoxContainer/ScrollContainer.layout_direction = LAYOUT_DIRECTION_LTR
		$VBoxContainer/ScrollContainer/GridBoxContainer.columns = 2
		$VBoxContainer/ScrollContainer.clip_contents = false
		$VBoxContainer/ScrollContainer/GridBoxContainer.size_flags_horizontal = SIZE_EXPAND_FILL
		$VBoxContainer/ScrollContainer/GridBoxContainer.add_theme_constant_override("v_separation" ,20)
		$VBoxContainer/ScrollContainer/GridBoxContainer.add_theme_constant_override("h_separation" , 450)
		var number_option = ["الف", "ب", "ج", "د"]
		for x in range(data.options.size()):
			var control = Control.new()
			var option = preload("res://scenes/option.tscn").instantiate()
			option.set("metadata/num", x)
			option.pressed.connect(test_button.bind(option.get("metadata/num")))
			option.get_child(0).text = number_option[x % len(number_option)] + ")  " + data.options[x]
			control.add_child(option)
			control.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			control.custom_minimum_size = option.custom_minimum_size
			$VBoxContainer/ScrollContainer/GridBoxContainer.add_child(control)
	elif data.state == 3:
		
		for x in range(data.options.size()):
			var option = preload("res://scenes/choice_option.tscn").instantiate()
			option.get_node("Label").text = data.options[x][0]
			option.get_child(0).correct = data.options[x][1]
			option.position = (Vector2(0, 1).rotated(deg_to_rad(x * (360 / data.options.size()))) * 250) - option.size / 2
			$options.add_child(option)
	elif data.state == 4:
		$VBoxContainer/ScrollContainer/GridBoxContainer.layout_direction = LAYOUT_DIRECTION_LTR
		$VBoxContainer/ScrollContainer/GridBoxContainer.size_flags_vertical = SIZE_EXPAND_FILL
		$VBoxContainer/ScrollContainer.layout_direction = LAYOUT_DIRECTION_LTR
		$VBoxContainer/ScrollContainer/GridBoxContainer.columns = 1
		$VBoxContainer/ScrollContainer.clip_contents = false
		$VBoxContainer/ScrollContainer/GridBoxContainer.size_flags_horizontal = SIZE_EXPAND_FILL
		$VBoxContainer/ScrollContainer/GridBoxContainer.add_theme_constant_override("v_separation" , 120)
		
		for x in range(data.options.size() / 2):
			var hbox = HBoxContainer.new()
			var control = Control.new()
			hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var option = preload("res://scenes/match_option2.tscn").instantiate()
			option.correct_sellect = data.answers[x]
			option.text = data.options[x * 2]
			option.dir = 1
			option.num = x
			option.add_to_group("left_col")
			control.add_child(option)
			var option2 = preload("res://scenes/match_option2.tscn").instantiate()
			var control2 = Control.new()
			for answer in data.answers:
				if int(answer.split("_")[1]) == x:
					option2.correct_sellect = answer
			option2.text = data.options[(x * 2) + 1]
			option2.dir = -1
			option2.num = x
			option2.add_to_group("right_col")
			control2.add_child(option2)
			hbox.add_theme_constant_override("separation", 500)
			hbox.add_child(control)
			hbox.add_child(control2)
			$VBoxContainer/ScrollContainer/GridBoxContainer.add_child(hbox)
		
		for option in get_tree().get_nodes_in_group("match_option"):
			option.start()
	elif data.state == 5:
		
		for child in $GridContainer.get_children():
			child.pressed.connect(word_btn_pressed.bind(child))
		var split_name = data.first_n.split()
		var split_name2 = data.last_n.split()
		
		$GridContainer2/box_word.set_meta("text", split_name[0])
		for x in range(split_name.size() - 1):
			var box = $GridContainer2/box_word.duplicate()
			box.add_to_group("first_name")
			box.set_meta("text", split_name[x+1])
			$GridContainer2.add_child(box)
		$GridContainer2.add_child(Control.new())
		for x in range(split_name2.size()):
			var box = $GridContainer2/box_word.duplicate()
			box.add_to_group("last_name")
			box.set_meta("text", split_name2[x])
			$GridContainer2.add_child(box)
		$GridContainer2/box_word.add_to_group("first_name")
		var http = HTTPRequest.new()
		add_child(http)
		http.request(data.img_refrence)
		var d = await http.request_completed
		http.queue_free()
		var image = Image.new()
		image.load_png_from_buffer(d[3])
		$biography.mode = 0
		$biography.offset = 0
		$biography/TextureRect.texture = ImageTexture.create_from_image(image)
		$biography/RichTextLabel.text = "[right]" + data.ques
func word_btn_pressed(btn):
	btn.disabled = true
	var w = ""
	if get_tree().has_group("first_name") and get_tree().has_group("last_name"):
		var f = get_tree().get_nodes_in_group("first_name")
		var l = get_tree().get_nodes_in_group("last_name")
		for x in range(f.size()):
			if f[x].get_meta("text") == btn.text:
				f[x].text = btn.text
				w = f[x].text
		for x in range(l.size()):
			if l[x].get_meta("text") == btn.text:
				l[x].text = btn.text
				w = l[x].text
	if w == "":
		error -= 1
		$biography/Label.text = "خطا : " + str(data.error) + " / " + str(data.error - error)
		btn.add_theme_stylebox_override("disabled", preload("res://styles/word_btn_f.tres"))
func test_button(_num):
	speed = 0
	answer_request = _num + 1
	for option in get_tree().get_nodes_in_group("options"):
		option.disabled = true
	if _num == data.correct_answer -1:
		$satan/AnimationPlayer.play("fall")
		$bee/AnimatedSprite2D.play("default")
		$bee/AnimationPlayer.play("true_answer")
		get_tree().get_nodes_in_group("options")[_num].add_theme_stylebox_override("disabled", preload("res://styles/test_btn_t.tres"))
	else:
		data.score = 0
		get_tree().get_nodes_in_group("options")[_num].add_theme_stylebox_override("disabled", preload("res://styles/test_btn_f.tres"))
		get_tree().get_nodes_in_group("options")[data.correct_answer - 1].add_theme_stylebox_override("disabled", preload("res://styles/test_btn_t.tres"))
		$satan/AnimationPlayer.play("shot")
		await $satan/AnimationPlayer.animation_finished
		$satan/AnimationPlayer.play("happing")
	await get_tree().create_timer(2).timeout
	end(data.score)
func end(_score):
	
	end_game = true
	set_process(false)
	var aninm = AnimationPlayer.new()
	var animation = Animation.new()
	for child in get_children():
		if child.name != "Label" and child.name != "TextureRect2" and child.name != "TileMap" and child.name != "CanvasLayer" and not child is AnimationPlayer and not child is PopupPanel and not child is HTTPRequest:
			var track = animation.add_track(Animation.TYPE_VALUE)
			animation.track_set_path(track, child.name + ":modulate:a")
			animation.track_insert_key(track, 0, 1.0)
			animation.track_insert_key(track, 1, 0.0)
	var l = AnimationLibrary.new()
	l.add_animation("hide", animation)
	aninm.add_animation_library("", l)
	add_child(aninm)
	aninm.play("hide")
	$Label.text = "امتیاز شما:" + str(_score)
	var _score2 = int(load_game("league_score", 0)) + _score
	var http = HTTPRequest.new()
	add_child(http)
	http.request(UpdateData.protocol+UpdateData.subdomin+"/auth/AnswerLeague", ["Content-Type: application/json", "Authorization: Bearer %s"%UpdateData.token], HTTPClient.METHOD_POST, JSON.stringify({"data":answer_request, "id":level, "part":part}))
	var d = await http.request_completed
	UpdateData.save("league_score", UpdateData.get_json(d[3]).score, false)
	http.queue_free()
	$AnimationPlayer4.play("end")
	await get_tree().create_timer(2).timeout
	Exit.change_scene("res://scenes/league_parts.tscn", true, 1)
func change_words_pos():
	var list = []
	var words2 = data.words
	randomize()
	for y in range(words2.size()):
		var x = randi_range(0, words2.size() - 1)
		list.append(words2[x])
		words2.remove_at(x)
	data.words = list
	for child in $TextureRect3/words.get_children():
		child.queue_free()
	for x in range(data.words.size()):
		add_words(data.words[x], (360 / data.words.size()) * x)
var a = 1 
func _process(delta):
	$PersianButton2.disabled = $PopupMenu.visible
	$satan.position.x -= speed * delta
	if $satan/body/polygons/spear2.visible:
		var spear = $satan/body/polygons/spear2
		var velocity = (-$satan.global_position + $bee.global_position).normalized()
		spear.rotation = Vector2(1, 0).rotated(velocity.angle()).angle()
		if collide:
			a -= 2 * delta
			if spear.modulate.a > 0:
				spear.modulate = Color(1, 1, 1, a)
			else:
				spear.visible = false
		else:
			spear.position += velocity * 3000 * delta
	if get_tree().has_group("choice_option"):
		var _end_game = 0
		var _end_game2 = true
		for option in get_tree().get_nodes_in_group("choice_option"):
			if option.sellected:
				_end_game += 1
			else:
				if option.correct:
					_end_game2 = false
		if !end_game and (_end_game >= 3 or _end_game2):
			_on_area_2d_area_entered()
			
	if get_tree().has_group("match_option"):
		var _end_game = true
		for option in get_tree().get_nodes_in_group("match_option"):
			if !option.checked:
				_end_game = false
		if !end_game and _end_game:
			_on_area_2d_area_entered()
	if get_tree().has_group("first_name"):
		var end_game = true
		var first_n = get_tree().get_nodes_in_group("first_name")
		var last_n = get_tree().get_nodes_in_group("last_name")
		for child in first_n:
			if child.text == "":
				end_game = false
		for child in last_n:
			if child.text == "":
				end_game = false
		if error <= 0 or end_game:
			_on_area_2d_area_entered()
			
			
	
	if rotate_words:
		speed_rotate += 10 * delta
		$TextureRect3/words.rotate(deg_to_rad(speed_rotate))
		if speed_rotate >= 10:
			back_rotate_words = true
			rotate_words = false
			change_words_pos()
	if back_rotate_words:
		speed_rotate -= 10 * delta
		$TextureRect3/words.rotate(deg_to_rad(speed_rotate))
		if speed_rotate <= 1:
			speed_rotate = 0
			if $TextureRect3/words.rotation != 0:
				stop_rotate_words = true
			back_rotate_words = false
	if stop_rotate_words:
		
		if int(rad_to_deg($TextureRect3/words.rotation)) % 360 != 0:
			if int(rad_to_deg($TextureRect3/words.rotation)) % 360 != 180:
				$TextureRect3/words.rotate(deg_to_rad(-(180 - (int(rad_to_deg($TextureRect3/words.rotation)) % 360)) / abs(180 - (int(rad_to_deg($TextureRect3/words.rotation)) % 360))))
			else:
				$TextureRect3/words.rotate(deg_to_rad(1))
		else:
			$TextureRect3/words.rotation = 0
			stop_rotate_words = false
			drag = true
	
	if !end_game:
		if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
			if drag:
				answered = false
				$label_pos/Label.add_theme_stylebox_override("normal", preload("res://styles/word_label_n3.tres"))
				if word:
					if !target_word.has(word):
						target_word.append(word)
				$TextureRect3/Line2D.points = []
				for words2 in target_word:
					$TextureRect3/Line2D.add_point(words2.global_position + words2.size / 2)
				$TextureRect3/Line2D.add_point(get_global_mouse_position())
				if $TextureRect3/Line2D.points.size() > 0:
					$TextureRect3/Line2D.set_point_position(len($TextureRect3/Line2D.points) - 1, get_global_mouse_position())
				text = ""
				for words2 in target_word:
					text += words2.text
				$label_pos/Label.text = text
		else:
			var next_level = true
			if data.state == 0:
				for x in range(data.answers.size()):
					var hbox = get_tree().get_nodes_in_group("answer"+str(x))[0]
					if text == data.answers[x]:
						for y in range(hbox.get_children().size()):
							if hbox.get_child(y).get_child(0).text == "":
								true_answer = true
								hbox.get_child(y).get_child(0).text = data.answers[x][data.answers[x].length() - 1 - y]
								w_answer_list.append(Vector2(x, y))
								find_word(hbox.get_child(y).get_child(0), x, y)
							else:
								answered = true
					for y in range(hbox.get_children().size()):
						if hbox.get_child(y).get_child(0).text == "":
							next_level = false
			if data.state == 1:
				for x in range(data.answers[0].size()):
					var boxs = get_tree().get_nodes_in_group("answer_r_"+str(x))
					if text == data.answers[0][data.answers[0].size() - x - 1]:
						for y in range(boxs.size()):
							if boxs[y].text == "":
								true_answer = true
								boxs[y].text = data.answers[0][data.answers[0].size() - x - 1][data.answers[0][data.answers[0].size() - x - 1].length() - y - 1]
								find_word(boxs[y], x, y)
								w_answer_list.append(Vector2(x, y))
							else:
								answered = true
					for y in range(boxs.size()):
						if boxs[y].text == "":
							next_level = false
				for x in range(data.answers[1].size()):
					var boxs = get_tree().get_nodes_in_group("answer_c_"+str(x))
					if text == data.answers[1][x]:
						for y in range(boxs.size()):
							if boxs[y].text == "":
								true_answer = true
								boxs[y].text = data.answers[1][x][y]
								find_word(boxs[y], x, y)
								w_answer_list.append(Vector2(x, y))
							else:
								answered = true
					for y in range(boxs.size()):
						if boxs[y].text == "":
							next_level = false
			if text != "":
				drag = false
				if true_answer:
					true_answer_animation()
					$label_pos/Label.add_theme_stylebox_override("normal", preload("res://styles/word_label_t3.tres"))
				elif answered:
					$label_pos/Label.add_theme_stylebox_override("normal", preload("res://styles/word_label_b3.tres"))
				else:
					$label_pos/Label.add_theme_stylebox_override("normal", preload("res://styles/word_label_f3.tres"))
				target_word = []
				$TextureRect3/Line2D.points = []
				drag = true
				
				if next_level and !end_game:
					speed = 0
					$bee/AnimationPlayer.play("true_answer")
					$bee/AnimatedSprite2D.play("default")
					$satan/AnimationPlayer.play("fall")
					if data.state == 1:
						for box in table_box:
							answer_request[box.x][box.y] = get_tree().get_nodes_in_group("answer_"+str(box.x)+"_"+str(box.y))[0].text
					end(data.score)
	$label_pos.global_position.y = $TextureRect3.global_position.y - $label_pos/Label.size.y
	$label_pos.global_position.x = ($TextureRect3.global_position.x + $TextureRect3.size.x / 2) - $label_pos/Label.size.x / 2



func _on_Label_mouse_exit(object):
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		target_word.erase(object)
	word = null

func _on_Label_mouse_hover(object):
	if !target_word.has(object) and drag:
		target_word.append(object)
	


func _on_PersianButton_pressed():
	var m = preload("res://scenes/menu_levels.tscn").instantiate()
	
	get_tree().get_root().add_child(m)
	menu_open = false
	$CanvasLayer/Panel/AnimationPlayer.play("close")

func _on_PersianButton2_pressed():
	$PersianButton2.disabled = true
	$PopupMenu.popup()


func _on_TextureButton_pressed():
	if !rotate_words and !stop_rotate_words and !back_rotate_words:
		rotate_words = true
		drag = false


func _on_button_5_pressed():
	Exit.change_scene("res://scenes/start.tscn")


func true_answer_animation():
	var tween = get_tree().create_tween()
	tween.tween_property($satan, "position:x", -46, 1)
	$bee/AnimationPlayer.play("blowing")
	$bee/AnimatedSprite2D.play("blowing")
	await $bee/AnimationPlayer.animation_finished
	$bee/AnimatedSprite2D.play("default")
	$bee/AnimationPlayer.play("Idle")
	true_answer = false
	if !drag:
		text = ""
		$label_pos/Label.text = text
func _on_help_button_pressed(state, _score, id):
	help(state, _score, id)
	menu_open = false
	$CanvasLayer/Panel/AnimationPlayer.play("close")
	

func _on_texture_button_pressed():
	menu_open = false
	$CanvasLayer/Panel/AnimationPlayer.play("close")



func _on_button_pressed():
	if !ques_menu:
		$AnimationPlayer2.play("question")
		ques_menu = true
		$bee/AnimatedSprite2D.play("default")
	else:
		$AnimationPlayer2.play_backwards("question")
		await $AnimationPlayer2.animation_finished
		ques_menu = false
		
func _on_button_2_pressed():
	$AnimationPlayer2.play_backwards("question")
	ques_menu = false

func _on_gui_input(event):
	if event is InputEventScreenTouch:
		if menu_open:
			menu_open = false
			$CanvasLayer/Panel/AnimationPlayer.play("close")
		if ques_menu:
			$AnimationPlayer2.play_backwards("question")
			ques_menu = false
		




func _on_area_2d_area_entered(area=null):
	speed = 0
	var _score = 0
	$PersianButton2.disabled = true
	if !end_game:
		end_game = true
		if data.state == 0:
			for x in range(data.answers.size()):
				var hbox = get_tree().get_nodes_in_group("answer"+str(x))[0]
				for y in range(hbox.get_children().size()):
					find_word(hbox.get_child(y).get_child(0), x, y)
					if hbox.get_child(y).get_child(0).text == "":
						hbox.get_child(y).get_child(0).text = data.answers[x][data.answers[x].length() - 1 - y]
						hbox.get_child(y).get_child(0).label_settings = preload("res://styles/box_word_f.tres")
					else:
						_score += 1

		if data.state == 1:
			if data.state == 1:
				for box in table_box:
					answer_request[box.x][box.y] = get_tree().get_nodes_in_group("answer_"+str(box.x)+"_"+str(box.y))[0].text
			
			for box in table_box:
				if get_tree().get_nodes_in_group("answer_"+str(box.x)+"_"+str(box.y))[0].text == "":
					get_tree().get_nodes_in_group("answer_"+str(box.x)+"_"+str(box.y))[0].text = data.data[box.x][box.y]
					find_word(get_tree().get_nodes_in_group("answer_"+str(box.x)+"_"+str(box.y))[0], box.x, box.y)
					get_tree().get_nodes_in_group("answer_"+str(box.x)+"_"+str(box.y))[0].label_settings = preload("res://styles/box_word_f.tres")
				else:
					_score += 1

		if data.state == 2:
			for option in get_tree().get_nodes_in_group("options"):
				option.disabled = true
			get_tree().get_nodes_in_group("options")[data.correct_answer - 1].add_theme_stylebox_override("disabled", preload("res://styles/test_btn_t.tres"))
		if data.state == 3:
			var options = get_tree().get_nodes_in_group("choice_option")
			var list = []
			for x in range(options.size()):
				
				if options[x].correct:
					list.append(options[x])
			for x in range(options.size()):
				if !options[x].sellected:
					if options[x].correct:
						options[x].get_node("Label").modulate = Color.GREEN
					else:
						options[x].get_node("Label").modulate = Color.RED
				else:
					answer_request.append(data.options[x][0])
					if options[x].correct:
						_score += data.score
					else:
						_score -= data.score
		if data.state == 4:
			var options = get_tree().get_nodes_in_group("left_col")
			for x in range(options.size()):
				answer_request.append(options[x].sellect_num)
				options[x].mouse_filter = MOUSE_FILTER_IGNORE
				if options[x].sellect_num == data.answers[x]:
					_score += data.score
					options[x].add_theme_stylebox_override("normal", preload("res://styles/test_btn_t.tres"))
					var noise = NoiseTexture2D.new()
					noise.noise = options[x].get_node("Line2D").texture.noise
					noise.color_ramp = preload("res://styles/match_option_t.tres")
					options[x].get_node("Line2D").texture = noise
				else:
					if options[x].sellect_num != "":
						_score -= data.score
					options[x].match_options(int(data.answers[x].split("_")[1]))
					options[x].add_theme_stylebox_override("normal", preload("res://styles/test_btn_f.tres"))
					var noise = NoiseTexture2D.new()
					noise.noise = options[x].get_node("Line2D").texture.noise
					noise.color_ramp = preload("res://styles/match_option_f.tres")
					options[x].get_node("Line2D").texture = noise
			var options2 = get_tree().get_nodes_in_group("right_col")
			for x in range(options2.size()):
				options2[x]._on_texture_button_pressed()
		if data.state == 5:
			_score = data.score
			var first_n = get_tree().get_nodes_in_group("first_name")
			var last_n = get_tree().get_nodes_in_group("last_name")
			var last = []
			var first = []
			for child in first_n:
				first.append(child.text)
				if child.text == "":
					child.text = child.get_meta("text")
					if _score > 0:
						_score -= int(data.score / 5)
			
			for child in last_n:
				last.append(child.text)
				if child.text == "":
					child.text = child.get_meta("text")
					if _score > 0:
						_score -= int(data.score / 5)
			answer_request.append(first)
			answer_request.append(last)
			$biography.show_pic = true
			$biography.offset = 0
		if _score <= 0 or data.state <= 1:
			$satan/AnimationPlayer.play("shot")
			await $satan/AnimationPlayer.animation_finished
			$satan/AnimationPlayer.play("happing")
			await get_tree().create_timer(2).timeout
		else:
			$satan/AnimationPlayer.play("fall")
			$bee/AnimatedSprite2D.play("default")
			$bee/AnimationPlayer.play("true_answer")
			await get_tree().create_timer(2).timeout
		end(_score)



func _on_spear_2_area_entered(area):
	collide = true
	$bee/AnimatedSprite2D.play("fear")
	$bee/AnimationPlayer.play("death")
	

func _on_area_2d_2_area_entered(area):
	$bee/AnimatedSprite2D.play("fear")
	$bee/AnimationPlayer.play("fear")
	
func _on_area_2d_2_area_exited(area):
	$bee/AnimatedSprite2D.play("default")
	$bee/AnimatedSprite2D.frame = 2
	$bee/AnimationPlayer.play("Idle")



func _on_animation_player_3_animation_finished(anim_name):
	var helps = []
	for child in $CanvasLayer/Panel/VBoxContainer.get_children():
		if child.visible and child is Button:
			helps.append(child)
	for btn in helps:
		var b = btn.duplicate()
		b.add_to_group("purchase")
		b.custom_minimum_size.y = 150
		b.text += str(await UpdateData.get_cost(b.get_meta("name", "")))
		if btn.get("metadata/id") < 3:
			b.pressed.disconnect(Callable(self, "_on_help_button_pressed"))
		else:
			b.pressed.disconnect(Callable(self, "help"))
		
		b.pressed.connect(help.bind(btn.get("metadata/id"), int(btn.text), btn.get("metadata/name")))
		$PopupMenu/MarginContainer/VBoxContainer.add_child(b)
	
