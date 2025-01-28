@tool
# Having a class name is handy for picking the effect in the Inspector.
class_name RichTextScaler
extends RichTextEffect


# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [scaler param=2.0]hello[/scaler] in text.
var bbcode = "scaler"


func _process_custom_fx(char_fx):
	var param = char_fx.env.get("max", 1.0)
	var param2 = char_fx.env.get("min", 0.5)
	var param3 = char_fx.env.get("freq", 1)
	var space = char_fx.env.get("space", 0)
	var param4 = char_fx.env.get("offset", [5, 5])
	char_fx.offset = Vector2(-param4[0], param4[1])
	var t = char_fx.transform
	var pos = char_fx.range.x - 1
	space = -clamp((abs(sin(char_fx.elapsed_time * param3))) * param, param2, param) * param * 5
	char_fx.transform = Transform2D(t.get_rotation(), Vector2(1, 1) * clamp((abs(sin(char_fx.elapsed_time * param3))) * param, param2, param) ,t.get_skew(), t.get_origin() + Vector2((pos * param * 4) + (pos * space) +(param4[0] * param), -param4[0]))
	return true
