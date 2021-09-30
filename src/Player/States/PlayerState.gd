class_name PlayerState
extends State

var player: Player

func _ready() -> void:
	yield(owner, "ready")
	player = owner as Player
	assert(player != null)
