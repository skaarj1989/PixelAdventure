extends "OnGround.gd"


func enter(_msg: Dictionary = {}) -> void:
	.enter(_msg)
	player.animation_player.play("run")
	$Timer.start()


func exit() -> void:
	$Timer.stop()
	.exit()


func update(_delta: float) -> void:
	.update(_delta)
	if player.is_idle():
		state_machine.transition_to("Idle")


func physics_update(delta: float) -> void:
	.physics_update(delta)


func _on_Timer_timeout() -> void:
	if player.surface_type == GameState.SURFACE_TYPE.DEFAULT:
		player.spawn_dust()
	else:
		add_child(GameState.spawn_splash(player.surface_type, Vector2(0, 16)))
