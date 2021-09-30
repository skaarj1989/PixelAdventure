extends StaticBody2D

onready var rng = RandomNumberGenerator.new()

func _ready() -> void:
	randomize()
	$AnimatedSprite.playing = false
	rng.randomize()
	$AnimatedSprite.frame = rng.randi() % 3
	$Timer.start(rng.randf_range(1.5, 2.0))


func _on_Timer_timeout() -> void:
	$AnimatedSprite.play("default")


func _on_AnimatedSprite_animation_finished() -> void:
	queue_free()
