class_name SkeletonBaseState
extends Node

enum States {
	BuildState,
	CraftState,
	CleanState,
	HarvestState,
	PlantState,
	NullState,
}

#enum BuildStates {
#	HeadForRss,
#	HeadForBuilding
#}
#
#enum CleanStates {
#	HeadForRss,
#	HeadForStorage
#}


var skeleton: Skeleton

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(_delta: float, _target_reached: bool) -> int:
	return States.NullState
