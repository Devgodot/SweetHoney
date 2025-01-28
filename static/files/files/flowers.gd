extends Area2D


var target = null
@export_range(1, 3) var num:int = 1
@export_range(-1, 1) var dir:int = 1
@export var range2:int = 100
@export var speed:float = 1
func _ready():
	var new_material = ShaderMaterial.new()
	new_material.shader = preload("res://shaders/flower.gdshader")
	new_material.set_shader_parameter("range", range2)
	new_material.set_shader_parameter("speed", speed)
	new_material.set_shader_parameter("dir", dir)
	$Flower4.material = new_material
	$AnimationPlayer.play(str(num))
func _on_area_2d_body_entered(body):
	if !target and !body.go_back:
		target = body
		var velocity = Vector2(1, 0).rotated((global_position - body.global_position).normalized().angle())
		if velocity.x < 0 and body.scale.x > 0:
			body.scale.x *= -1
		body.velocity2 = velocity * body.SPEED

func _on_body_entered(body):
	if body == target and !body.go_back:
		body.collect()


func _on_body_exited(body):
	if target == body:
		target = null
