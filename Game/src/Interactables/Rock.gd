class_name Rock
extends InteractableTimed

@onready var stone := preload("res://src/Interactables/Stone.tscn")

var scene
var center_pos: Vector2
var destructable = false

func _ready():
	own_z = 10

func interact() -> void:
	super()

func continue_interaction() -> void:
	super()
	if interaction_stopped: return
	for i in range(randi_range(1, 3)):
		var instance = stone.instantiate()
		
		# Strong dependence on the scene structure!!!
		get_parent().get_parent().get_node("DroppedResources").add_child(instance)
		# TODO: remove magic constants
		instance.global_position = global_position + Vector2(0, -48)
		instance.move(instance.global_position + Vector2(randi_range(-5, 5) * 5, randi_range(-5, 5) * 5))
	die()
	
func die():
	scene.remove_building_from_instances_dict(center_pos, Vector2i(1, 1))
	super()

