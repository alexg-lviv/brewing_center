class_name WFC
extends Node2D


@onready var Map: TileMap = get_node("WFCMap")
@onready var T: Timer = get_node("Timer")

@export  var height: int   = 80
@export  var width : int   = 140
@export  var delay : float = 0.0002
@export  var timer_delay: bool = false

const PROB_INDEX: int = 4

## the map that describes all the cells [br]
## key: Vector3i  [br]
##      first element             - tileset atlas ID  [br]
##      second and third elemtnts - tile altlas coordinates  [br]
## value: [Array] of [int] of size 5  [br]
##      first 4 elements describe 4 corners, to which terrains these belong  [br]
##      the   5 element - the probability with which this tile will be placed  [br]
##                        base - 10 (to be able to decrease and increase it)  [br]
const CELLS: Dictionary = {
	Vector3i(0, 0, 0): [1, 1, 2, 1,    10], # top    left   dirt tile
	Vector3i(0, 1, 0): [1, 1, 2, 2,    10], # top    center dirt tile
	Vector3i(0, 2, 0): [1, 1, 1, 2,    10], # top    right  dirt tile
	Vector3i(0, 0, 1): [1, 2, 2, 1,    10], # center left   dirt tile
	Vector3i(0, 1, 1): [2, 2, 2, 2,    10], # center center dirt tile
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
	Vector3i(1, 2, 2): [1, 2, 2, 2,    10],  # bottom right  grass tile
	
#	Vector3i(2, 0, 0): [1, 1, 3, 1,    1],
#	Vector3i(2, 1, 0): [1, 1, 3, 3,    1],
#	Vector3i(2, 2, 0): [1, 1, 1, 3,    1],
#	Vector3i(2, 0, 1): [1, 3, 3, 1,    1],
#	Vector3i(2, 1, 1): [3, 3, 3, 3,    1],
#	Vector3i(2, 2, 1): [3, 1, 1, 3,    1],
#	Vector3i(2, 0, 2): [1, 3, 1, 1,    1],
#	Vector3i(2, 1, 2): [3, 3, 1, 1,    1],
#	Vector3i(2, 2, 2): [3, 1, 1, 1,    1],
}


## the map of all possible combinations of sides corners [br]
## 4 keys responsible for the sides [br]
## the value for each key is another Dictionary [br]
## keys in inner dictionaries are the Vector2i which describe 2 corners associated with that side [br]
## this dictionary is crutial for the algorithm and is being filled on ready [br]
var adjs: Dictionary = {
	"top": {},
	"right": {},
	"bottom": {},
	"left": {}
}

## a map of 4 directions from text to [Vector2i]
const directions: Dictionary = {
	"top"   : Vector2i(0, 1),
	"right" : Vector2i(1, 2),
	"bottom": Vector2i(2, 3),
	"left"  : Vector2i(3, 0) 
}

## ordered [Array] of names of dirrections
var dir_names: Array[String] = ["right", "bottom", "left", "top"]
## ordered [Array] of names of dirrections in which the corners must connect
var new_tile_dirs_lookout: Array[String] = ["left", "top", "right", "bottom"]

## the [Array] of all the possible tiles [br]
## when choosing a tile, it will be duplicated and the spare elements are gona be yeeted
var all_tiles  : Array[Vector3i] = []


## initialize the adjs dictionary and create the world :D
func _ready():
	pass
	fill_adjs()
	create_world()


## function to inisialize the adjacency Dictionary
func fill_adjs():
	for tile in CELLS.keys():
		# add tile to the list of all possible tiles
		all_tiles.append(tile)
		# iterate over 4 possible directions
		for direction in adjs.keys():
			var edges = Vector2i(CELLS[tile][directions[direction][0]], CELLS[tile][directions[direction][1]])
			# if there are such edges - append tile
			if adjs[direction].has(edges):
				adjs[direction][edges].append(tile)
			# else create a new array there
			else:
				adjs[direction][edges] = [tile]


## main function to create the world [br]
## iterates over the rectangle and fills it out [br]
## in the future, if want to make generation more interesting - this is the place to look at) [br]
func create_world():
	for i in range(width):
		for j in range(height):
			var pos: Vector2i = Vector2i(i, j)
			var chosen: Vector3i = chose_cell(pos)
			if chosen == Vector3i(1000, 1000, 1000): continue
			Map.set_cell(0, pos, chosen[0], Vector2i(chosen[1], chosen[2]))
			
			if timer_delay:
				T.start(delay)
				await(T.timeout)



## function to find intercection of 2 arrays [br]
## used to get the tiles that can be connected to any of the 4 neighbouring tiles [br]
## quite ineffective. would be cool to implement it in a more klever way...
func intercect(arr1: Array, arr2: Array) -> Array:
	var out: Array = []
	for el in arr1:
		if arr2.has(el): out.append(el)
	return out


## function to chose one random element from array [br]
## currently unused
func chose_one_of(arr: Array) -> Variant:
	return arr[randi_range(0, arr.size()-1)]


## function to chose one weighted tile [br]
## takes tiles probabilities from the CELLS map [br]
## complexity O(2n), I dont like it(( but seems like there is no better option...
func chose_one_of_weighted(arr: Array[Vector3i]) -> Vector3i:
	var cumulative_prob: int = 0
	for tile in arr:
		cumulative_prob += CELLS[tile][PROB_INDEX]
	var chosen_num: int = randi_range(0, cumulative_prob)
	var cur_prob: int = 0
	for tile in arr:
		cur_prob += CELLS[tile][PROB_INDEX]
		if cur_prob >= chosen_num:
			return tile
	
	# should never come here but who knows...
	print("Error: no tile was selected")
	return Vector3i(1000, 1000, 1000)


## chose one cell that can be placed on the position [br]
## according to the constraints of the already placed cells [br]
func chose_cell(pos: Vector2i) -> Vector3i:
	var possible_tiles: Array[Vector3i] = all_tiles.duplicate(1)
	var neighbours := Map.get_surrounding_tiles(pos)
	for k in range(len(neighbours)):
		var source = Map.get_cell_source_id(0, neighbours[k])
		if source == -1: continue
		
		var direction: String = new_tile_dirs_lookout[k]
		var coords = Map.get_cell_atlas_coords(0, neighbours[k])
		
		var n_tile: Vector3i = Vector3i(source, coords[0], coords[1])
		var n_tile_constraints: Vector2i = Vector2i(
			CELLS[n_tile][directions[direction][1]],
			CELLS[n_tile][directions[direction][0]])
		possible_tiles = intercect(possible_tiles, adjs[dir_names[k]][n_tile_constraints])
	return chose_one_of_weighted(possible_tiles)
