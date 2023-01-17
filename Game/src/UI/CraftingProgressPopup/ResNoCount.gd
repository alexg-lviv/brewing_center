extends HBoxContainer

@onready var preview: TextureRect = get_node("TextureBg/Texture")

## set the texture of resource to what we want
func update_texture(rss: String) -> void:
	preview.texture = load(ResDescription.dropped_rss_sprites[rss])
