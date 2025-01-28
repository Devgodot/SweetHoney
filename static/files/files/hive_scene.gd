extends Control
signal start

var timer
var collect = false
@export var score = 0

func load_game(_name, defaulte = null):
	var confige = ConfigFile.new()
	confige.load(save_path)
	return confige.get_value("user", _name, defaulte)
func collect_honey(_score, pos, num):
	collect = true
	save("score",  _score)
	if get_tree().has_group("score"):
		get_tree().get_nodes_in_group("score")[0].text = "امتیاز : " + str(_score)
	var animation = %AnimationPlayer.get_animation("collect_honey")
	animation.track_insert_key(0, 0.0, pos)
	$TextureProgressBar.scale = Vector2((num * 0.2) + 0.2, (num * 0.2) + 0.2)
	animation.track_insert_key(2, 0.0, Vector2((num * 0.2) + 0.2, (num * 0.2) + 0.2))
	%AnimationPlayer.play("collect_honey")
func _ready():
	score = load_game("score", 0)
	$TextureProgressBar2.value = score * 100 / 5000
	$TextureProgressBar2/Label.text = str(score)
	var data = await UpdateData.request(UpdateData.protocol+UpdateData.subdomin+"/auth/get?name=open_hives")
	
	if get_tree().has_group("honey_hive") and data.num:
		for x in range(get_tree().get_nodes_in_group("honey_hive").size()):
			var h = get_tree().get_nodes_in_group("honey_hive")[x]
			h.onlock = bool(data.num[x])
			if h.onlock:
				h.disabled = false
				h.texture_normal = load("res://sprite/hive2.png")
				h.get_node("timer").start(str("hive", h.num), 0)
				h.get_node("timer").show()
	start.emit()
var save_path = "user://data.cfg"
func save(_name, num):
	var confige = ConfigFile.new()
	confige.load(save_path)
	confige.set_value("user", _name, num)
	confige.save(save_path)
func _notification(what):
	if what == NOTIFICATION_WM_GO_BACK_REQUEST:
		_on_button_pressed()
func _on_button_pressed():
	Exit.change_scene("res://scenes/start.tscn")

func _process(delta):
	
	if (%AnimationPlayer.current_animation == "collect_honey" and %AnimationPlayer.current_animation_position >= 4) or \
	(%AnimationPlayer.current_animation == "end" and %AnimationPlayer.current_animation_position <= 1):
		var tween = get_tree().create_tween()
		tween.tween_property($TextureProgressBar2, "value", load_game("score", 0) * 100 / 5000, 2)
		var tween2 = get_tree().create_tween()
		tween2.tween_property(self, "score", load_game("score", 0), 1.5)
	$TextureProgressBar2/Label.text = str(int(score))
func _on_animation_player_animation_finished(anim_name):
	$Node2D.queue_free()


func _on_animation_player_animation_finished2(anim_name):
	match anim_name:
		"collect_honey":
			%AnimationPlayer.play("end")
		"end":
			collect = false
