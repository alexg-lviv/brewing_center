## Building: Area2d
##
## abstract class from which inherit all the buildings
## that can interact with ober buildings (belts)
## and Transportable Items
class_name Building
extends Area2D

# "double linked list" variables
var left     :Building  = null
var right    :Building  = null
var back     :Building  = null
var forward  :Building  = null

var direction_to_next: String
var receiving_queue: Array

## calculates relative direction from which other belt is connected to current belt 
func get_relative_rotation(other_rotation: float) -> float:
	var rel_rotation: float = other_rotation - rotation
	return rel_rotation if rel_rotation >= 0 else rel_rotation+2*PI


func _on_AreaTo_area_entered(area):
	pass

## function that is called checked deletion of the next belt
func del_forward():
	forward = null

func die():
	pass

func send_obj():
	pass

func ready_callback():
	send_obj()

func receive(area):
	pass

func dequeue() -> String:
	return receiving_queue.pop_front()

func enqueue(direction_from: String):
	if   direction_from == "back" : receiving_queue.push_back("back")
	elif direction_from == "left" : receiving_queue.push_back("left")
	elif direction_from == "right": receiving_queue.push_back("right")