extends "Rock.gd"

const _offsets = [Vector2(-1, 0), Vector2(1, 0)]

onready var _child_prefab := preload("Rock3.tscn")


func _on_hit() -> void:
	for offset in _offsets:
		_spawn_child(_child_prefab, offset * _get_width() * 0.3)
		yield(_animated_sprite, "animation_finished")
		queue_free()
