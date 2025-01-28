extends LineEdit

var drag = false
@export var dir = 1
var target
var num = 0
var sellect_num = ""
# Called when the node enters the scene tree for the first time.
func _ready():
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
		else:
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
	if object.dir != dir and !object.target and object.sellect_num == "" and drag:
		target = object
		
func _on_mouse_exited(object):
	if sellect_num == "":
		target = null
func match_options(_num):
	if get_tree().has_group("right_col"):
		for option in get_tree().get_nodes_in_group("right_col"):
			if option.num == _num:
				target = option
				$Line2D.add_point(Vector2(size.x, (size.y / 2)))
				var pos = target.global_position - global_position
				$Line2D.add_point(Vector2(pos.x , pos.y + (target.size.y / 2)))
				target.target = self
				sellect_num = str(num) + "_" + str(target.num)
				target.sellect_num = str(num) + "_" + str(target.num)
