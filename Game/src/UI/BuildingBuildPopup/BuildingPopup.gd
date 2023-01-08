extends Control

@onready var container: HBoxContainer = get_node("HBoxContainer")
@onready var texture: TextureRect = get_node("TextureRect")

@onready var element = preload("res://src/UI/BuildingBuildPopup/ResAndCount.tscn")


var resources: Dictionary = {
	"Wood": "res://art/rss/log1.png",
	"Stone": "res://art/rss/stone.png" 
}

func _ready():
	update_container()

func update_container():
	if container.size.x > texture.size.x - 30:
		container.scale = Vector2((texture.size.x - 30) / container.size.x, (texture.size.x - 30) / container.size.x)
		container.pivot_offset = container.size / 2

func add_resource(resource: String, desired_amount: int) -> void:
	var instance = element.instantiate()
	container.call_deferred("add_child", instance)
	instance.call_deferred("update_texture", resources[resource])
	instance.call_deferred("set_desired_amount", desired_amount)
	instance.set_deferred("name", resource)
	call_deferred("update_container")

func update_res_count(resource_name: String, amount_left: int) -> void:
	var res_ui_container = container.get_node(resource_name)
	res_ui_container.set_count_label(res_ui_container.desired_amount - amount_left)
