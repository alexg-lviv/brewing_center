extends Building
class_name Furnace
@icon("res://art/buildings/FurnaceBurning.png")

@onready var FurnaceAnimPlayer: AnimationPlayer = get_node("FurnaceAnimation")
@onready var PulserAnimPlayer: AnimationPlayer = get_node("AvailabilityAnimaion")
@onready var Pulser := get_node("Polygon2D")

var fuel: bool = false
var rss: bool = false


## if the drag_mode is active - all the storages signal that they are available to place items
## TODO: add visibility notifiers for optimisation
func _process(_delta: float) -> void:
	if Glob.drag_mode and (!fuel or !rss):
		PulserAnimPlayer.play("Pulsing")
		Pulser.self_modulate = "#ff0000"
	else:
		PulserAnimPlayer.play("Idle")
