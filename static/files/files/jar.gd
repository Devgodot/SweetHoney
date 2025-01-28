extends Area2D

var data
var target:RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if target:
		if !target.drag:
			target.global_position = $Marker2D.global_position
			if target.correct:
				target.get_node("Label").modulate = Color.GREEN
			else:
				target.get_node("Label").modulate = Color.RED
			
			target.freeze = false
			target.sellected = true
			target.set_collision_mask_value(1, true)
			target.set_collision_layer_value(1, true)
			target.set_collision_layer_value(2, false)
			target.get_node("Label").scale = Vector2(7000 / target.get_node("Label").size.x, 7000 / target.get_node("Label").size.y) * 0.01
			target.get_node("CollisionShape2D").scale = target.get_node("Label").scale
			target = null
			

func _on_body_entered(body:RigidBody2D):
	target = body




func _on_body_exited(body):
	target = null
