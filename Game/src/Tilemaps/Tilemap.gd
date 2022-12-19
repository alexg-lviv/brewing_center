extends TileMap


func _ready() -> void:
	for tree in get_children():
		tree.update_z_index()
