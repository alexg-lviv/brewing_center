extends Control
class_name CraftRssSelection

signal item_activated(item: String)
signal closed

@onready var List: ItemList = get_node("TextureRect/ScrollContainer/ItemList")

var items: Array[String] = []
var selected_item 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func clear():
	List.clear()
	items.clear()

func add_item(item: String, string_to_write: String) -> void:
	List.add_item(string_to_write, load(ResDescription.dropped_rss_sprites[item]))
	items.append(item)


func _on_item_list_item_activated(index: int) -> void:
	emit_signal("item_activated", items[index])

func hide() -> void:
	visible = false

func show() -> void:
	visible = true


func _on_texture_button_pressed() -> void:
	emit_signal("closed")
	hide()
