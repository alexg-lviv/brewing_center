class_name Skeleton
extends Area2D

@onready var player = get_node("../Player")
@onready var NavAgent :NavigationAgent2D = get_node("NavigationAgent2D")

@onready var Scene :GameWorld = get_parent() 

var clear_floor_state:  bool = true
var heading_to_object:  bool = false
var heading_to_storage: bool = false

var target_pos: Vector2

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	if clear_floor_state:
		chose_target_to_clear_or_store()
		NavAgent.set_target_location(target_pos)
		var direction := global_position.direction_to(NavAgent.get_next_location())
		global_position += direction * 100. * delta


func chose_target_to_clear_or_store() -> void:
	if !heading_to_object and !heading_to_storage:
		var objects : Array = Scene.get_dropped_materials()
		var selected_object = get_min_distance_object(objects)
		if selected_object == null: return
		heading_to_object = true
		target_pos = selected_object.global_position
	if heading_to_storage:
		var storages: Array = Scene.get_storages()
		var storage_selected = get_min_distance_object(storages)
		target_pos = storage_selected.global_position


func get_min_distance_object(objects: Array) -> Variant:
	if objects.is_empty(): return null
	var min_dist: float  = global_position.distance_squared_to(objects[0].global_position)
	var min_obj : Object = objects[0]
	for item in objects:
		var temp_dist = global_position.distance_squared_to(item.global_position)
		if temp_dist < min_dist:
			min_dist = temp_dist
			min_obj = item
	return min_obj
