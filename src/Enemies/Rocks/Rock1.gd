extends "Rock.gd"

const offsets = [Vector2(-1, 0), Vector2(1, 0)]

onready var child_prefab := preload("Rock2.tscn")


func _on_hit() -> void:
	for offset in offsets:
		_spawn_child(child_prefab, offset * _get_width() * 0.3)
		yield(animated_sprite, "animation_finished")
		queue_free()
