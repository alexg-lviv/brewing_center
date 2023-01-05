class_name Skeleton
extends Area2D

@onready var player = get_node("../Player")
@onready var NavAgent :NavigationAgent2D = get_node("NavigationAgent2D")
	

func _process(delta: float) -> void:
	NavAgent.set_target_location(player.global_position)
	var direction := global_position.direction_to(NavAgent.get_next_location())
	global_position += direction * 100. * delta
