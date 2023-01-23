class_name DroppedResource
extends Movable
@icon("res://art/icons/log1.png")

@onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")

var rss_name: String = "" : set = _set_rss_name
var rss_type: String = ""

func _set_rss_name(new_name: String) -> void:
	rss_name = new_name
	if ResDescription.dropped_type_by_rss.has(rss_name):
		rss_type = ResDescription.dropped_type_by_rss[rss_name]
	AnimPlayer.play(rss_name)
