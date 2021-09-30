extends PlayerState


func enter(_msg: Dictionary = {}):
	.enter()
	player.snap = Vector2.ZERO
	player.raycast.enabled = true
	match player.surface_type:
		GameState.SURFACE_TYPE.DEFAULT:
			player.spawn_dust()
		GameState.SURFACE_TYPE.SAND: pass
		GameState.SURFACE_TYPE.MUD: pass
		GameState.SURFACE_TYPE.ICE: pass


func exit() -> void:
	player.snap = Vector2.DOWN * 8
	player.raycast.enabled = false
	.exit()


func update(_delta: float) -> void:
	.update(_delta)
	player.raycast.position = Vector2(-player.facing * 4, 4)
	player.raycast.cast_to = player.facing * Vector2(12, 0)	
	
	if player.is_on_floor() and player.velocity.y == 0:
		state_machine.transition_to("Idle" if player.is_idle() else "Run")


func physics_update(_delta: float) -> void:
	.physics_update(_delta)
