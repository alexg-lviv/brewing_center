extends Node

const FLOAT_EPSILON = 0.01

var GRID_STEP: int = 64

var exit_build_mode_on_build: bool = false
var build_mode: bool = false
var draw_area_mode: bool = false

var drag_mode : bool = false
var drag_rss  : Movable = null


var curr_tool_selected = null: set = _set_curr_tool

func _set_curr_tool(new_tool) -> void:
	pass

# DEMOLISH MODE VARS
var demolish_mode: bool = false

enum Actions{
	Craft,
	Build,
	Plant,
}

var previews_dict: Dictionary = {
	"Storage": "res://art/buildings/storage.png",
	"Furnace": "res://art/buildings/Furnace.png",
	"GardenBed": "res://art/buildings/GardenBed/GardenBed.png",
}
var objects_dict: Dictionary = {
	"Storage": "res://src/Buildings/Storage/Storage.tscn",
	"Furnace": "res://src/Buildings/Furnace/Furnace.tscn",
	"GardenBed": "res://src/Buildings/GardenBed/GardenBed.tscn",
}

var dismensions_dict: Dictionary = {
	"Storage": Vector2i(2, 2),
	"Furnace": Vector2i(2, 2),
	"GardenBed": Vector2i(1, 1),
}

var build_cost_dict: Dictionary = {
	"Storage": {
		"Stone": 1,
		"Log": 2,
	},
	"Furnace": {
		"Stone": 1
	},
	"GardenBed": null
}

var modulate_clear: String = "ffffff"
var modulate_green: String = "73feb0"
var modulate_red:   String = "ff6565"

## a helper function of comparison of 2 floating-point vectors
func compare(first: Vector2, second: Vector2) -> bool:
	if abs(first.x - second.x) < 1 and abs(first.y - second.y) < 1:
		return false
	return true
