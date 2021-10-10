extends "OnGround.gd"


onready var _samples := [
	preload("res://assets/SFX/Footstep/Footstep_Dirt_00.wav"),
	preload("res://assets/SFX/Footstep/Footstep_Dirt_04.wav"),
]

func _ready() -> void:
	$Audio.set_stream(_samples.front())


func enter(_msg: Dictionary = {}) -> void:
	.enter(_msg)
	player.animation_player.play("run")
	$Audio.play()
	$Timer.start()


func exit() -> void:
	$Timer.stop()
	.exit()


func update(_delta: float) -> void:
	if not $Audio.playing:
		$Audio.play()
		
	if player.is_idle():
		state_machine.transition_to("Idle")
	.update(_delta)


func physics_update(delta: float) -> void:
	.physics_update(delta)


func _on_Timer_timeout() -> void:
	if player.surface_type == GameState.SURFACE_TYPE.DEFAULT:
		player.spawn_dust()
	else:
		add_child(GameState.spawn_splash(player.surface_type, Vector2(0, 16)))


func _on_Audio_finished() -> void:
	_samples.shuffle()
	$Audio.set_stream(_samples.front())
