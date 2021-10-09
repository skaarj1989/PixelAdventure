extends KinematicBody2D

export(int) var hit_points := 2

const OFFSETS := [
	# Left/right
	Vector2(-1, -1), Vector2(1, -1), # Top
	Vector2(-1,  1), Vector2(1,  1), # Bottom
]

onready var _box_piece_prefab := preload("res://src/Items/Boxes/BoxPiece.tscn")
onready var _hit := preload("res://assets/SFX/Impact/18400_1464709080.wav")

func _ready() -> void:
	#warning-ignore:return_value_discarded
	$AnimationPlayer.connect("animation_finished", self, "animation_finished")
	$AnimationPlayer.play("idle")


func _physics_process(_delta: float) -> void:
	if hit_points == 0:
		return
	
	var collision = move_and_collide(Vector2.ZERO)
	if collision and $AnimationPlayer.get_current_animation() == "idle":
		var collider = collision.collider
		if collider.is_in_group("player") and collision.normal.y != 0:
			take_damage()
			if collision.normal.y == 1:
				collider.bounce_up(12.0)


func take_damage() -> void:
	$AnimationPlayer.play("hit")
	$Audio.play()
	hit_points -= 1
	GameState.camera.add_trauma(0.5)


func destroy() -> void:
	$CollisionShape2D.disabled = true
	$Sprite.visible = false
	
	var variant = filename.get_file().get_basename()
	for i in range(4):
		var offset = OFFSETS[i]
		var piece = _box_piece_prefab.instance()
		piece.variant = variant
		piece.get_node("Sprite").frame = i
		piece.position = position + offset * 5
		get_parent().add_child(piece)
		piece.apply_impulse(Vector2.ZERO, offset * GameState.TILE_SIZE)


func animation_finished(anim_name: String) -> void:
	if anim_name == "hit":
		$AnimationPlayer.play("idle")
		if hit_points == 0:
			destroy()


func _on_Audio_finished() -> void:
	if hit_points == 0:
		queue_free()
