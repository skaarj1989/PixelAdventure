extends "InAir.gd"


func enter(_msg: Dictionary = {}) -> void:
	.enter()
	player.animation_player.play("wall_jump")


func exit() -> void:
	.exit()


func update(_delta: float) -> void:
	.update(_delta)
	if Input.is_action_just_pressed("jump"):
		player.facing = -player.facing
		player.velocity.x += player.facing * GameState.TILE_SIZE * 6
		player.can_jump = true
		state_machine.transition_to("Jump", {"power": 10.0})


func physics_update(_delta: float) -> void:
	.physics_update(_delta)
	if not player.raycast.is_colliding():
		state_machine.transition_to("Fall")
