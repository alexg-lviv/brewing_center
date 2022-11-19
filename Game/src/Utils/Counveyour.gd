extends Area2D

class_name Belt

var left = null
var right = null
var back = null
var forward = null

onready var AnimPlayer: AnimationPlayer = get_node("AnimationPlayer")

func update_neighbours():
	var anim_name: String = ""
	if !back and !left and !right: anim_name = "s"
	if back: anim_name += "s"
	if left: anim_name += "l"
	if right: anim_name += "r"
	AnimPlayer.play(anim_name)

# r for rotation
func add_neighbour(belt: Belt, r: int):
	# this are hella klever shinenigans
	# i just hope that I will never come back here...
	r -= rotation_degrees
	r += 360
	r %= 360
	if r == 0: back = belt
	elif r == 90: left = belt
	elif r == 270: right = belt
	update_neighbours()


func delete_neighbour(r: int):
	r -= rotation_degrees
	r += 360
	r %= 360
	if r == 0: back = null
	elif r == 90: left = null
	elif r == 270: right = null
	update_neighbours()

func _on_AreaTo_area_entered(area):
	forward = area
	area.add_neighbour(self, rotation_degrees)

func del_forward():
	forward = null

func die():
	if right: right.del_forward()
	if left: left.del_forward()
	if back: back.del_forward()
	if forward:
		forward.delete_neighbour(rotation_degrees)
	queue_free()
