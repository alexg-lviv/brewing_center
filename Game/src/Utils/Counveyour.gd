extends Area2D

const GRID_STEP: int = 32

onready var me: Area2D = get_node(".")

func _process(delta):
	# move_belt()
	pass


func move_belt():
	var mouse_pos: Vector2 = get_global_mouse_position()
	me.global_position = Vector2(
		stepify(mouse_pos.x, GRID_STEP),
		stepify(mouse_pos.y, GRID_STEP)
	)
