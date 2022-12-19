extends Sprite2D




func _on_area_2d_mouse_entered() -> void:
	material.set_shader_parameter("active", true)


func _on_area_2d_mouse_exited() -> void:
	material.set_shader_parameter("active", false)
