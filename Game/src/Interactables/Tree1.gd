extends Interactable

@onready var log := preload("res://src/Interactables/Log.tscn")
@onready var progress := preload("res://src/UI/InteractionProgress.tscn")
@onready var InteractionTimer : Timer = get_node("InteractionTimer")

var bar
var interaction_time : float = 1
var interaction_going: bool = false
var interaction_stopped: bool = false

func _ready():
	modify_z = true
	own_z = 10

func _process(_delta: float) -> void:
	super(_delta)
	if interaction_going and Input.is_action_just_released("click") and is_instance_valid(bar):
		interaction_stopped = true
		interaction_going = false
		bar.die()

func interact():
	InteractionTimer.start(interaction_time)
	bar = progress.instantiate()
	add_child(bar)
	bar.start(interaction_time, InteractionTimer)
	interaction_stopped = false
	interaction_going = true

func _on_interaction_timer_timeout() -> void:
	if interaction_stopped: return
	for i in range(randi_range(1, 3)):
		var instance = log.instantiate()
		get_parent().add_child(instance)
		instance.position = position
		instance.move(position + Vector2(randi_range(-10, 10) * 5, randi_range(-10, 10) * 5))
	die()
