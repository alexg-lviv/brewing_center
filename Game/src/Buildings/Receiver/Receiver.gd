class_name Receiver
extends Building


## delay to spawn objects
var send_obj_delay: float = 1
var objects_queue: Array[Interactable] = []
var enqueued: bool = false

## function of death  
## clear dependencies  
## and die
func die() -> void:
	if forward: forward.delete_neighbour(rotation)
	queue_free()

## a signal tha is called when the belt is placed in front of other belt
## or pointing towards other belt
##
## updates own "linked list" and calls update neighbours for the next belt
func _on_AreaTo_area_entered(area) -> void:
	forward = area
	area.add_neighbour(self, rotation)
	if !objects_queue.is_empty(): forward.enqueue(direction_to_next)


### function to make object move
func send_object() -> void:
	var obj_to_send = objects_queue.pop_back()
	obj_to_send.get_taken_by_building(self)
	forward.receive_object(obj_to_send)
	obj_to_send.move(forward.position)
	enqueued = false


func _on_area_from_area_entered(area: Area2D) -> void:
	objects_queue.push_back(area)
	if forward: 
		forward.enqueue(direction_to_next)
		enqueued = true

func _on_area_from_area_exited(_area: Area2D) -> void:
	print("SMTH EXITED")



