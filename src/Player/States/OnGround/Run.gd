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
	match player.surface_type:
		GameState.SURFACE_TYPE.DEFAULT:
			player.spawn_dust()
		GameState.SURFACE_TYPE.SAND: pass
		GameState.SURFACE_TYPE.MUD: pass
		GameState.SURFACE_TYPE.ICE: pass
