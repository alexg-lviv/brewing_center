extends Area2D

func move(position: Vector2):
	var tween := get_tree().create_tween()
	tween.tween_property(self, "position", position, 0.5)
