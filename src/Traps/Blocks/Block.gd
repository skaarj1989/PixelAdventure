extends KinematicBody2D


onready var _part_prefabs = [
	preload("Part1.tscn"),
	preload("Part2.tscn")
]

func _ready() -> void:
	$AnimatedSprite.play("idle")


func _physics_process(_delta: float) -> void:
	var collision = move_and_collide(Vector2.ZERO, true, true, true)
	if collision and $AnimatedSprite.animation == "idle":
		var collider = collision.collider
		if collider.is_in_group("player"):
			if collision.normal.y != 0 and abs(collision.collider_velocity.y) > 1:
				$AnimatedSprite.play("hit_top")
				if collision.normal.y == 1:
					collider.bounce_up(8.5)
				GameState.camera.add_trauma(0.1)


func destroy() -> void:
	$CollisionShape2D.disabled = true
	$AnimatedSprite.visible = false
	$Audio.play()

	for prefab in _part_prefabs:
		var part = prefab.instance()
		part.position = position
		get_parent().add_child(part)


func _on_AnimatedSprite_animation_finished() -> void:
	match $AnimatedSprite.animation:
		"hit_top", "hit_side":
			destroy()


func _on_Audio_finished() -> void:
	queue_free()
