extends Area2D

signal collected

var type: String


onready var _rng := RandomNumberGenerator.new()

func _ready() -> void:
	$AnimatedSprite.visible = false
	$Sprite.texture = load("res://assets/Items/Fruits/%s.png" % type)
	_rng.randomize()
	$AnimationPlayer.play("idle")
	$AnimationPlayer.seek(_rng.randf_range(0.0, 0.8))


func _on_Fruit_body_entered(body) -> void:
	if body.is_in_group("player"):
		$CollisionShape2D.set_deferred("disabled", true)
		$Sprite.visible = false
		$AnimatedSprite.visible = true
		$AnimatedSprite.play("collected")
		$Audio.play()
		emit_signal("collected")
		#yield($AnimatedSprite, "animation_finished")
		#queue_free()


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation == "collected":
		queue_free()
