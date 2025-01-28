extends RigidBody2D

var drag = false
var correct = false
var start_pos
var sellected
var show_state = false
# Called when the node enters the scene tree for the first time.
func _ready():
	start_pos = global_position
	
#	$Label.scale = Vector2(10000 / $Label.size.x, 10000 / $Label.size.y) * 0.01
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if drag and !show_state:
		global_position = get_global_mouse_position()
	if !Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		drag = false
		if !sellected and !show_state:
			global_position = start_pos
	if show_state and !sellected:
		if correct:
			drag = true
			var jar
			if get_tree().has_group("jar"):
				jar = get_tree().get_nodes_in_group("jar")[0]
			var tween = get_tree().create_tween()
			tween.tween_property(self, "global_position", jar.get_node("Marker2D").global_position, 0.5)
			tween.set_ease(Tween.EASE_OUT)
			await tween.finished
			$Label.scale = Vector2(10000 / $Label.size.x, 10000 / $Label.size.y) * 0.01
			$CollisionShape2D.scale = $Label.scale
			drag = false
			freeze = false
			sellected = true
			set_collision_mask_value(1, true)
			set_collision_layer_value(1, true)
			set_collision_layer_value(2, false)
			jar.target = null

		



func _on_label_gui_input(event):
	if event is InputEventMouseButton and event.is_pressed() and !sellected:
		drag = true
		
