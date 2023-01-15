extends Building
class_name Furnace
@icon("res://art/buildings/FurnaceBurning.png")

@onready var FurnaceAnimPlayer: AnimationPlayer = get_node("FurnaceAnimation")
@onready var PulserAnimPlayer: AnimationPlayer = get_node("AvailabilityAnimaion")
@onready var Pulser := get_node("Polygon2D")
@onready var popup = get_node("BuildingPopup")

var fuel: bool = false
var rss: bool = false

var fuel_selected:           String = "Coal"
var object_to_smelt_selected: String = "Iron"

var my_demand:          Dictionary = {}
var my_reserved_demand: Dictionary = {}

func _ready():
	reset_demand()
	popup.position.y -= Glob.GRID_STEP

## if the drag_mode is active - all the storages signal that they are available to place items
## TODO: add visibility notifiers for optimisation
func _process(_delta: float) -> void:
	if Glob.drag_mode and (!fuel or !rss) and (Glob.drag_rss.rss_name in my_demand.keys() and my_demand[Glob.drag_rss.rss_name] > 0):
		PulserAnimPlayer.play("Pulsing")
		Pulser.self_modulate = "#00ff00"
	else:
		PulserAnimPlayer.play("Idle")


## accept the object if there is free place and add to counter
func take_object(from_skeleton: bool = false, object: DroppedResource = null) -> void:
	if !from_skeleton:
		object = temp_obj
	object.move_and_die(global_position)

func reset_demand():
	my_demand = {}
	my_reserved_demand = {}
	my_demand[fuel_selected] = 1
	my_demand[object_to_smelt_selected] = 1
	update_demands()


func update_demands():
	for res in my_demand.keys():
		popup.add_resource(res, my_demand[res])

## remember that item entered yourself
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Movables"):
		if (fuel_selected == area.rss_name) or (object_to_smelt_selected == area.rss_name):
			temp_obj = area
			area.get_reserved_by_building(self)

## ok forget about it, its GONE
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Movables"):
		if (fuel_selected == area.rss_name) or (object_to_smelt_selected == area.rss_name):
			area.forget_about_reservation_building()
			temp_obj = null
