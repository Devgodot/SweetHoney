extends Control

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "start" and $AnimationPlayer.current_animation_position != 0:
		$AnimationPlayer.play_backwards("start")
		await $AnimationPlayer.animation_finished
		$AnimationPlayer.play("RESET")
		Exit.change_scene("res://scenes/load.tscn", false)
