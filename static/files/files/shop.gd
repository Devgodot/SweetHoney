extends Control

var save_path = "user://data.cfg"
var num
var cost
var mode_purchase
var score = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	score = load_game("score", 0)
	$PopupPanel/Control/yes.pressed.connect(_on_purchase_button_complated)
	$PopupPanel/Control/no.pressed.connect(_on_purchase_button_faild)
	for x in range(get_tree().get_nodes_in_group("hive_shop").size()):
		
		var button = get_tree().get_nodes_in_group("hive_shop")[x].get_child(0)
		button.pressed.connect(_on_hive_button_pressed.bind(x, button.get("metadata/cost")))
		if load_game("open_hive"+str(x), false):

			button.disabled = true
			
func save(_name, num):
	var confige = ConfigFile.new()
	confige.load(save_path)
	confige.set_value("user", _name, num)
	confige.save(save_path)
func load_game(_name, defaulte=null):
	var confige = ConfigFile.new()
	confige.load(save_path)
	return confige.get_value("user", _name, defaulte)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	modulate = [Color.WHITE, Color("4f4f4f")][int($PopupPanel.visible)]
	$TextureProgressBar/Label.text = str(score)
	$TextureProgressBar.value = score * 100 / 5000
func _on_purchase_button_faild():
	$PopupPanel.hide()
func _on_purchase_button_complated():
	$PopupPanel.hide()
	
	match mode_purchase:
		"hive":
			score -= cost
			save("score", score)
			if get_tree().has_group('score'):
				get_tree().get_nodes_in_group("score")[0].text = "امتیاز : "+ str(load_game("score", 0))
			get_tree().get_nodes_in_group("hive_shop")[num].get_child(0).disabled = true

			save("open_hive"+str(num), true)
			
func _on_hive_button_pressed(_num, _cost):
	
	if load_game("score", 0) >= _cost:
		$PopupPanel.popup_centered()
		cost = _cost
		num = _num
		mode_purchase = "hive"
func _on_texture_button_pressed():
	Exit.change_scene("res://scenes/start.tscn")
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		Exit.change_scene("res://scenes/start.tscn")
