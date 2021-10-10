extends PlayerState


func enter(_msg: Dictionary = {}) -> void:
	player.collision_shape.set_deferred("disabled", true)
	player.sprite.visible = false
	player.animated_sprite.visible = true
	player.animated_sprite.play("disappear")
	yield(player.animated_sprite, "animation_finished")
	player.animated_sprite.visible = false
