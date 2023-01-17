extends TextureProgressBar
class_name ArrowProgress

## timer passed as reference to track the value of the bar
var _timer: Timer

## increase the value of the timer progresively dependent on the timer left time and die if finished
func _process(_delta: float) -> void:
	value = max_value - _timer.time_left
	
	if value == max_value:
		die()

## start the progress bar, set max value and accept the timer
func start(val: float, timer: Timer) -> void:
	value = 0.
	max_value = val
	_timer = timer

## well basicaly die
func die() -> void:
	queue_free()
