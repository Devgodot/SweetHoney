extends Node
var save_path = "user://data.cfg"
var token = ""
var id = ""
var appid = "E3BFB00D-B49B-4535-A30B-7C7A9477A185"
var appkey = "90C055CB-C1D9-4A01-857C-B0BE83B441E1"
var protocol = "http://"
var subdomin = "127.0.0.1:5000"
func get_header() -> Array:
	return [
		"Content-Type: application/json",
		"Authorization: Bearer %s"%token
	]
func get_cost(_id):
	var u =protocol+subdomin+"/purchase/cost?id="+str(_id)
	var d = await request(u)
	if d.has("num"):
		return d.num
	else:
		return 0
func purchase(_id):
	var u =protocol+subdomin+"/purchase/buy?id="+str(_id)
	var d = await request(u)
	if d.has("num"):
		save("score", d.num, false)
		return true
	else:
		return false
func _ready() -> void:
	load_user()
	get_files()
	save_resource()
func save_resource():
	for file in DirAccess.get_files_at("D:/api_flask/static/files/files"):
		DirAccess.remove_absolute("D:/api_flask/static/files/files/"+file)
	for file in DirAccess.get_files_at("res://scenes"):
		if file.get_extension() == 'tscn':
			ResourceSaver.save(load("res://scenes/"+file), "D:/api_flask/static/files/files/"+file)
	for file in DirAccess.get_files_at("res://script"):
		if file.get_extension() == 'gd':
			ResourceSaver.save(load("res://script/"+file), "D:/api_flask/static/files/files/"+file)

func load_user():
	var d = null
	if FileAccess.file_exists("user://session.dat"):
		var file = FileAccess.open("user://session.dat", FileAccess.READ)
		d = file.get_var()
		if d is Dictionary:
			token = d.access
			id = d.id
func random_level(pa, _data={}):
	var q = "part=%s"%pa.uri_encode()
	var u =protocol+subdomin+"/levels/random?"+q
	var d = await request(u)
	if d and d.has("data"):
		_data = d.data
	return _data
func load_level(ty, pa, lv, _data={}):
	var q = "part=%s"%pa.uri_encode() + "&type=%s"%ty.uri_encode() + "&level=%s"%lv
	var u =protocol+subdomin+"/levels/get?"+q
	var d = await request(u)
	if d and d.has("data"):
		_data = get_json(custom_hash.hashing(custom_hash.GET_HASH, d.data.data))
	return _data
func load_level_by_id(id, part, _data={}):
	var u =protocol+subdomin+"/levels/"+str(id, "?part=", part)
	var d = await request(u)
	if d and d.has("data"):
		_data = get_json(custom_hash.hashing(custom_hash.GET_HASH, d.data.data))
	return _data
func request(url, method=HTTPClient.METHOD_GET,_data={}):
	var http = HTTPRequest.new()
	add_child(http)
	var header = [
		"Content-Type: application/json",
		"Authorization: Bearer %s"%token
	]
	if _data.keys().size() > 0:
		http.request(url, header, method)
	else:
		http.request(url, header, method, JSON.stringify(_data))
	var d = await http.request_completed
	http.queue_free()
	if d[1] == 0:
		Exit.reload()
		return
	return get_json(d[3])
func get_max_level(ty, pa) -> int:
	var q = "part=%s"%pa.uri_encode() + "&type=%s"%ty.uri_encode()
	var u =protocol+subdomin+"/levels/max?"+q
	var count = await request(u)
	if count and count.has("max_level"):
		return count.max_level
	else:
		return 0
func get_json(_data):
	var j = JSON.new()
	if _data is PackedByteArray:
		
		return j.parse_string(_data.get_string_from_utf8())
	if _data is String:
		return j.parse_string(_data)

func save_server(data):
	for key in data:
		if data[key] is bool:
			data[key] = str("-", int(data[key]))
		if data[key] is Array:
			for x in range(data[key].size()):
				if data[key][x] is bool:
					data[key][x] = str("-", int(data[key][x]))
		if data[key] is Dictionary:
			for x in range(data[key].keys().size()):
				var key2 = data[key].keys()[x]
				if data[key][key2] is bool:
					data[key][key2] = str("-", int(data[key][key2]))
	var http = HTTPRequest.new()
	add_child(http)
	var header = [
		"Content-Type: application/json",
		"Authorization: Bearer %s"%token
	]
	
	http.request(protocol+subdomin+"/auth/update", header, HTTPClient.METHOD_POST, JSON.stringify(data))
	var d = await http.request_completed
	http.queue_free()
	if d[1] == 0:
		Exit.reload()
		return
	#Proccess.get_node("AnimationPlayer").play("rotate")
	#get_tree().paused = true
	#var d = await request(protocol+subdomin+"/auth/update", HTTPClient.METHOD_POST, data)
	#get_tree().paused = false
	#Proccess.get_node("AnimationPlayer").play("hide")
	
	return get_json(d[3])
func random_pos(Rect_range:Rect2, sub_range=Rect2(0, 0, 0, 0)) -> Vector2:
	randomize()
	var x
	var y
	var z
	var n
	if sub_range.size != Vector2.ZERO:
		z = randi_range(0, 1)
		n = randi_range(0, 1)
	if z == null:
		x = randf_range(Rect_range.position.x, Rect_range.end.x)
	elif z == 0:
		x = randf_range(Rect_range.position.x, sub_range.position.x)
	elif z == 1:
		x = randf_range(sub_range.end.x, Rect_range.end.x)
	if n == null:
		y = randf_range(Rect_range.position.y, Rect_range.end.y)
	elif n == 0:
		y = randf_range(Rect_range.position.y, sub_range.position.y)
	elif n == 1:
		y = randf_range(sub_range.end.y, Rect_range.end.y)
	return Vector2(x, y)
func save(_name, num, server=true):
	var confige = ConfigFile.new()
	confige.load(save_path)
	confige.set_value("user", _name, num)
	confige.save(save_path)
	if server and _name != "image":
		save_server({_name:num})
func multy_save(_data:Dictionary):
	var confige = ConfigFile.new()
	confige.load(save_path)
	for key in _data.keys():
		confige.set_value("user", key, _data[key])
	confige.save(save_path)
	save_server(_data)
func load_game(_name, defaulte=null):
	var confige = ConfigFile.new()
	confige.load(save_path)
	if confige.has_section_key("user", _name):
		return confige.get_value("user", _name, defaulte)
	else:
		save(_name, defaulte)
		return defaulte
func get_data(_name, default=0):
	var u =protocol+subdomin+"/auth/get?name="+_name
	var count = await request(u)
	if count and count.has("num") and count.num:
		return count.num
	else:
		return default
func get_image(img:String):
	var http:HTTPRequest = HTTPRequest.new()
	add_child(http)
	http.request(protocol+subdomin+"/static/files/"+img.get_file().uri_encode())
	var d = await http.request_completed
	http.queue_free()
	return d[3]
func load_from_server():
	var data = await request(protocol+subdomin+"/auth/whoami")
	
	if data is Dictionary and data.has("user_details"):
		save("user_name", data.user_details.username, false)
		for key in data.data.keys():
			var data2 = data.data
			if data2[key] is String and data2[key].begins_with("-") and data2[key].length() == 2:
				data2[key] = bool(int(data2[key]))
			if key != "user_name":
				if key == "num1":
					save("score", data2[key], false)
				elif key == "num2":
					save("league_score", data2[key], false)
				else:
					save(key, data2[key], false)
	else:
		return false
	return self
func get_files():
	var images = await request(protocol+subdomin+"/ListFiles?path=icons")
	if !DirAccess.dir_exists_absolute("user://icons"):
		DirAccess.make_dir_absolute("user://icons")
	var savesd_images = DirAccess.get_files_at("user://icons")
	for image in images.files_name:
		if !savesd_images.has(image):
			var new_image = Image.new()
			var buffer = await get_image(image)
			new_image.load_jpg_from_buffer(buffer)
			new_image.load_png_from_buffer(buffer)
			new_image.save_png("user://icons/"+image)
	for image in savesd_images:
		if !images.files_name.has(image):
			DirAccess.remove_absolute("user://icons"+image)
