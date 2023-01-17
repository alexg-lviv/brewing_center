extends Control
class_name CraftingPopup

@onready var container: HBoxContainer = get_node("HBoxContainer")

@onready var res_preview: = preload("res://src/UI/CraftingProgressPopup/ResNoCount.tscn")
@onready var arrow_progress: = preload("res://src/UI/ProgressBars/ArrowProgress.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func initialise_container(res_in: String, res_out: String, max_value: float, timer: Timer) -> void:
	var rss_in = res_preview.instantiate()
	container.add_child(rss_in)
	rss_in.update_texture(res_in)
	
	var progress = arrow_progress.instantiate()
	container.add_child(progress)
	progress.start(max_value, timer)
	
	var rss_out = res_preview.instantiate()
	container.add_child(rss_out)
	rss_out.update_texture(res_out)

func clear():
	for child in container.get_children():
		child.queue_free()


## make popup more transparent on hower
func _on_mouse_entered() -> void:
	modulate = "ffffff62"

## restore transparency when unhowered
func _on_mouse_exited() -> void:
	modulate = "ffffffff"
