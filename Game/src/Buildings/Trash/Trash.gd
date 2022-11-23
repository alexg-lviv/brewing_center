class_name Trash
extends Building

var busy = false

func enqueue(direction_from: String):
	super(direction_from)
	ask_send_object()

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

func ask_send_object():
	if receiving_queue.is_empty(): return
	var build: String = dequeue()
	if   build == "back" and back  != null:  back.send_object()
	elif build == "left" and left  != null:  left.send_object()
	elif build == "right"and right != null: right.send_object()

func receive_object(_object):
	pass

func _on_trash_area_entered(area):
	if area.is_in_group("TransportableItems"):
		area.die()
	elif area.is_in_group("Buildings"):
		add_neighbour(area, area.rotation)