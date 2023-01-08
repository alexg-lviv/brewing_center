class_name ResAndCount
extends HBoxContainer

@onready var texture: TextureRect = get_node("Texture")
@onready var count_label: Label = get_node("Count")

var curr_amount: int = 0
var desired_amount: int = 0

func update_texture(path) -> void:
	texture.texture = load(path)

func set_desired_amount(amount: int) -> void:
	desired_amount = amount
	set_count_label(curr_amount)

func set_count_label(curr: int) -> void:
	curr_amount = curr
	count_label.text = str(curr) + "/" + str(desired_amount) 
