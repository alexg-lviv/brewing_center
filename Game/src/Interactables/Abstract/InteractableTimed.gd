class_name InteractableTimed
extends Interactable

@onready var progress := preload("res://src/UI/ProgressBars/InteractionProgress.tscn")
@onready var InteractionTimer : Timer = get_node("InteractionTimer")

var bar
@export var interaction_time : float = 1.
var interaction_going: bool = false
var interaction_stopped: bool = false

var reserved_by_skeleton: bool = false
var reservation_skeleton: Skeleton = null

var being_harvested_by_skeleton: bool = false

## handle release of mouse button to stop the interaction
## and destroy the progress bar
func _process(delta: float) -> void:
	super(delta)
	if !being_harvested_by_skeleton and interaction_going and Input.is_action_just_released("click") and is_instance_valid(bar):
		interaction_stopped = true
		interaction_going = false
		bar.die()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

## derived interract function
## creates timer and progress bar
## hides mouse cursor and replaces it with progress bar
func interact() -> void:
	if being_harvested_by_skeleton: return
	InteractionTimer.start(interaction_time)
	bar = progress.instantiate()
	add_child(bar)
	bar.start(interaction_time, InteractionTimer)
	interaction_stopped = false
	interaction_going = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

## function of continuation of interaction after timer timed out
## figured out its better to do so than to use await()
## however might change to await later for the sake of code simplicity
func continue_interaction() -> void:
	if !being_harvested_by_skeleton:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		if interaction_stopped: return
	else: 
		reservation_skeleton.finish_harvesting()
		

## timeout timer signal to continue interaction
func _on_interaction_timer_timeout() -> void:
	continue_interaction()


## reservation by skeleton
## makes it so 2 skeletons dont run for the same objects
func get_reserved_by_skeleton(skeleton: Skeleton):
	reserved_by_skeleton = true
	reservation_skeleton = skeleton


func get_harvested_by_skeleton(skeleton: Skeleton, time_multiplier: float = 2.):
	being_harvested_by_skeleton = true
	InteractionTimer.start(interaction_time * time_multiplier)
	bar = progress.instantiate()
	bar.follow_cursor = false
	bar.skeleton_overhead_position = skeleton.OverHeadMarker
	add_child(bar)
	bar.start(interaction_time * time_multiplier, InteractionTimer)
	interaction_stopped = false
	interaction_going = true
