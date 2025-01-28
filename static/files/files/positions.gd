extends Control

signal start
# Called when the node enters the scene tree for the first time.
func _ready():
	#Sound.connect_signals(self)
	
	#var scores = await UpdateData.request(UpdateData.protocol+UpdateData.subdomin+"/users/all?filter=iconANDlvlANDname&sort=lvl&per_page=50")
	var request = HTTPRequest.new()
	add_child(request)
	request.timeout = 3
	request.request(UpdateData.protocol+UpdateData.subdomin+"/users/all?filter=lvlANDiconANDname&sort=lvl&per_page=5", UpdateData.get_header())
	var d = await request.request_completed
	var scores = UpdateData.get_json(d[3])
	for score in scores.users:
		var count = scores.users.count(score)
		if count > 1:
			for x in range(count - 1):
				scores.users.erase(score)
	for x in range(scores.users.size()):
		var data = scores.users[x]
		var score = data.data.lvl
		var _name:String= data.data.name if data.data.has('name') else ""
		if _name == "":
			_name = data.phone.left(4)+"****"+data.phone.right(3)
		var icon = data.data.icon
		add_item(data.data.position + 1, _name, score, icon, %VBoxContainer3.get_child(x))
	var request3 = HTTPRequest.new()
	add_child(request3)
	request3.timeout = 3
	request3.request(UpdateData.protocol+UpdateData.subdomin+"/users/me?sort=lvl", UpdateData.get_header())
	var d2 = await request3.request_completed
	var data2 = UpdateData.get_json(d2[3])
	request3.queue_free()
	if data2.has("pos") and data2.pos != 0:
		$Panel/VBoxContainer2/TextureRect3/RichTextLabel2.text = str("[center]", data2.pos)
	
	var my_name = load_game("name", "")
	if my_name == "":
		my_name = load_game('phone')
	$Panel/VBoxContainer2/Label.text = my_name
	$Panel/VBoxContainer2/TextureRect/TextureRect.texture = create_image(load_game("icon", ""))
	$Panel/VBoxContainer2/TextureRect4/RichTextLabel.text = str("[center]", data2.num)
	start.emit()
func load_game(_name, defaulte = null):
	var confige = ConfigFile.new()
	confige.load("user://data.cfg")
	return confige.get_value("user", _name, defaulte)
func add_item(x, _name, lv, icon, p= $obj):
	if p :
		p.get_node("MarginContainer/HBoxContainer/RichTextLabel").text = str("[center]",x)
		p.get_node("MarginContainer/HBoxContainer/TextureRect2/RichTextLabel2").text = str("[center]", lv)
		p.get_node("MarginContainer/HBoxContainer/Label").text = _name
		p.show()
		if icon != "":
			set_image(p.get_node("MarginContainer/HBoxContainer/TextureRect/TextureRect"), icon)
		
# Called every frame. 'delta' is the elapsed time since the previous frame.
func set_image(p, icon):
	p.texture = create_image(icon)
func create_image(_name) -> ImageTexture:
	var image = Image.new()
	if _name != "":
		image.load("user://icons/"+_name)
	return ImageTexture.create_from_image(image)
func _on_button_pressed():
	Exit.change_scene("res://scenes/start.tscn")
