## Main game world
##
## a field  for construction, harvesting and all the gameplay
class_name GameWorld
extends Node2D
@icon("res://art/icons/world.png")


@export var trees_prob: float = 0.15
@export var rock_prob: float = 0.06
@export var coal_prob: float = 0.04
@export var iron_ore_prob: float = 0.02
@export var scene_size: Vector2 = Vector2(3000, 2000)
@export var skeletopns_num: int = 5

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
@onready var BuildSelectionPopup: BuildingSelection = get_node("UI/BuildingSelectionPopup")

@onready var RssOnMap = preload("res://src/Interactables/Resource.tscn")
@onready var Minion = preload("res://src/Minions/Skeleton.tscn")


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


var demand_buid_res_dict: Dictionary = {}
var demand_craft_res_dict: Dictionary = {}
var demand_plant_res_dict: Dictionary = {}


## array of buildings that need resources to build
var demand_build_buildings: Array = []
var demand_craft_buildings: Array = []
var demand_plant_buildings: Array = []

var storages: Array = []
var resources_in_storages: Dictionary = {
	"Log": [],
	"Stone": [],
	"Iron": [],
	"Coal": [],
	"IronBar": []
}
var amount_in_storages: Dictionary = {
	"Log": [],
	"Stone": [],
	"Iron": [],
	"Coal": [],
	"IronBar": []
}


var DictOfDicts: Dictionary = {}
var DictOfDemandBuildings: Dictionary = {}

func _ready():
	
	DictOfDicts[Glob.Actions.Craft] = demand_craft_res_dict
	DictOfDicts[Glob.Actions.Build] = demand_buid_res_dict
	DictOfDicts[Glob.Actions.Plant] = demand_plant_res_dict
	
	DictOfDemandBuildings[Glob.Actions.Craft] = demand_craft_buildings
	DictOfDemandBuildings[Glob.Actions.Build] = demand_build_buildings
	DictOfDemandBuildings[Glob.Actions.Plant] = demand_plant_buildings
	
	
	create_environment(scene_size)
	Glob.curr_tool_selected = "Hand"
	
	
	
	for button in get_tree().get_nodes_in_group("ActionButton"):
		button.connect("pressed", Callable(self, "_on_action_button_pressed").bind(button.get_name()))
	
	for button in get_tree().get_nodes_in_group("BuildButton"):
		button.connect("pressed", Callable(self, "_on_build_button_pressed").bind(button.get_name()))
	
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
	
	handle_tools_selection()


func handle_tools_selection() -> void:
	if Input.is_action_just_pressed("numpad_1"):
		Glob.curr_tool_selected = "Hand"
	if Input.is_action_just_pressed("numpad_2"):
		Glob.curr_tool_selected = "Axe"
	if Input.is_action_just_pressed("numpad_3"):
		Glob.curr_tool_selected = "Pickaxe"

#########################################
#########################################
#### clear and harvest areas drawing ####
#########################################
#########################################

## function to update the array to add all the tiles that were drawn  
## the tiles are taken from the input dictionary as keys
func update_drawn_array(dict: Dictionary) -> Array:
	var res: Array = []
	for key in dict.keys():
		if dict[key] != null: res.append(key)
	return res
	
## the function to handle areas drawing
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

## set the TileMap layers to invisible and hide preview sprite
func reset_areas_prewiew() -> void:
	AreaPrev.visible = false
	HighlightMap.set_layer_enabled(0, false)
	HighlightMap.set_layer_enabled(1, false)

## set area preview based on what build_type is active
func set_area_prewiew() -> void:
	AreaPrev.visible = true
	AreaPrev.modulate = areas_modulate[build_type]
	var layer = areas_dict[build_type]
	HighlightMap.set_layer_enabled(layer, true)

## update the position of preview
func update_area_prewiew() -> void:
	AreaPrev.global_position = get_grid_pos(get_global_mouse_position())



####################
####################
#### demolition ####
####################
####################

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



####################
####################
####  building  ####
####################
####################


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


####################
####################
####  preview   ####
####################
####################

## signal that handles UI build button actions
## it can eather specify which object to build
## or enter demolition mode
func _on_action_button_pressed(action_type: String):
	if action_type == "Demolish":
		# TODO: REWRITE IT TO SETTER
		Glob.build_mode = false
		Glob.demolish_mode = true
		Glob.draw_area_mode = false
		reset_preview()
		reset_areas_prewiew()
	elif action_type == "Clear" or action_type == "Harvest":
		Glob.draw_area_mode = true
		Glob.build_mode = false
		Glob.demolish_mode = false
		build_type = action_type
		reset_preview()
	elif action_type == "Build":
		BuildSelectionPopup.show()


func _on_build_button_pressed(build_name: String):
	# TODO: REWRITE IT TO SETTER
	BuildSelectionPopup.hide()
	Glob.build_mode = true
	Glob.demolish_mode = false
	Glob.draw_area_mode = false
	build_type = build_name
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



##############################
##############################
#### add objects to scene ####
##############################
##############################

## create object to scene, set its gridified position and rotation
## add it to the building instances dict
func place_object(object_name: String, grid_pos: Vector2):
	var NewObj = load("res://src/Buildings/InProgressBuilding.tscn").instantiate()
	BuildingsContainer.get_node("InProgress").add_child(NewObj)
	NewObj.global_position = grid_pos
	NewObj.rotation = build_rotation
	NewObj.center_pos = grid_pos
	NewObj.build_type = object_name
	NewObj.initiate_building(object_name)
	if !NewObj.died:
		add_to_positions_dict(grid_pos, NewObj)
	
	if Glob.exit_build_mode_on_build:
			Glob.build_mode = false
			reset_preview()

## called from the InProgressBuilfing class
## used to actually place the building we were intending to build
func build_object(object_name: String, grid_pos: Vector2, b_rotation: float):
	var NewObj = load(Glob.objects_dict[object_name]).instantiate()
	BuildingsContainer.get_node(object_name).add_child(NewObj)
	NewObj.global_position = grid_pos
	NewObj.rotation = b_rotation
	NewObj.center_pos = grid_pos
	if is_instance_valid(NewObj):
		add_to_positions_dict(grid_pos, NewObj, object_name)
	if object_name == "Storage":
		storages.append(NewObj)


###############################
###############################
#### positions shenenigans ####
###############################
###############################

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
func add_to_positions_dict(grid_pos: Vector2, object, type: String = "") -> void:
	if type == "": type = build_type
	for pos in get_covering_positions(grid_pos, Glob.dismensions_dict[type]):
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


##############################
##############################
#### environmant creation ####
##############################
##############################


## helper function to create environment and populate it with all the requiered resources
func create_environment(world_size: Vector2) -> void:
	create_trees(world_size)
	spawn_skeletons()

func spawn_skeletons():
	for i in range(skeletopns_num):
		var temp_skeleton = Minion.instantiate()
		call_deferred("add_child", temp_skeleton)
		temp_skeleton.set_deferred("global_position", Vector2(500, 500))
		temp_skeleton.set_deferred("tool", Glob.tools_sprites.keys()[randi_range(0, 1)])

## function to create trees with specific probability over the specific area
func create_trees(world_size: Vector2) -> void:
	for i in range(0, world_size.x, Glob.GRID_STEP):
		for j in range(Glob.GRID_STEP / 2, world_size.y, Glob.GRID_STEP):
			var to_spawn: bool = false
			var obj: Interactable
			var curr_obj: String = ""
			if randf_range(0, 1) < trees_prob: 
				to_spawn = true
				curr_obj = "Tree"
			elif randf_range(0, 1) < rock_prob:
				to_spawn = true
				curr_obj = "Rock"
			elif randf_range(0, 1) < coal_prob:
				to_spawn = true
				curr_obj = "CoalOre"
			elif randf_range(0, 1) < iron_ore_prob:
				to_spawn = true
				curr_obj = "IronOre"
				
			if !to_spawn: continue
			obj = RssOnMap.instantiate()
			var pos: Vector2 = Vector2(i - Glob.GRID_STEP/2., j - Glob.GRID_STEP/2.)
			ResourcesContainer.call_deferred("add_child", obj)
			obj.set_deferred("global_position", pos)
			obj.set_deferred("scene", self)
			obj.set_deferred("center_pos", pos)
			obj.call_deferred("update_z")
			obj.set_deferred("self_name", curr_obj)
#			if randi_range(0, 2) == 1:
#				obj.call_deferred("mirror")
			instances_dict[pos] = obj
			clear_nav(pos)


################################
################################
#### navigation shenenigans ####
################################
################################

## remove navigation tile on the position (in absolute world coordinates, not tilemap ones)
func clear_nav(pos: Vector2) -> void:
	Tilemap.set_cell(1, pos/Glob.GRID_STEP, -1)

## set navigation tile on the position
func set_nav(pos: Vector2) -> void:
	Tilemap.set_cell(1, pos/Glob.GRID_STEP, 2, Vector2i(0, 0))



#########################################
#########################################
#### materials/resources shenenigans ####
#########################################
#########################################

## get all the movable resources on the scene that are not stored and are not reserved by anyone
func get_dropped_materials() -> Array[Movable]:
	var res : Array[Movable] = []
	for item in DroppedResources.get_children():
		if item.taken_by_building or item.reserved_by_skeleton or item.taken_by_skeleton: continue
		if get_grid_pos(item.global_position) in pickup_tiles: res.append(item)
	return res

## get all the storages to which are not full
func get_storages() -> Array:
	var res: Array = []
	for storage in BuildingsContainer.get_node("Storage").get_children():
		if storage.stored_objects < 9:
			res.append(storage)
	return res

## get all the static big resources on map
func get_resources(tool: String) -> Array[InteractableTimed]:
	var res: Array[InteractableTimed] = []
	for resource in ResourcesContainer.get_children():
		if resource.reserved_by_skeleton: continue
		if (get_grid_pos(resource.global_position) in harvest_tiles
			and ResDescription.rss_harvest_tool[resource.self_name] == tool):
			res.append(resource)
	return res

## get all the buildings that need to be built based on resource name
## returns all the active constructions that need the stated rss
func get_build_building(resource: String, action: int) -> Array[InProgressBuilding]:
	var result: Array[InProgressBuilding] = []
	var temp_dict = DictOfDicts[action]
	if !temp_dict.has(resource): return result
	for build in temp_dict[resource]:
		if build != null:
			result.append(build)
	return result

## update the demand for construction
func update_rss_demand(res: String, amount: int, building: Building, action: int):
	var temp_dict = DictOfDicts[action]
	if amount > 0:
		if temp_dict.has(res):
			if !temp_dict[res].has(building):
				temp_dict[res].append(building)
		else:
			temp_dict[res] = [building]
	else:
		if temp_dict.has(res):
			temp_dict[res].erase(building)


## update the demand for crafting
func update_plant_rss_demand(res: String, amount: int, building: Building):
	if amount > 0:
		if demand_plant_res_dict.has(res):
			if !demand_plant_res_dict[res].has(building):
				demand_plant_res_dict[res].append(building)
		else:
			demand_plant_res_dict[res] = [building]
	else:
		if demand_plant_res_dict.has(res):
			demand_plant_res_dict[res].erase(building)

## when the resource is added to the storage,
## update the scene dictionary with the resourcources as keys and arrays of storages as values
## two dictionaries are maintained: one with storages and the other one is with quantities of those rss
func add_stored_resource(storage: Storage, resource: String) -> void:
	var index: int = resources_in_storages[resource].find(storage)
	if index != -1:
		amount_in_storages[resource][index] += 1
	else:
		resources_in_storages[resource].push_back(storage)
		amount_in_storages[resource].push_back(1)

## when we want to reserve a resource from the storage, this fumction is called
## maintains 2 dictionaries as in the above example
func try_remove_stored_resource(storage: Storage, resource: String) -> bool:
	var index: int = resources_in_storages[resource].find(storage)
	if index != -1:
		amount_in_storages[resource][index] -= 1
		if amount_in_storages[resource][index] <= 0:
			amount_in_storages[resource].pop_at(index)
			resources_in_storages[resource].pop_at(index)
		return true
	return false

## simply a getter
func get_demanding_buildings(action: int) -> Array:
	return DictOfDemandBuildings[action]

func add_demanding_buildings(building: Building, action: int) -> void:
	var temp_arr = DictOfDemandBuildings[action]
	if !temp_arr.has(building):
		temp_arr.append(building)

func remove_demanding_buildings(building: Building, action: int) -> void:
	var temp_arr = DictOfDemandBuildings[action]
	temp_arr.erase(building)

## get all the available resource of this type by rss name
func get_all_resources_by_name(res_name: String) -> Array[Movable]:
	var result: Array[Movable] = []
	for res in DroppedResources.get_children():
		if (res.self_name == res_name 
				and res.current_skeleton     == null 
				and res.reservation_skeleton == null
				and (get_grid_pos(res.global_position) in pickup_tiles
					or res.taken_by_building)):
			result.append(res)
	return result


func get_all_resources_by_type(res_type: String) -> Array[Movable]:
	var result: Array[Movable] = []
	for res in DroppedResources.get_children():
		if (res.type == res_type 
				and res.current_skeleton     == null 
				and res.reservation_skeleton == null
				and (get_grid_pos(res.global_position) in pickup_tiles
					or res.taken_by_building)):
			result.append(res)
	return result

## check if there are any available storages
func check_available_storages() -> bool:
	for storage in storages:
		if storage.stored_objects < 9:
			return true
	return false
