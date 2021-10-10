extends Area2D

func _on_Arrow_body_entered(body) -> void:
	if body.is_in_group("player"):
		$CollisionShape2D.set_deferred("disabled", true)
		$AnimatedSprite.play("hit")
		body.bounce_up(12.0)
		GameState.camera.add_trauma(0.3)


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation == "hit":
		queue_free()
