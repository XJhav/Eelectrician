extends Node2D

signal update_power
signal intialize
signal level_complete

const CELL_SIZE = 16

@export_placeholder("LevelName") var level_name : String


var level_title_label : Control:
	get:
		return get_tree().get_first_node_in_group("LevelTitle")
var level_num_label : Control:
	get:
		return get_tree().get_first_node_in_group("LevelNumber")
var player : Node2D:
	get:
		return get_tree().get_first_node_in_group("Player")
var power_tiles : Array[Node]:
	get:
		return get_tree().get_nodes_in_group("PowerTile")
var player_snake : Array[Vector2]:
	get:
		return player.current_snake
var player_charge : int:
	get:
		return player.current_charge

var paused : bool = false
var player_has_moved : bool = false

func _ready():
	emit_signal("intialize")
	emit_signal("update_power")
	player_has_moved = false
	
	start_of_level_aesthetics()

func start_of_level_aesthetics():
	SceneManager.transition_fade_out()
	level_num_label.text = str(SceneManager.current_world_num) + "-" + str(SceneManager.current_level_num)
	
	await get_tree().create_timer(0.5).timeout
	insert_level_name()

func _on_update_power():
	if !player_has_moved:
		player_has_moved = true

func update_charge_ui():
	var ui = get_tree().get_first_node_in_group("LevelUI")
	
	ui.update_energy_segment_colors(player_charge)

func insert_level_name():
	level_title_label.text = level_name
	var title_tween_in = create_tween()
	title_tween_in.tween_property(level_title_label, "position", Vector2(35,240), 1.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	
	await title_tween_in.finished
	if player_has_moved:
		await get_tree().create_timer(1).timeout
	else:
		await update_power
	
	var title_tween_out = create_tween()
	title_tween_out.tween_property(level_title_label, "position", Vector2(-200,240), 1.25).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)

func check_level_complete():
	await get_tree().process_frame
	
	if len(get_tree().get_nodes_in_group("PowerOrb")) != 0:
		AudioManager.play_sfx("Collect")
		return
	
	GameData.complete_level(SceneManager.current_world_name, SceneManager.current_level_num)
	
	SceneManager.transitioning = true
	
	AudioManager.play_sfx("Win")
	emit_signal("level_complete")
	
	var ui = get_tree().get_first_node_in_group("LevelUI")
	ui._on_pause_menu_resume_pressed()
	level_complete_animation()
	
	await get_tree().create_timer(1).timeout
	
	SceneManager.load_next_level()

func level_complete_animation():
	var level_complete_screen_object : Node = preload("res://Scenes/LevelWinScreen.tscn").instantiate()
	add_child(level_complete_screen_object)

func restart():
	if SceneManager.transitioning:
		return
	
	if !GameData.instant_restart_enabled:
		SceneManager.load_level(get_tree().current_scene.scene_file_path)
	
	if player.moving or !player.can_move_input or paused:
		return
	
	if GameData.instant_restart_enabled:
		player.undo_manager.load_indexed_state(1)

func _input(event):
	if event.is_action_pressed("restart") and !SceneManager.transitioning:
		restart()
