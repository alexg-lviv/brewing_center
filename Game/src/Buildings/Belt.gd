## Belt
##
## a belt object that transports resources in the game
class_name Belt
extends Building

# transporting objects variables
var object        : Object = null
var send_obj_delay: float  = 1.5
var ready_to_send : bool   = true
var busy          : bool   = false
var objs_counter  : int    = 0 
var connections   : Array  = []

@onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")
@onready var MoveTimer: Timer = get_node("MoveTimer")


## function to update the current animation of the belt
## called when the belt gains or looses neighbours
func update_animation():
	var anim_name: String = ""
	if !back and !left and !right: anim_name = "back"
	if left:   anim_name += "left"
	if back:   anim_name += "back"
	if right:  anim_name += "right"
	AnimPlayer.play(anim_name)

## function to update the "double linked list" of belts
## called checked signal from other belt
## calculates from which direction the neighbour was added
## and calls update animation
func add_neighbour(other_belt, other_rotation: float):
	other_rotation = get_relative_rotation(other_rotation)
	if other_rotation == 0:   
		back = other_belt
		connections.append(back)
	if abs(other_rotation - PI/2) < Glob.FLOAT_EPSILON:  
		left = other_belt
		connections.append(left)
	if abs(other_rotation - 3*PI/2) < Glob.FLOAT_EPSILON: 
		right = other_belt
		connections.append(right)
	update_animation()

## function to update the "double linked list" of belts
## called checked signal from other belt
## calculates from which direction the neighbour was deleted
## and calls update animation
func delete_neighbour(other_rotation: float):
	other_rotation = get_relative_rotation(other_rotation)
	if other_rotation == 0:   
		connections.erase(back)
		back = null
	if abs(other_rotation - PI/2) < Glob.FLOAT_EPSILON:  
		connections.erase(left)
		left = null
	if abs(other_rotation - 3*PI/2) < Glob.FLOAT_EPSILON: 
		connections.erase(right)
		right = null
	update_animation()

## function that is called checked deletion of the next belt
func del_forward():
	forward = null

## function of death
## updates all connected belts
## and dies
func die():
	if right:   right.del_forward()
	if left:    left.del_forward()
	if back:    back.del_forward()
	if forward: forward.delete_neighbour(rotation)
	if object: object.die()
	queue_free()


## a signal tha is called when the belt is placed in front of other belt
## or pointing towards other belt
##
## updates own "linked list" and calls update neighbours for the next belt
func _on_AreaTo_area_entered(area):
	forward = area
	area.add_neighbour(self, rotation)
	if ready_to_send: send_obj()

## a signal that is called when transportable object enters the belt  
## starts a timer and adds an object to variable
#func _on_Belt_area_entered(area):
#	if area.is_in_group("TransportableItems"):
#		pass

## a signal of timer after which an object starts moving
func _on_MoveTimer_timeout():
	ready_to_send = true
	send_obj()

## function to make object moves
func send_obj():
	if !forward or !ready_to_send or !object or forward.busy: return
	forward.receive(object)
	object.move(forward.position)
	object = null
	busy = false
	notify_ready()
	
## after one neighbour commits to send us resource
## we do not want to accept othe resources until we are ready
## so we set busy = true
func receive(area):
	busy = true
	objs_counter += 1
	object = area
	ready_to_send = false
	MoveTimer.start(send_obj_delay)

## callback from the [forward] object signaling that it is now free
## and we can send an object
##
## used to avoid items stacking checked the belts
func ready_callback():
	send_obj()


func notify_ready():
	# a calculation of which neighbour to let through if we have more than one
	if connections.size() > 0:
		connections[objs_counter % connections.size()].ready_callback()

