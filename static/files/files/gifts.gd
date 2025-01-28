extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$Button/TextureRect/TextureRect2.texture = ImageTexture.create_from_image(Image.load_from_file("user://gift3_img/"+DirAccess.get_files_at("user://gift3_img")[0]))
	$Button2/TextureRect/TextureRect2.texture = ImageTexture.create_from_image(Image.load_from_file("user://gift2_img/"+DirAccess.get_files_at("user://gift2_img")[0]))
	$Button3/TextureRect/TextureRect2.texture = ImageTexture.create_from_image(Image.load_from_file("user://gift1_img/"+DirAccess.get_files_at("user://gift1_img")[0]))
	$Button4/TextureRect/TextureRect2.texture = $Button/TextureRect/TextureRect2.texture
	$Button5/TextureRect/TextureRect2.texture = $Button2/TextureRect/TextureRect2.texture
	$Button6/TextureRect/TextureRect2.texture = $Button3/TextureRect/TextureRect2.texture
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
