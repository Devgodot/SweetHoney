extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_texture_button_pressed():
	if $AnimationPlayer.is_playing() :
		await $AnimationPlayer.animation_finished
	Exit.change_scene("res://scenes/start.tscn")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed() and !$AnimationPlayer.is_playing() and $AnimationPlayer.current_animation_position != 0:
			$AnimationPlayer.play_backwards($AnimationPlayer.current_animation)
			await $AnimationPlayer.animation_finished
			$AnimationPlayer.play("RESET")
func _on_button_pressed(extra_arg_0: int) -> void:
	$AnimationPlayer.play(str("gift",extra_arg_0))
