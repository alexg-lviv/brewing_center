## Main game world
##
## a field  for construction, harvesting and all the gameplay
class_name GameWorld
extends Node2D


@export var trees_prob: float = 0.2
@export var rock_prob: float = 0.05

# BUILD MODE VARS
var build_type: String
var can_build: bool = false
## 0 - up, PI/2 - right
var build_rotation: float = 0


var last_object: Interactable = null

var is_drawing: bool = false
var is_erasing: bool = false

@onready var UI := get_node("UI")
@onready var Tilemap : TileMap = get_node("TileMap")
@onready var Player := get_node("Player")
@onready var PrevSprite: Sprite2D = get_node("ObjSprite")
@onready var ResourcesContainer: Node2D = get_node("Resources")
@onready var DroppedResources: Node2D = get_node("DroppedResources")
@onready var BuildingsContainer: Node2D = get_node("Buildings")
@onready var AreaPrev: Sprite2D = get_node("AreaPreview")
@onready var HighlightMap: TileMap = get_node("HighlightMap")


@onready var Tree1 = preload("res://src/Interactables/Tree1.tscn")
@onready var Rock = preload("res://src/Interactables/Rock.tscn")

var areas_dict: Dictionary = {
	"Clear": 0,
	"Harvest": 1
}

var areas_modulate: Dictionary ={
	"Clear": "73feb0",
	"Harvest": "ff6565"
}

## dictionary of all instanced buildings
## the key is their grid coords, and the value is reference to the object itself
var instances_dict: Dictionary = {}

var obj_prev_name: String

var _last_shaded_red: Vector2 = Vector2.ZERO

var drawn_pickup_area: Dictionary = {}
var pickup_tiles: Array

var drawn_harvest_area: Dictionary = {}
var harvest_tiles: Array


func _ready():
	create_environment(Vector2(1000, 1000))
	
	for button in get_tree().get_nodes_in_group("BuildButton"):
		button.connect("pressed",Callable(self,"_on_build_button_pressed").bind(button.get_name()))
	
	Signals.connect("object_howered", Callable(self,"_on_object_howered"))
	Signals.connect("object_unhowered", Callable(self,"_on_object_unhowered"))

func _on_object_howered(object):
	if is_instance_valid(last_object):
		last_object.exit()
	last_object = object

func _on_object_unhowered(object):
	if object == last_object:
		last_object = null

func _process(_delta):
	if Glob.build_mode:
		handle_building()
	elif Glob.demolish_mode:
		handle_demolition()
	elif Glob.draw_area_mode:
		handle_areas_drawing()

func update_drawn_array(dict: Dictionary) -> Array:
	var res: Array = []
	for key in dict.keys():
		if dict[key] != null: res.append(key)
	return res
	

func handle_areas_drawing() -> void:
	if Input.is_action_pressed("ui_cancel"): 
		Glob.draw_area_mode = false
		reset_areas_prewiew()
		return

	var layer = areas_dict[build_type]
	
	if Input.is_action_just_pressed("click"):
		is_drawing = true
	if Input.is_action_just_released("click"):
		is_drawing = false
		pickup_tiles = update_drawn_array(drawn_pickup_area)
		harvest_tiles = update_drawn_array(drawn_harvest_area)
		

	if Input.is_action_just_pressed("right_click"):
		is_erasing = true
	if Input.is_action_just_released("right_click"):
		is_erasing = false
		pickup_tiles = update_drawn_array(drawn_pickup_area)
		harvest_tiles = update_drawn_array(drawn_harvest_area)
		

	set_area_prewiew()
	update_area_prewiew()
	
	if is_drawing:
		var grid_pos: Vector2 = get_grid_pos(get_global_mouse_position())
		HighlightMap.set_cell(layer, grid_pos / Glob.GRID_STEP, 0, Vector2(1, 1))
		if layer == 0:
			drawn_pickup_area[grid_pos] = 1
		elif layer == 1:
			drawn_harvest_area[grid_pos] = 1
	
	if is_erasing:
		var grid_pos: Vector2 = get_grid_pos(get_global_mouse_position())
		HighlightMap.set_cell(layer, grid_pos / Glob.GRID_STEP)
		if layer == 0:
			drawn_pickup_area.erase(grid_pos)
		elif layer == 1:
			drawn_harvest_area.erase(grid_pos)

func reset_areas_prewiew() -> void:
	AreaPrev.visible = false
	HighlightMap.set_layer_enabled(0, false)
	HighlightMap.set_layer_enabled(1, false)

func set_area_prewiew() -> void:
	AreaPrev.visible = true
	AreaPrev.modulate = areas_modulate[build_type]
	var layer = areas_dict[build_type]
	HighlightMap.set_layer_enabled(layer, true)
	

func update_area_prewiew() -> void:
	AreaPrev.global_position = get_grid_pos(get_global_mouse_position())

## if we are in demolition mode, the function handles everything connected to it
## handles input, shades the objects, destroys checked click
func handle_demolition():
	var mouse_pos = get_global_mouse_position()
	var grid_pos = get_grid_pos(mouse_pos, false)

	if grid_pos != _last_shaded_red and instances_dict.has(_last_shaded_red) and is_instance_valid(instances_dict[_last_shaded_red]):
		instances_dict[_last_shaded_red].modulate = Glob.modulate_clear
	if instances_dict.has(grid_pos) and is_instance_valid(instances_dict[grid_pos]) and instances_dict[grid_pos].destructable:
		instances_dict[grid_pos].modulate = Glob.modulate_red
		_last_shaded_red = grid_pos
		if Input.is_action_just_pressed("click"):
			destroy_object(grid_pos)
	if Input.is_action_just_pressed("ui_cancel"): 
		Glob.demolish_mode = false


## destroys the object, calls its death function and removes the object from instances dict
func destroy_object(grid_pos: Vector2):
	var obj_pos = instances_dict[grid_pos].center_pos
	var dimensions = instances_dict[grid_pos].self_cells_size
	instances_dict[grid_pos].die()
	remove_building_from_instances_dict(obj_pos, dimensions)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and Glob.build_mode and can_build:
		var dismensions: bool = true if (Glob.dismensions_dict[build_type].x % 2 == 0) else false
		var grid_pos: Vector2 = get_grid_pos(get_global_mouse_position(), dismensions)
		place_object(build_type, grid_pos)

## if we are in build mode, the function handles everything connected to it
## previews object, shades it, checks if we can place it there
## handles input and actualy builds
func handle_building():
	var mouse_pos: Vector2 = get_global_mouse_position()
	var dismensions: bool = true if (Glob.dismensions_dict[build_type].x % 2 == 0) else false
	var grid_pos: Vector2 = get_grid_pos(mouse_pos, dismensions)
	
	check_if_free_cells_to_build(grid_pos)
	update_texture_preview(grid_pos)
	
	if Input.is_action_just_pressed("ui_cancel"):
		Glob.build_mode = false
		reset_preview()
	handle_rotation()


## handle rotation for the objects
## 0   == up
## PI/2  == right
## PI == down
## 2*PI/2 == left
func handle_rotation():
	if Input.is_action_just_pressed("ui_left"):
		build_rotation = 3*PI/2
	if Input.is_action_just_pressed("ui_up"):
		build_rotation = 0
	if Input.is_action_just_pressed("ui_right"):
		build_rotation = PI/2
	if Input.is_action_just_pressed("ui_down"):
		build_rotation = PI


## signal that handles UI build button actions
## it can eather specify which object to build
## or enter demolition mode
func _on_build_button_pressed(building_type: String):
	if building_type == "Demolish":
		# TODO: REWRITE IT TO SETTER
		Glob.build_mode = false
		Glob.demolish_mode = true
		Glob.draw_area_mode = false
		reset_preview()
		reset_areas_prewiew()
	elif building_type == "Clear" or building_type == "Harvest":
		Glob.draw_area_mode = true
		Glob.build_mode = false
		Glob.demolish_mode = false
		build_type = building_type
		reset_preview()
	else:
		# TODO: REWRITE IT TO SETTER
		Glob.build_mode = true
		Glob.demolish_mode = false
		Glob.draw_area_mode = false
		build_type = building_type
		set_preview(build_type)
		reset_areas_prewiew()


## set prewiew of the object we are going to build
## set texture, z-index, rotation
func set_preview(preview_name: String):
	obj_prev_name = preview_name
	var new_obj_sprite = load(Glob.previews_dict[preview_name])
	PrevSprite.set_texture(new_obj_sprite)
	PrevSprite.rotation = build_rotation

## updates preview textures, called from _process
## responsible for shading if the building can be built checked the coordinates or no
func update_texture_preview(grid_pos: Vector2):
	PrevSprite.global_position = grid_pos
	PrevSprite.rotation = build_rotation
	if(can_build):
		PrevSprite.modulate = Glob.modulate_green
	else:
		PrevSprite.modulate = Glob.modulate_red

## reset preview for preview sprite
## make it invisible
func reset_preview():
	PrevSprite.set_texture(null)

## create object to scene, set its gridified position and rotation
## add it to the building instances dict
func place_object(object_name: String, grid_pos: Vector2):
	var NewObj = load(Glob.objects_dict[object_name]).instantiate()
	BuildingsContainer.get_node(object_name).add_child(NewObj)
	NewObj.global_position = grid_pos
	NewObj.rotation = build_rotation
	NewObj.center_pos = grid_pos
	add_to_positions_dict(grid_pos, NewObj)
	
	if Glob.exit_build_mode_on_build:
			Glob.build_mode = false
			reset_preview()


## helper function to gridify the coordinates
## dimensions - true for even, false for odd
## if dismensions is true - snaps to intersections of tiles
## if dismensions is false  - snaps to centers of tiles
func get_grid_pos(pos: Vector2, dismensions: bool = false) -> Vector2:
	if dismensions: return Vector2(
		snapped(pos.x, Glob.GRID_STEP),
		snapped(pos.y, Glob.GRID_STEP))
	else: return Vector2(
		snapped(pos.x - Glob.GRID_STEP/2., Glob.GRID_STEP) + Glob.GRID_STEP/2.,
		snapped(pos.y - Glob.GRID_STEP/2., Glob.GRID_STEP) + Glob.GRID_STEP/2.)

## helper function to get all the tiles that are covered by building
## now works only for 1x1 and 2x2 buildings but if needed to extend - its easy to do
## TODO: try to unify it and get rid of several if branches for every possible size
func get_covering_positions(pos: Vector2, dismesions: Vector2i) -> Array[Vector2]:
	var positions: Array[Vector2] = []
	if dismesions == Vector2i(1, 1):
		positions.append(Vector2(pos))
	if dismesions == Vector2i(2, 2):
		for i in range(0, 2):
			for j in range(0, 2):
				positions.append(Vector2(pos.x + Glob.GRID_STEP * (i-0.5), pos.y + Glob.GRID_STEP * (j-0.5)))
	return positions

## put an item to the positions dict and
## if the building spans more than one cell, iterate over them
func add_to_positions_dict(grid_pos: Vector2, object: Object) -> void:
	for pos in get_covering_positions(grid_pos, Glob.dismensions_dict[build_type]):
		instances_dict[pos] = object
		clear_nav(pos)

## check if the building can be built on this position
## takes into account the size of the building
func check_if_free_cells_to_build(grid_pos: Vector2) -> void:
	can_build = true
	for pos in get_covering_positions(grid_pos, Glob.dismensions_dict[build_type]):
		if instances_dict.has(pos) and is_instance_valid(instances_dict[pos]): 
			can_build = false
			return

## helper function to delete the building from the dict
## instead of searching every appearance of the building - simply recalculate its positions
## and iterate over those
func remove_building_from_instances_dict(obj_pos: Vector2, dimensions: Vector2i) -> void:
	var covering_positions = get_covering_positions(obj_pos, dimensions)
	for pos in covering_positions:
		instances_dict.erase(pos)
		set_nav(pos)



## helper function to create environment and populate it with all the requiered resources
func create_environment(world_size: Vector2) -> void:
	create_trees(world_size)

## function to create trees with specific probability over the specific area
func create_trees(world_size: Vector2) -> void:
	for i in range(0, world_size.x, Glob.GRID_STEP):
		for j in range(0, world_size.y, Glob.GRID_STEP):
			var to_spawn: bool = false
			var obj: Interactable
			if randf_range(0, 1) < trees_prob: 
				to_spawn = true
				obj = Tree1.instantiate()
			elif randf_range(0, 1) < rock_prob:
				to_spawn = true
				obj = Rock.instantiate()
			if !to_spawn: continue
			var pos: Vector2 = Vector2(i - Glob.GRID_STEP/2., j - Glob.GRID_STEP/2.)
			ResourcesContainer.call_deferred("add_child", obj)
			obj.set_deferred("global_position", pos)
			obj.set_deferred("scene", self)
			obj.set_deferred("center_pos", pos)
			obj.call_deferred("update_z")
			instances_dict[pos] = obj
			clear_nav(pos)


## remove navigation tile on the position (in absolute world coordinates, not tilemap ones)
func clear_nav(pos: Vector2) -> void:
	Tilemap.set_cell(1, pos/Glob.GRID_STEP, -1)

## set navigation tile on the position
func set_nav(pos: Vector2) -> void:
	Tilemap.set_cell(1, pos/Glob.GRID_STEP, 2, Vector2i(0, 0))


## get all the movable resources on the scene that are not stored and are not reserved by anyone
func get_dropped_materials() -> Array[Movable]:
	var res : Array[Movable] = []
	for item in DroppedResources.get_children():
		if item.taken_by_building or item.reserved_by_skeleton or item.taken_by_skeleton: continue
		if get_grid_pos(item.global_position) in pickup_tiles: res.append(item)
	return res

## get all the storages to which are not full
func get_storages() -> Array[Storage]:
	var res : Array[Storage] = []
	for storage in BuildingsContainer.get_node("Storage").get_children():
		if storage.stored_objects < 9:
			res.append(storage)
	return res

func get_resources() -> Array[InteractableTimed]:
	var res: Array[InteractableTimed] = []
	for resource in ResourcesContainer.get_children():
		if resource.reserved_by_skeleton: continue
		if get_grid_pos(resource.global_position) in harvest_tiles:
			res.append(resource)
	return res
