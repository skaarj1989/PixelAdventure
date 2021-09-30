extends "InAir.gd"


func enter(_msg: Dictionary = {}) -> void:
	.enter(_msg)
	player.animation_player.play("double_jump")
	player.velocity.y = -(GameState.TILE_SIZE * _msg["power"])
	player.can_jump = false


func exit() -> void:
	.exit()


func update(_delta: float) -> void:
	.update(_delta)
	if player.is_falling():
		state_machine.transition_to("Fall")


func physics_update(_delta: float) -> void:
	.physics_update(_delta)
