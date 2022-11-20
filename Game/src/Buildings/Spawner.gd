## Spawners
class_name Spawner
extends Area2D

var forward: Belt = null

var send_obj_delay: float = 1
var ready_to_send: bool = false

onready var SpawnTimer: Timer = get_node("SpawnTimer")
onready var Item := preload("res://src/TransportableItems/Elixir.tscn")

func _ready():
	pass


func del_forward():
	forward = null

func _on_AreaTo_area_entered(area):
	forward = area
	area.add_neighbour(self, rotation_degrees)
	if ready_to_send: send_obj()

func send_obj():
	if !forward or !ready_to_send or forward.busy: return
	forward.receive()
	ready_to_send = false
	var new_object = Item.instance()
	get_parent().add_child(new_object)
	new_object.position = position + Vector2(cos(rotation), sin(rotation)*(Glob.GRID_STEP/2))
	new_object.move(forward.position)
	

func _on_SpawnTimer_timeout():
	send_obj()
	ready_to_send = true


func ready_callback():
	if ready_to_send: send_obj()
