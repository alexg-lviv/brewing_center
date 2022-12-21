extends Building
class_name Spawner
## Spawner creates objects


## delay to spawn objects
var send_obj_delay: float = 1
var ready_to_send: bool = false

@onready var SpawnTimer: Timer = get_node("SpawnTimer")
@onready var Item := preload("res://src/Interactables/Log.tscn")

func _ready():
	SpawnTimer.start(send_obj_delay)

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
	if ready_to_send: forward.enqueue(direction_to_next)


### function to make object move
func send_object() -> void:
	ready_to_send = false
	var new_object = Item.instantiate()
	forward.receive_object(new_object)
	get_parent().call_deferred("add_child", new_object)
	new_object.set_deferred("position", position + Vector2(sin(rotation), cos(rotation)*-1)*(Glob.GRID_STEP/2))
	new_object.call_deferred("move", forward.position)
	SpawnTimer.start(send_obj_delay)

## signal of timer to send objects every n seconds if possible
func _on_spawn_timer_timeout() -> void:
	if forward: forward.enqueue(direction_to_next)
	ready_to_send = true
