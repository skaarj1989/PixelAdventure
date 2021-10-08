extends Area2D


func _on_Trampoline_body_entered(body) -> void:
	if body.is_in_group("player"):
		$AnimatedSprite.play("jump")
		$Audio.play()
		body.bounce_up(18.0)
		GameState.camera.add_trauma(0.3)


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation == "jump":
		$AnimatedSprite.play("idle")
