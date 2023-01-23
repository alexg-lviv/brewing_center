extends Node
class_name GardenBedBaseState

enum States{
	NullState,
	EmptyState,
	PlantedState,
	AlmostDoneState
}

var garden_bed: GardenBed

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(_delta: float) -> int:
	return States.NullState
