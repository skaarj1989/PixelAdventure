extends PlayerState

const ROTATE_SPEED = 160.0 # Degrees/sec


func enter(_msg: Dictionary = {}) -> void:
	player.animation_player.play("hit")


func update(_delta: float) -> void:
	player.rotation_degrees += -player.facing * ROTATE_SPEED * _delta
