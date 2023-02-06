extends Control

@onready var ToolsContainer = get_node("ToolsContainer")
var inactive_texture = load("res://art/tools/tools_bg_inactive.png")
var active_texture = load("res://art/tools/tools_bg_active.png")

func _ready() -> void:
	Glob.connect("selected_tool_changed", Callable(_on_current_tool_selected))

func _on_current_tool_selected(selected_tool: String) -> void:
	for tool in ToolsContainer.get_children():
		if tool.name == selected_tool:
			tool.set("texture_normal", active_texture)
		else:
			tool.set("texture_normal", inactive_texture)
