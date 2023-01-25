extends Area2D
class_name Skeleton
@icon("res://art/icons/skeleton.png")

# TODO: SWITCH NAVIGATION TO ASTAR2DGRID

@onready var NavAgent :NavigationAgent2D = get_node("NavigationAgent2D")
@onready var HandsMarker: Marker2D = get_node("Hand")
@onready var OverHeadMarker: Marker2D = get_node("OverHead")
@onready var StatesManager: SkeletonStatesManager = get_node("StatesManager")

@onready var Scene :GameWorld = get_parent() 

var harvesting:              bool = false
var finished_harvesting:     bool = false
var object_in_hands: Movable = null

var target = null

func _ready() -> void:
	StatesManager.initialise(self)


## every tick chose tje target where to go and actualy move
func _process(_delta: float) -> void:
	pass


## reset the states and forget about an object you were going to
## if there are other things you have to do - it will take new tatget the next tick
func forget_about_object():
	target = null

func chose_target_and_resource(action: int) -> Array:
	NavAgent.target_desired_distance = 70
	var buildings: Array = Scene.get_demanding_buildings(action)
	# iterate through all the buildings that need something
	for building in buildings:
		# iterate through resources that this building needs
		for res in building.my_demand:
			# check if it still needs resources, and if they are not reserved
			if (building.my_demand[res] - building.my_reserved_demand[res].size()) > 0:
				# get all the instances of the resource on scene that can be taken
				var resources
				if res in ResDescription.dropped_rss_sprites.keys():
					resources = Scene.get_all_resources_by_name(res)
				elif res in ResDescription.dropped_rss_types.keys():
					resources = Scene.get_all_resources_by_type(res)
				if resources.is_empty(): continue
				var closest: Movable = get_min_distance_object(resources)
				closest.get_reserved_by_skeleton(self)
				if closest.current_building != null: 
					Scene.try_remove_stored_resource(closest.current_building, closest.rss_name)
				return [building, closest]
	return []


func chose_target_to_harvest() -> void:
	NavAgent.target_desired_distance = 50
	var resources: Array = Scene.get_resources()
	var resource_selected = get_min_distance_object(resources)
	if resource_selected == null: 
		target = null
		return
	resource_selected.get_reserved_by_skeleton(self)
	target = resource_selected

func chose_target_to_store() -> void:
	NavAgent.target_desired_distance = 70
	var storages: Array = Scene.get_storages()
	var storage_selected = get_min_distance_object(storages)
	if storage_selected == null: return
	target = storage_selected

func chose_target_to_clear() -> void:
	NavAgent.target_desired_distance = 5
	var objects : Array = Scene.get_dropped_materials()
	var selected_object: Movable = get_min_distance_object(objects)
	if selected_object == null: return
	target = selected_object
	selected_object.get_reserved_by_skeleton(self)

## has 2 conditions the first one stands for chosing an item that we will follow  
## the second one is for the storage  
## change desired distances respectively to the type of destination we are heading to
func chose_target_to_clear_or_store() -> void:
	pass

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
	object_in_hands.get_taken_by_skeleton(self)

func drop_object() -> void:
	object_in_hands.move(global_position + Vector2(0, 10))
	object_in_hands.get_dropped_by_skeleton()
	object_in_hands = null

func unreserve_object() -> void:
	target.get_dropped_by_skeleton()
	target = null

func harvest_resource():
	target.get_harvested_by_skeleton(self, 3)
	harvesting = true

func finish_harvesting():
	harvesting = false
	finished_harvesting = true

## release object tht you are carrying
## reset the states and make the storage take the object
func place_object_to_building():
	target.get_resource(object_in_hands, self)
	target = null
	object_in_hands = null

func get_rejected_by_building():
	target = null
