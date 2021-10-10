extends PlayerState


func enter(_msg: Dictionary = {}):
	player.snap = Vector2.ZERO
	player.raycast.enabled = true
	match player.surface_type:
		GameState.SURFACE_TYPE.DEFAULT:
			player.spawn_dust()
		GameState.SURFACE_TYPE.SAND: pass
		GameState.SURFACE_TYPE.MUD: pass
		GameState.SURFACE_TYPE.ICE: pass


func exit() -> void:
	player.raycast.enabled = false


func update(_delta: float) -> void:
	player.raycast.position = Vector2(-player.facing * 4, 4)
	player.raycast.cast_to = player.facing * Vector2(12, 0)	
	
	if player.is_on_floor() and player.velocity.y == 0:
		state_machine.transition_to("Idle" if player.is_idle() else "Run")
