extends PopupPanel
var images = []
var filter_image = []
var page = 1
var max_page = 1
signal button_pressed
# Called when the node enters the scene tree for the first time.
var save_path = "user://data.cfg"
func save(_name, num, path=save_path):
	var confige = ConfigFile.new()
	confige.load(save_path)
	confige.set_value("user", _name, num)
	confige.save(path)
func load_game(_name, defaulte=null, path=save_path):
	var confige = ConfigFile.new()
	confige.load(path)
	return confige.get_value("user", _name, defaulte)

func _ready():
	get_files()

func get_image(img):
	var image = Image.new()
	image.load("user://icons/"+img)
	add_icon(image, img)

func get_files(pattern=""):
	for child in %icons.get_children():
		child.queue_free()
	size = Vector2(730, 800)
	var images = DirAccess.get_files_at("user://icons")
	var l = []
	
	for image in images:
		if image.contains(pattern):
			l.append(image)
	if pattern == "":
		l = images
	max_page = int(l.size() / 15) + 1
	add_page_btn(max_page)
	var l2 = []
	for x in range(l.size()):
		if x >= (page - 1) * 15 and x < page * 15:
			l2.append(l[x])
	for x in range(l2.size()):
		var img = l2[x]
		get_image(img)
	size = Vector2(730, 800)
func add_page_btn(max_page):
	for child in %HBoxContainer.get_children():
		child.queue_free()
	if max_page > 5:
		if page > 2 and page < max_page - 2:
			for x in range(page + 2, page - 2):
				var button = $Button.duplicate()
				button.show()
				button.text = str(x)
				button.pressed.connect(page_button_pressed.bind(x))
				%HBoxContainer.add_child(button)
		else :
			for x in range(5):
				var y = 0
				if page <= 2:
					y = x + 1
				else :
					y = max_page - 4 + x
				var button = $Button.duplicate()
				button.show()
				button.text = str(y)
				button.pressed.connect(page_button_pressed.bind(y))
				%HBoxContainer.add_child(button)
	else:
		for x in range(max_page):
			var button = $Button.duplicate()
			button.show()
			button.text = str(x+1)
			button.pressed.connect(page_button_pressed.bind(x+1))
			%HBoxContainer.add_child(button)
func page_button_pressed(x):
	if page!=x:
		page = x
		get_files(%LineEdit.text)
func add_icon(img:Image, _name):
	var vbox = VBoxContainer.new()
	vbox.custom_minimum_size = Vector2(140, 210)
	var tex = ImageTexture.create_from_image(img)
	var btn = TextureButton.new()
	btn.texture_normal = tex
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	btn.custom_minimum_size = Vector2(140, 140)
	btn.pressed.connect(_on_btn_pressed.bind(tex, _name))
	var label = $Label.duplicate()
	label.show()
	if %LineEdit.text == "":
		label.text = "[center]"+ _name.get_file().get_basename().uri_decode()
	else:
		var text = "[center]"
		for t in _name.get_file().get_basename().uri_decode().split(%LineEdit.text):
			text += t + "[color=red]%s[/color]"%%LineEdit.text
		for x in range(8 + %LineEdit.text.length()):
			text = text.erase(text.length() - 1)
		label.text = text
	vbox.add_child(btn)
	vbox.add_child(label)
	%icons.add_child(vbox)
func _on_btn_pressed(img, _name):
	emit_signal("button_pressed", img)
	UpdateData.save("icon", _name)
	hide()
func _on_button_3_pressed():
	if page != 1:
		page = 1
		get_files(%LineEdit.text)


func _on_button_pressed():
	if page > 1:
		page -= 1
		get_files(%LineEdit.text)


func _on_button_2_pressed():
	
	if page < max_page:
		page += 1
		get_files(%LineEdit.text)


func _on_button_4_pressed():
	
	if page != max_page:
		page = max_page
		
		get_files(%LineEdit.text)


func _on_line_edit_text_changed(new_text):
	get_files(new_text)
	
