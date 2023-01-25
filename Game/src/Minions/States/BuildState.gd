class_name SkeletonBuildState
extends SkeletonBaseState

var heading_to_resource: bool = false
var heading_to_building: bool = false

var building: InProgressBuilding = null
var resource_chosen: Movable = null

func enter() -> void:
	building = null
	resource_chosen = null
	var building_and_res: Array = skeleton.chose_target_and_resource(Glob.Actions.Build)
	if building_and_res.size() == 2:
		building = building_and_res[0]
		resource_chosen = building_and_res[1]
		building.reserve_demanded_res_by_skeleton(skeleton, resource_chosen.rss_name)
		resource_chosen.get_reserved_by_skeleton(skeleton)
	skeleton.target = resource_chosen
	heading_to_resource = true

func exit() -> void:
	pass

func process(delta: float, target_reached: bool) -> int:
	if resource_chosen == null: 
		return States.CraftState
	if target_reached and heading_to_resource:
		heading_to_resource = false
		heading_to_building = true
		skeleton.pick_up_object()
		skeleton.target = building
		target_reached = false
	
	if target_reached and heading_to_building:
		skeleton.place_object_to_building()
		heading_to_building = false
		skeleton.target = null
		enter()
		return States.NullState
	
	
	if heading_to_building and skeleton.target == null:
		skeleton.drop_object()
		return States.CraftState
	if heading_to_resource and skeleton.target == null:
		return States.CraftState

	
	skeleton.NavAgent.set_target_location(skeleton.target.global_position)
	var direction := skeleton.global_position.direction_to(skeleton.NavAgent.get_next_location())
	skeleton.global_position += direction * 100. * delta
	
	return States.NullState

