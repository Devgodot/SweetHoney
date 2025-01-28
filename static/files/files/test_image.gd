extends Control


# Called when the node enters the scene tree for the first time.
func _test(result, response_code, headers, body, object):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	$VBoxContainer/RichTextLabel.text = str(json.get_data())
	object.queue_free()

func _ready():
	# Create an HTTP request node and connect its completion signal.
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(self._http_request_completed)

	# Perform a GET request. The URL below returns JSON as of writing.
	# Perform a POST request. The URL below returns JSON as of writing.
	# Note: Don't make simultaneous requests using a single HTTPRequest node.
	# The snippet below is provided for reference only.
	var url 
	var body = {
  "firstName": "mhh",
  "lastName": "Fellow",
  "email": "bob.fellow@gmail.com",
  "dateOfBirth": "1996-08-24"
}
	var error = http_request.request("https://api.npoint.io/680855558693fe456753", [], HTTPClient.METHOD_POST, JSON.new().stringify(body))
	if error != OK:
		push_error("An error occurred in the HTTP request.")

# Called when the HTTP request is completed.
func _http_request_completed(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()

	# Will print the user agent string used by the HTTPRequest node (as recognized by httpbin.org).
	print(response)
	

func _on_http_request_request_completed2(result, response_code, headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	
	print(body.get_string_from_utf8())
func _on_http_request_request_completed(result, response_code, headers, body, object):
	if body == null:
		print("a problme exsited")
	if body.size() > 0:
		var image = Image.new()
		if $VBoxContainer/LineEdit.text.get_extension().left(3) == "png":
			image.load_png_from_buffer(body)
		else:
			image.load_jpg_from_buffer(body)
			
		var tex = ImageTexture.create_from_image(image)
		$VBoxContainer/TextureRect.texture = tex
	else:
		print("a problme exsited")
	object.queue_free()
func _on_button_pressed():
	if $VBoxContainer/LineEdit.text != "":
		var http = HTTPRequest.new()
		add_child(http)
		match $VBoxContainer/HBoxContainer/OptionButton.selected:
			1:
				http.request_completed.connect(_test.bind(http))
			0:
				http.request_completed.connect(_on_http_request_request_completed.bind(http))
		var err = http.request($VBoxContainer/LineEdit.text)
		if err != OK:
			print("a problme exsited")


func _on_option_button_item_selected(index):
	$VBoxContainer/TextureRect.hide()
	$VBoxContainer/RichTextLabel.hide()
	match index:
		0:
			$VBoxContainer/TextureRect.show()
		1:
			$VBoxContainer/RichTextLabel.show()
