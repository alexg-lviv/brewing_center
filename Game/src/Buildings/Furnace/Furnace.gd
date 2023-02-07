## Furnace class
##
## Accepts a fuel and a material to smelt
extends Building
class_name Furnace
@icon("res://art/buildings/Furnace/FurnaceBurning1.png")

@onready var FurnaceAnimPlayer: AnimationPlayer = get_node("FurnaceAnimation")
@onready var PulserAnimPlayer: AnimationPlayer = get_node("AvailabilityAnimaion")
@onready var Pulser:= get_node("Polygon2D")
@onready var SmeltTimer: Timer = get_node("SmeltingTimer")
@onready var scene: GameWorld = get_node("../../..")
@onready var DroppedResources = get_node("../../../DroppedResources")
@onready var popup: BuildingPopup = get_node("BuildingPopup")
@onready var ResourcesSelectionPopup: CraftRssSelection = get_node("CraftingRssSelection")
@onready var CraftPopup: CraftingPopup = get_node("CraftingPopup")
@onready var BurnableOrFuelSelectionPopup: FurnaceRssSelector = get_node("FurnaceRssSelection")

@onready var ResObject:= preload("res://src/Interactables/DroppedItem.tscn")

var selection: String

var is_fuel_selected: bool = false
var is_burnable_selected: bool = false

var fuel: bool = false
var rss: bool = false

var fuel_selected:           String = "Coal"
var object_to_smelt_selected: String = "Iron"

var received_rss:       Dictionary = {}

## reset demand
func _ready():
	reset_demand()
	popup.set_warning()
	BurnableOrFuelSelectionPopup.hide()
	ResourcesSelectionPopup.hide()


func _process(_delta: float) -> void:
	if Glob.drag_mode and (!fuel or !rss) and (Glob.drag_rss.self_name in my_demand.keys() and my_demand[Glob.drag_rss.self_name] > 0):
		PulserAnimPlayer.play("Pulsing")
		Pulser.self_modulate = "#00ff00"
	else:
		PulserAnimPlayer.play("Idle")

## accept resource, called from Movable if you drag it in with the mouse
## or from skeleton. if called from skeleton, the skeleton instance is passed in and
## the skeleton is removed from the reservation dictionary
func get_resource(item: Movable, skeleton: Skeleton = null):
	var resource_name = item.self_name
	if skeleton != null:
		my_reserved_demand[resource_name].erase(skeleton)
	else:
		var temp_skel: Skeleton = my_reserved_demand[resource_name].pop_back()
		if temp_skel != null: temp_skel.get_rejected_by_building()
	
	item.move_and_die(center_pos)
	my_demand[resource_name] -= 1
	if received_rss.has(resource_name):
		received_rss[resource_name] += 1
	else:
		received_rss[resource_name] = 1
	
	var done = true
	for res in my_demand.keys():
		scene.update_rss_demand(res, my_demand[res], self, Glob.Actions.Craft)
		if my_demand[res] != 0: done = false
	
	popup.update_res_count(resource_name, my_demand[resource_name])
	if done: start_smelting()

## start the smelting of an object
func start_smelting() -> void:
	# TODO: rework time system here
	FurnaceAnimPlayer.play("Active")
	var time_to_smelt: float = 15.
	SmeltTimer.start(time_to_smelt)
	CraftPopup.initialise_container(object_to_smelt_selected, ResDescription.rss_smelt_chains[object_to_smelt_selected],
									time_to_smelt, SmeltTimer)
	popup.hide()
	popup.clear_popup()
	scene.remove_demanding_buildings(self, Glob.Actions.Craft)

## finish the smelting and create an instance of resource
func _on_smelting_timer_timeout() -> void:
	reset_demand()
	CraftPopup.clear()
	FurnaceAnimPlayer.play("Idle")
	var result_obj: DroppedItem= ResObject.instantiate()
	DroppedResources.add_child(result_obj)
	result_obj.global_position = center_pos
	result_obj.self_name = ResDescription.rss_smelt_chains[object_to_smelt_selected]
	result_obj.move(center_pos + Vector2(0, 96) + Vector2(randf_range(-5, 5), randf_range(-5, 5)))
	set_demand()
	popup.show()

## reset demand to none
func reset_demand():
	my_demand = {}
	my_reserved_demand = {}
	received_rss = {}
	popup.clear_popup()

## set demand to all ones  
## to be reworked completely
func set_demand():
	my_demand = {}
	my_demand[fuel_selected] = int(ceil(float(ResDescription.res_heat_required[object_to_smelt_selected]) / float(ResDescription.res_heat_produced[fuel_selected])))
	my_demand[object_to_smelt_selected] = 1
	
	var new_reserved_demand: Dictionary = {}
	for res in my_reserved_demand.keys():
		if res == fuel_selected:
			new_reserved_demand[res] = my_reserved_demand[res]
		elif res == object_to_smelt_selected:
			new_reserved_demand[res] = my_reserved_demand[res]
	unreserve_demand()
	my_reserved_demand = new_reserved_demand
	if !my_reserved_demand.has(fuel_selected): 
		my_reserved_demand[fuel_selected] = []
	if !my_reserved_demand.has(object_to_smelt_selected):
		my_reserved_demand[object_to_smelt_selected] = []
	update_demand()
	update_already_received()

func update_already_received():
	for rss in received_rss.keys():
		if my_demand.has(rss) and my_demand[rss] > 0:
			my_demand[rss] -= received_rss[rss]
			popup.call_deferred("update_res_count", rss, my_demand[rss])
		else:
			throw_rss_out(rss, received_rss[rss])
			received_rss.erase(rss)

## update demand, update variables on the scene and the popup
func update_demand():
	popup.clear_popup()
	for res in my_demand.keys():
		popup.add_resource(res, my_demand[res])
		scene.add_demanding_buildings(self, Glob.Actions.Craft)
		scene.update_rss_demand(res, my_demand[res], self, Glob.Actions.Craft)

func unreserve_demand():
	for rss in my_reserved_demand.keys():
		if rss != fuel_selected and rss != object_to_smelt_selected:
			for skeleton in my_reserved_demand[rss]:
				skeleton.get_rejected_by_building()

func throw_rss_out(rss: String, amount: int) -> void:
	for i in range(amount):
		var result_obj: DroppedItem= ResObject.instantiate()
		DroppedResources.add_child(result_obj)
		result_obj.global_position = center_pos
		result_obj.self_name = rss
		result_obj.move(center_pos + Vector2(0, 96) + Vector2(randf_range(-5, 5), randf_range(-5, 5)))
		

## remember that item entered yourself
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Movables"):
		if (fuel_selected == area.self_name) or (object_to_smelt_selected == area.self_name):
			temp_obj = area
			area.get_reserved_by_building(self)

## ok forget about it, its GONE
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Movables"):
		if (fuel_selected == area.self_name) or (object_to_smelt_selected == area.self_name):
			area.forget_about_reservation_building()
			temp_obj = null



func _on_crafting_rss_selection_item_activated(item: String) -> void:
	if selection == "Fuel":
		BurnableOrFuelSelectionPopup.set_fuel_texture(item)
		is_fuel_selected = true
		fuel_selected = item
	elif selection == "Burnable":
		BurnableOrFuelSelectionPopup.set_burnable_texture(item)
		is_burnable_selected = true
		object_to_smelt_selected = item
	if is_fuel_selected and is_burnable_selected:
		set_demand()


func _on_building_popup_popup_pressed() -> void:
	if BurnableOrFuelSelectionPopup.visible:
		BurnableOrFuelSelectionPopup.hide()
	else:
		BurnableOrFuelSelectionPopup.show()
	ResourcesSelectionPopup.hide()


func _on_furnace_rss_selection_enter_burnable_selection() -> void:
	ResourcesSelectionPopup.clear()
	ResourcesSelectionPopup.show()
	for res in ResDescription.dropped_rss_types["Burnable"]:
		ResourcesSelectionPopup.add_item(res, "heat requiered" + str(ResDescription.res_heat_required[res]))
	selection = "Burnable"


func _on_furnace_rss_selection_enter_fuel_selection() -> void:
	ResourcesSelectionPopup.clear()
	ResourcesSelectionPopup.show()
	for res in ResDescription.dropped_rss_types["Fuel"]:
		ResourcesSelectionPopup.add_item(res, "heat produced" + str(ResDescription.res_heat_produced[res]))
	selection = "Fuel"


func _on_furnace_rss_selection_closed() -> void:
	ResourcesSelectionPopup.hide()


func _on_crafting_rss_selection_closed() -> void:
	pass # Replace with function body.
