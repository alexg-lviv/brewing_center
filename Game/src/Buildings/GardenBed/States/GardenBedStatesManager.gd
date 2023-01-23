extends Node2D
class_name GardenBedStatesManager


@onready var States = {
	GardenBedBaseState.States.EmptyState: get_node("EmptyState"),
	GardenBedBaseState.States.PlantedState: get_node("PlantedState"),
	GardenBedBaseState.States.AlmostDoneState: get_node("AlmostDoneState")
}

var current_state: GardenBedBaseState

func _process(delta: float) -> void:
	var next_state: int = current_state.process(delta)
	if next_state != SkeletonBaseState.States.NullState:
		change_state(next_state)

func change_state(new_state: int) -> void:
	if current_state: current_state.exit()
	
	current_state = States[new_state]
	current_state.enter()

func initialise(garden_bed: GardenBed) -> void:
	for node in get_children():
		node.garden_bed = garden_bed
	
	change_state(SkeletonBaseState.States.BuildState)
