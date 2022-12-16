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

func dequeue() -> String:
	return receiving_queue.pop_front()

func enqueue(direction_from: String):
	if   direction_from == "back" : receiving_queue.push_back("back")
	elif direction_from == "left" : receiving_queue.push_back("left")
	elif direction_from == "right": receiving_queue.push_back("right")

func _on_AreaTo_area_entered(area):
	pass

## function to update the "double linked list" of belts
## called checked signal from other belt
## calculates from which direction the neighbour was deleted
func delete_neighbour(other_rotation: float):
	other_rotation = get_relative_rotation(other_rotation)
	if other_rotation == 0:   
		back = null
	if abs(other_rotation - PI/2) < Glob.FLOAT_EPSILON: 
		left = null
	if abs(other_rotation - 3*PI/2) < Glob.FLOAT_EPSILON: 
		right = null

## clear the forward transporting object or building
## from the "double linked list"
## called from the forward object
func del_forward():
	forward = null

## default die function
## you would BETTER owerride it in successors classes!!!
func die():
	if right:   right.del_forward()
	if left:    left.del_forward()
	if back:    back.del_forward()
	if forward: forward.delete_neighbour(rotation)
	queue_free()

func receive(area):
	pass

func receive_object(_object):
	pass

