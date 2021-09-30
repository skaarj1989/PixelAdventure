extends PlayerState


func enter(_msg: Dictionary = {}) -> void:
	player.can_jump = true
	if player.surface_type == GameState.SURFACE_TYPE.DEFAULT:
		player.spawn_dust()
	else:
		player.add_child(GameState.spawn_splash(player.surface_type, Vector2(0, 16)))


func exit() -> void:
	.exit()


func update(_delta: float) -> void:
	.update(_delta)
	if Input.is_action_just_pressed("jump") and player.can_jump:
		state_machine.transition_to("Jump", {"power": 11.0})


func physics_update(_delta: float) -> void:
	.physics_update(_delta)
	if not player.is_on_floor():
		state_machine.transition_to("Fall")
