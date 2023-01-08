class_name SkeletonCleanState
extends SkeletonBaseState

var heading_to_resource: bool = false
var heading_to_storage:  bool = false

func enter() -> void:
	skeleton.chose_target_to_clear()
	heading_to_resource = true

func exit() -> void:
	skeleton.target = null
	heading_to_resource = false
	heading_to_storage = false

func process(delta: float, target_reached: bool) -> int:
	if skeleton.target == null: return States.HarvestState

	if target_reached and heading_to_resource:
		heading_to_resource = false
		heading_to_storage = true
		skeleton.pick_up_object()
		skeleton.chose_target_to_store()
		skeleton.NavAgent.set_target_location(skeleton.target.global_position)
		return States.NullState
	
	if target_reached and heading_to_storage:
		skeleton.place_object_to_storage()
		return States.BuildState
	
	if heading_to_storage: skeleton.chose_target_to_store()
	# if you have chosen the storage and it is null.. there is no storage
	if skeleton.target == null: 
		# TODO: skeleton.drop_resource
		return States.BuildState
	
	skeleton.NavAgent.set_target_location(skeleton.target.global_position)
	var direction := skeleton.global_position.direction_to(skeleton.NavAgent.get_next_location())
	skeleton.global_position += direction * 100. * delta
	
	return States.NullState
