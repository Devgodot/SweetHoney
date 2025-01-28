extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	var data = {
		"mhh83":{
			"password": "12345678",
			"score": 89,
			"phone": "09100977913"
			
		}
	}
	var json = JSON.stringify(data)
	$HTTPRequest.request("https://mock.apidog.com/m2/363774-0-default/3730616?apidogToken=teqN02VceRLX4IGVVHtSkOy296tqjhGb", ["Content-Type : application/json"], HTTPClient.METHOD_PATCH, json)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_http_request_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	print(json.get_data())
