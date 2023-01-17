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


## if the drag_mode is active - all the storages signal that they are available to place items
## TODO: add visibility notifiers for optimisation
func _process(_delta: float) -> void:
	if Glob.drag_mode and (Glob.drag_rss.rss_name in my_demand.keys() and my_demand[Glob.drag_rss.rss_name] > 0):
		AnimPlayer.play("Pulsing")
		Pulser.self_modulate = "#00ff00"
	else:
		AnimPlayer.play("Idle")


func initiate_building(build_type: String):
	sprite.texture = load(Glob.previews_dict[build_type])
	sprite.modulate = "ffffff64"
	var resources: Dictionary = Glob.build_cost_dict[build_type]
	var dismensions: Vector2 = Glob.dismensions_dict[build_type]
	
	collision.shape.size = Vector2(dismensions.x * Glob.GRID_STEP / 2, dismensions.y * Glob.GRID_STEP / 2)
	
	popup.position.y -= Glob.GRID_STEP * (dismensions.y / 2)
	
	for key in resources.keys():
		popup.add_resource(key, resources[key])
		my_demand[key] = resources[key]
		my_reserved_demand[key] = []
		scene.update_build_rss_demand(key, my_demand[key], self)


func get_resource(item: Movable, skeleton: Skeleton = null):
	var resource_name = item.rss_name
	if skeleton != null:
		my_reserved_demand[resource_name].erase(skeleton)
	
	item.move_and_die(center_pos)
	my_demand[resource_name] -= 1
	scene.update_build_rss_demand(resource_name, my_demand[resource_name], self)
	
	var done = true
	for val in my_demand.values():
		if val != 0: done = false
	
	popup.update_res_count(resource_name, my_demand[resource_name])
	
	if done: finish_building()

func finish_building() -> void:
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

func reserve_demanded_res_by_skeleton(skeleton: Skeleton, resource: String):
	my_reserved_demand[resource].append(skeleton)
