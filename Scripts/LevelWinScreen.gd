extends CanvasLayer

@onready var banner = $Banner

@export var transition : Tween.TransitionType

func _ready():
	var banner_tween : Tween = create_tween()
	banner_tween.tween_property(banner, "position", Vector2(-60,180), 0.65).set_ease(Tween.EASE_OUT).set_trans(transition)
