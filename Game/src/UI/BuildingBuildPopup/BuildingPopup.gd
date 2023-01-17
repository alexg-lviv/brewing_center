extends Control
class_name BuildingPopup

@onready var container: HBoxContainer = get_node("HBoxContainer")
@onready var texture: TextureRect = get_node("TextureRect")

@onready var element = preload("res://src/UI/BuildingBuildPopup/ResAndCount.tscn")

## on ready, update container, set scale and offset
func _ready():
	update_container()

## update container - set the scale and pivot
func update_container():
	container.scale = Vector2((texture.size.x - 30) / container.size.x, (texture.size.x - 30) / container.size.x)
	container.pivot_offset = container.size / 2

## add resource  
## instantiate the resource and count variable, set the resource sprite and set the text  
## add it to the container
func add_resource(resource: String, desired_amount: int) -> void:
	var instance = element.instantiate()
	container.call_deferred("add_child", instance)
	instance.call_deferred("update_texture", ResDescription.dropped_rss_sprites[resource])
	instance.call_deferred("set_desired_amount", desired_amount)
	instance.set_deferred("name", resource)
	call_deferred("update_container")

## add count of resources when we put resource to the destination
func update_res_count(resource_name: String, amount_left: int) -> void:
	var res_ui_container = container.get_node(resource_name)
	res_ui_container.set_count_label(res_ui_container.desired_amount - amount_left)

## clear all the resources in the node
func clear_popup():
	for node in container.get_children():
		node.queue_free()

## turn off visibility
func hide():
	visible = false

## turn on visibility
func show():
	visible = true

## make popup more transparent on hower
func _on_mouse_entered() -> void:
	modulate = "ffffff62"

## restore transparency when unhowered
func _on_mouse_exited() -> void:
	modulate = "ffffffff"
