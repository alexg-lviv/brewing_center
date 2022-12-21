extends InteractableTimed

@onready var wooden_log := preload("res://src/Interactables/Log.tscn")

func _ready():
	modify_z = true
	own_z = 10

func interact() -> void:
	super()

func continue_interaction() -> void:
	super()
	if interaction_stopped: return
	for i in range(randi_range(1, 3)):
		var instance = wooden_log.instantiate()
		get_parent().add_child(instance)
		instance.position = position
		instance.move(position + Vector2(randi_range(-10, 10) * 5, randi_range(-10, 10) * 5))
	die()
	
