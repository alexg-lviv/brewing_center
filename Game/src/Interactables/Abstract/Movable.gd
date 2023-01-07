class_name Movable
extends Interactable

@export var rss_name: String = ""

var follow_cursor: bool = false
var continue_followig: bool = false
var last_mouse_pos  : Vector2
var mouse_pos_offset: Vector2

var taken_by_building: bool = false
var current_building : Building = null

var reserved_by_building: bool = false
var reservation_building: Building = null

var taken_by_skeleton: bool = false
var current_skeleton : Skeleton = null
var skeleton_arms: Marker2D = null

var reserved_by_skeleton: bool = false
var reservation_skeleton: Skeleton = null


## set own z-index and set its modification to false
func _ready():
	z_index = own_z

## function to move object to specific position
## used to spread objects on drop or to move them via conveyours
func move(dest_position: Vector2, time: float = 0.75) -> void:
	continue_followig = false
	var tween := get_tree().create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "global_position", dest_position, time)

## basically, input handling and manipulation of states
## if the follow_cursor is true - moves using lerp
## not a tween because the position of cursor always changes
func _process(_delta: float) -> void:
	if taken_by_skeleton:
		global_position = skeleton_arms.global_position
		return
	if follow_cursor and Input.is_action_just_released("click"):
		Glob.drag_mode = false
		follow_cursor = false
		if !in_focus: Sprite.material.set_shader_parameter("active", false)
		if reserved_by_building: 
			reservation_building.take_object()
		else:
			continue_followig = true
			last_mouse_pos = get_global_mouse_position()
	if follow_cursor:
		position = lerp(position, get_global_mouse_position() + mouse_pos_offset, 0.05)
		Sprite.material.set_shader_parameter("active", true)
	elif continue_followig:
		if Glob.compare(position, last_mouse_pos):
			position = lerp(position, last_mouse_pos + mouse_pos_offset, 0.05)
		else: continue_followig = false

## derived interact function describing interactions - follow
func interact():
	if is_instance_valid(current_building):
		current_building.forget_about_item(self)
	current_building = null
	taken_by_building = false
	Glob.drag_mode = true
	mouse_pos_offset = position - get_global_mouse_position()
	follow_cursor = true

## function that reserves item by the building
## beeing called from the building script and saves the current building to the variable
func get_taken_by_building(building: Building):
	taken_by_building = true
	current_building = building
	continue_followig = false
	
	if is_instance_valid(reservation_skeleton): reservation_skeleton.forget_about_object()
	reserved_by_building = false
	reservation_building = null
	reservation_skeleton = null
	current_skeleton = null
	reserved_by_skeleton = false
	taken_by_skeleton = false
	
	monitorable = true
	monitoring = false

## the function that is being called from the building script to reserve an object by the building
## used in storage script to wait until the player releases the button and storage takes the object
func get_reserved_by_building(building: Building):
	reserved_by_building = true
	reservation_building = building

## the function to remove building reservation
## called when object exits the storage and wasnt placed
func forget_about_reservation_building():
	reserved_by_building = false
	reservation_building = null

## reservation by skeleton
## makes it so 2 skeletons dont run for the same objects
func get_reserved_by_skeleton(skeleton: Skeleton):
	reserved_by_skeleton = true
	reservation_skeleton = skeleton

## save the skeleton position where we should move
## turn off monitorable and monitoring
func get_taken_by_skeleton(skeleton: Skeleton):
	taken_by_skeleton = true
	current_skeleton = skeleton
	reserved_by_building = false
	reservation_building = null
	reserved_by_skeleton = false
	reservation_skeleton = null
	
	skeleton_arms = skeleton.HandsMarker
	
	monitoring = false
	monitorable = false
