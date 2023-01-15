class_name Storage
extends Building

@onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")
@onready var Pulser := get_node("Polygon2D")

@onready var Slots: Array = get_node("StorageSlots").get_children()
var StoredItems: Array = Array([null, null, null, null, null, null, null, null, null])


var stored_objects = 0



## if the drag_mode is active - all the storages signal that they are available to place items
## TODO: add visibility notifiers for optimisation
func _process(_delta: float) -> void:
	if Glob.drag_mode and stored_objects < 9:
		AnimPlayer.play("Pulsing")
		if stored_objects >= 9:
			Pulser.self_modulate = "#ff0000"
		else:
			Pulser.self_modulate = "#00ff00"
	else:
		AnimPlayer.play("Idle")


## accept the object if there is free place and add to counter
func take_object(from_skeleton: bool = false, object: Movable = null) -> void:
	if from_skeleton:
		for i in range(len(StoredItems)):
			if StoredItems[i] != null: continue
			object.get_taken_by_building(self)
			object.move(Slots[i].global_position)
			StoredItems[i] = object
			stored_objects += 1
			break
	else:
		for i in range(len(StoredItems)):
			if StoredItems[i] != null: continue
			temp_obj.get_taken_by_building(self)
			temp_obj.move(Slots[i].global_position)
			StoredItems[i] = temp_obj
			temp_obj = null
			stored_objects += 1
			break

## release item and let it travel to the bright future
func forget_about_item(item: Interactable) -> void:
	StoredItems[StoredItems.find(item)] = null
	stored_objects -= 1

## remember that item entered yourself
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Movables"):
		temp_obj = area
		area.get_reserved_by_building(self)

## ok forget about it, its GONE
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Movables"):
		area.forget_about_reservation_building()
		temp_obj = null

