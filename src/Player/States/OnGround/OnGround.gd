extends PlayerState


func enter(_msg: Dictionary = {}) -> void:
	player.snap = Vector2.DOWN * 8
	player.can_jump = true
	if player.surface_type == GameState.SURFACE_TYPE.DEFAULT:
		player.spawn_dust()
	else:
		player.add_child(GameState.spawn_splash(player.surface_type, Vector2(0, 16)))


func update(_delta: float) -> void:
	if Input.is_action_just_pressed("jump") and player.can_jump:
		state_machine.transition_to("Jump", {"power": 11.0})
	elif Input.is_action_just_pressed("descent"):
		player.position.y += 1


func physics_update(_delta: float) -> void:
	if not player.is_on_floor():
		state_machine.transition_to("Fall")
