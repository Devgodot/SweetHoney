@tool
# Having a class name is handy for picking the effect in the Inspector.
class_name RichTextLight
extends RichTextEffect

var list = []
# To use this effect:
# - Enable BBCode on a RichTextLabel.
# - Register this effect on the label.
# - Use [light param=2.0]hello[/light] in text.
var bbcode = "light"

	

func _process_custom_fx(char_fx):
	var param = char_fx.env.get("param", 1.0)
	var freq = char_fx.env.get("freq", 1.0)
	var num = char_fx.env.get("num", 1.0)
	var len = char_fx.env.get("len", 0.0)
	var alpha = char_fx.env.get("alpha", 1.0)
	var color = char_fx.env.get("color", char_fx.color.to_html(false))
	
	if char_fx.elapsed_time == 0:
		list = []
	if !list.has(char_fx.range):
		if char_fx.glyph_flags != TextServer.GRAPHEME_IS_SPACE and char_fx.glyph_flags != TextServer.GRAPHEME_IS_TAB:
			list.append(char_fx.range)
	
	for x in range(num):
		if char_fx.range.x + x == int(char_fx.elapsed_time * freq) % int([list.size(), len][int(len != 0)] + num):
			if color != char_fx.color.to_html(false):
				char_fx.color = Color(color)
			else:
				char_fx.color += char_fx.color
			char_fx.color.a = 1.0
		else :
			char_fx.color = char_fx.color
			if color != char_fx.color.to_html(false):
				char_fx.color.a = alpha
	return true
