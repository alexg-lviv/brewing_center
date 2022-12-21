extends CanvasLayer

@onready var Progress:= get_node("TextureProgressBar")
var _timer: Timer

func _physics_process(_delta: float) -> void:
	Progress.global_position = Progress.get_global_mouse_position() - Progress.size / 2
	Progress.value = Progress.max_value - _timer.time_left
	
	if Progress.value == Progress.max_value:
		die()

func start(val: float, timer: Timer) -> void:
	Progress.max_value = val
	_timer = timer

func die() -> void:
	queue_free()
