class_name InProgressBuilding
extends Building

@onready var sprite: Sprite2D = get_node("Sprite2D")
@onready var collision: CollisionShape2D = get_node("CollisionShape2D")
@onready var popup = get_node("BuildingPopup")


func _ready():
	initiate_building("Storage")


func initiate_building(build_type: String):
	sprite.texture = load(Glob.previews_dict[build_type])
	sprite.modulate = "ffffff64"
	var resources: Dictionary = Glob.build_cost_dict[build_type]
	var dismensions: Vector2 = Glob.dismensions_dict[build_type]
	
	collision.shape.size = Vector2(dismensions.x * Glob.GRID_STEP, dismensions.y * Glob.GRID_STEP)
	
	popup.position.y -= Glob.GRID_STEP * (dismensions.y / 2)
	
	for key in resources.keys():
		print(key, " ", resources[key])
		popup.add_resource(key, resources[key])
	

func get_resources():
	pass

