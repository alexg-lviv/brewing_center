class_name Belt
extends Area2D
## a belt object that transports resources in the game


var left: Belt = null
var right: Belt = null
var back: Belt = null
var forward: Belt = null

onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")


## function to update the current animation of the belt
## called when the belt gains or looses neighbours
func update_animation():
	var anim_name: String = ""
	if !back and !left and !right: anim_name = "back"
	if back: anim_name += "back"
	if left: anim_name += "left"
	if right: anim_name += "right"
	AnimPlayer.play(anim_name)

## calculates relative direction from which other belt is connected to current belt 
func _get_relative_rotation(other_rotation: int) -> int:
	return ((other_rotation - int(rotation_degrees) + 360) % 360)

## function to update the "double linked list" of belts
## called on signal from other belt
## calculates from which direction the neighbour was added
## and calls update animation
func add_neighbour(other_belt: Belt, other_rotation: int):
	other_rotation = _get_relative_rotation(other_rotation)
	if other_rotation == 0:   back = other_belt
	if other_rotation == 90:  left = other_belt
	if other_rotation == 270: right = other_belt
	update_animation()

## function to update the "double linked list" of belts
## called on signal from other belt
## calculates from which direction the neighbour was deleted
## and calls update animation
func delete_neighbour(other_rotation: int):
	other_rotation = _get_relative_rotation(other_rotation)
	if other_rotation == 0:   back = null
	if other_rotation == 90:  left = null
	if other_rotation == 270: right = null
	update_animation()

## function that is called on deletion of the next belt
func del_forward():
	forward = null

## function of death
## updates all connected belts
## and dies
func die():
	if right:   right.del_forward()
	if left:    left.del_forward()
	if back:    back.del_forward()
	if forward: forward.delete_neighbour(rotation_degrees)
	queue_free()


## a signal tha is called when the belt is placed in front of other belt
## or pointing towards other belt
##
## updates own "linked list" and calls update neighbours for the next belt
func _on_AreaTo_area_entered(area):
	forward = area
	area.add_neighbour(self, rotation_degrees)
