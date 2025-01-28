extends Node3D

var new_anime = false
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if randi_range(0, 1000) == 0 and get_tree().get_processed_tweens().size() == 0:
		var tween = get_tree().create_tween()
		tween.tween_property($Skeleton3D, "rotation:y", deg_to_rad(-40), 0.5)
		tween.play()
		
		await get_tree().create_timer(randi_range(2, 4)).timeout
		var tween2 = get_tree().create_tween()
		tween2.tween_property($Skeleton3D, "rotation:y", deg_to_rad(0), 0.5)
		tween2.play()
		
	if randi_range(0, 1000) == 0 and $AnimationPlayer.current_animation == "idle":
		new_anime = true
	if new_anime and int($AnimationPlayer.current_animation_position) == 0:
		new_anime = false
		$AnimationPlayer.play(["happy", "sad", "transition"][randi_range(0, 2)])
		await  $AnimationPlayer.animation_finished
		$AnimationPlayer.play("idle")
		
