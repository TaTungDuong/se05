extends Label

@onready var button = $Button
@export var table = ""
@export var field = ""
@export var id = 0

const theme_normal = preload("res://assets/resources/themes/theme_cell.tres")
const theme_select = preload("res://assets/resources/themes/theme_cell_selected.tres")

signal cell_pressed

func _ready():
	button.disabled = false
	self.theme = theme_normal

func _on_button_pressed():
	self.emit_signal("cell_pressed", self)
