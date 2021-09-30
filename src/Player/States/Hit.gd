extends PlayerState

const ROTATE_SPEED = 160.0 # Degrees/sec


func enter(_msg: Dictionary = {}) -> void:
	.enter()
	player.animation_player.play("hit")


func exit() -> void:
	.exit()


func update(_delta: float) -> void:
	.update(_delta)
	player.rotation_degrees += -player.facing * ROTATE_SPEED * _delta


func physics_update(_delta: float) -> void:
	.physics_update(_delta)
