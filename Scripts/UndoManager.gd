extends Node2D

var level_manager : Node2D:
	get:
		return get_tree().current_scene

@export_range(25,250,5) var max_undo_states : int = 100

const power_orb_object : PackedScene = preload("res://Scenes/power_orb.tscn")
var undo_states : Array[UndoState] = []
var player : Node2D:
	get:
		return get_parent()

func save_state():
	var new_undo_state = UndoState.new()
	
	new_undo_state.player_powered = player.powered
	new_undo_state.player_charge = player.current_charge
	new_undo_state.player_snake = player.current_snake.duplicate()

	for power_orb in get_tree().get_nodes_in_group("PowerOrb"):
		new_undo_state.power_orbs.append(power_orb.position)

	save_power_blocks_to_state(new_undo_state)
	save_wire_blocks_to_state(new_undo_state)
	save_doors_to_state(new_undo_state)
	
	undo_states.append(new_undo_state)
	
	if len(undo_states) > max_undo_states:
		undo_states.pop_front()

func save_power_blocks_to_state(undo_state : UndoState):
	var power_tile_positions : Array[Vector2] = []
	
	for power_tile in get_tree().get_nodes_in_group("PowerTile"):
		power_tile_positions.append(power_tile.position)
	
	undo_state.power_blocks = power_tile_positions

func save_doors_to_state(undo_state : UndoState):
	var door_powers : Array[bool] = []
	var door_solids : Array[bool] = []
	
	for door in get_tree().get_nodes_in_group("Door"):
		door_powers.append(door.powered)
		door_solids.append(door.solid)
	
	undo_state.door_power_states = door_powers
	undo_state.door_solid_states = door_solids

func save_wire_blocks_to_state(undo_state : UndoState):
	var wire_blocks : Array[WireBlockState] = []
	
	for wire_block in get_tree().get_nodes_in_group("WireBlock"):
		var wire_block_state = WireBlockState.new()
		
		wire_block_state.block_position = wire_block.position
		wire_block_state.powered = wire_block.powered
		
		wire_blocks.append(wire_block_state)
	
	undo_state.wires = wire_blocks

func move_player_sprites_to_snake(snake_to_set : Array[Vector2]):
	for i in len(player.snake_block_container.get_children()):
		var sprite : Node = player.snake_block_container.get_children()[i]
		var new_sprite_position : Vector2 = snake_to_set[i] * player.CELL_SIZE
		
		sprite.global_position = new_sprite_position
	
	player.update_sprite_power()
	player.instant_plug_rotation_update()

func load_last_state():
	if len(undo_states) < 2:
		return
	
	for orb in get_tree().get_nodes_in_group("PowerOrb"):
		orb.queue_free()
	for power_orb_pos in undo_states[-1].power_orbs:
		var new_power_orb = power_orb_object.instantiate()
		level_manager.add_child(new_power_orb)
		new_power_orb.position = power_orb_pos
	
	player.powered = undo_states[-1].player_powered
	player.current_charge = undo_states[-1].player_charge
	player.current_snake = undo_states[-1].player_snake
	move_player_sprites_to_snake(player.current_snake)
	
	load_wire_blocks_state(undo_states[-1])
	load_power_blocks_state(undo_states[-1])
	load_doors_state(undo_states[-1])
	
	undo_states.pop_back()
	AudioManager.play_sfx("Undo")

func load_wire_blocks_state(undo_state : UndoState):
	var wire_blocks : Array[Node] = get_tree().get_nodes_in_group("WireBlock")
	
	for i in len(wire_blocks):
		var wire_block = wire_blocks[i]
		
		wire_block.position = undo_state.wires[i].block_position
		wire_block.powered = undo_state.wires[i].powered

func load_power_blocks_state(undo_state : UndoState):
	var power_blocks : Array[Node] = get_tree().get_nodes_in_group("PowerTile")
	
	for i in len(power_blocks):
		var power_block = power_blocks[i]
		
		power_block.position = undo_state.power_blocks[i]

func load_doors_state(undo_state : UndoState):
	var doors : Array[Node] = get_tree().get_nodes_in_group("Door")
	
	for i in len(doors):
		var door = doors[i]
		door.powered = undo_state.door_power_states[i]
		door.solid = undo_state.door_solid_states[i]

func load_indexed_state(index : int):
	if len(undo_states) < 2:
		return
	if index == -1:
		print("State Load Failed : Use 'load_last_state()'")
		return
	
	for orb in get_tree().get_nodes_in_group("PowerOrb"):
		orb.queue_free()
	for power_orb_pos in undo_states[index].power_orbs:
		var new_power_orb = power_orb_object.instantiate()
		level_manager.add_child(new_power_orb)
		new_power_orb.position = power_orb_pos
	
	player.powered = undo_states[index].player_powered
	player.current_charge = undo_states[index].player_charge
	player.current_snake = undo_states[index].player_snake
	move_player_sprites_to_snake(player.current_snake)
	
	load_wire_blocks_state(undo_states[index])
	load_power_blocks_state(undo_states[index])
	load_doors_state(undo_states[index])

	undo_states = undo_states.slice(0, index)
	AudioManager.play_sfx("Undo")
