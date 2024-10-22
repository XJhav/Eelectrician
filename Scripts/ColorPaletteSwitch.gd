extends CanvasLayer

@onready var color_rect = $ColorRect

@export_enum("Blue","Green","Red","Purple") var color : String = "Blue"

func _ready():
	var shader_material : ShaderMaterial = color_rect.material
	match color:
		"Blue":
			shader_material.set_shader_parameter("darkest_shade", Color8(28,26,48))
			shader_material.set_shader_parameter("dark_shade", Color8(38,61,110))
			shader_material.set_shader_parameter("light_shade", Color8(46,115,158))
			shader_material.set_shader_parameter("lightest_shade", Color8(74,194,207))
		"Green":
			shader_material.set_shader_parameter("darkest_shade", Color(0.00,0.1,0.12))
			shader_material.set_shader_parameter("dark_shade", Color(0, 0.32, 0.25))
			shader_material.set_shader_parameter("light_shade", Color(0,0.5,0.26))
			shader_material.set_shader_parameter("lightest_shade", Color(0.55,0.76,0))
		"Red":
			shader_material.set_shader_parameter("darkest_shade", Color(0.24,0,0.01))
			shader_material.set_shader_parameter("dark_shade", Color(0.47,0,0.14))
			shader_material.set_shader_parameter("light_shade", Color(0.84, 0, 0.2))
			shader_material.set_shader_parameter("lightest_shade", Color(1, .36, 0.31))
		"Purple":
			shader_material.set_shader_parameter("darkest_shade", Color(0.14,0,0.25))
			shader_material.set_shader_parameter("dark_shade", Color(.32,0,.58))
			shader_material.set_shader_parameter("light_shade", Color(0.57,0,0.9))
			shader_material.set_shader_parameter("lightest_shade", Color(0.79,0.47,0.99))
