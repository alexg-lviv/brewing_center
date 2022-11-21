## Belt
##
## a belt object that transports resources in the game
class_name Belt
extends Building


# "double linked list" variables
var left :Building   = null
var right:Building   = null
var back :Building   = null

# transporting objects variables
var object        : Object = null
var send_obj_delay: float  = 1
var ready_to_send : bool   = false
var busy          : bool   = false
var objs_counter  : int    = 0 
var connections   : Array  = []

onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")
onready var MoveTimer: Timer = get_node("MoveTimer")


## function to update the current animation of the belt
## called when the belt gains or looses neighbours
func update_animation():
	var anim_name: String = ""
	if !back and !left and !right: anim_name = "back"
	if back: anim_name += "back"
	if left: anim_name += "left"
	if right: anim_name += "right"
	AnimPlayer.play(anim_name)

## function to update the "double linked list" of belts
## called on signal from other belt
## calculates from which direction the neighbour was added
## and calls update animation
func add_neighbour(other_belt, other_rotation: int):
	other_rotation = get_relative_rotation(other_rotation)
	if other_rotation == 0:   
		back = other_belt
		connections.append(back)
	if other_rotation == 90:  
		left = other_belt
		connections.append(left)
	if other_rotation == 270: 
		right = other_belt
		connections.append(right)
	update_animation()

## function to update the "double linked list" of belts
## called on signal from other belt
## calculates from which direction the neighbour was deleted
## and calls update animation
func delete_neighbour(other_rotation: int):
	other_rotation = get_relative_rotation(other_rotation)
	if other_rotation == 0:   
		connections.erase(back)
		back = null
	if other_rotation == 90:  
		connections.erase(left)
		left = null
	if other_rotation == 270: 
		connections.erase(right)
		right = null
	print(connections.size())
	update_animation()

## function that is called on deletion of the next belt
func del_forward():
	_forward = null

## function of death
## updates all connected belts
## and dies
func die():
	if right:   right.del_forward()
	if left:    left.del_forward()
	if back:    back.del_forward()
	if _forward: _forward.delete_neighbour(rotation_degrees)
	queue_free()


## a signal tha is called when the belt is placed in front of other belt
## or pointing towards other belt
##
## updates own "linked list" and calls update neighbours for the next belt
func _on_AreaTo_area_entered(area):
	_forward = area
	area.add_neighbour(self, rotation_degrees)
	if ready_to_send: send_obj()

## a signal that is called when transportable object enters the belt  
## starts a timer and adds an object to variable
func _on_Belt_area_entered(area):
	if area.is_in_group("TransportableItems"):
		objs_counter += 1
		object = area
		MoveTimer.start(send_obj_delay)
		ready_to_send = false

## a signal of timer after which an object starts moving
func _on_MoveTimer_timeout():
	ready_to_send = true
	send_obj()

## function to make object move
func send_obj():
	if !_forward or !object or _forward.busy: return
	_forward.receive()
	object.move(_forward.position)
	object = null
	busy = false
	
	# a calculation of which neighbour to let through if we have more than one
	connections[objs_counter % connections.size()].ready_callback()
	
## after one neighbour commits to send us resource
## we do not want to accept othe resources until we are ready
## so we set busy = true
func receive():
	busy = true

## callback from the [forward] object signaling that it is now free
## and we can send an object
##
## used to avoid items stacking on the belts
func ready_callback():
	send_obj()
