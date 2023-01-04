extends Building

@onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")
@onready var Pulser := get_node("Polygon2D")

var StoredItems: Array = Array([null, null, null, null, null, null, null, null, null])
@onready var Slots: Array = get_node("StorageSlots").get_children()


var stored_objects = 0
var temp_obj

func _process(delta: float) -> void:
	if Glob.drag_mode:
		AnimPlayer.play("Pulsing")
		if stored_objects >= 9:
			Pulser.self_modulate = "#ff0000"
		else:
			Pulser.self_modulate = "#00ff00"
	else:
		AnimPlayer.play("Idle")
	

	if Glob.drag_mode and Input.is_action_just_released("click") and is_instance_valid(temp_obj) and stored_objects < 9:
		temp_obj.get_taken_by_building(self)
		take_object()

func take_object() -> void:
	for i in range(len(StoredItems)):
		if StoredItems[i] == null:
			temp_obj.move(Slots[i].global_position)
			StoredItems[i] = temp_obj
			temp_obj = null
			stored_objects += 1
			break

func forget_about_item(item: Interactable) -> void:
	StoredItems[StoredItems.find(item)] = null
	stored_objects -= 1

func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Movables"):
		temp_obj = area

func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Movables"):
		temp_obj = null
