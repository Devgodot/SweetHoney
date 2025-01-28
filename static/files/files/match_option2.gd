extends Label

var drag = false
@export var dir = 1
var target
var num = 0
var sellect_num = ""
var correct_sellect = ""
var checked = false
# Called when the node enters the scene tree for the first time.
func _ready():
	if dir == 1:
		$TextureButton.position = Vector2(-$TextureButton.size.x, (size.y / 2) - ($TextureButton.size.x / 2))
	else:
		$TextureButton.position = Vector2(size.x, (size.y / 2) - ($TextureButton.size.x / 2))
	

func start():
	if get_tree().has_group("match_option"):
		for option in get_tree().get_nodes_in_group("match_option"):
			option.mouse_entered.connect(_on_mouse_entered.bind(option))
			option.mouse_exited.connect(_on_mouse_exited.bind(option))
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		drag = false
		if !target:
			$Line2D.points = []
			sellect_num = ""
			$TextureButton.hide()
		else:
			
			$TextureButton.show()
			target.target = self
			if dir == 1:
				sellect_num = str(num) + "_" + str(target.num)
				target.sellect_num = str(num) + "_" + str(target.num)
			else:
				sellect_num = str(target.num) + "_" + str(num)
				target.sellect_num = str(target.num) + "_" + str(num)
			if dir == 1:
				if $Line2D.points.size() > 0:
					var pos = target.global_position - global_position
					$Line2D.set_point_position(1, Vector2(pos.x , pos.y + (target.size.y / 2)))
			else:
				if $Line2D.points.size() > 0:
					var pos = target.global_position - Vector2(global_position.x - size.x, global_position.y)
					$Line2D.set_point_position(1, Vector2(pos.x , pos.y + (target.size.y / 2)))
	if checked:
		$TextureButton.hide()
		mouse_filter = Control.MOUSE_FILTER_IGNORE
func _on_gui_input(event):
	
	if event is InputEventMouseButton and event.is_pressed():
		drag = true
		$Line2D.points = []
		if target:
			target.get_child(0).points = []
			target.sellect_num = ""
			sellect_num = ""
			target.target = null
			target = null
			
			
	if event is InputEventMouseMotion and drag:
		if event.global_position.x < global_position.x + (size.x / 2):
			if $Line2D.points.size() == 0:
				$Line2D.add_point(Vector2(0, (size.y / 2)))
				$Line2D.add_point(event.position)
			else:
				$Line2D.set_point_position(0, Vector2(0, (size.y / 2)))
				$Line2D.set_point_position(1, event.position)
		else:
			if $Line2D.points.size() == 0:
				$Line2D.add_point(Vector2(size.x, (size.y / 2)))
				$Line2D.add_point(event.position)
			else:
				$Line2D.set_point_position(0, Vector2(size.x, (size.y / 2)))
				$Line2D.set_point_position(1, event.position)
func _on_mouse_entered(object):
	
	if drag and object.dir != dir and !object.target and object.sellect_num == "":
		target = object

func _on_mouse_exited(object):
	if sellect_num == "":
		target = null
func match_options(_num, state=0):
	if get_tree().has_group("right_col"):
		for option in get_tree().get_nodes_in_group("right_col"):
			if option.num == _num:
				target = option
				$Line2D.points = []
				target.get_child(0).points = []
				$Line2D.add_point(Vector2(size.x, (size.y / 2)))
				var pos = target.global_position - global_position
				$Line2D.add_point(Vector2(pos.x , pos.y + (target.size.y / 2)))
				if state == 1:
					if target.target:
						target.target.target = null
					sellect_num = str(num) + "_" + str(_num)
					target.sellect_num = sellect_num
				target.target = self


func _on_texture_button_pressed():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	target.mouse_filter = Control.MOUSE_FILTER_IGNORE
	if sellect_num == correct_sellect:
		var noise = NoiseTexture2D.new()
		noise.noise = $Line2D.texture.noise
		noise.color_ramp = preload("res://styles/match_option_t.tres")
		$Line2D.texture = noise
		add_theme_stylebox_override("normal", preload("res://styles/match_option2_t.tres"))
		target.add_theme_stylebox_override("normal", preload("res://styles/match_option2_t.tres"))
		
	else:
		var noise = NoiseTexture2D.new()
		noise.noise = $Line2D.texture.noise
		noise.color_ramp = preload("res://styles/match_option_f.tres")
		add_theme_stylebox_override("normal", preload("res://styles/match_option2_f.tres"))
		target.add_theme_stylebox_override("normal", preload("res://styles/match_option2_f.tres"))
		$Line2D.texture = noise
	target.get_node("Line2D").texture = $Line2D.texture
	checked = true
	target.checked = true
	if get_tree().has_group("help_match"):
		var list = []
		for option in get_tree().get_nodes_in_group("left_col"):
			if !option.checked:
				list.append(option)
		for option in list:
			if get_tree().get_nodes_in_group("right_col")[int(option.correct_sellect.split("_")[1])].checked:
				list.erase(option)
		if list.size() < 1:
			get_tree().get_nodes_in_group("help_match")[0].disabled = true
			get_tree().get_nodes_in_group("help_match")[1].disabled = true
