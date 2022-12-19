extends Interactable

@onready var log := preload("res://src/Interactables/log.tscn")

func _ready():
	modify_z = true
	own_z = 10

func interact():
	for i in range(randi_range(1, 3)):
		var instance = log.instantiate()
		get_parent().add_child(instance)
		instance.position = position
		instance.move(position + Vector2(randi_range(-10, 10) * 5, randi_range(-10, 10) * 5))
	die()
