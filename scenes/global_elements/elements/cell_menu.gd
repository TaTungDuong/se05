extends VBoxContainer

@export var text = ""
@export var filter = ""
@onready var input = $LineEdit
@onready var label = $HBoxContainer/Label
@onready var option = $HBoxContainer/OptionButton

func _process(_delta):
	option.fit_to_longest_item  = false
	label.text = text
	input.placeholder_text = "Filter"
	filter = input.text

signal filter_submitted
func _on_line_edit_text_submitted(_new_text):
	emit_signal("filter_submitted")

signal column_sorted
func _on_option_button_item_selected(index):
	var order = ";"
	if index == 1:
		order = " order by " + text + " asc;"
	if index == 2:
		order = " order by " + text + " desc;"
	emit_signal("column_sorted", order)
