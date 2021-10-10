extends RigidBody2D

const MAX_NUM_BLINKS := 12

var _num_blinks := 0


func _on_Timer_timeout():
	$AnimatedSprite.visible = !$AnimatedSprite.visible
	_num_blinks += 1
	
	if _num_blinks == MAX_NUM_BLINKS:
		queue_free()
	else:
		$Timer.start(0.1)
