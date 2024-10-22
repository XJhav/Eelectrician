extends CanvasLayer

signal fade_out_transition_finished
signal fade_in_transition_finished

@onready var fade_rect = $FadeRect
@onready var animation_player = $AnimationPlayer

func _ready():
	fade_rect.set_deferred("size", Vector2(1000,270))
	fade_rect.position = Vector2(-250,0)

func fade_in():
	animation_player.play("FadeIn")

func fade_out():
	animation_player.play("FadeOut")

func _on_animation_player_animation_finished(anim_name):
	match anim_name:
		"FadeIn":
			emit_signal("fade_in_transition_finished")
		"FadeOut":
			emit_signal("fade_out_transition_finished")
			queue_free()
		_:
			pass
