class_name MovableItem
extends Area2D
## Movable Item class for the transportation operations
##
## an item that is being created by spawner and transported by belts

## function of lerp movement to specified position
func move(dest_position: Vector2):
	var tween := get_tree().create_tween()
	tween.tween_property(self, "global_position", dest_position, 0.5)

func die():
	queue_free()

