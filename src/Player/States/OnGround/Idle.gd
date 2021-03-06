extends "OnGround.gd"


func enter(_msg: Dictionary = {}) -> void:
	.enter(_msg)
	player.animation_player.play("idle")


func exit() -> void:
	.exit()


func update(_delta: float) -> void:
	if not player.is_idle():
		state_machine.transition_to("Run")
	.update(_delta)


func physics_update(_delta: float) -> void:
	.physics_update(_delta)
