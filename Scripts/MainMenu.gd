extends Control

func _ready():
	SceneManager.transition_fade_out()


func _on_reset_data_pressed():
	SceneManager.load_level(SceneManager.menus_paths["main"])
	GameData.completed_levels = []


func _on_play_button_pressed():
	if len(GameData.completed_levels) == 0:
		SceneManager.load_level(SceneManager.get_level_path("blue", 1))
	else:
		SceneManager.load_level(SceneManager.menus_paths["world_select"])

func _on_play_button_mouse_entered():
	AudioManager.play_sfx("UI")

func _on_reset_data_mouse_entered():
	AudioManager.play_sfx("UI")
