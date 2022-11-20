extends Node

var GRID_STEP: int = 32

var exit_build_mode_on_build: bool = false

var previews_dict: Dictionary = {
	"Belt": "res://art/belt/s.png",
	"Spawner": "res://art/buildings/spawner.png"
}
var objects_dict: Dictionary = {
	"Belt": "res://src/Buildings/Counveyour.tscn",
	"Spawner": "res://src/Buildings/Spawner.tscn"
}


var modulate_clear: String = "ffffff"
var modulate_green: String = "73feb0"
var modulate_red:   String = "ff6565"
