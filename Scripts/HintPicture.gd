class_name HintPicture
extends TextureRect

var level_manager : Node2D:
	get:
		return get_tree().current_scene

@export_placeholder("This Is A Hint") var text_to_display : String
@onready var tooltip_panel_container = $TooltipPanelContainer
@onready var label = $TooltipPanelContainer/Label


func _ready():
	connect("mouse_entered", func(): tooltip_panel_container.visible = true; AudioManager.play_sfx("UI"))
	connect("mouse_exited", func(): tooltip_panel_container.visible = false)
	level_manager.connect("level_complete", func(): tooltip_panel_container.visible = false)
	
	tooltip_panel_container.global_position = Vector2(0, 180)
	label.text = text_to_display
	
	await get_tree().process_frame
	tooltip_panel_container.force_update_transform()
	tooltip_panel_container.global_position = Vector2(tooltip_panel_container.size.x / -2, 80)
	
	tooltip_panel_container.visible = false
