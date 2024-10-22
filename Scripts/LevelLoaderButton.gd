extends TextureButton

@onready var label = $Label
@export var level_num : int = 0

func _ready():
	if level_num == 0:
		level_num = int(str(name))
	
	label.text = str(level_num)
	
	if GameData.is_level_completed(SceneManager.current_world_name, level_num):
		texture_normal = preload("res://Sprites/UI/smallbutton4.png")
		texture_hover = preload("res://Sprites/UI/smallbutton5.png")
		texture_pressed = preload("res://Sprites/UI/smallbutton6.png")

func _on_pressed():
	SceneManager.load_level(SceneManager.get_level_path(SceneManager.current_world_name, level_num))

func _on_mouse_entered():
	AudioManager.play_sfx("UI")
