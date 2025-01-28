extends Panel
signal button_pressed
@export var btn_text : PackedStringArray
@export var btn_style_n = StyleBox
@export var btn_style_h = StyleBox
@export var btn_style_p = StyleBox
@export var font : LabelSettings
func add_item(text, style, font, id):
	var hbox = HBoxContainer.new()
	hbox.alignment = BoxContainer.ALIGNMENT_CENTER
	
	var btn = Button.new()
	btn.text = text
	btn.add_theme_stylebox_override("normal", style[0])
	btn.add_theme_stylebox_override("hover", style[1])
	btn.add_theme_stylebox_override("pressed", style[2])
	btn.add_theme_stylebox_override("focus", StyleBoxEmpty.new())
	btn.add_theme_color_override("font_color", font.font_color)
	btn.add_theme_color_override("font_focus_color", font.font_color)
	btn.add_theme_color_override("font_hover_color", font.font_color)
	btn.add_theme_color_override("font_pressed_color", font.font_color)
	btn.add_theme_color_override("font_outline_color", font.outline_color)
	btn.add_theme_font_override("font", font.font)
	btn.add_theme_font_size_override("font_size", font.font_size)
	btn.add_theme_constant_override("outline_size", font.outline_size)
	btn.pressed.connect(_on_btn_pressed.bind(id))
	hbox.add_child(btn)
	$ScrollContainer/VBoxContainer.add_child(hbox)
# Called when the node enters the scene tree for the first time.
func _ready():
	for x in range(btn_text.size()):
		add_item(btn_text[x], [btn_style_n, btn_style_h, btn_style_p], font, x)
	
func _on_btn_pressed(id):
	
	emit_signal("button_pressed", id)
	hide()


func _unhandled_input(event):
	if event is InputEventMouseButton and event.is_pressed():
		hide()
