## Resource that is created and placed on map
##
## can be harvested  
## serves as the masterclass for all the resources  
## the sprite and kind of resource, and the drop behaviour are determined by
## rss_name with its setter function
extends InteractableTimed
class_name ResourceOnMap
@icon("res://art/icons/tree.png")

@onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")

@onready var dropped_item := preload("res://src/Interactables/DroppedResource.tscn")

var rss_name: String = "" : set = _set_rss_name

var scene
var center_pos: Vector2
var destructable = false

## z-index shenenigans
func _ready():
	own_z = 10

func interact() -> void:
	super()

## a function to continue interaction, owerrided from the parent class
## spawns the random amount of resources dropped from self and dies
func continue_interaction() -> void:
	super()
	if interaction_stopped: return
	for i in range(randi_range(ResDescription.rss_drop_bounds[rss_name].x, ResDescription.rss_drop_bounds[rss_name].y)):
		var instance: DroppedResource = dropped_item.instantiate()
		
		# Strong dependence on the scene structure!!!
		get_parent().get_parent().get_node("DroppedResources").add_child(instance)
		instance.rss_name = ResDescription.rss_drop_resource_types[rss_name]
		# TODO: remove magic constants
		instance.global_position = global_position + Vector2(0, -48)
		instance.move(instance.global_position + Vector2(randi_range(-5, 5) * 5, randi_range(-5, 5) * 5))
	die()

## well basically death function
func die():
	scene.remove_building_from_instances_dict(center_pos, Vector2i(1, 1))
	super()

## setter for rss_name variable
func _set_rss_name(new_name: String) -> void:
	rss_name = new_name
	AnimPlayer.play(rss_name)
	interaction_time = ResDescription.rss_harvest_time[rss_name]
