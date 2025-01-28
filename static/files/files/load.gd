extends Control
var scene = "res://scenes/start.tscn"
var progress = []
var scene_load_state = 0
var save_path = "user://data.cfg"
var save_img_path = "user://files.cfg"
var load_complate = false
var update_game2 = false
var current_load = 0
var version = "1.1"
var load_list = []
var http
var exit = false
var token = ""
var code = ""
var id = ""
var job_complate = false
var job_complate2 = true
var load_data = false

func save(_name, num, path):
	var confige = ConfigFile.new()
	confige.load(path)
	confige.set_value("user", _name, num)
	confige.save(path)
func load_game(_name, path, defaulte=null):
	var confige = ConfigFile.new()
	confige.load(path)
	return confige.get_value("user", _name, defaulte)

func check_session() -> bool:
	var d = null
	if FileAccess.file_exists("user://session.dat"):
		var file = FileAccess.open("user://session.dat", FileAccess.READ)
		d = file.get_var()
		if d is Dictionary:
			token = d.access
			id = d.id
	UpdateData.load_user()
	return d != null && d is Dictionary
# Called when the node enters the scene tree for the first time.
func _ready():

	#Sound.connect_signals(self)
	if !check_session():
		$login.show()
	else:
		var d = await UpdateData.load_from_server()
		if d is UpdateData:
			load_data = true
		else:
			$login.show()
	if load_game("begin", save_img_path, []).size() != 0:
		var image = Image.load_from_file("user://begin/" + load_game("begin", save_img_path, [])[0])
		if image != null:
			$TextureRect.texture = ImageTexture.create_from_image(image)
	if !FileAccess.file_exists(save_path):
		var confige = ConfigFile.new()
		confige.save(save_path)
	if !FileAccess.file_exists(save_img_path):
		var confige = ConfigFile.new()
		confige.save(save_img_path)
	save("version", version, save_path)
	$Panel2.link = load_game("link", save_path, "")
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(request_complated)
	http.request(UpdateData.protocol+UpdateData.subdomin+"/game/data", ["Authorization: Bearer %s"%UpdateData.token])
func _on_line_edit_text_changed(new_text, obj:LineEdit):
	if new_text != "":
		obj.call_deferred("grab_focus")
func _on_line_edit_text_changed2(event, obj:LineEdit, obj2):
	if obj2.text == "" and obj2.has_focus():
		if event is InputEventKey:
			if event.keycode == KEY_BACKSPACE:
				obj.call_deferred("grab_focus")
func request_complated(result, response_code, header, body):
	if response_code == 0:
		Exit.reload()
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	load_list = json.get_data()
	if load_list is Dictionary and load_list.has("data"):
		for key in load_list.data.keys():
			if load_list.data[key] is String and load_list.data[key].begins_with(UpdateData.protocol):
				await _on_http_request_request_completed([key, load_list.data[key]])
			else:
				if key == "version":
					if load_game("version", save_path) != load_list.data[key]:
						update_game()
						update_game2 = true
						if get_tree().has_group("loader"):
							get_tree().get_nodes_in_group("loader")[0].queue_free()
						return
				if load_list.data[key] is float:
					load_list.data[key] = str(load_list.data[key])
				UpdateData.save(key, load_list.data[key], false)
	job_complate = true

func _input(event):
	if event is InputEventScreenTouch and load_complate and !exit:
		exit = true
		Exit.change_scene(scene)
		

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "load_complate":
		$AnimationPlayer.play_backwards("effect")
func _on_get_image_complated(resulte, response_code, header, body, url, _name2):
	if response_code == 0:
		Exit.reload()
	var image = Image.new()
	if !DirAccess.dir_exists_absolute("user://"+_name2):
		DirAccess.make_dir_absolute("user://"+_name2)
	if image.load_png_from_buffer(body) == OK:
		image.save_png("user://" +_name2+ "/" + url.get_file().get_basename() + "." + url.get_extension().left(3))
	if image.load_jpg_from_buffer(body) == OK:
		image.save_jpg("user://" +_name2+ "/" + url.get_file().get_basename() + "." + url.get_extension().left(3))
	if _name2 == "load_scene_img":
		$TextureRect.texture = ImageTexture.create_from_image(image)
	save(_name2, url, save_img_path)
	
func _on_http_request_request_completed(body:Array):
	
	var _name = body[0]
	$Timer.start()
	if body != null and body.size() > 0:
		if _name == "app":
			save(_name, body[1], save_path)
			$Panel2.link = body[1]
			return self
		else:
			if load_game(_name, save_img_path, "") == body[1] and FileAccess.file_exists("user://" +_name+ "/" + body[1].get_file().get_basename() + "." + body[1].get_extension().left(3)):
				return self
			else:
				var url = load_game(_name, save_img_path, "")
				DirAccess.remove_absolute("user://" +_name+ "/" + url.get_file().get_basename() + "." + url.get_extension().left(3))
				var http = HTTPRequest.new()
				add_child(http)
				http.request_completed.connect(_on_get_image_complated.bind(body[1], _name))
				http.request(body[1])
				var d = await http.request_completed
				if d[1] == 0:
					Exit.reload()
				http.queue_free()
				return self
func _process(delta):

	if load_data and !update_game2 and job_complate  and !$login.visible:
		load_complate = true
		$Timer.stop()
		if $AnimationPlayer.current_animation != "effect":
			$AnimationPlayer.play("effect")
	
func no_internet():
	if !$login.visible:
		$Weak_internet.hide()
		$Timer.stop()
		$AnimationPlayer.play("RESET")
		$Panel.show()

func _on_button_pressed():
	queue_free()
	get_tree().reload_current_scene()
func update_game():
	$Timer.stop()
	$Panel2.show()
	
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		get_tree().quit()
func _on_http_manager_job_failed(object):
	$HTTPManager.queue_free()
	if get_tree().has_group("loader"):
		get_tree().get_nodes_in_group("loader")[0].queue_free()
	no_internet()


func _on_timer_timeout():
	if !$login.visible:
		$Weak_internet.popup()

func remove_extra_space(text:String) ->String:
	var s = text.split(" ")
	var text2 = ""
	for t in s:
		if t != "":
			text2 += t + " "
	return text2

func get_json(data):
	var j = JSON.new()
	return j.parse_string(data.get_string_from_utf8())
func request_completed2(result, response_code, header, body):
	if response_code == 0:
		Exit.reload()
	var j = JSON.new()
	var data = j.parse_string(body.get_string_from_utf8())
	if data is Dictionary and (response_code==200 or response_code == 201):
		if data.has("tokens"):
			save_auth(data.tokens)
			UpdateData.load_user()
			await UpdateData.load_from_server()
			load_data = true
			$login.hide()
	else:
		if data is Dictionary:
			$login.error = data.error
	
func signup(body):
	var auth = HTTPRequest.new()
	auth.request_completed.connect(request_completed2)
	add_child(auth)
	var headers = [
		"Content-Type: application/json"
	]
	auth.request(UpdateData.protocol+UpdateData.subdomin+"/auth/register", headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	await auth.request_completed
	auth.queue_free()
func save_auth(auth):
	
	var file = FileAccess.open("user://session.dat", FileAccess.WRITE)
	file.store_var(auth)
	file.close()
func login(body):
	var auth = HTTPRequest.new()
	auth.request_completed.connect(request_completed2)
	add_child(auth)
	var headers = [
		"Content-Type: application/json"
	]
	
	auth.request(UpdateData.protocol+UpdateData.subdomin+"/auth/login", headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	await auth.request_completed
	
	auth.queue_free()
func verify(body):
	var auth = HTTPRequest.new()
	auth.request_completed.connect(request_completed2)
	add_child(auth)
	var headers = [
		"Content-Type: application/json"
	]
	
	auth.request(UpdateData.protocol+UpdateData.subdomin+"/auth/verify", headers, HTTPClient.METHOD_POST, JSON.stringify(body))
	await auth.request_completed
	auth.queue_free()
