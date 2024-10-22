extends Control

var level_manager : Node2D:
	get:
		return get_tree().current_scene

@onready var pause_menu = $PauseMenu
@onready var pause_button = $PauseButton
@onready var texture_progress_bar = $TextureProgressBar
@onready var energy_segment_container = $EnergyBar/Outline/EnergySegmentContainer
@onready var energy_bar_outline = $EnergyBar/Outline

const POWERED_COLOR : Color = Color8(253, 255, 171, 255)
const UNPOWERED_COLOR : Color = Color8(68, 12, 255, 255)

func _ready():
	pass

func create_energy_bar(segment_count : int):
	for child in energy_segment_container.get_children():
		energy_segment_container.remove_child(child)

	energy_bar_outline.size.x = round(160.0 / segment_count) * segment_count
	
	for i in range(segment_count):
		var new_segment : NinePatchRect = NinePatchRect.new()
		
		new_segment.texture = preload("res://Sprites/UI/EnergySegment.png")
		new_segment.region_rect = Rect2(0, 0, 28, 18)
		
		new_segment.patch_margin_left = 11
		new_segment.patch_margin_top = 3
		new_segment.patch_margin_right = 11
		new_segment.patch_margin_bottom = 3
		
		new_segment.size_flags_horizontal = 3
		
		energy_segment_container.add_child(new_segment)
	
	await get_tree().process_frame # This is the part that adjusts the segments to be equal sizes
	
	var main_segment_size = 0
	for i in len(energy_segment_container.get_children()):
		var child = energy_segment_container.get_children()[i]

		if i <= 0:
			main_segment_size = child.size.x
			continue
		energy_bar_outline.size.x += main_segment_size - child.size.x

func update_energy_segment_colors(charge_amount : int):
	var energy_segments = energy_segment_container.get_children()
	if len(energy_segments) != level_manager.player.max_charge:
		create_energy_bar(level_manager.player.max_charge)
	
	energy_segments = energy_segment_container.get_children()
	
	for energy_segment in energy_segments:
		energy_segment.modulate = UNPOWERED_COLOR
	
	for i in range(charge_amount):
		energy_segments[i].modulate = POWERED_COLOR

func _on_pause_button_pressed():
	if SceneManager.transitioning:
		return
	
	AudioManager.play_sfx("Pause")
	level_manager.paused = true
	pause_menu.visible = true

func _on_pause_menu_resume_pressed():
	level_manager.paused = false
	pause_menu.visible = false

func _on_restart_button_pressed():
	level_manager.restart()


func _on_pause_menu_main_menu_pressed():
	SceneManager.load_level(SceneManager.menus_paths["level_select_" + SceneManager.current_world_name])
