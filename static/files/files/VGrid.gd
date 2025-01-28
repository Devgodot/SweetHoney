class_name VGrid
extends HBoxContainer

@export var rows : int
func _enter_tree():
	alignment = BoxContainer.ALIGNMENT_CENTER
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	size_flags_vertical = Control.SIZE_EXPAND_FILL
	var vboxes = []
	var _size = (get_children().size() / rows) + (1 - int(get_children().size() % rows == 0))
	for x in range(_size):
		var vbox = VBoxContainer.new()
		vbox.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox.size_flags_vertical = Control.SIZE_EXPAND_FILL
		for c in range(get_children().size() / _size):
			if get_children().size() > c + (x * rows):
				var child = get_child(c + (x * rows))
				vbox.add_child(child.duplicate())
		vboxes.append(vbox)
	for child in get_children():
		child.queue_free()
	for v in vboxes:
		add_child(v)
