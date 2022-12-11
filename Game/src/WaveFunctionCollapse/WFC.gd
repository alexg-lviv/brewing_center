class_name WFC
extends Node2D


@onready var Map: TileMap = get_node("WFCMap")
@onready var T: Timer = get_node("Timer")

@export  var height: int   = 80
@export  var width : int   = 140
@export  var delay : float = 0.0002
@export  var timer_delay: bool = false


const CELLS: Dictionary = {
	Vector3i(0, 0, 0): [1, 1, 2, 1,    10], # top    left   dirt tile
	Vector3i(0, 1, 0): [1, 1, 2, 2,    10], # top    center dirt tile
	Vector3i(0, 2, 0): [1, 1, 1, 2,    10], # top    right  dirt tile
	Vector3i(0, 0, 1): [1, 2, 2, 1,    10], # center left   dirt tile
	Vector3i(0, 1, 1): [2, 2, 2, 2,    50], # center center dirt tile
	Vector3i(0, 2, 1): [2, 1, 1, 2,    10], # center right  dirt tile
	Vector3i(0, 0, 2): [1, 2, 1, 1,    10], # bottom left   dirt tile
	Vector3i(0, 1, 2): [2, 2, 1, 1,    10], # bottom center dirt tile
	Vector3i(0, 2, 2): [2, 1, 1, 1,    10], # bottom right  dirt tile
	
	Vector3i(1, 0, 0): [2, 2, 1, 2,    10], # top    left   grass tile
	Vector3i(1, 1, 0): [2, 2, 1, 1,    10], # top    center grass tile
	Vector3i(1, 2, 0): [2, 2, 2, 1,    10], # top    right  grass tile
	Vector3i(1, 0, 1): [2, 1, 1, 2,    10], # center left   grass tile
	Vector3i(1, 1, 1): [1, 1, 1, 1,    10], # center center grass tile
	Vector3i(1, 2, 1): [1, 2, 2, 1,    10], # center right  grass tile
	Vector3i(1, 0, 2): [2, 1, 2, 2,    10], # bottom left   grass tile
	Vector3i(1, 1, 2): [1, 1, 2, 2,    10], # bottom center grass tile
	Vector3i(1, 2, 2): [1, 2, 2, 2,    10]  # bottom right  grass tile
}

var adjs: Dictionary = {
	"top": {},
	"right": {},
	"bottom": {},
	"left": {}
}

var directions: Dictionary = {
	"top"   : Vector2i(0, 1),
	"right" : Vector2i(1, 2),
	"bottom": Vector2i(2, 3),
	"left"  : Vector2i(3, 0) 
}

var dir_names  : Array[String] = ["right", "bottom", "left", "top"]
var dir_names2 : Array[String] = ["left", "top", "right", "bottom"]

var all_tiles  : Array[Vector3i] = []

func _ready():
	fill_adjs()
	create_world()


func fill_adjs():
	for tile in CELLS.keys():
		all_tiles.append(tile)
		for direction in adjs.keys():
			var edges = Vector2i(CELLS[tile][directions[direction][0]], CELLS[tile][directions[direction][1]])
			if adjs[direction].has(edges):
				adjs[direction][edges].append(tile)
			else:
				adjs[direction][edges] = [tile]

func intercect(arr1: Array, arr2: Array) -> Array:
	var out: Array = []
	for el in arr1:
		if arr2.has(el): out.append(el)
	return out

func chose_one_of(arr: Array) -> Variant:
	return arr[randi_range(0, arr.size()-1)]

func chose_one_of_weighted(arr: Array[Vector3i]) -> Vector3i:
	var cumulative_prob: int = 0
	for tile in arr:
		# TODO: replace 4 with constant
		cumulative_prob += CELLS[tile][4]
	var chosen_num: int = randi_range(0, cumulative_prob)
	var cur_prob: int = 0
	for tile in arr:
		# TODO: replace 4 with constant
		cur_prob += CELLS[tile][4]
		if cur_prob >= chosen_num:
			return tile

	print("Error: no tile was selected")
	return Vector3i.ZERO

func create_world():
	for i in range(width):
		for j in range(height):
			var pos: Vector2i = Vector2i(i, j)
			var possible_tiles: Array[Vector3i] = all_tiles.duplicate(1)
			var neighbours := Map.get_surrounding_tiles(pos)
			for k in range(len(neighbours)):
				var source = Map.get_cell_source_id(0, neighbours[k])
				if source == -1: continue
				
				var direction: String = dir_names2[k]
				var coords = Map.get_cell_atlas_coords(0, neighbours[k])
				
				var n_tile: Vector3i = Vector3i(source, coords[0], coords[1])
				var n_tile_constraints: Vector2i = Vector2i(
					CELLS[n_tile][directions[direction][1]],
					CELLS[n_tile][directions[direction][0]])
				possible_tiles = intercect(possible_tiles, adjs[dir_names[k]][n_tile_constraints])
			var chosen: Vector3i = chose_one_of_weighted(possible_tiles)
			Map.set_cell(0, pos, chosen[0], Vector2i(chosen[1], chosen[2]))
			
			if timer_delay:
				T.start(delay)
				await(T.timeout)
