extends TextureButton

@export var level_load_key : String = "world_select"

func _ready():
	connect("pressed", func(): SceneManager.load_level(SceneManager.menus_paths[level_load_key]))
	connect("mouse_entered", func(): AudioManager.play_sfx("UI"))
