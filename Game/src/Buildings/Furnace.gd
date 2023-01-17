extends Building
class_name Furnace
@icon("res://art/buildings/FurnaceBurning.png")

@onready var FurnaceAnimPlayer: AnimationPlayer = get_node("FurnaceAnimation")
@onready var PulserAnimPlayer: AnimationPlayer = get_node("AvailabilityAnimaion")
@onready var Pulser:= get_node("Polygon2D")
@onready var popup: BuildingPopup = get_node("BuildingPopup")
@onready var CraftPopup: CraftingPopup = get_node("CraftingPopup")
@onready var SmeltTimer: Timer = get_node("SmeltingTimer")
@onready var scene: GameWorld = get_node("../../..")
@onready var DroppedResources = get_node("../../../DroppedResources")

@onready var ResObject:= preload("res://src/Interactables/DroppedResource.tscn")

var fuel: bool = false
var rss: bool = false

var fuel_selected:           String = "Coal"
var object_to_smelt_selected: String = "Iron"

var my_demand:          Dictionary = {}
var my_reserved_demand: Dictionary = {}

func _ready():
	reset_demand()
	set_demand()
	popup.position.y -= Glob.GRID_STEP

## if the drag_mode is active - all the storages signal that they are available to place items
## TODO: add visibility notifiers for optimisation
func _process(_delta: float) -> void:
	if Glob.drag_mode and (!fuel or !rss) and (Glob.drag_rss.rss_name in my_demand.keys() and my_demand[Glob.drag_rss.rss_name] > 0):
		PulserAnimPlayer.play("Pulsing")
		Pulser.self_modulate = "#00ff00"
	else:
		PulserAnimPlayer.play("Idle")


func get_resource(item: Movable, skeleton: Skeleton = null):
	var resource_name = item.rss_name
	if skeleton != null:
		my_reserved_demand[resource_name].erase(skeleton)
	
	item.move_and_die(center_pos)
	my_demand[resource_name] -= 1
	
	# TODO: UPDATE RSS DEMAND ON SCENE
	
	var done = true
	for res in my_demand.keys():
		scene.update_craft_rss_demand(res, my_demand[res], self)
		if my_demand[res] != 0: done = false
	
	popup.update_res_count(resource_name, my_demand[resource_name])
	if done: start_smelting()

## accept the object if there is free place and add to counter
func take_object(from_skeleton: bool = false, object: DroppedResource = null) -> void:
	get_resource(temp_obj)

func start_smelting() -> void:
	# TODO: rework time system here
	FurnaceAnimPlayer.play("Active")
	var time_to_smelt: float = 5.
	SmeltTimer.start(time_to_smelt)
	CraftPopup.initialise_container(object_to_smelt_selected, ResDescription.rss_smelt_chains[object_to_smelt_selected],
									time_to_smelt, SmeltTimer)
	popup.hide()
	popup.clear_popup()
	scene.remove_demanding_craft_building(self)


func _on_smelting_timer_timeout() -> void:
	CraftPopup.clear()
	FurnaceAnimPlayer.play("Idle")
	var result_obj: DroppedResource= ResObject.instantiate()
	DroppedResources.add_child(result_obj)
	result_obj.global_position = center_pos
	result_obj.rss_name = ResDescription.rss_smelt_chains[object_to_smelt_selected]
	result_obj.move(center_pos + Vector2(0, 96))
	set_demand()
	popup.show()



func reset_demand():
	my_demand = {}
	my_reserved_demand = {}
	popup.clear_popup()

func set_demand():
	# TODO: change to more complex system
	my_demand[fuel_selected] = 1
	my_demand[object_to_smelt_selected] = 1
	my_reserved_demand[fuel_selected] = []
	my_reserved_demand[object_to_smelt_selected] = []
	update_demand()

func update_demand():
	for res in my_demand.keys():
		popup.add_resource(res, my_demand[res])
		scene.add_demanding_craft_building(self)
		scene.update_craft_rss_demand(res, my_demand[res], self)

## remember that item entered yourself
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Movables"):
		if (fuel_selected == area.rss_name) or (object_to_smelt_selected == area.rss_name):
			temp_obj = area
			area.get_reserved_by_building(self)

## ok forget about it, its GONE
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Movables"):
		if (fuel_selected == area.rss_name) or (object_to_smelt_selected == area.rss_name):
			area.forget_about_reservation_building()
			temp_obj = null

func reserve_demanded_res_by_skeleton(skeleton: Skeleton, resource: String):
	my_reserved_demand[resource].append(skeleton)


