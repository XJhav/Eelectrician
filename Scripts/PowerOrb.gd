extends Area2D


var level_manager : Node2D:
	get:
		return get_tree().current_scene

func _ready():
	level_manager.connect("update_power", check_for_player)

func check_for_player():
	if round(position / level_manager.CELL_SIZE) in level_manager.player_snake:
		level_manager.player.use_orb(self)
