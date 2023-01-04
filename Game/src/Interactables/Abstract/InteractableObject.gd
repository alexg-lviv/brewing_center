class_name Interactable
extends Area2D

var in_focus: bool = false
var modify_z: bool = false
@export var own_z: int = 10

@onready var Sprite = get_node("Sprite2d")

## if needed, change self z-index according to y.position
## needed to ve able to pass the pbjects from the back as the player
func _process(_delta) -> void:
	if modify_z: z_index = own_z + global_position.y / 10.

## called when mouse enters the object
## sets outline shader to active if the mode allows
## emits signal to avoid multiple selections
func _on_interactable_mouse_entered() -> void:
	if !Glob.demolish_mode and !Glob.build_mode and !Glob.drag_mode:
		in_focus = true
		Sprite.material.set_shader_parameter("active", true)
		Signals.emit_signal("object_howered", self)

## called when the mouse exits
## emits signal so the global value can be reset
## and colls the function to clear outline
func _on_interactable_mouse_exited() -> void:
	Signals.emit_signal("object_unhowered", self)
	exit()

## clears outline and some helper variables
## called when mouse exits object or when
## mouse enters another object and global script calls it
func exit() -> void:
	in_focus = false
	Sprite.material.set_shader_parameter("active", false)

## handle input and call interact on mouse button
func _unhandled_input(event: InputEvent) -> void:
	if in_focus and event is InputEventMouseButton and event.pressed:
		interact()

## abstract function to interact
## each object derived from this class must implement it himself
func interact():
	pass

## abstract function of death
## each object derived from this class must implement it himself
## else default is queue_free()
func die():
	queue_free()

