extends Node2D


# BUILD MODE VARS
var build_mode: bool = false
var build_type: String
# 0 - up, 90 - right
var build_rotation_degrees: int = 0

# DEMOLISH MODE VARS
var demolish_mode: bool = false


onready var UI := get_node("UI")
onready var Tilemap := get_node("TileMap")
onready var Player := get_node("Player")
onready var PrevSprite: Sprite = get_node("ObjSprite")

var previews_dict: Dictionary = {
	"Belt": "res://art/belt/s.png"
}
var objects_dict: Dictionary = {
	"Belt": "res://src/Utils/Counveyour.tscn"
}

var instances_dict: Dictionary = {}

var obj_prev_name: String

var _last_shaded_red: Vector2 = Vector2.ZERO


func _ready():
	for button in get_tree().get_nodes_in_group("BuildButton"):
		button.connect("pressed", self, "_on_build_button_pressed", [button.get_name()])


func _process(_delta):
	if build_mode:
		handle_building()
	elif demolish_mode:
		handle_demolition()


func handle_demolition():
	var mouse_pos = get_global_mouse_position()
	var grid_pos = get_grid_pos(mouse_pos)
	if grid_pos != _last_shaded_red and instances_dict.has(_last_shaded_red):
		instances_dict[_last_shaded_red].modulate = "ffffff"
	if instances_dict.has(grid_pos):
		instances_dict[grid_pos].modulate = "ff6565"
		_last_shaded_red = grid_pos
		if Input.is_action_just_pressed("click"):
			destroy_object(grid_pos)


func destroy_object(grid_pos: Vector2):
	instances_dict[grid_pos].die()
	instances_dict.erase(grid_pos)


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


func handle_rotation():
	if Input.is_action_just_pressed("ui_left"):
		build_rotation_degrees = 270
	if Input.is_action_just_pressed("ui_up"):
		build_rotation_degrees = 0
	if Input.is_action_just_pressed("ui_right"):
		build_rotation_degrees = 90
	if Input.is_action_just_pressed("ui_down"):
		build_rotation_degrees = 180


func _on_build_button_pressed(building_type: String):
	if building_type == "Reset":
		build_mode = false
		demolish_mode = true
		reset_preview()
	else:
		build_mode = true
		demolish_mode = false
		build_type = building_type
		set_preview(build_type)


func set_preview(prev_name: String):
	obj_prev_name = prev_name
	var new_obj_sprite = load(previews_dict[prev_name])
	PrevSprite.set_texture(new_obj_sprite)
	PrevSprite.rotation_degrees = build_rotation_degrees
	PrevSprite.z_index = 4


func get_grid_pos(mouse_pos: Vector2) -> Vector2:
	return Vector2(
		stepify(mouse_pos.x + Glob.GRID_STEP / 2, Glob.GRID_STEP) - Glob.GRID_STEP / 2,
		stepify(mouse_pos.y + Glob.GRID_STEP / 2, Glob.GRID_STEP) - Glob.GRID_STEP / 2)

func update_texture_preview(grid_pos: Vector2, can_build: bool):
	PrevSprite.global_position = grid_pos
	PrevSprite.rotation_degrees = build_rotation_degrees
	if(can_build):
		PrevSprite.modulate = "73feb0"
	else:
		PrevSprite.modulate = "ff6565"


func reset_preview():
	PrevSprite.set_texture(null)


func place_object(object_name: String, grid_pos: Vector2):
	var NewObj = load(objects_dict[object_name]).instance()
	add_child(NewObj)
	NewObj.position = grid_pos
	NewObj.rotation_degrees = build_rotation_degrees
	instances_dict[grid_pos] = NewObj
