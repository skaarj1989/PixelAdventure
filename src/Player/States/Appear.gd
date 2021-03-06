extends PlayerState


func enter(_msg: Dictionary = {}) -> void:
	$Audio.play()
	player.collision_shape.set_deferred("disabled", true)
	player.sprite.visible = false
	player.animated_sprite.visible = true
	player.animated_sprite.play("appear")
	yield(player.animated_sprite, "animation_finished")
	state_machine.transition_to("Idle")


func exit() -> void:
	player.collision_shape.set_deferred("disabled", false)
	player.sprite.visible = true
	player.animated_sprite.visible = false
