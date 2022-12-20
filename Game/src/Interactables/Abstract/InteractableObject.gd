class_name Interactable
extends Sprite2D

var in_focus: bool = false
var modify_z: bool = false
var own_z: int = 10


func _process(_delta) -> void:
	if modify_z: z_index = own_z + global_position.y / 10.

func _on_area_2d_mouse_entered() -> void:
	if !Glob.demolish_mode and !Glob.build_mode:
		in_focus = true
		material.set_shader_parameter("active", true)
		Signals.emit_signal("object_howered", self)

func _on_area_2d_mouse_exited() -> void:
	Signals.emit_signal("object_unhowered", self)
	exit()

func exit() -> void:
	in_focus = false
	material.set_shader_parameter("active", false)

func _unhandled_input(event: InputEvent) -> void:
	if in_focus and event is InputEventMouseButton and event.pressed:
		interact()

func interact():
	pass

func die():
	queue_free()
