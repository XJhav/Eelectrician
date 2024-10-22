extends Node2D

var level_manager : Node2D:
	get:
		return get_tree().current_scene

@onready var snake_block_container = $SnakeBlockContainer
@onready var move_ray = $MoveCheckRay
@onready var snake_connector = $SnakeConnector
@onready var plug_sprite = $PlugSprite
@onready var undo_manager = $UndoManager

@export var starting_snake : Array[Vector2] = [Vector2(0,0)]
@export var snake_block_z_order : int = 0
var move_animation_time : float = 0.15

const POWERED_COLOR : Color = Color8(253, 255, 220, 255)
const UNPOWERED_COLOR : Color = Color8(68, 12, 255, 255)

const MID_BLOCK_COLOR : Color = Color8(100, 100, 255, 255)
const DARK_BLOCK_COLOR : Color = Color8(68, 12, 255, 255)

const snake_block_sprite_object : PackedScene = preload("res://Scenes/snake_block_sprite.tscn")
const snake_block_sprites : Array[Texture2D] = [preload("res://Sprites/Snake/SnakeBlock1.png"), preload("res://Sprites/Snake/SnakeBlock2.png"),preload("res://Sprites/Snake/SnakeBlock3.png"),preload("res://Sprites/Snake/SnakeBlock4.png")]


var drag_accumulated_vec2 : Vector2 = Vector2.ZERO
var drag_start_vec2 : Vector2 = Vector2()
var max_charge : int:
	get:
		return current_length * 2

var moving : bool = false

var can_move_input : bool = true
var powered : bool = false:
	set(value):
		powered = value
		if powered:
			refill_charge()
			update_sprite_power()

const CELL_SIZE = 16

var current_facing_direction : Vector2 = Vector2.ZERO
var current_charge : int = 1:
	set(value):
		current_charge = clamp(value, 0 , 100)
		update_charge_ui()
var current_length : int
var current_snake : Array[Vector2] = []:
	set(value):
		current_snake = value
		current_length = len(value)

func _process(delta):
	var snake_block_positions : Array[Vector2] = []
	
	
	plug_sprite.position = snake_block_container.get_children()[-1].position
	
	for snake_block in snake_block_container.get_children():
		snake_block_positions.append(snake_block.position)
	
	snake_connector.points = snake_block_positions

func _ready():
	GameData.connect("player_speed_updated", update_anim_speed)
	level_manager.connect("level_complete", level_complete_animation)
	
	for button in get_tree().get_nodes_in_group("UndoButton"):
		button.pressed.connect(undo)
	
	update_anim_speed()
	
	current_snake = starting_snake
	current_facing_direction = (current_snake[0] - current_snake[1])
	if max_charge == 0:
		max_charge = current_length * 2
	current_charge = max_charge
	
	set_points_to_snake(current_snake)
	undo_manager.save_state()
	
	

func _input(event):
	if moving or !can_move_input or level_manager.paused or SceneManager.transitioning:
		return
		
	if event.is_action("undo") and !event.is_action_released("undo"):
		undo_manager.load_last_state()
	
	if current_charge <= 0:
		return
	
	if event.is_action("down") and !event.is_action_released("down"):
		move_snake(Vector2.DOWN)
	elif event.is_action("up") and !event.is_action_released("up"):
		move_snake(Vector2.UP)
	elif event.is_action("left") and !event.is_action_released("left"):
		move_snake(Vector2.LEFT)
	elif event.is_action("right") and !event.is_action_released("right"):
		move_snake(Vector2.RIGHT)
	elif event is InputEventScreenDrag:
		
		if drag_start_vec2 == Vector2() or event.velocity.length() <= 10:
			drag_start_vec2 = event.position
			drag_accumulated_vec2 = Vector2.ZERO
		
		drag_accumulated_vec2 += event.relative
		
		if drag_accumulated_vec2.x > 20 and drag_accumulated_vec2.normalized().x > 0.86:
			move_snake(Vector2.RIGHT)
			drag_start_vec2 = Vector2()
			drag_accumulated_vec2 = Vector2.ZERO
		elif drag_accumulated_vec2.x < -20 and drag_accumulated_vec2.normalized().x < -0.86:
			move_snake(Vector2.LEFT)
			drag_start_vec2 = Vector2()
			drag_accumulated_vec2 = Vector2.ZERO
		elif drag_accumulated_vec2.y > 20 and drag_accumulated_vec2.normalized().y > 0.86:
			move_snake(Vector2.DOWN)
			drag_start_vec2 = Vector2()
			drag_accumulated_vec2 = Vector2.ZERO
		elif drag_accumulated_vec2.y < -20 and drag_accumulated_vec2.normalized().y < -0.86:
			move_snake(Vector2.UP)
			drag_start_vec2 = Vector2()
			drag_accumulated_vec2 = Vector2.ZERO
		

	elif event is InputEventScreenTouch and event.is_released():
		drag_start_vec2 = Vector2()
		drag_accumulated_vec2 = Vector2.ZERO




func set_points_to_snake(snake_to_set : Array[Vector2]):
	for i in len(snake_to_set):
		var point = snake_to_set[i]
		var new_sprite = snake_block_sprite_object.instantiate()
		
		if i == 0:
			new_sprite.texture = snake_block_sprites[0]
		else:
			new_sprite.texture = snake_block_sprites[0]
		
		new_sprite.z_index = snake_block_z_order
		
		snake_block_container.add_child(new_sprite)
		new_sprite.global_position = point * CELL_SIZE
		update_plug_rotation()

func instant_plug_rotation_update():
	plug_sprite.rotation = vector2_to_angle(get_snake_block_facing_direction(len(current_snake) - 1), 0)

func update_plug_rotation():
	plug_sprite.rotation = wrapf(plug_sprite.rotation, 0, 2 * PI)
	var plug_rotate_tween = create_tween()
	plug_rotate_tween.tween_property(plug_sprite, "rotation", deg_to_rad(shortest_rotation(rad_to_deg(plug_sprite.rotation), rad_to_deg(vector2_to_angle(get_snake_block_facing_direction(len(current_snake) - 1), 0)))), move_animation_time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)

func move_snake(direction : Vector2):
	var empty_space_ahead : bool = false
	var blocks_to_push : Array[Node] = []
	move_ray.clear_exceptions()
	while empty_space_ahead == false:
		move_ray.position = current_snake[0] * CELL_SIZE
		move_ray.target_position = direction * (len(blocks_to_push) + 1) * CELL_SIZE
		move_ray.force_raycast_update()
		
		var hit : Node = move_ray.get_collider()
		
		if (is_pos_in_current_snake(direction, len(blocks_to_push) + 1)):
			return
		elif hit == null:
			empty_space_ahead = true
		elif hit.is_in_group("Solid"):
			return
		elif hit.is_in_group("PowerOrb") and len(blocks_to_push) == 0:
			empty_space_ahead = true
		elif hit.is_in_group("Pushable"):
			blocks_to_push.append(hit)
			move_ray.add_exception(hit)
		elif !hit.is_in_group("Solid"):
			move_ray.add_exception(hit)
		else:
			empty_space_ahead = true
	
	undo_manager.save_state()
	AudioManager.play_sfx("Move")
	
	moving = true
	current_facing_direction = direction
	
	current_snake.insert(0, current_snake[0] + direction)
	current_snake.pop_at(-1)
	
	tween_sprites_to_snake(current_snake)
	
	for block in blocks_to_push:
		var block_tween = create_tween()
		block_tween.tween_property(block, "position", round(block.position + (direction * CELL_SIZE)), move_animation_time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
	
	update_plug_rotation()
	
	await get_tree().create_timer(move_animation_time).timeout
	
	powered = false

	
	if !powered:
		current_charge -= 1
	update_sprite_power()
	
	level_manager.emit_signal("update_power")
	
	await get_tree().process_frame
	
	moving = false

func tween_sprites_to_snake(snake : Array[Vector2]):
	var current_sprites = snake_block_container.get_children()
	for i in len(current_sprites):
		var sprite = current_sprites[i]
		var snake_block_tween = create_tween()
		
		snake_block_tween.tween_property(sprite, "global_position", snake[i] * CELL_SIZE, move_animation_time).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_SINE)
		
		# await get_tree().create_timer(0.02).timeout

func is_pos_in_current_snake(direction : Vector2, spaces_ahead : int) -> bool:
	if current_length == 2:
		return (current_snake[0] + direction * spaces_ahead) in current_snake
	return (current_snake[0] + direction * spaces_ahead) in current_snake.slice(0,-1)

func update_sprite_power():
	var sprite_objects = snake_block_container.get_children()
	
	if powered:
		for i in len(sprite_objects):
			sprite_objects[i].modulate = Color.WHITE
			if i == 0:
				sprite_objects[i].texture = snake_block_sprites[3]
			else:
				sprite_objects[i].texture = snake_block_sprites[3]
		snake_connector.modulate = POWERED_COLOR
		
		plug_sprite.modulate = Color.WHITE
		return

	for i in len(sprite_objects):
		if i == 0:
			sprite_objects[i].texture = snake_block_sprites[0]
		else:
			sprite_objects[i].texture = snake_block_sprites[0]
	
	var charge_to_subtract = max_charge - current_charge
	var snake_sprite_index : int = -1
	
	for sprite_object in sprite_objects:
		sprite_object.modulate = Color.WHITE
	
	while charge_to_subtract > 0:
		if charge_to_subtract >= 2:
			sprite_objects[snake_sprite_index].modulate = DARK_BLOCK_COLOR
			charge_to_subtract -= 2
			snake_sprite_index -= 1
			continue
		elif charge_to_subtract < 2:
			sprite_objects[snake_sprite_index].modulate = MID_BLOCK_COLOR
			break
	
	if current_charge <= 0:
		snake_connector.modulate = Color.BLACK
		plug_sprite.modulate = DARK_BLOCK_COLOR
	else:
		snake_connector.modulate = UNPOWERED_COLOR
		plug_sprite.modulate = Color.WHITE

func is_solid_block_ahead(direction : Vector2) -> bool:
	move_ray.global_position = current_snake[0] * CELL_SIZE
	move_ray.target_position = direction * CELL_SIZE
	move_ray.force_raycast_update()
	
	var hit : Node = move_ray.get_collider()
	
	if hit == null:
		return false
	elif hit.is_in_group("Solid"):
		return true
	return false
	
func enable_power(input_position : Vector2, corresponding_snake_point : Vector2):
	if corresponding_snake_point != current_snake[-1]:
		return
	if round(input_position) != (current_snake[-1] + -1 * get_snake_block_facing_direction(current_length - 1)) * CELL_SIZE:
		return
	powered = true


func get_snake_block_facing_direction(snake_block_index : int) -> Vector2:
	if snake_block_index == 0:
		return current_facing_direction
	elif snake_block_index <= current_length - 1:
		return (current_snake[snake_block_index - 1] - current_snake[snake_block_index])
	else:
		print("Facing Direction Error")
		return Vector2.ZERO

func vector2_to_angle(vector: Vector2, angle_offset : float) -> float:
	var angle = atan2(vector.y, vector.x)
	var adjusted_angle = deg_to_rad(angle_offset) + angle
	if rad_to_deg(angle) > 180:
		angle = angle - 2 * PI
	
	return wrapf(adjusted_angle, 0, TAU)

func shortest_rotation(initial_degrees: float, final_degrees: float) -> float:
	if initial_degrees == final_degrees:
		return final_degrees
	
	var initial = fmod(initial_degrees + 360, 360)
	var final = fmod(final_degrees + 360, 360)
	
	var delta = final - initial
	if delta > 180:
		delta -= 360
	elif delta < -180:
		delta += 360
	
	return initial + delta

func refill_charge():
	current_charge = current_length * 2

func use_orb(orb : Node2D):
	orb.queue_free()
	await get_tree().process_frame
	level_manager.check_level_complete()

func update_charge_ui():
	level_manager.update_charge_ui()

func update_anim_speed():
	move_animation_time = GameData.player_anim_speed

func level_complete_animation():
	snake_connector.modulate = UNPOWERED_COLOR
	plug_sprite.modulate = Color.WHITE
	
	for some_var_name_that_i_wont_use in range(1):
		for i in len(snake_block_container.get_children()):
			var child = snake_block_container.get_children()[i]
			var time_to_wait = 0.3 / len(snake_block_container.get_children())

			pulse_snake_sprite(child, time_to_wait)
			
			await get_tree().create_timer(time_to_wait).timeout

func pulse_snake_sprite(sprite : Node, time : float):
	sprite.modulate = Color.WHITE
	sprite.texture = snake_block_sprites[3]
	await get_tree().create_timer(time).timeout
	sprite.texture = snake_block_sprites[0]

func undo():
	if !moving and can_move_input and !level_manager.paused and !SceneManager.transitioning:
		undo_manager.load_last_state()
