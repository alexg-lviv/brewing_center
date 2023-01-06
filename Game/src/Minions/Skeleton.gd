class_name Skeleton
extends Area2D

@onready var player = get_node("../Player")
@onready var NavAgent :NavigationAgent2D = get_node("NavigationAgent2D")
@onready var HandsMarker: Marker2D = get_node("Marker2D")

@onready var Scene :GameWorld = get_parent() 

var clear_floor_state:  bool = true
var heading_to_object:  bool = false
var heading_to_storage: bool = false

var harvest_resources_state: bool = false

var object_in_hands: Movable = null

var target = null

func _ready() -> void:
	pass


## every tick chose tje target where to go and actualy move
func _process(delta: float) -> void:
	if clear_floor_state:
		chose_target_to_clear_or_store()
		if !is_instance_valid(target): return
		NavAgent.set_target_location(target.global_position)
		var direction := global_position.direction_to(NavAgent.get_next_location())
		global_position += direction * 100. * delta

## reset the states and forget about an object you were going to
## if there are other things you have to do - it will take new tatget the next tick
func forget_about_object():
	target = null
	heading_to_object = false
	heading_to_storage = false

## has 2 conditions the first one stands for chosing an item that we will follow  
## the second one is for the storage  
## change desired distances respectively to the type of destination we are heading to
func chose_target_to_clear_or_store() -> void:
	if !heading_to_object and !heading_to_storage:
		NavAgent.target_desired_distance = 5
		var objects : Array = Scene.get_dropped_materials()
		var selected_object: Movable = get_min_distance_object(objects)
		if selected_object == null: return
		heading_to_object = true
		target = selected_object
		selected_object.get_reserved_by_skeleton(self)
	if heading_to_storage:
		NavAgent.target_desired_distance = 70
		var storages: Array = Scene.get_storages()
		var storage_selected = get_min_distance_object(storages)
		target = storage_selected

## get the clothes one from an array
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

## pick up an obkect
## reset the states and callback to object
func pick_up_object() -> void:
	object_in_hands = target
	target = null
	heading_to_object = false
	heading_to_storage = true
	object_in_hands.get_taken_by_skeleton(self)

## release object tht you are carrying
## reset the states and make the storage take the object
func place_object_to_storage() -> void:
	target.take_object(true, object_in_hands)
	target = null
	heading_to_object = false
	heading_to_storage = false
	object_in_hands = null

## regarding to the states, do different things
func _on_navigation_agent_2d_target_reached() -> void:
	if clear_floor_state and heading_to_object:
		pick_up_object()
	elif clear_floor_state and heading_to_storage:
		place_object_to_storage()
