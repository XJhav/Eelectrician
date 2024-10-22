extends Node

const menus_paths : Dictionary = {"main" : "res://Scenes/main_menu.tscn", "level_select_blue" : "res://Scenes/level_select_menu_blue.tscn", "level_select_green" : "res://Scenes/level_select_menu_green.tscn", "level_select_red" : "res://Scenes/level_select_menu_red.tscn", "world_select" : "res://Scenes/world_select_menu.tscn"}
const scene_path_base : String = "res://Scenes/Levels/"
var current_world_name : String = "":
	get:
		var current_path = get_tree().current_scene.scene_file_path
		for color in ["blue", "green", "red", "purple"]:
			if current_path.contains(color):
				return color
		return ""
var current_world_num : int = 0:
	get:
		var current_path = get_tree().current_scene.scene_file_path
		var i : int = 0
		for color in ["blue", "green", "red", "purple"]:
			i += 1
			if current_path.contains(color):
				return i
		return 0
var current_level_num : int = 1:
	get:
		var current_path : String = get_tree().current_scene.scene_file_path
		return int(current_path)
var transitioning : bool = false

const transition_scene : PackedScene = preload("res://Scenes/transition_screen.tscn")

func transition_fade_out():
	var transition_layer = transition_scene.instantiate()
	get_tree().current_scene.add_child(transition_layer)
	transition_layer.fade_rect.position = Vector2(-250,0)
	transition_layer.fade_out()
	await transition_layer.fade_out_transition_finished
	transitioning = false
	
func transition_fade_in():
	var transition_layer = transition_scene.instantiate()
	get_tree().current_scene.add_child(transition_layer)
	transition_layer.fade_rect.position = Vector2(-1250,0)
	transition_layer.fade_in()
	await transition_layer.fade_in_transition_finished
	transitioning = true

func load_level(path : String):
	if !ResourceLoader.exists(path):
		path = get_level_select_path()
		
		if !ResourceLoader.exists(path):
			print("Couldn't find scene to load in files")
			return
	
	AudioManager.play_sfx("Whoosh")
	await transition_fade_in() 
	
	
	get_tree().change_scene_to_file(path)

func get_next_level_path():
	var current_path_plus_one = scene_path_base + current_world_name + "_" + str(current_level_num + 1) + ".tscn"
	if ResourceLoader.exists(current_path_plus_one):
		return current_path_plus_one
	return "Null"

func get_level_select_path():
	var path = "res://Scenes/level_select_menu_" + current_world_name + ".tscn"
	if ResourceLoader.exists(path):
		return path
	return "Null"

func get_level_path(world_name : String, level_num : int):
	var current_path = scene_path_base + world_name + "_" + str(level_num) + ".tscn"
	if ResourceLoader.exists(current_path):
		return current_path
	return "Null"

func load_next_level():
	load_level(get_next_level_path())


func _input(event):
	if event.is_action_pressed("ui_text_backspace"):
		if Engine.time_scale == 1:
			Engine.time_scale = 0.2
		else:
			Engine.time_scale = 1
		
