class_name Movable
extends Interactable

func _ready():
	modify_z = false
	own_z = 2
	z_index = 2

func move(dest_position: Vector2) -> void:
	var tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", dest_position, 0.5)

func interact():
	die()
