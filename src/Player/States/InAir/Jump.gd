extends "InAir.gd"


func enter(_msg: Dictionary = {}) -> void:
	.enter(_msg)
	player.animation_player.play("jump")
	player.velocity.y = -(GameState.TILE_SIZE * _msg["power"])


func exit() -> void:
	.exit()


func update(_delta: float) -> void:
	.update(_delta)
	if Input.is_action_just_pressed("jump") and player.can_jump:
		state_machine.transition_to("DoubleJump", {"power": 8.0})


func physics_update(_delta: float) -> void:
	.physics_update(_delta)
	if player.is_falling():
		state_machine.transition_to("Fall")
