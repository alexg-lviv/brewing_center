## Building: Area2d
##
## abstract class from which inherit all the buildings
## that can interact with ober buildings (belts)
## and Transportable Items
class_name Building
extends Area2D

var _forward: Building = null

## calculates relative direction from which other belt is connected to current belt 
func get_relative_rotation(other_rotation: int) -> int:
	return ((other_rotation - int(rotation_degrees) + 360) % 360)


func _on_AreaTo_area_entered(area):
	pass

## function that is called on deletion of the next belt
func del_forward():
	_forward = null

func die():
	pass

func send_obj():
	pass

func ready_callback():
	send_obj()
