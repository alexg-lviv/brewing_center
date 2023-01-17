extends HBoxContainer

@onready var preview: TextureRect = get_node("TextureBg/Texture")

func update_texture(rss: String) -> void:
	preview.texture = load(ResDescription.dropped_rss_sprites[rss])
