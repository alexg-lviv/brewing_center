## Resource that is created and placed on map
##
## can be harvested  
## serves as the masterclass for all the resources  
## the sprite and kind of resource, and the drop behaviour are determined by
## self_name with its setter function
class_name ResourceOnMap
extends InteractableTimed
@icon("res://art/icons/tree.png")

@onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")
@onready var ResSprite: Sprite2D = get_node("Sprite2d")

@onready var dropped_item := preload("res://src/Interactables/DroppedItem.tscn")

var self_name: String = "" : set = _set_rss_name

var scene: GameWorld
var center_pos: Vector2
var destructable = false

## z-index shenenigans
func _ready():
	own_z = 10

func interact() -> void:
	if ResDescription.rss_harvest_tool[self_name] == Glob.curr_tool_selected:
		super()

## a function to continue interaction, owerrided from the parent class
## spawns the random amount of resources dropped from self and dies
func continue_interaction() -> void:
	super()
	if interaction_stopped: return
	for temp_res in ResDescription.rss_drop_bounds[self_name].keys():
		var probs: Vector2i = ResDescription.rss_drop_bounds[self_name][temp_res]
		for i in range(randi_range(probs.x, probs.y)):
			var instance: DroppedItem = dropped_item.instantiate()
			
			# Strong dependence on the scene structure!!!
			get_parent().get_parent().get_node("DroppedResources").add_child(instance)
			instance.self_name = temp_res
			# TODO: remove magic constants
			instance.global_position = global_position + Vector2(0, -48)
			instance.move(instance.global_position + Vector2(randi_range(-5, 5) * 5, randi_range(-5, 5) * 5))
	die()

## well basically death function
func die():
	scene.remove_building_from_instances_dict(center_pos, Vector2i(1, 1))
	super()

## setter for self_name variable
func _set_rss_name(new_name: String) -> void:
	self_name = new_name
	AnimPlayer.play(self_name)
	var temp_arr = ResDescription.rss_sprites[self_name]
	ResSprite.texture = load(temp_arr[randi_range(0, temp_arr.size()-1)])
	
	interaction_time = ResDescription.rss_harvest_time[self_name]

func mirror() -> void:
	scale.x = -1
