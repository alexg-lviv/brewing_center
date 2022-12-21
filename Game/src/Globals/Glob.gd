extends Node

const FLOAT_EPSILON = 0.01

var GRID_STEP: int = 64

var exit_build_mode_on_build: bool = false
var build_mode: bool = false
var drag_mode : bool = false

# DEMOLISH MODE VARS
var demolish_mode: bool = false

var previews_dict: Dictionary = {
	"Belt": "res://art/belt/s.png",
	"Spawner": "res://art/buildings/spawner.png",
	"Trash": "res://art/buildings/Trash.png",
	"Extractor": "res://art/buildings/spawner.png"
}
var objects_dict: Dictionary = {
	"Belt": "res://src/Buildings/Belt/Belt.tscn",
	"Spawner": "res://src/Buildings/Spawner/Spawner.tscn",
	"Trash": "res://src/Buildings/Trash/Trash.tscn",
	"Extractor": "res://src/Buildings/Pump/Pump.tscn"
}


var modulate_clear: String = "ffffff"
var modulate_green: String = "73feb0"
var modulate_red:   String = "ff6565"

## a helper function of comparison of 2 floating-point vectors
func compare(first: Vector2, second: Vector2) -> bool:
	if abs(first.x - second.x) < 1 and abs(first.y - second.y) < 1:
		return false
	return true
