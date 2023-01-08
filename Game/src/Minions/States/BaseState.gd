class_name SkeletonBaseState
extends Node

enum States {
	BuildState,
	CleanState,
	HarvestState,
	NullState
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

func process(delta: float, target_reached: bool) -> int:
	return States.NullState
