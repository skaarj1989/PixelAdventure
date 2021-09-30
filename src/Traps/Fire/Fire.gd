extends StaticBody2D

enum {ON, OFF}

export(float) var ignition_delay := 0.25 # In seconds
export(float) var burning_time := 1.0 # In seconds

var state := OFF


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation == "hit":
		$Timer.start(ignition_delay)


func _on_Trigger_body_entered(body) -> void:
	if body.is_in_group("player"): 
		$AnimatedSprite.play("hit")
		call_deferred("disable_trigger", true)


func disable_trigger(disabled: bool) -> void:
	$Trigger/CollisionShape2D.disabled = disabled


func _on_SearArea_body_entered(body) -> void:
	if body.is_in_group("player"):
		body.take_damage()


func _on_Timer_timeout() -> void:
	change_state(ON if state == OFF else OFF)


func change_state(new_state) -> void:
	if new_state == state:
		return
	
	match new_state:
		ON:
			$AnimatedSprite.play("on")
			$SearArea/CollisionShape2D.disabled = false
			$Timer.start(burning_time)
		OFF:
			$AnimatedSprite.play("off")
			$SearArea/CollisionShape2D.disabled = true
			disable_trigger(false)
		
	state = new_state
