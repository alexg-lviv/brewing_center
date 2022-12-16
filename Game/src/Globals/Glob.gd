extends Node

const FLOAT_EPSILON = 0.01

var GRID_STEP: int = 32

var exit_build_mode_on_build: bool = false

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
