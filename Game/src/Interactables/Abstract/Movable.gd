class_name Movable
extends Interactable

var follow_cursor: bool = false
var can_unfollow : bool = true
var continue_followig: bool = false
var last_mouse_pos: Vector2

@onready var MoveTimer: Timer = get_node("MoveTimer")

func _ready():
	modify_z = false
	own_z = 2
	z_index = 2

func move(dest_position: Vector2, time: float = 0.75) -> void:
	var tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "position", dest_position, time)

func _process(delta: float) -> void:
	if follow_cursor and Input.is_action_just_released("click"):
		follow_cursor = false
		continue_followig = true
		last_mouse_pos = get_global_mouse_position()
	if follow_cursor:
		position = lerp(position, get_global_mouse_position(), 0.05)
	elif continue_followig:
		if compare(position, last_mouse_pos):
			position = lerp(position, last_mouse_pos, 0.05)
		else: continue_followig = false

func compare(first: Vector2, second: Vector2) -> bool:
	if abs(first.x - second.x) < 1 and abs(first.y - second.y) < 1:
		return false
	return true

func interact():
	follow_cursor = true
	MoveTimer.start()
	can_unfollow = false

func _on_move_timer_timeout() -> void:
	can_unfollow = true
