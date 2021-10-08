extends Area2D

var type: String


onready var rng = RandomNumberGenerator.new()

func _ready() -> void:
	$AnimatedSprite.visible = false
	$Sprite.texture = load("res://assets/Items/Fruits/%s.png" % type)
	rng.randomize()
	$AnimationPlayer.play("idle")
	$AnimationPlayer.seek(rng.randf_range(0.0, 0.8))


func _on_Fruit_body_entered(body) -> void:
	if body.is_in_group("player"):
		$AnimatedSprite.visible = true
		$AnimatedSprite.animation = "collected"
		$Audio.play()
		$Sprite.visible = false


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation == "collected":
		queue_free()
