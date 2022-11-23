## Belt
##
## a belt object that transports resources in the game
class_name Belt
extends Building

# transporting objects variables
var object        : Object = null
var send_obj_delay: float  = 1.5
var ready_to_send : bool   = false
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
		connections.append(back)
	if abs(other_rotation - PI/2) < Glob.FLOAT_EPSILON:  
		left = other_belt
		other_belt.direction_to_next = "left"
		connections.append(left)
	if abs(other_rotation - 3*PI/2) < Glob.FLOAT_EPSILON: 
		right = other_belt
		other_belt.direction_to_next = "right"
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
	area.add_neighbour(self, rotation)
	forward = area
	if ready_to_send: forward.enqueue(direction_to_next)

func receive_object(obj: MovableItem):
	object = obj
	MoveTimer.start(send_obj_delay)

func send_object():
	if !object: return
	ready_to_send = false
	forward.receive_object(object)
	object.move(forward.position)
	object = null
	ask_send_object()

func _on_move_timer_timeout():
	if forward: forward.enqueue(direction_to_next)
	ready_to_send = true

func ask_send_object():
	if object or receiving_queue.is_empty(): return
	var build: String = dequeue()
	if   build == "back" and back  != null:  back.send_object()
	elif build == "left" and left  != null:  left.send_object()
	elif build == "right"and right != null: right.send_object()

func _process(_delta):
	ask_send_object()
