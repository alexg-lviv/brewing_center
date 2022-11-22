class_name Trash
extends Building

var busy = false

## function to update the "double linked list" of belts
## called checked signal from other belt
## calculates from which direction the neighbour was added
## and calls update animation
func add_neighbour(other_belt, other_rotation: int):
	other_rotation = get_relative_rotation(other_rotation)
	if other_rotation == 0:   
		back = other_belt
	if abs(other_rotation - PI/2) < Glob.FLOAT_EPSILON:  
		left = other_belt
	if abs(other_rotation - 3*PI/2) < Glob.FLOAT_EPSILON: 
		right = other_belt

## signal handling deletion of transportable item or connection of other buildings
func _on_building_area_entered(area):
	if area.is_in_group("TransportableItems"):
		area.die()
	elif area.is_in_group("Buildings"):
		add_neighbour(area, area.rotation)
