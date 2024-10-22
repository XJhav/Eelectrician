extends Node

signal player_speed_updated

var player_anim_speed : float = 0.15:
	set(value):
		player_anim_speed = value
		emit_signal("player_speed_updated")

var instant_restart_enabled : bool = false

var completed_levels : Array[String] = []


func _ready():
	completed_levels = load_completed_levels()

func complete_level(world_name : String, level_num : int):
	if !completed_levels.has(world_name + str(level_num)):
		completed_levels.append(world_name + str(level_num))
		save_completed_levels(completed_levels)

func is_level_completed(world_name : String, level_num : int):
	return completed_levels.has(world_name + str(level_num))

func save_completed_levels(levels_completed: Array):
	# Serialize the array into a JSON string
	var data = JSON.stringify(levels_completed)
	# Save it to localStorage without extra escaping
	JavaScriptBridge.eval("localStorage.setItem('completed_levels', '" + data + "')")

func load_completed_levels() -> Array[String]:
	# Retrieve the JSON string from localStorage
	var json_string = JavaScriptBridge.eval("localStorage.getItem('completed_levels')")
	
	# Check if valid data is present
	if json_string != null and json_string != "":
		# Parse the JSON string back into a Variant
		var result = JSON.parse_string(json_string)
		if result is Array:
			var typed_result : Array[String] = []
			# Validate that all items in the array are strings and add them to a typed array
			for item in result:
				if typeof(item) == TYPE_STRING:
					typed_result.append(item)
				else:
					push_error("Non-string item found in completed levels data.")
			return typed_result  # Return the typed array of strings
	return []  # Return an empty array if no valid data is found
