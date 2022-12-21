class_name Movable
extends Interactable

var follow_cursor: bool = false
var continue_followig: bool = false
var last_mouse_pos  : Vector2
var mouse_pos_offset: Vector2


## set own z-index and set its modification to false
func _ready():
	modify_z = false
	own_z = 5
	z_index = 5

## function to move object to specific position
## used to spread objects on drop or to move them via conveyours
func move(dest_position: Vector2, time: float = 0.75) -> void:
	var tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", dest_position, time)

## basically, input handling and manipulation of states
## if the follow_cursor is true - moves using lerp
## not a tween because the position of cursor always changes
func _process(_delta: float) -> void:
	if follow_cursor and Input.is_action_just_released("click"):
		Glob.drag_mode = false
		follow_cursor = false
		continue_followig = true
		last_mouse_pos = get_global_mouse_position()
	if follow_cursor:
		position = lerp(position, get_global_mouse_position() + mouse_pos_offset, 0.05)
	elif continue_followig:
		if Glob.compare(position, last_mouse_pos):
			position = lerp(position, last_mouse_pos + mouse_pos_offset, 0.05)
		else: continue_followig = false

## derived interact function describing interactions - follow
func interact():
	Glob.drag_mode = true
	mouse_pos_offset = position - get_global_mouse_position()
	follow_cursor = true
