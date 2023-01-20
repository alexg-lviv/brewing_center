class_name InProgressBuilding
extends Building

@onready var sprite: Sprite2D = get_node("Sprite2D")
@onready var collision: CollisionShape2D = get_node("CollisionShape2D")
@onready var popup = get_node("BuildingPopup")
@onready var scene: GameWorld = get_node("../../..")

@onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")
@onready var Pulser := get_node("Polygon2D")

var my_demand: Dictionary = {}
var my_reserved_demand: Dictionary = {}

var build_type: String

var died: bool = false

## if the drag_mode is active - all the storages signal that they are available to place items
## TODO: add visibility notifiers for optimisation
func _process(_delta: float) -> void:
	if Glob.drag_mode and (Glob.drag_rss.rss_name in my_demand.keys() and my_demand[Glob.drag_rss.rss_name] > 0):
		AnimPlayer.play("Pulsing")
		Pulser.self_modulate = "#00ff00"
	else:
		AnimPlayer.play("Idle")

## function to initiate the building process  
## add demands to the main scene, set preview sprite, set popup
func initiate_building(build_type: String) -> void:
	var resources = Glob.build_cost_dict[build_type]
	var dismensions: Vector2 = Glob.dismensions_dict[build_type]
	if resources == null:
		finish_building()
		return
	sprite.texture = load(Glob.previews_dict[build_type])
	sprite.modulate = "ffffff64"
	
	scene.add_demanding_build_building(self)
	
	
	collision.shape.size = Vector2(dismensions.x * Glob.GRID_STEP / 2, dismensions.y * Glob.GRID_STEP / 2)
	
	popup.position.y -= Glob.GRID_STEP * (dismensions.y / 2)
	
	for key in resources.keys():
		popup.add_resource(key, resources[key])
		my_demand[key] = resources[key]
		my_reserved_demand[key] = []
		scene.update_build_rss_demand(key, my_demand[key], self)


## accept resource, called from Movable if you drag it in with the mouse
## or from skeleton. if called from skeleton, the skeleton instance is passed in and
## the skeleton is removed from the reservation dictionary
func get_resource(item: Movable, skeleton: Skeleton = null):
	var resource_name = item.rss_name
	if skeleton != null:
		my_reserved_demand[resource_name].erase(skeleton)
	else:
		if my_reserved_demand.has(resource_name):
			var temp_skel: Skeleton = my_reserved_demand[resource_name].pop_back()
			if temp_skel != null: temp_skel.get_rejected_by_building()
		
	
	item.move_and_die(center_pos)
	my_demand[resource_name] -= 1
	scene.update_build_rss_demand(resource_name, my_demand[resource_name], self)
	
	var done = true
	for val in my_demand.values():
		if val != 0: done = false
	
	popup.update_res_count(resource_name, my_demand[resource_name])
	
	if done: finish_building()


## funush building, call function to instantiate the building, and die ourselves
func finish_building() -> void:
	died = true
	scene.build_object(build_type, center_pos, rotation)
	scene.demand_build_buildings.erase(self)
	queue_free()


## remember that item entered yourself
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Movables"):
		temp_obj = area
		area.get_reserved_by_building(self)

## ok forget about it, its GONE
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Movables"):
		area.forget_about_reservation_building()
		temp_obj = null


## remember that the resource should bring us resource so we dont need other skeletons to bring it
func reserve_demanded_res_by_skeleton(skeleton: Skeleton, resource: String):
	my_reserved_demand[resource].append(skeleton)
