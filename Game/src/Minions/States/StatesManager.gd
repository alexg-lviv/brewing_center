class_name SkeletonStatesManager
extends Node

@onready var States = {
	SkeletonBaseState.States.HarvestState: get_node("HarvestState"),
	SkeletonBaseState.States.CleanState:   get_node("CleanState"),
	SkeletonBaseState.States.BuildState:   get_node("BuildState"),
	SkeletonBaseState.States.CraftState:   get_node("CraftState"),
	SkeletonBaseState.States.PlantState:   get_node("PlantState")
}

var current_state: SkeletonBaseState
var target_reached: bool = false


func _process(delta: float) -> void:
	var next_state: int = current_state.process(delta, target_reached)
	target_reached = false
	if next_state != SkeletonBaseState.States.NullState:
		change_state(next_state)

func change_state(new_state: int) -> void:
	if current_state: current_state.exit()
	
	current_state = States[new_state]
	current_state.enter()

func initialise(skeleton: Skeleton) -> void:
	for node in get_children():
		node.skeleton = skeleton
	
	change_state(SkeletonBaseState.States.BuildState)


func _on_navigation_agent_2d_target_reached() -> void:
	target_reached = true
