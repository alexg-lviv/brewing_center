extends Node


var rss_sprites: Dictionary = {
	"Rock":    "res://art/Resources/Rock1.png",
	"IronOre": "res://art/Resources/IronOre1.png",
	"CoalOre": "res://art/Resources/CoalOre1.png",
	"Tree":    "res://art/rss/tree1.png",
}

var dropped_rss_sprites: Dictionary = {
	"Stone":   "res://art/Resources/Dropped/Stone.png",
	"Iron":    "res://art/Resources/Dropped/Iron.png",
	"IronBar": "res://art/Resources/Dropped/IronBar.png",
	"Log":     "res://art/Resources/Dropped/Log.png",
	"Coal":    "res://art/Resources/Dropped/Coal.png",
}

var dropped_rss_types: Dictionary = {
	"Fuel": ["Log", "Coal"],
	"Burnable": ["Iron"]
}

var burning_force: Dictionary = {
	"Log": 1,
	"Coal": 3,
}

var rss_smelt_chains: Dictionary = {
	"Iron": "IronBar"
}

var rss_drop_bounds: Dictionary = {
	"Rock":    Vector2i(1, 2),
	"IronOre": Vector2i(2, 4),
	"CoalOre": Vector2i(1, 3),
	"Tree":    Vector2i(2, 3),
}

var rss_harvest_time: Dictionary = {
	"Rock":    3,
	"IronOre": 5,
	"CoalOre": 4,
	"Tree":    2,
}

var rss_drop_resource_types: Dictionary = {
	"Rock":    "Stone",
	"IronOre": "Iron",
	"CoalOre": "Coal",
	"Tree":    "Log",
}
