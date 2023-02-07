extends Control
class_name FurnaceRssSelector

signal enter_fuel_selection
signal enter_burnable_selection
signal closed

@onready var FuelTexture: TextureRect = get_node("Background/FuelButton/TextureRect")
@onready var BurnableTexture: TextureRect = get_node("Background/BurnableButton/TextureRect")

func set_burnable_texture(resource: String) -> void:
	BurnableTexture.texture = load(ResDescription.dropped_rss_sprites[resource])

func set_fuel_texture(resource: String) -> void:
	FuelTexture.texture = load(ResDescription.dropped_rss_sprites[resource])

func _on_fuel_button_pressed() -> void:
	emit_signal("enter_fuel_selection")

func _on_burnable_button_pressed() -> void:
	emit_signal("enter_burnable_selection")


func _on_texture_button_pressed() -> void:
	emit_signal("closed")
	hide()
