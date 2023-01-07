extends CanvasLayer

@onready var Progress:= get_node("TextureProgressBar")
var _timer: Timer
var follow_cursor: bool = true

var skeleton_overhead_position: Marker2D

func _process(_delta: float) -> void:
	if follow_cursor:
		Progress.position = Progress.get_global_mouse_position() - Progress.size / 2
	if skeleton_overhead_position != null:
		Progress.position = (skeleton_overhead_position.global_position - Progress.size / 2)
	Progress.value = Progress.max_value - _timer.time_left
	
	if Progress.value == Progress.max_value:
		die()

func start(val: float, timer: Timer) -> void:
	Progress.max_value = val
	_timer = timer

func die() -> void:
	queue_free()
