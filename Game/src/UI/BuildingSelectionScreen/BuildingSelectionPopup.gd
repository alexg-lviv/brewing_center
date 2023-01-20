extends Control
class_name BuildingSelection

signal closed

func _ready() -> void:
	hide()

func _on_texture_button_pressed() -> void:
	emit_signal("closed")
	hide()
