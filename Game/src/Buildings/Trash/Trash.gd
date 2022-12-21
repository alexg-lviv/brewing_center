class_name Trash
extends Building
## Trash deletes objects


## function to update the "double linked list" of belts
## called checked signal from other belt
## calculates from which direction the neighbour was added
## and calls update animation
func add_neighbour(other_belt, other_rotation: float) -> void:
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

## function just to meet the code API  
##
## immideately after we get ti enqueue, we ask to send the object
func enqueue(direction_from: String) -> void:
	super(direction_from)
	ask_send_object()

## ask all the connections to send us object
func ask_send_object() -> void:
	if receiving_queue.is_empty(): return
	var build: String = dequeue()
	if   build == "back" and back  != null:  back.send_object()
	elif build == "left" and left  != null:  left.send_object()
	elif build == "right"and right != null: right.send_object()

## just delete all the transportable objects
## and add other buildings as neighbiurs
func _on_trash_area_entered(area) -> void:
	if area.is_in_group("Movables"):
		area.die()
	elif area.is_in_group("Buildings"):
		add_neighbour(area, area.rotation)
