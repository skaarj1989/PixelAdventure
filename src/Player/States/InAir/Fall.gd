extends "InAir.gd"


func enter(_msg: Dictionary = {}) -> void:
	# Don't call super (starts emitting dust)
	player.animation_player.play("fall")
	player.raycast.enabled = true


func exit() -> void:
	.exit()


func update(_delta: float) -> void:
	.update(_delta)
	if Input.is_action_just_pressed("jump") and player.can_jump:
		state_machine.transition_to("DoubleJump", {"power": 10.0})


func physics_update(_delta: float) -> void:
	.physics_update(_delta)
	if player.is_on_wall() and player.raycast.is_colliding():
		state_machine.transition_to("WallJump")
