extends Control

signal start
var save_path = "user://data.cfg"
var time = {}
@onready var score = load_game("score", 0)
@export var need_score = 0
var camera_move = false
var light = 255
var league = false
var ticket = 0

func save(_name, num):
	var confige = ConfigFile.new()
	confige.load(save_path)
	confige.set_value("user", _name, num)
	confige.save(save_path)
func load_game(_name, defaulte = null):
	var confige = ConfigFile.new()
	confige.load(save_path)
	return confige.get_value("user", _name, defaulte)
# Called when the node enters the scene tree for the first time.
func _ready():
	
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 3
	request.request(UpdateData.protocol+UpdateData.subdomin+"/auth/CheckLeague", UpdateData.get_header())
	var r = UpdateData.get_json((await request.request_completed)[3])
	league = r.league
	need_score = r.num
	ticket = r.num2
	request.queue_free()
	if load_game("end_league", false):
		$Button.disabled = true
		$timer.queue_free()
		$timer2.show()
		$timer2.start("close_league", load_game("league_close_time"), 0)
	else:
		$timer.start("end_league", load_game("league_end_time"), 0)
	var request2 = HTTPRequest.new()
	add_child(request2)
	request2.timeout = 3
	request2.request(UpdateData.protocol+UpdateData.subdomin+"/users/all?filter=lANDiconANDname&sort=l&per_page=50", UpdateData.get_header())
	var d = await request2.request_completed
	var data = UpdateData.get_json(d[3])
	for user in data.users:
		var _name:String= user.data.name if user.data.has('name') else ""
		if _name == "":
			_name = user.phone.left(4)+"****"+user.phone.right(3)
		var s = 0
		if user.data.has("l"):
			s = user.data.l
		var _icon = user.data.icon
		var pos = user.data.position + 1
		add_item(_name, s, pos, _icon)
	var request3 = HTTPRequest.new()
	add_child(request3)
	request3.timeout = 3
	request3.request(UpdateData.protocol+UpdateData.subdomin+"/users/me?sort=l", UpdateData.get_header())
	var d2 = await request3.request_completed
	var data2 = UpdateData.get_json(d2[3])
	request3.queue_free()
	if data2.has("pos") and data2.pos != 0:
		$MarginContainer/VBoxContainer/my_position/Panel/HBoxContainer/HBoxContainer/Label.text = str("رتبه : ", data2.pos)
	else:
		$MarginContainer/VBoxContainer/my_position/Panel/HBoxContainer/HBoxContainer/Label.text = "رتبه : - "
	
	$MarginContainer/VBoxContainer/my_position/Panel/HBoxContainer/HBoxContainer2/Label.text = str(r.num3)
	var my_name = load_game("name", "")
	if my_name == "":
		my_name = load_game('phone')
	$MarginContainer/VBoxContainer/my_position/Panel/HBoxContainer/HBoxContainer/Label2.text = my_name
	
	$MarginContainer/VBoxContainer/my_position/Panel/HBoxContainer/HBoxContainer/TextureRect/TextureRect.texture = create_image(load_game("icon", ""))
	emit_signal("start")
func add_item(_name, _score, pos, icon):
	var i = preload("res://scenes/positions_panel.tscn").instantiate()
	i.get_node("Panel/HBoxContainer/HBoxContainer2/Label").text = str(_score)
	i.get_node("Panel/HBoxContainer/HBoxContainer/Label2").text = _name
	i.get_node("Panel/HBoxContainer/HBoxContainer/Label").text = str("_", pos)
	i.get_node("Panel/HBoxContainer/HBoxContainer/TextureRect/TextureRect").texture = create_image(icon)
	%VBoxContainer.add_child(i)

func create_image(_name) -> ImageTexture:
	var image = Image.new()
	if _name != "":
		image.load("user://icons/"+_name)
	return ImageTexture.create_from_image(image)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if league:
		$Button3.hide()
		$Button.show()
		$Label.hide()
		$TextureProgressBar.hide()
	else:
		if score < need_score:
			#$Button3.disabled = true
			$TextureProgressBar.value = score * 100 / need_score
		else:
			$TextureProgressBar.value = 100
			if ticket >= 1:
				$PopupPanel/MarginContainer/VBoxContainer/BoxContainer3/Button.disabled = false
		$Label.text = str(score) + " / " + str(need_score)
		$PopupPanel/MarginContainer/VBoxContainer/BoxContainer/Label2.text =  $Label.text
		$PopupPanel/MarginContainer/VBoxContainer/BoxContainer2/Label2.text =  str(ticket, " / ", 1)
		
	$ColorRect.visible = $PopupPanel.visible

func _on_button_2_pressed():
	Exit.change_scene("res://scenes/start.tscn", true, 1)

func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_button_2_pressed()
func _on_timer_timeout():
	save("end_league", true)
	$Button.disabled = true

func _on_timer2_timeout():
	save("close_league", true)
	Exit.change_scene("res://scenes/start.tscn")


func _on_button_3_pressed():
	$PopupPanel.popup()


func _on_button_pressed():
	
	Exit.change_scene("res://scenes/league_parts.tscn", true, 1)


func _on_cancel_pressed() -> void:
	$PopupPanel.hide()


func _on_pay_pressed() -> void:
	$PopupPanel/MarginContainer/VBoxContainer/BoxContainer3/TextureRect.show()
	$PopupPanel/MarginContainer/VBoxContainer/BoxContainer3/Button.hide()
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 3
	request.request(UpdateData.protocol+UpdateData.subdomin+"/auth/OpenLeague", UpdateData.get_header())
	var r = UpdateData.get_json((await request.request_completed)[3])
	league = r.league
	request.queue_free()
	$PopupPanel/MarginContainer/VBoxContainer/BoxContainer3/TextureRect.hide()
	$PopupPanel/MarginContainer/VBoxContainer/BoxContainer3/Button.show()
	score -= need_score
	ticket -= 1
	save("score", score)
	$PopupPanel.hide()
