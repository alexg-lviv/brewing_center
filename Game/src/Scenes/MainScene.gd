## Main game world
##
## a field  for construction, harvesting and all the gameplay
class_name GameWorld
extends Node2D


@export var trees_prob: float = 0.2

# BUILD MODE VARS
var build_type: String
var can_build: bool = false
## 0 - up, PI/2 - right
var build_rotation: float = 0


var last_object: Interactable = null


@onready var UI := get_node("UI")
@onready var Tilemap : TileMap = get_node("TileMap")
@onready var Player := get_node("Player")
@onready var PrevSprite: Sprite2D = get_node("ObjSprite")
@onready var EnvironmentContainer: Node2D = get_node("Environment")
@onready var DroppedResources: Node2D = get_node("DroppedResources")
@onready var BuildingsContainer: Node2D = get_node("Buildings")


@onready var Tree1 = preload("res://src/Interactables/Tree1.tscn")


## dictionary of all instanced buildings
## the key is their grid coords, and the value is reference to the object itself
var instances_dict: Dictionary = {}

var obj_prev_name: String

var _last_shaded_red: Vector2 = Vector2.ZERO


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
	if Input.is_action_just_pressed("ui_cancel"): Glob.demolish_mode = false


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
		Glob.build_mode = false
		Glob.demolish_mode = true
		reset_preview()
	else:
		Glob.build_mode = true
		Glob.demolish_mode = false
		build_type = building_type
		set_preview(build_type)


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
	NewObj.position = grid_pos
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
func get_grid_pos(pos: Vector2, dismensions: bool) -> Vector2:
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
			if randf_range(0, 1) > trees_prob: continue
			var pos: Vector2 = Vector2(i - Glob.GRID_STEP/2., j - Glob.GRID_STEP/2.)
			var tree: Interactable = Tree1.instantiate()
			EnvironmentContainer.call_deferred("add_child", tree)
			tree.set_deferred("position", pos)
			tree.set_deferred("scene", self)
			tree.set_deferred("center_pos", pos)
			tree.call_deferred("update_z")
			instances_dict[pos] = tree
			clear_nav(pos)


func clear_nav(pos: Vector2) -> void:
	Tilemap.set_cell(1, pos/Glob.GRID_STEP, -1)

func set_nav(pos: Vector2) -> void:
	Tilemap.set_cell(1, pos/Glob.GRID_STEP, 2, Vector2i(0, 0))


func get_dropped_materials() -> Array[Movable]:
	var res : Array[Movable] = []
	for item in DroppedResources.get_children():
		if item.taken_by_building or item.reserved_by_skeleton or item.taken_by_skeleton: continue
		res.append(item)
	return res

func get_storages() -> Array[Storage]:
	var res : Array[Storage] = []
	for storage in BuildingsContainer.get_node("Storage").get_children():
		if storage.stored_objects < 9:
			res.append(storage)
	return res
