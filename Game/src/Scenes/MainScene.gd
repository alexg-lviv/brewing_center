## Main game world
##
## a field  for construction, harvesting and all the gameplay
class_name GameWorld
extends Node2D


# BUILD MODE VARS
var build_mode: bool = false
var build_type: String
## 0 - up, 90 - right
var build_rotation: float = 0

# DEMOLISH MODE VARS
var demolish_mode: bool = false


@onready var UI := get_node("UI")
@onready var Tilemap := get_node("TileMap")
@onready var Player := get_node("Player")
@onready var PrevSprite: Sprite2D = get_node("ObjSprite")

## dictionary of all instanced buildings
## the key is their grid coords, and the value is reference to the object itself
var instances_dict: Dictionary = {}

var obj_prev_name: String

var _last_shaded_red: Vector2 = Vector2.ZERO


func _ready():
	for button in get_tree().get_nodes_in_group("BuildButton"):
		button.connect("pressed",Callable(self,"_on_build_button_pressed").bind(button.get_name()))


func _process(_delta):
	if build_mode:
		handle_building()
	elif demolish_mode:
		handle_demolition()

## if we are in demolition mode, the function handles everything connected to it
## handles input, shades the objects, destroys checked click
func handle_demolition():
	var mouse_pos = get_global_mouse_position()
	var grid_pos = get_grid_pos(mouse_pos)
	if grid_pos != _last_shaded_red and instances_dict.has(_last_shaded_red):
		instances_dict[_last_shaded_red].modulate = Glob.modulate_clear
	if instances_dict.has(grid_pos):
		instances_dict[grid_pos].modulate = Glob.modulate_red
		_last_shaded_red = grid_pos
		if Input.is_action_just_pressed("click"):
			destroy_object(grid_pos)
	if Input.is_action_just_pressed("ui_cancel"): demolish_mode = false


## destroys the object, calls its death function and removes the object from instances dict
func destroy_object(grid_pos: Vector2):
	instances_dict[grid_pos].die()
	instances_dict.erase(grid_pos)


## if we are in build mode, the function handles everything connected to it
## previews object, shades it, checks if we can place it there
## handles input and actualy builds
func handle_building():
	var mouse_pos: Vector2 = get_global_mouse_position()
	var grid_pos: Vector2 = get_grid_pos(mouse_pos)
	var can_build: bool = !instances_dict.has(grid_pos)
	update_texture_preview(grid_pos, can_build)
	if can_build and Input.is_action_just_pressed("click"):
		place_object(build_type, grid_pos)
		if Glob.exit_build_mode_on_build:
			build_mode = false
			reset_preview()
	if Input.is_action_just_pressed("ui_cancel"):
		build_mode = false
		reset_preview()
	handle_rotation()


## handle rotation for the objects
## 0   == up
## 90  == right
## 180 == down
## 270 == left
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
		build_mode = false
		demolish_mode = true
		reset_preview()
	else:
		build_mode = true
		demolish_mode = false
		build_type = building_type
		set_preview(build_type)


## set prewiew of the object we are going to build
## set texture, z-index, rotation
func set_preview(prev_name: String):
	obj_prev_name = prev_name
	var new_obj_sprite = load(Glob.previews_dict[prev_name])
	PrevSprite.set_texture(new_obj_sprite)
	PrevSprite.rotation = build_rotation
	PrevSprite.z_index = 4


## helper function to gridify the coordinates
func get_grid_pos(pos: Vector2) -> Vector2:
	return Vector2(
		snapped(pos.x + Glob.GRID_STEP / 2, Glob.GRID_STEP) - Glob.GRID_STEP / 2,
		snapped(pos.y + Glob.GRID_STEP / 2, Glob.GRID_STEP) - Glob.GRID_STEP / 2)


## updates preview textures, called from _process
## responsible for shading if the building can be built checked the coordinates or no
func update_texture_preview(grid_pos: Vector2, can_build: bool):
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
	add_child(NewObj)
	NewObj.position = grid_pos
	NewObj.rotation = build_rotation
	instances_dict[grid_pos] = NewObj
