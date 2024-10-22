extends Area2D

var level_manager : Node2D:
	get:
		return get_tree().current_scene

@onready var animated_sprite = $AnimatedSprite
@onready var collision_shape_2d = $CollisionShape2D

@export var connected_targets : Array[Node2D] = []
@export_enum("Solid", "Passable") var unpowered_state : String = "Solid"
@export var all_targets_req : bool = true


var powered = false
var solid = false:
	set(value):
		solid = value
		update_solid_state()

func _ready():
	level_manager.connect("update_power", update_power_state)
	update_power_state()

func update_power_state():
	check_target_blocks()
	
	if powered:
		if unpowered_state == "Solid":
			solid = false
		elif unpowered_state == "Passable" and door_is_closable():
			solid = true
	
	elif !powered:
		if unpowered_state == "Solid" and door_is_closable():
			solid = true
		elif unpowered_state == "Passable":
			solid = false

func check_target_blocks():
	var targets_activated : int = 0
	
	if len(connected_targets) == 0:
		powered = true
		return
	
	for target in connected_targets:
		if !target.is_in_group("TargetBlock"):
			print("That's not a target block in the Door")
			break
		if target.powered:
			targets_activated += 1
	
	if (targets_activated >= 1 and !all_targets_req) or (targets_activated == len(connected_targets)):
		powered = true
		return
	powered = false

func door_is_closable():
	if has_overlapping_areas() or round(position / 16) in level_manager.player_snake:
		return false
	return true

func _mouse_entered_area():
	for target in connected_targets:
		if target.is_in_group("WireBlock"):
			target.show_selected_sprite()

func _on_mouse_exited():
	for target in connected_targets:
		if target.is_in_group("WireBlock"):
			target.hide_selected_sprite()

func update_solid_state():
	if solid == true:
		if !is_in_group("Solid"):
			add_to_group("Solid")
		animated_sprite.play("Solid")
		if unpowered_state == "Solid":
			animated_sprite.modulate = Color.PALE_TURQUOISE
		else:
			animated_sprite.modulate = Color.WHITE
	elif solid == false:
		if is_in_group("Solid"):
			remove_from_group("Solid")
		animated_sprite.play("Passable")
		animated_sprite.modulate = Color.WHITE
