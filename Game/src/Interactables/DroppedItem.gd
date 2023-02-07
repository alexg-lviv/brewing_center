class_name DroppedItem
extends Movable
@icon("res://art/icons/log1.png")

@onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")

var self_name: String = "" : set = _set_rss_name
var type: String = ""

func _set_rss_name(new_name: String) -> void:
	self_name = new_name
	if ResDescription.dropped_type_by_rss.has(self_name):
		type = ResDescription.dropped_type_by_rss[self_name]
	AnimPlayer.play(self_name)
