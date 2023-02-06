class_name SkeletonHarvestState
extends SkeletonBaseState

func enter() -> void:
	skeleton.chose_target_to_harvest(skeleton.tool)

func exit() -> void:
	skeleton.target = null

func process(delta: float, target_reached: bool) -> int:
	if skeleton.harvesting: return States.NullState
	if skeleton.target == null: return States.BuildState
	if skeleton.finished_harvesting: 
		skeleton.finished_harvesting = false
		return States.BuildState
	
	if target_reached:
		skeleton.harvest_resource()
	else:
		skeleton.NavAgent.set_target_location(skeleton.target.global_position)
		var direction := skeleton.global_position.direction_to(skeleton.NavAgent.get_next_location())
		skeleton.global_position += direction * 100. * delta

	return States.NullState
