extends Area2D

var level_manager : Node2D:
	get:
		return get_tree().current_scene

@onready var power_ray = $PowerRay

var direction_array : Array[Vector2] = [Vector2.UP, Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT]

func _ready():
	level_manager.connect("update_power", give_adjacents_power)

func give_adjacents_power():
	for direction in direction_array:
		if adjacent_to_player(direction):
			level_manager.player.enable_power(position, round(position / level_manager.CELL_SIZE) + direction)

	for direction in direction_array:
		power_ray.target_position = direction * level_manager.CELL_SIZE
		power_ray.force_raycast_update()
		
		var hit : Node = power_ray.get_collider()
		
		if hit == null:
			continue
		if hit.is_in_group("TargetBlock"):
			hit.powered = true

func adjacent_to_player(direction : Vector2) -> bool:
	return round((position / level_manager.CELL_SIZE) + direction) in level_manager.player_snake
