extends Node


var rss_sprites: Dictionary = {
	"Rock":    ["res://art/Resources/Rock1.png"],
	"IronOre": ["res://art/Resources/IronOre1.png"],
	"CoalOre": ["res://art/Resources/CoalOre1.png"],
	"Tree":    [
				"res://art/Resources/Tree2.png",
				"res://art/Resources/Tree3.png",
				"res://art/Resources/Tree4.png",
				"res://art/Resources/Tree5.png"]
}

var dropped_rss_sprites: Dictionary = {
	"Stone":   "res://art/Resources/Dropped/Stone.png",
	"Iron":    "res://art/Resources/Dropped/Iron.png",
	"IronBar": "res://art/Resources/Dropped/IronBar.png",
	"Log":     "res://art/Resources/Dropped/Log.png",
	"Coal":    "res://art/Resources/Dropped/Coal.png",
	"Acorn":   "res://art/Resources/Dropped/acorn.png"
}


var dropped_rss_types: Dictionary = {
	"Fuel": ["Log", "Coal"],
	"Burnable": ["Iron"],
	"Seed": ["Acorn"]
}

var dropped_type_by_rss: Dictionary = {
	"Log": "Fuel",
	"Coal": "Fuel",
	"Iron": "Burnable",
	"Acorn": "Seed"
}


var res_heat_required: Dictionary = {
	"Iron": 3
}

var res_heat_produced: Dictionary = {
	"Log": 2,
	"Coal": 3,
}

var rss_smelt_chains: Dictionary = {
	"Iron": "IronBar"
}

var rss_drop_bounds: Dictionary = {
	"Rock":    {
		"Stone": Vector2i(1, 2),
	},
	"IronOre": {
		"Iron": Vector2i(2, 4),
	},
	"CoalOre": {
		"Coal": Vector2i(1, 3),
	},
	"Tree": {
		"Log": Vector2i(2, 3),
		"Acorn": Vector2i(0, 1)
	},
}

var rss_harvest_time: Dictionary = {
	"Rock":    0.5,
	"IronOre": 0.5,
	"CoalOre": 0.5,
	"Tree":    0.5,
}

var rss_drop_resource_types: Dictionary = {
	"Rock":    "Stone",
	"IronOre": "Iron",
	"CoalOre": "Coal",
	"Tree":    "Log",
}
