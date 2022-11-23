## Belt
##
## a belt object that transports resources in the game
class_name Belt
extends Building

# transporting objects variables
var object        : Object = null
var send_obj_delay: float  = 1.5
var ready_to_send : bool   = false
var objs_counter  : int    = 0 

@onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")
@onready var MoveTimer: Timer = get_node("MoveTimer")

func _process(_delta):
	ask_send_object()

#########################################
#########################################
## Functions related to belts building ##
## and animation                       ##
#########################################
#########################################

## function to update the current animation of the belt
## called when the belt gains or looses neighbours
func update_animation():
	var anim_name: String = ""
	if !back and !left and !right: anim_name = "back"
	if back:   anim_name += "back"
	if left:   anim_name += "left"
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
		other_belt.direction_to_next = "back"
	if abs(other_rotation - PI/2) < Glob.FLOAT_EPSILON:  
		left = other_belt
		other_belt.direction_to_next = "left"
	if abs(other_rotation - 3*PI/2) < Glob.FLOAT_EPSILON: 
		right = other_belt
		other_belt.direction_to_next = "right"
	update_animation()

## function to update the "double linked list" of belts
## called checked signal from other belt
## calculates from which direction the neighbour was deleted
## and calls update animation
func delete_neighbour(other_rotation: float):
	super(other_rotation)
	update_animation()

## function that is called checked deletion of the next belt
func del_forward():
	forward = null

## function of death
## updates all connected belts
## and dies
func die():
	super()
	if object: object.die()
	queue_free()

## a signal tha is called when the belt is placed in front of other belt
## or pointing towards other belt
##
## updates own "linked list" and calls update neighbours for the next belt
func _on_AreaTo_area_entered(area):
	area.add_neighbour(self, rotation)
	forward = area
	if ready_to_send: forward.enqueue(direction_to_next)

###########################################
###########################################
## Functions related to objects movement ##
###########################################
###########################################

## function to notify belt the it will receive object
## save object to variable and start timer to count
## when to send it further
func receive_object(obj: MovableItem):
	object = obj
	MoveTimer.start(send_obj_delay)

## actually send object
## make it move, notify next building that we send it  
## and ask to send object to this belt if there are any
func send_object():
	if !object: return
	ready_to_send = false
	forward.receive_object(object)
	object.move(forward.position)
	object = null
	ask_send_object()

## notify next building that we are ready to send object
## and set the variable
func _on_move_timer_timeout():
	if forward: forward.enqueue(direction_to_next)
	ready_to_send = true

## function to ask to send us objects
## if there are any obkects in the queue
## and send them
func ask_send_object():
	if object or receiving_queue.is_empty(): return
	var build: String = dequeue()
	if   build == "back" and back  != null:  back.send_object()
	elif build == "left" and left  != null:  left.send_object()
	elif build == "right"and right != null: right.send_object()

