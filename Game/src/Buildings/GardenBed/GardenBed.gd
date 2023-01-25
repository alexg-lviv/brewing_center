extends Building
class_name GardenBed
@icon("res://art/buildings/GardenBed/GardenBed.png")


@onready var PulserAnimPlayer: AnimationPlayer = get_node("PulsePlayer")
@onready var SelfAnimation: AnimationPlayer = get_node("BedPlayer")
@onready var Pulser: Polygon2D = get_node("Polygon2D")
@onready var Scene: GameWorld = get_node("../../..")
@onready var ResourcesContainer = get_node("../../../Resources")
@onready var WaterTimer: Timer = get_node("WaterTimer")
@onready var GrowthTimer: Timer = get_node("GrowthTimer")

var my_demand: Dictionary = {}
var my_reserved_demand: Dictionary = {}

var state: int : set = _set_state

var time_to_water: float = 7.5
var time_to_grow: float = 10.


@onready var Res = preload("res://src/Interactables/Resource.tscn")


enum States {
	EmptyState,
	PlantedState,
	SproutState,
	AlmostDoneState,
	DoneState
}

var animations_to_state_dict: Dictionary = {
	States.EmptyState: "Empty",
	States.PlantedState: "Planted",
	States.SproutState: "Sprout",
	States.AlmostDoneState: "AlmostDone"
}

func _set_state(new_state: int) -> void:
	state = new_state
	SelfAnimation.play(animations_to_state_dict[state])

func _ready() -> void:
	reset_demand()
	state = States.EmptyState

func _process(_delta: float) -> void:
	if Glob.drag_mode and state == States.EmptyState and Glob.drag_rss.rss_name in ResDescription.dropped_rss_types["Seed"]:
		PulserAnimPlayer.play("Pulsing")
		Pulser.self_modulate = "#00ff00"
	else:
		PulserAnimPlayer.play("Idle")


func get_resource(item: Movable, skeleton: Skeleton = null) -> void:
	var resource_name = item.rss_name
	var resource_type = item.rss_type
	if skeleton != null:
		my_reserved_demand[resource_type].erase(skeleton)
	else:
		var temp_skel: Skeleton = my_reserved_demand[resource_type].pop_back()
		if temp_skel != null: temp_skel.get_rejected_by_building()
	
	item.move_and_die(center_pos, 0.3)
	my_demand[resource_type] -= 1
	
	var done = true
	for res in my_demand.keys():
		Scene.update_rss_demand(res, my_demand[res], self, Glob.Actions.Plant)
		if my_demand[res] != 0: done = false
	
	if done: start_growth()

func start_growth():
	state += 1
	GrowthTimer.start(time_to_grow / 3)

func reset_demand() -> void:
	my_demand = {"Seed": 1}
	my_reserved_demand = {}
	for key in my_demand.keys():
		my_reserved_demand[key] = []


## remember that item entered yourself
func _on_area_entered(area: Area2D) -> void:
	if area.is_in_group("Movables") and area.rss_type in my_demand.keys():
		temp_obj = area
		area.get_reserved_by_building(self)

## ok forget about it, its GONE
func _on_area_exited(area: Area2D) -> void:
	if area.is_in_group("Movables") and area.rss_type in my_demand.keys():
		area.forget_about_reservation_building()
		temp_obj = null

func transition_states() -> void:
	if state < States.AlmostDoneState:
		state += 1
		GrowthTimer.start(time_to_grow / 3)
	elif state == States.AlmostDoneState:
		spawn_result()

func spawn_result() -> void:
	var instance = Res.instantiate()
	ResourcesContainer.call_deferred("add_child", instance)
	instance.set_deferred("global_position", global_position + Vector2(0, -20))
	instance.set_deferred("rss_name", "Tree")
	instance.set_deferred("scene", Scene)
	Scene.instances_dict[global_position + Vector2(0, -20)] = instance
	queue_free()

func _on_growth_timer_timeout() -> void:
	transition_states()


func _on_water_timer_timeout() -> void:
	pass # Replace with function body.
