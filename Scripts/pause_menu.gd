extends Control

signal resume_pressed
signal main_menu_pressed

@onready var player_speed_slider = $Panel/PlayerSpeedSlider
@onready var sfx_slider = $Panel/SFXSlider
@onready var check_button = $Panel/CheckButton

func _ready():
	player_speed_slider.value = GameData.player_anim_speed
	sfx_slider.value = AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX"))
	check_button.button_pressed = GameData.instant_restart_enabled

func _on_resume_pressed():
	emit_signal("resume_pressed")

func _on_main_menu_pressed():
	emit_signal("main_menu_pressed")

func _on_sfx_slider_value_changed(value):
	var bus_id = AudioServer.get_bus_index("SFX")
	
	AudioServer.set_bus_volume_db(bus_id, value)

func _on_resume_mouse_entered():
	AudioManager.play_sfx("UI")
	pass

func _on_main_menu_mouse_entered():
	AudioManager.play_sfx("UI")
	pass

func _on_player_speed_slider_value_changed(value):
	GameData.player_anim_speed = value


func _on_check_button_toggled(toggled_on):
	GameData.instant_restart_enabled = toggled_on
