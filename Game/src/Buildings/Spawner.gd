## Spawners
class_name Spawner
extends Area2D

var forward: Belt = null

var send_obj_delay: float = 1
var ready_to_send: bool = false

onready var SpawnTimer: Timer = get_node("SpawnTimer")
onready var Item := preload("res://src/TransportableItems/Elixir.tscn")

## clear the forward transporting object or building
## from the "double linked list"
## called from the forward object
func del_forward():
	forward = null

## a signal tha is called when the belt is placed in front of other belt
## or pointing towards other belt
##
## updates own "linked list" and calls update neighbours for the next belt
func _on_AreaTo_area_entered(area):
	forward = area
	area.add_neighbour(self, rotation_degrees)
	if ready_to_send: send_obj()


## function to make object move
func send_obj():
	if !forward or !ready_to_send or forward.busy: return
	forward.receive()
	ready_to_send = false
	var new_object = Item.instance()
	get_parent().add_child(new_object)
	new_object.position = position + Vector2(cos(rotation), sin(rotation)*(Glob.GRID_STEP/2))
	new_object.move(forward.position)
	
## signal for timer tospawn an object
func _on_SpawnTimer_timeout():
	ready_to_send = true
	send_obj()

## callback from the [forward] object signaling that it is now free
## and we can send an object
##
## used to avoid items stacking on the belts
func ready_callback():
	if ready_to_send: send_obj()
