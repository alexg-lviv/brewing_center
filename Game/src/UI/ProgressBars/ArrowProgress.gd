extends TextureProgressBar
class_name ArrowProgress

var _timer: Timer

func _process(_delta: float) -> void:
	value = max_value - _timer.time_left
	
	if value == max_value:
		die()

func start(val: float, timer: Timer) -> void:
	max_value = val
	_timer = timer

func die() -> void:
	queue_free()
