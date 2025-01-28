extends Control


var level = 1
var max_level = 1
var unlock_level = 1
var save_path = "user://data.cfg"
var part = 0
var teach = true
var guid
var reset_guid = true
@export var gift_score = 30
@export_subgroup("guids")
@export_multiline var guid_league = ""
@export_global_file("*.mp3", "*.wav") var sound_guid_league
@export_multiline var guid_hive = ""
@export_global_file("*.mp3", "*.wav") var sound_guid_hive
@export_multiline var guid_normal_levels = ""
@export_global_file("*.mp3", "*.wav") var sound_guid_normal_levels
@export_multiline var guid_gift = ""
@export_global_file("*.mp3", "*.wav") var sound_guid_gift
@export_multiline var guid_shop = ""
@export_global_file("*.mp3", "*.wav") var sound_guid_shop
var guid_text_list = []
var page = 0
func save(_name, num):
	var confige = ConfigFile.new()
	confige.load(save_path)
	confige.set_value("user", _name, num)
	confige.save(save_path)
func load_game(_name, defaulte=null):
	var confige = ConfigFile.new()
	confige.load(save_path)
	return confige.get_value("user", _name, defaulte)
func load_game2(_name, defaulte=null):
	var confige = ConfigFile.new()
	confige.load("user://files.cfg")
	return confige.get_value("user", _name, defaulte)
func _ready():
	
	if FileAccess.file_exists(save_path):
		level = load_game("level", 1)
		teach = load_game("teach", true)
		#$VBoxContainer/HBoxContainer4/Control/Panel/Label.text = load_game('name', "")
		#$VBoxContainer/HBoxContainer4/Control/Panel/Label.editable = false
		part = load_game("part", 0)

	if load_game("begin_league", false):
		$timer.queue_free()
		$timer2.show()
		$timer2.start("close_league", load_game("league_close_time"), 0)
	else:
		$timer.start("begin_league", load_game('league_open_time'), 0)
	if load_game("close_league", false):
		$timer.queue_free()
		$timer2.queue_free()
	match part:
		0:
			max_level = load_game("max_level_h", 1)
			unlock_level = load_game("unlock_level_h", 1)
		1:
			max_level = load_game("max_level_v", 1)
			unlock_level = load_game("unlock_level_v", 1)
		2:
			max_level = load_game("max_level_s", 1)
			unlock_level = load_game("unlock_level_s", 1)
		3:
			max_level = load_game("max_level_m", 1)
			unlock_level = load_game("unlock_level_m", 1)
	
	if level > max_level:
		level = max_level
		save("level", level)
	$gift/timer.start("gift", 0)
#	if load_game("img", "") != "":
#		$VBoxContainer/HBoxContainer4/Control/Panel/TextureButton2.show()
#		$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/Label.hide()
#		var tex = load("res://sprite/user_img.png")
#		if FileAccess.file_exists("user://icons/" + load_game("img")):
#			var image = Image.load_from_file("user://icons/" + load_game("img"))
#			tex = ImageTexture.create_from_image(image)
#		else:
#			save("img", "")
#			$VBoxContainer/HBoxContainer4/Control/Panel/TextureButton2.hide()
#		$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/TextureRect2.texture = tex
#	else:
#		$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/TextureRect2.texture = load("res://sprite/user_img.png")
	#$VBoxContainer/HBoxContainer4/Control/Panel/Label2.text = "امتیاز : "+ str(load_game("score", 0))
	#$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect2.value = load_game("score", 0) * 100 / 5000
	
func _on_PersianButton_pressed():
#	add_child(preload("res://scenes/particles.tscn").instantiate())
	if !guid:
		Exit.change_scene("res://scenes/normal_menu.tscn", true)
	else:
		if reset_guid:
			$AnimationPlayer.play("light_off")
			await $AnimationPlayer.animation_finished
			$AnimationPlayer.play("guid")
			guid_text_list = guid_normal_levels.split("\n")
			page = 0
			reset_guid = false
			$PanelQ/RichTextLabel.text = "[right]" + guid_text_list[page] + "\n[/right][i][u][b] بزن روی صفحه"





func _on_texture_button_pressed():
	$icons.show()
	



func _on_icons_button_pressed(img):
	save("img_mode", 0)
	save("img", img)
	save("rotate_img", 0)
	var image = Image.load_from_file("user://icons/" + load_game("img"))
	var tex = ImageTexture.create_from_image(image)
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/TextureRect2.texture = tex
	$icons.hide()
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/Label.hide()
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureButton2.show()

func _on_texture_button_2_pressed():
	save("img_mode", 0)
	save("img", "res://sprite/user_img.png")
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/Label.show()
	save("rotate_img", 0)
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/TextureRect2.rotation_degrees = load_game("rotate_img", 0)
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/TextureRect2.texture = load(load_game("img", "res://sprite/user_img.png"))
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureButton2.hide()
	





func _on_label_text_submitted(new_text):
	var t = new_text.split(" ")
	var text = ""
	for x in t:
		if x != "":
			text += x
	if text != "" and new_text != "":
		save("name", new_text)
		$VBoxContainer/HBoxContainer4/Control/Panel/Label.editable = false


func _on_edit_name_pressed():
	$VBoxContainer/HBoxContainer4/Control/Panel/Label.editable = true


func _on_PersianButton3_pressed():
	$PopupPanel2.hide()
	$AnimationPlayer2.play("change_scene")
	await $AnimationPlayer2.animation_finished
	get_tree().quit()
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_quit_pressed()

func _on_turn_texture_pressed():
	save("rotate_img", load_game("rotate_img", 0) + 90)
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/TextureRect2.rotation_degrees = load_game("rotate_img", 0)

	
func _on_gui_input(event):
	if event is InputEventScreenTouch:
#		var t = $VBoxContainer/HBoxContainer4/Control/Panel/Label.text.split(" ")
#		var text = ""
#		for x in t:
#			if x != "":
#				text += x
#		if text != "" and $VBoxContainer/HBoxContainer4/Control/Panel/Label.text != "":
#			save("name", $VBoxContainer/HBoxContainer4/Control/Panel/Label.text)
#			$VBoxContainer/HBoxContainer4/Control/Panel/Label.editable = false
		if guid and $PanelQ.scale.x >= 1:
			if page < guid_text_list.size() - 1:
				page += 1
				$PanelQ/RichTextLabel.text = "[right]" + guid_text_list[page] + "\n[/right][i][u][b] بزن روی صفحه"
			else:
				$AnimationPlayer.play("close")
				guid = false
				reset_guid = true
			
				
func _on_file_dialog_file_sellected(path):
	save("img_mode", 1)
	save("img", path)
	save("rotate_img", 0)
	var image = Image.load_from_file(load_game("img", "res://sprite/user_img.png"))
	var tex = ImageTexture.create_from_image(image)
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/TextureRect2.rotation_degrees = load_game("rotate_img", 0)
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/TextureRect2.texture = tex
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/TextureRect2.rotation_degrees = load_game("rotate_img", 0)
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureRect/Label.hide()
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureButton2.show()
	$VBoxContainer/HBoxContainer4/Control/Panel/TextureButton3.show()

func _process(delta):
	$ColorRect.visible = $PopupPanel2.visible
	if load_game("gift", false):
		if $gift/AnimationPlayer.current_animation != "gift":
			$gift/AnimationPlayer.play("rotate_door")
	if load_game("begin_league"):
		$VBoxContainer/PersianButton2.disabled = false
		$VBoxContainer/PersianButton2/Lock.hide()
	if load_game("close_league"):
		$VBoxContainer/PersianButton2.disabled = true
		$VBoxContainer/PersianButton2/Lock.show()
		

func _on_timer_timeout():
	if !load_game("gift", false):
		save("gift", true)



func _on_realisticgoldgiftbox_body_pressed():
	if load_game("gift", false):
		var requst = HTTPRequest.new()
		add_child(requst)
		requst.timeout = 3
		requst.request(UpdateData.protocol + UpdateData.subdomin+"/auth/GetGift", UpdateData.get_header(), HTTPClient.METHOD_POST, JSON.stringify({"name":"gift"}))

		var d = await requst.request_completed
		var data = UpdateData.get_json(d[3])
		if data:
			if data.has("num"):
				$gift/Label.text = "+" + str(data["num"])
				$gift/AnimationPlayer.play("gift")
				await $gift/AnimationPlayer.animation_finished
				$gift/AnimationPlayer.play("RESET")
				save("score", data["num2"])
				save("gift", false)
				$gift/timer.update_time()
				$gift/timer.start("gift", 0)
			if data.has("gift"):
				save("gift", false)
				$gift/AnimationPlayer.play("RESET")
				$gift/timer.update_time()
				$gift/timer.start("gift", 0)
		requst.queue_free()
			
func _on_hives_pressed():
	if !guid:
		save("last_time_gift", $gift/timer.current_time)
		Exit.change_scene("res://scenes/hive_scene.tscn", true)
	else:
		if reset_guid:
			$AnimationPlayer.play("light_off")
			await $AnimationPlayer.animation_finished
			$AnimationPlayer.play("guid")
			guid_text_list = guid_hive.split("\n")
			page = 0
			reset_guid = false
			$PanelQ/RichTextLabel.text = "[right]" + guid_text_list[page] + "\n[/right][i][u][b] بزن روی صفحه"
func _on_guid_button_pressed():
	guid = true
	$AnimationPlayer.play("light_on")
	await $AnimationPlayer.animation_finished
	$AnimationPlayer.play("effect")


func _on_guid_league_button_pressed():
	if reset_guid:
		$AnimationPlayer.play("light_off")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("guid")
		guid_text_list = guid_league.split("\n")
		page = 0
		reset_guid = false
		$PanelQ/RichTextLabel.text = "[right]" + guid_text_list[page] + "\n[/right][i][u][b] بزن روی صفحه"


func _on_timer_2_timeout():
	save('close_league', true)
	$VBoxContainer/PersianButton2.disabled = true
	$VBoxContainer/PersianButton2/Lock.show()
	$timer2.queue_free()

func _on_gift_button_pressed():
	if guid:
		if reset_guid:
			$AnimationPlayer.play("light_off")
			await $AnimationPlayer.animation_finished
			$AnimationPlayer.play("guid")
			guid_text_list = guid_gift.split("\n")
			page = 0
			reset_guid = false
			$PanelQ/RichTextLabel.text = "[right]" + guid_text_list[page] + "\n[/right][i][u][b] بزن روی صفحه"
	else:
		Exit.change_scene("res://scenes/gifts.tscn", true)


func _on_timer_begin_league_timeout():
	save('begin_league', true)
	$timer.queue_free()




func _on_shop_button_pressed():
	if guid:
		if reset_guid:
			$AnimationPlayer.play("light_off")
			await $AnimationPlayer.animation_finished
			$AnimationPlayer.play("guid")
			guid_text_list = guid_shop.split("\n")
			page = 0
			reset_guid = false
			$PanelQ/RichTextLabel.text = "[right]" + guid_text_list[page] + "\n[/right][i][u][b] بزن روی صفحه"
	else:
		Exit.change_scene("res://scenes/shop.tscn", true)


func _on_league_button_pressed():
	Exit.change_scene("res://scenes/league_menu.tscn", true)


func _on_button_pressed():
	$PopupPanel2.hide()


func _on_quit_pressed():
	$PopupPanel2.popup_centered()


func _on_texture_button_toggled(toggled_on: bool) -> void:
	if !toggled_on:
		$TextureButton/AnimationPlayer.play_backwards("open")
	else :
		$TextureButton/AnimationPlayer.play("open")


func _on_rankingbutton_pressed() -> void:
	Exit.change_scene("res://scenes/positions.tscn", true)


func _on_texture_button_3_pressed() -> void:
	var r = HTTPRequest.new()
	add_child(r)
	r.timeout = 3
	r.request(UpdateData.protocol+UpdateData.subdomin+"/auth/logout", UpdateData.get_header())
	var d = await r.request_completed
	var data = UpdateData.get_json(d[3])
	if data:
		if data.has("message"):
			if FileAccess.file_exists("user://session.dat"):
				DirAccess.remove_absolute("user://session.dat")
			if FileAccess.file_exists("user://data.cfg"):
				DirAccess.remove_absolute("user://data.cfg")
			if FileAccess.file_exists("user://files.cfg"):
				DirAccess.remove_absolute("user://files.cfg")
			Exit.change_scene("res://scenes/intro.tscn", false)
