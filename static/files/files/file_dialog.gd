extends Control
signal file_sellected(_path)
var current_path 
var size_item = Vector2(64, 64)
var list_folder = []
var list_file = []
var list = []
var get_var = true
var directory = DirAccess

# Called when the node enters the scene tree for the first time.
func _ready():
	
	
	$PanelContainer/VBoxContainer/ScrollContainer/GridContainer.add_theme_constant_override("h_separation", size_item.x + 20)
	$PanelContainer/VBoxContainer/ScrollContainer/GridContainer.add_theme_constant_override("v_separation", size_item.y + 50)
	var path = OS.get_system_dir(OS.SYSTEM_DIR_DCIM)
	current_path = OS.get_system_dir(OS.SYSTEM_DIR_DCIM)
	$PanelContainer/VBoxContainer/HBoxContainer/LineEdit.text = current_path
	directory = DirAccess.open(current_path)
	directory.list_dir_begin()
func popup_center():
	set_anchors_preset(Control.PRESET_CENTER)
	show()
func popup():
	show()

func create_files(_name, _path):
	var btn = TextureButton.new()
	var image = Image.load_from_file(_path)
	image.resize(size_item.x, size_item.y, Image.INTERPOLATE_BILINEAR)
	var tex = ImageTexture.create_from_image(image)
	btn.texture_normal = tex
	btn.stretch_mode = TextureButton.STRETCH_SCALE
	btn.pressed.connect(file_button_pressed.bind(_name))
	var label = Label.new()
	label.text = _name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.position = Vector2(0, size_item.y)
	label.size = size_item
	
	var control = Control.new()
	
	control.add_child(btn)
	control.add_child(label)
	$PanelContainer/VBoxContainer/ScrollContainer/GridContainer.add_child(control)
func create_folders(_name, _path):
	var btn = TextureButton.new()
	btn.texture_normal = preload("res://sprite/folder.png")
	btn.ignore_texture_size = true
	btn.stretch_mode = TextureButton.STRETCH_SCALE
	btn.size = size_item
	btn.flip_h = true
	btn.pressed.connect(folder_button_pressed.bind(_path))
	
	var label = Label.new()
	label.text = _name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.clip_text = true
	label.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
	label.position = Vector2(0, size_item.y)
	label.size = size_item
	
	var control = Control.new()
	
	control.add_child(btn)
	control.add_child(label)
	$PanelContainer/VBoxContainer/ScrollContainer/GridContainer.add_child(control)

func folder_button_pressed(_path):
	
	var dir = DirAccess.open(_path)
	var path = dir.get_current_dir()
	current_path = path
	for child in $PanelContainer/VBoxContainer/ScrollContainer/GridContainer.get_children():
		child.queue_free()
	get_var = true
	directory = DirAccess.open(current_path)
	directory.list_dir_begin()
	$PanelContainer/VBoxContainer/HBoxContainer/LineEdit.text = path
	$PanelContainer/VBoxContainer/HBoxContainer3/LineEdit.text = ""
func file_button_pressed(_name):
	$PanelContainer/VBoxContainer/HBoxContainer3/LineEdit.text = _name


func _on_button_pressed():
	var path = $PanelContainer/VBoxContainer/HBoxContainer/LineEdit.text
	var dir = DirAccess
	
	if DirAccess.dir_exists_absolute(path + "/.."):
		dir = DirAccess.open(path + "/..")
		path = dir.get_current_dir()
		current_path = path
	else:
		path = current_path
	for child in $PanelContainer/VBoxContainer/ScrollContainer/GridContainer.get_children():
		child.queue_free()
	$PanelContainer/VBoxContainer/HBoxContainer/LineEdit.text = path
	$PanelContainer/VBoxContainer/HBoxContainer3/LineEdit.text = ""
	for child in $PanelContainer/VBoxContainer/ScrollContainer/GridContainer.get_children():
		child.queue_free()
	get_var = true
	directory = DirAccess.open(current_path)
	directory.list_dir_begin()

func _process(delta):
	if int(($PanelContainer.size.x - 60) / size_item.x) - 2 > 0:
		$PanelContainer/VBoxContainer/ScrollContainer/GridContainer.columns =int(($PanelContainer.size.x - 60) / size_item.x) - 2
	else:
		$PanelContainer/VBoxContainer/ScrollContainer/GridContainer.columns = 1
	size_item = Vector2(1, 1) * $PanelContainer/VBoxContainer/HBoxContainer/HSlider.value
	if get_var:
		var next = directory.get_next()
		if next != "":
			if directory.current_is_dir():
				create_folders(next, current_path + "/" + next)
			else:
				if next.get_extension() == "png" or next.get_extension() == "jpg":
					create_files(next, current_path +"/"+ next)
		else:
			directory.list_dir_end()
			get_var = false
			for x in range($PanelContainer/VBoxContainer/ScrollContainer/GridContainer.columns):
				var c = Control.new()
				$PanelContainer/VBoxContainer/ScrollContainer/GridContainer.add_child(c)

	$PanelContainer/VBoxContainer/HBoxContainer/Label2.text = "size : " + str(size_item.x) 
	if DirAccess.dir_exists_absolute($PanelContainer/VBoxContainer/HBoxContainer/LineEdit.text):
		if FileAccess.file_exists($PanelContainer/VBoxContainer/HBoxContainer/LineEdit.text + "/" + $PanelContainer/VBoxContainer/HBoxContainer3/LineEdit.text):
			$PanelContainer/VBoxContainer/HBoxContainer4/Button.disabled = false
		else:
			$PanelContainer/VBoxContainer/HBoxContainer4/Button.disabled = true
	else:
			$PanelContainer/VBoxContainer/HBoxContainer4/Button.disabled = true



func _on_button_2_pressed():
	hide()
	$PanelContainer/VBoxContainer/HBoxContainer3/LineEdit.text = ""


func _on_sellect_button_pressed():
	hide()
	emit_signal("file_sellected", $PanelContainer/VBoxContainer/HBoxContainer/LineEdit.text + "/"+ $PanelContainer/VBoxContainer/HBoxContainer3/LineEdit.text)
	

func _on_line_edit_text_submitted(new_text):
	var path = new_text
	var dir = DirAccess
	
	if DirAccess.dir_exists_absolute(new_text):

		dir = DirAccess.open(new_text)
		path = dir.get_current_dir()
		current_path = path
		$PanelContainer/VBoxContainer/HBoxContainer3/LineEdit.text = ""
	else:
		path = current_path
		
	$PanelContainer/VBoxContainer/HBoxContainer/LineEdit.text = path

	for child in $PanelContainer/VBoxContainer/ScrollContainer/GridContainer.get_children():
		child.queue_free()
	get_var = true
	directory = DirAccess.open(current_path)
	directory.list_dir_begin()
func _on_h_slider_drag_ended(value_changed):
	$PanelContainer/VBoxContainer/ScrollContainer/GridContainer.columns =int(($PanelContainer.size.x - 60) / size_item.x) - 1
	$PanelContainer/VBoxContainer/ScrollContainer/GridContainer.add_theme_constant_override("h_separation", size_item.x + 20)
	$PanelContainer/VBoxContainer/ScrollContainer/GridContainer.add_theme_constant_override("v_separation", size_item.y + 50)
	for child in $PanelContainer/VBoxContainer/ScrollContainer/GridContainer.get_children():
		child.queue_free()
	get_var = true
	directory = DirAccess.open(current_path)
	directory.list_dir_begin()

func _on_h_slider_value_changed(value):
	size_item = Vector2(1, 1) * value
