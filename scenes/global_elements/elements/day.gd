extends Button

signal day_chosen
func _on_pressed():
	emit_signal("day_chosen", self)
