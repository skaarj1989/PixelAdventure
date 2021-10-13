extends StaticBody2D

enum {ON, OFF}

export(float) var ignition_delay := 0.25 # In seconds
export(float) var burning_time := 1.0 # In seconds

var state := OFF


onready var match_being_struck_sfx := preload("res://assets/SFX/MatchBeingStruck.wav")
onready var burning_sfx := preload("res://assets/SFX/Burning.wav")


func _on_AnimatedSprite_animation_finished() -> void:
	if $AnimatedSprite.animation == "hit":
		$Timer.start(ignition_delay)


func _on_Trigger_body_entered(body) -> void:
	if body.is_in_group("player"): 
		$AnimatedSprite.play("hit")
		$Trigger/CollisionShape2D.set_deferred("disabled", true)
		$Audio.stream = match_being_struck_sfx
		$Audio.play()


func _on_SearArea_body_entered(body) -> void:
	if body.is_in_group("player"):
		body.take_damage()


func _on_Timer_timeout() -> void:
	_change_state(ON if state == OFF else OFF)


func _change_state(new_state) -> void:
	if new_state == state:
		return
	
	match new_state:
		ON:
			$AnimatedSprite.play("on")
			$SearArea/CollisionShape2D.disabled = false
			$Audio.stream = burning_sfx
			$Audio.play()
			$Timer.start(burning_time)
		OFF:
			$AnimatedSprite.play("off")
			$Trigger/CollisionShape2D.disabled = false
			$SearArea/CollisionShape2D.disabled = true
			$Audio.stop()
		
	state = new_state
