extends Node


var save_path = "user://data.cfg"

func save(_name, num):
	var confige = ConfigFile.new()
	confige.load(save_path)
	confige.set_value("user", _name, num)
	confige.save(save_path)
func get_scene(path, anime=true, mode=0):
	if anime:
		if ChaneSene.get_node("AnimationPlayer").current_animation != "open_close":
			ChaneSene.get_node("AnimationPlayer").play("open_close")
			if mode == 1:
				ChaneSene.get_node("HBoxContainer/TextureRect").texture = load("res://sprite/Untitled_۲۰۲۴۱۲۰۶_۱۰۲۲۱۶.jpg")
				ChaneSene.get_node("HBoxContainer/TextureRect2").texture = load("res://sprite/Untitled_۲۰۲۴۱۲۰۶_۱۰۲۲۱۶.jpg")
			else:
				ChaneSene.get_node("HBoxContainer/TextureRect").texture = load("res://sprite/Untitled_۲۰۲۴۱۱۱۸_۱۴۳۳۵۶.jpg")
				ChaneSene.get_node("HBoxContainer/TextureRect2").texture = load("res://sprite/Untitled_۲۰۲۴۱۱۱۸_۱۴۳۳۵۶.jpg")

		if !DirAccess.dir_exists_absolute("user://resources"):
			DirAccess.make_dir_absolute("user://resources")
	await get_tree().create_timer(0.5).timeout
	var requst = HTTPRequest.new()
	add_child(requst)
	
	requst.request(UpdateData.protocol+UpdateData.subdomin+"/download?filename="+path.get_file(), UpdateData.get_header())
	var d = await requst.request_completed
	var file = FileAccess.open("user://resources/"+path.get_file(), FileAccess.WRITE)
	file.store_buffer(d[3])
	file.close()
	requst.request(UpdateData.protocol+UpdateData.subdomin+"/download?filename="+path.get_file().get_basename()+".gd", UpdateData.get_header())
	d = await requst.request_completed
	var file2 = FileAccess.open("user://resources/"+path.get_file().get_basename()+".gd", FileAccess.WRITE)
	file2.store_buffer(d[3])
	file2.close()
	var path2 = "user://resources/"+path.get_file()
	requst.queue_free()
	
	ResourceLoader.load_threaded_request(path2)
	while ResourceLoader.load_threaded_get_status(path2) == 1:
		if anime:
			pass
		
	return [ResourceLoader.load_threaded_get(path2), ResourceLoader.load("user://resources/"+path.get_file().get_basename()+".gd")]
func change_scene(path, anime=true, mode=0):
	var d = await get_scene(path, anime, mode)
	var scene = d[0]
	for child in get_tree().get_root().get_children():
		if child != AddBee and child != ChaneSene and child != self  and child != CheckInternet and child != UpdateData:
			child.queue_free()
	var s = scene.instantiate()
	s.set_script(d[1])
	get_tree().get_root().add_child(s)
	if anime:
		if s.has_signal("start"):
			await s.start
		ChaneSene.get_node("AnimationPlayer").play_backwards("open_close")
