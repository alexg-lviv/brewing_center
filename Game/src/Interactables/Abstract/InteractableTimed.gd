class_name InteractableTimed
extends Interactable

@onready var progress := preload("res://src/UI/InteractionProgress.tscn")
@onready var InteractionTimer : Timer = get_node("InteractionTimer")

var bar
var interaction_time : float = 1
var interaction_going: bool = false
var interaction_stopped: bool = false

func _process(_delta: float) -> void:
	super(_delta)
	if interaction_going and Input.is_action_just_released("click") and is_instance_valid(bar):
		interaction_stopped = true
		interaction_going = false
		bar.die()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


func interact() -> void:
	InteractionTimer.start(interaction_time)
	bar = progress.instantiate()
	add_child(bar)
	bar.start(interaction_time, InteractionTimer)
	interaction_stopped = false
	interaction_going = true
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


func continue_interaction() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	if interaction_stopped: return

func _on_interaction_timer_timeout() -> void:
	continue_interaction()
