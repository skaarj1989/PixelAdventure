extends PlayerState


onready var animated_sprite: AnimatedSprite = owner.get_node("AnimatedSprite")

func _ready() -> void:
	._ready()
	#warning-ignore:return_value_discarded
	animated_sprite.connect(
		"animation_finished",
		self,
		"_on_AnimatedSprite_animation_finished"
	)


func enter(_msg: Dictionary = {}) -> void:
	.enter()
	$Audio.play()
	player.collision_shape.disabled = true
	player.animated_sprite.visible = true
	player.animated_sprite.play("appear")


func exit() -> void:
	player.collision_shape.disabled = false
	player.animated_sprite.visible = false
	player.sprite.visible = true
	.exit()


func update(_delta: float) -> void:
	.update(_delta)


func physics_update(_delta: float) -> void:
	.physics_update(_delta)


func _on_AnimatedSprite_animation_finished() -> void:
	if player.animated_sprite.animation == "appear":
		state_machine.transition_to("Idle")
