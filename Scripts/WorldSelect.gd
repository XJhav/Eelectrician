extends Control

@export var world_2_button : TextureButton
@export var world_3_button : TextureButton
@export var level_counter : Label

func _ready():
	SceneManager.transition_fade_out()
	
	level_counter.text = "LEVELS COMPLETED: " + str(len(GameData.completed_levels))
	
	if len(GameData.completed_levels) >= 10:
		world_2_button.disabled = false
		world_2_button.get_child(0).text = "WORLD 2"
		world_2_button.get_child(1).queue_free()
	if len(GameData.completed_levels) >= 20:
		world_3_button.disabled = false
		world_3_button.get_child(0).text = "WORLD 3"
		world_3_button.get_child(1).queue_free()
