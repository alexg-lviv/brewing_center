extends Movable
class_name DroppedResource
@icon("res://art/icons/log1.png")

@onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")

var rss_name: String = "" : set = _set_rss_name

func _set_rss_name(new_name: String) -> void:
	rss_name = new_name
	AnimPlayer.play(rss_name)
