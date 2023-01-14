extends Node

const FLOAT_EPSILON = 0.01

var GRID_STEP: int = 64

var exit_build_mode_on_build: bool = false
var build_mode: bool = false
var drag_mode : bool = false
var draw_area_mode: bool = false

# DEMOLISH MODE VARS
var demolish_mode: bool = false

var previews_dict: Dictionary = {
#	"Belt": "res://art/belt/s.png",
#	"Spawner": "res://art/buildings/spawner.png",
#	"Trash": "res://art/buildings/Trash.png",
#	"Extractor": "res://art/buildings/spawner.png",
#	"Receiver": "res://art/buildings/sender.png",
	"Storage": "res://art/buildings/storage.png",
	"Furnace": "res://art/buildings/Furnace.png"
}
var objects_dict: Dictionary = {
#	"Belt": "res://src/Buildings/Belt/Belt.tscn",
#	"Spawner": "res://src/Buildings/Spawner/Spawner.tscn",
#	"Trash": "res://src/Buildings/Trash/Trash.tscn",
#	"Extractor": "res://src/Buildings/Pump/Pump.tscn",
#	"Receiver": "res://src/Buildings/Receiver/Receiver.tscn",
	"Storage": "res://src/Buildings/Storage.tscn",
	"Furnace": "res://src/Buildings/Furnace.tscn"
}

var dismensions_dict: Dictionary = {
#	"Belt": Vector2i(1, 1),
#	"Spawner": Vector2i(1, 1),
#	"Trash": Vector2i(1, 1),
#	"Extractor": Vector2i(1, 1),
#	"Receiver": Vector2i(1, 1),
	"Storage": Vector2i(2, 2),
	"Furnace": Vector2i(2, 2)
}

var build_cost_dict: Dictionary = {
	"Storage": {
		"Stone": 1,
		"Log": 2,
	},
	"Furnace": {
		"Stone": 4
	}
}

var modulate_clear: String = "ffffff"
var modulate_green: String = "73feb0"
var modulate_red:   String = "ff6565"

## a helper function of comparison of 2 floating-point vectors
func compare(first: Vector2, second: Vector2) -> bool:
	if abs(first.x - second.x) < 1 and abs(first.y - second.y) < 1:
		return false
	return true
