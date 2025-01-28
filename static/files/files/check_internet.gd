extends Node
signal disconnect_internet
var http = HTTPRequest.new()
# Called when the node enters the scene tree for the first time.
func _ready():
#	add_child(http)
#	http.request_completed.connect(_request.bind(http))
#	http.request("https://mock.apidog.com/m2/363774-0-default/3750064?apidogApiId=3750064&apidogToken=ZHZunnawqfMRhDpCKzpBs3Zlwl1lKONl")
	pass
func _request(result, response_code, header, body, _http):
	if response_code == 0:
		emit_signal("disconnect_internet")
	remove_child(_http)
	var http2 = HTTPRequest.new()
	add_child(http2)
	http2.request_completed.connect(_request2.bind(http2))
	var err = http2.request("https://mock.apidog.com/m2/363774-0-default/3750064?apidogApiId=3750064&apidogToken=ZHZunnawqfMRhDpCKzpBs3Zlwl1lKONl")
	if err != OK:
		emit_signal("disconnect_internet")
func _request2(result, response_code, header, body, _http):
	if response_code == 0:
		emit_signal("disconnect_internet")
	remove_child(_http)
	var http2 = HTTPRequest.new()
	add_child(http2)
	http2.request_completed.connect(_request.bind(http2))
	var err = http2.request("https://mock.apidog.com/m2/363774-0-default/3750064?apidogApiId=3750064&apidogToken=ZHZunnawqfMRhDpCKzpBs3Zlwl1lKONl")
	if err != OK:
		emit_signal("disconnect_internet")
	
