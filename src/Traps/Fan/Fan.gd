extends Node2D

enum {ON, OFF}

export(float) var reach := 100.0

var state := OFF
var target


onready var direction = Vector2.UP.rotated(rotation)

func _ready() -> void:
	$AoE/CollisionShape2D.shape.extents.y = reach
	$AoE/CollisionShape2D.position.y = -reach + 4
	$Particles2D.emitting = false

func _process(_delta: float) -> void:
	if state == ON and target:
		target.velocity += direction * GameState.GRAVITY * 1.5 * _delta


func change_state(new_state) -> void:
	if state == new_state:
		return
	
	match new_state:
		ON:
			$AnimatedSprite.play("on")
			$AoE/CollisionShape2D.disabled = false
			$Particles2D.emitting = true
		OFF:
			$AnimatedSprite.play("off")
			$AoE/CollisionShape2D.disabled = true
			$Particles2D.emitting = false
	
	state = new_state


func _on_AoE_body_entered(body) -> void:
	target = body
	target.snap = Vector2.ZERO


func _on_AoE_body_exited(body) -> void:
	target = null


func _on_Timer_timeout() -> void:
	change_state(ON if state == OFF else OFF)
	$Timer.start()
