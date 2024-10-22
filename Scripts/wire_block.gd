extends Area2D

var level_manager : Node2D:
	get:
		return get_tree().current_scene

@onready var base_sprite = $BaseSprite
@onready var wire_center_sprite = $WireSpriteContainer/WireCenter
@onready var wire_sprite_container = $WireSpriteContainer
@onready var power_ray = $PowerDetectionRay
@onready var selected_sprite = $SelectedSprite


@export var is_target_block : bool = false
@export var auto_deactivate : bool = true
@export var gives_off_power : bool = true
@export var wire_directions : Array[Vector2] = [Vector2.RIGHT]

const wire_sprites : Dictionary = {"up": preload("res://Sprites/Blocks/Wire Block Pieces/WireBlock4.png"), "down" : preload("res://Sprites/Blocks/Wire Block Pieces/WireBlock3.png"), "left": preload("res://Sprites/Blocks/Wire Block Pieces/WireBlock6.png"), "right": preload("res://Sprites/Blocks/Wire Block Pieces/WireBlock5.png")}

const POWERED_COLOR : Color = Color8(253, 255, 171, 255)
const UNPOWERED_COLOR : Color = Color8(68, 12, 255, 255)

var powered : bool = false:
	set(value):
		powered = value
		update_wire_sprite_power()

func _ready():
	level_manager.connect("update_power", update_power)
	add_wire_sprites()
	
	hide_selected_sprite()

func update_power():
	var initial_power_state = powered
	
	await get_tree().process_frame
	if has_path_to_power():
		if !powered:
			powered = true
	else:
		if powered and auto_deactivate:
			powered = false
	
	if powered and gives_off_power:
		give_adjacents_power()
	
	if powered != initial_power_state:
		level_manager.emit_signal("update_power")

func emit_update_power_signal():
	level_manager.emit_signal("update_power")

func add_wire_sprites():
	update_wire_sprite_power()
	if is_target_block:
		return
	for direction in wire_directions:
		var new_sprite : Sprite2D = Sprite2D.new()
		
		match direction:
			Vector2.UP:
				new_sprite.texture = wire_sprites["up"]
			Vector2.DOWN:
				new_sprite.texture = wire_sprites["down"]
			Vector2.LEFT:
				new_sprite.texture = wire_sprites["left"]
			Vector2.RIGHT:
				new_sprite.texture = wire_sprites["right"]
			_:
				pass
		
		new_sprite.z_index = wire_center_sprite.z_index + 1
		wire_sprite_container.add_child(new_sprite)
		new_sprite.position = Vector2.ZERO
	
	update_wire_sprite_power()


func update_wire_sprite_power():
	var wire_sprites_local = wire_sprite_container.get_children()
	
	if powered:
		for sprite in wire_sprites_local:
			sprite.modulate = POWERED_COLOR
		return
	
	for sprite in wire_sprites_local:
		sprite.modulate = UNPOWERED_COLOR

func conditional_power_enable(input_position : Vector2):
	if is_adjacent_to_wired_side(input_position):
		powered = true


func is_adjacent_to_wired_side(input_position : Vector2) -> bool:
	if round((input_position - position) / level_manager.CELL_SIZE) in wire_directions:
		return true
	return false

func wire_is_connected(wire : Node) -> bool:
	if !wire.is_in_group("WireBlock"):
		return false
	
	var input_wire_directions : Array[Vector2] = wire.wire_directions
	
	if ((position - wire.position) / level_manager.CELL_SIZE) in input_wire_directions:
		return true
	return false

func has_path_to_power(visited_wires : Dictionary = {}) -> bool:
	var current_wire : Node = self
	visited_wires[current_wire] = true
	var current_connected_wires = []
	
	if current_wire.is_in_group("PowerTile"):
		return true
	if !current_wire.is_in_group("WireBlock"):
		return false
	
	for direction in current_wire.wire_directions:
	
		if ((round((current_wire.position / level_manager.CELL_SIZE) + direction)) in level_manager.player_snake) and level_manager.player.powered:
			return true
		
		power_ray.target_position = direction * level_manager.CELL_SIZE
		power_ray.force_raycast_update()
		
		var hit = power_ray.get_collider()
		
		if hit == null:
			continue
		elif hit.is_in_group("PowerTile"):
			current_connected_wires.append(hit)
		elif hit.is_in_group("WireBlock"):
			if current_wire.wire_is_connected(hit):
				current_connected_wires.append(hit)
	
	for wire in current_connected_wires:
		if wire.is_in_group("PowerTile"):
			return true
		
		if wire not in visited_wires and wire.gives_off_power and wire.has_path_to_power(visited_wires):
			return true
	
	return false

func give_adjacents_power():
	for direction in wire_directions:
		if adjacent_to_player(direction):
			level_manager.player.enable_power(position, round(position / level_manager.CELL_SIZE) + direction)
	
	for direction in wire_directions:
		power_ray.target_position = direction * level_manager.CELL_SIZE
		power_ray.force_raycast_update()
		
		var hit : Node = power_ray.get_collider()
		
		if hit == null:
			continue
		if hit.is_in_group("TargetBlock"):
			hit.powered = true

func adjacent_to_player(direction : Vector2) -> bool:
	return round((position / level_manager.CELL_SIZE) + direction) in level_manager.player_snake

func hide_selected_sprite():
	selected_sprite.visible = false

func show_selected_sprite():
	selected_sprite.visible = true
