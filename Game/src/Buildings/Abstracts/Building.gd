class_name Building
extends Area2D

@export var health: int = 100

## size of the building in grid cells of game
@export var self_cells_size: Vector2i = Vector2i(1,1)

var center_pos: Vector2
var destructable = true

var temp_obj: DroppedResource = null

var my_reserved_demand: Dictionary = {}
var my_demand: Dictionary = {}


## calculates relative direction from which other belt is connected to current belt 
func get_relative_rotation(other_rotation: float) -> float:
	var rel_rotation: float = other_rotation - rotation
	return rel_rotation if rel_rotation >= 0 else rel_rotation+2*PI

func die() -> void:
	queue_free()


func forget_about_item(_item: Interactable) -> void:
	pass


## remember that the resource should bring us resource so we dont need other skeletons to bring it
func reserve_demanded_res_by_skeleton(skeleton: Skeleton, resource: String):
	my_reserved_demand[resource].append(skeleton)

