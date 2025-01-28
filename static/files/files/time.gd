extends Label

signal timeout

enum MODE {Day, Hour}
@export var mode = MODE.Day
var current_time = {"year": 2023, "month": 1, "day": 1, "second" : 0,  "minute" : 0,  "hour" : 0}
var local_time = 0
@export var open_time = {"year": 2023, "month": 8, "day": 25, "second" : 0,  "minute" : 0,  "hour" : 0}
var month_day = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
var start_timer = false
var time_left = ""
var start_download = true
@export var open_time2 = {"hour":0, "minute":0, "second":0}
var _base_name = "gift"
var save_path = "user://data.cfg"
# Called when the node enters the scene tree for the first time.

func save(_name, num):
	var confige = ConfigFile.new()
	confige.load(save_path)
	confige.set_value("user", _name, num)
	confige.save(save_path)
func load_game(_name, defaulte=null, path=save_path):
	var confige = ConfigFile.new()
	confige.load(path)
	return confige.get_value("user", _name, defaulte)
func day_timer(year : int, month : int, day : int, hour : int, minute : int, second : int):
	open_time = {"year": year, "month": month, "day": day, "second" : second,  "minute" : minute,  "hour" : hour}
	start_timer = true

func hour_timer(hour : int, minute : int, second : int):
	open_time2 = {"hour":hour, "minute":minute, "second":second}
	start_timer = true
func store_time():
	var file = FileAccess.open("res://files/daily_gift_time.json", FileAccess.WRITE)
	file.store_line(JSON.stringify(open_time2))
	file.close()
func stop():
	start_timer = false
func _ready():
	var time_request = HTTPRequest.new()
	add_child(time_request)
	time_request.request_completed.connect(_on_time_request_completed.bind(time_request))
	time_request.request(UpdateData.protocol+UpdateData.subdomin+"/auth/GetTime", UpdateData.get_header(), HTTPClient.METHOD_POST, JSON.stringify({"name":_base_name, "mode":mode}))
	
func start(_name, time, _mode=1):
	_base_name = _name
	mode = _mode
	start_timer = true
	match mode:
		MODE.Day:
			open_time = time
		MODE.Hour:
			open_time2 = time
	var time_request = HTTPRequest.new()
	add_child(time_request)
	time_request.request_completed.connect(_on_time_request_completed.bind(time_request))
	time_request.request(UpdateData.protocol+UpdateData.subdomin+"/auth/GetTime", UpdateData.get_header(), HTTPClient.METHOD_POST, JSON.stringify({"name":_base_name, "mode":mode}))
	
func _on_time_request_completed(result, response_code, headers, body, http):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	if response:
		if response.has("gift"):
			emit_signal("timeout")
			current_time = 0
		if response.has("time"):
			current_time = int(response["time"])
			start_download = false
			http.queue_free()
			
	else:
		http.request(UpdateData.protocol+UpdateData.subdomin+"/auth/GetTime", UpdateData.get_header(), HTTPClient.METHOD_POST, JSON.stringify({"name":_base_name, "mode":mode}))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func update_time():
	var time_request = HTTPRequest.new()
	add_child(time_request)
	time_request.request_completed.connect(_on_time_request_completed.bind(time_request))
	time_request.request(UpdateData.protocol+UpdateData.subdomin+"/auth/GetTime", UpdateData.get_header(), HTTPClient.METHOD_POST, JSON.stringify({"name":_base_name, "mode":mode}))
func _process(delta):

	local_time += delta
	if local_time > 1:
		local_time -= 1
		if compute_time():
			update_time()
	if start_timer and !start_download:
		var days = 0
		var d = 1
		var t = ""
		var t2 = ":"
		var t3 = ":"
		match mode:
			MODE.Day:
				var result = int(open_time) - current_time
				if int(result / 60) % 60 <= 9:
					t2 = ":0"
				if result % 60 <= 9:
					t3 = ":0"
				if result / 3600 <= 9:
					t = "0"
				if result > 0:
					time_left = t + str(result / 3600) + t2 + str(int(result / 60) % 60) + t3 + str(result % 60)
				elif result <= 0:
					emit_signal("timeout")
			MODE.Hour:
				var result = 86400 - current_time
				if result > 0:
					if int(result / 60) % 60 <= 9:
						t2 = ":0"
					if result % 60 <= 9:
						t3 = ":0"
					if result / 3600 <= 9:
						t = "0"
					time_left = t + str(result / 3600) +t2 + str(int(result / 60) % 60) + t3 + str(result % 60)
				elif result <= 0 and !load_game(_base_name, false):
					emit_signal("timeout")
					time_left = 0
	else:
		time_left = ""
	text = time_left
	
func compute_time():
	var r = false
	if current_time is Dictionary:
		current_time.second += 1
		if current_time.second >= 60:
			current_time.second = 0
			r = true
			current_time.minute += 1
			if current_time.minute >= 60:
				current_time.minute = 0
				current_time.hour += 1
				if current_time.hour >= 24:
					current_time.hour = 0
	else:
		current_time += 1
	return r
