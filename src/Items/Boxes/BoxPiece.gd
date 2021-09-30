extends RigidBody2D

const MAX_NUM_BLINKS = 12

var variant: String
var num_blinks = 0

func _ready():
	assert(variant != "")
	$Sprite.texture = load("res://assets/Items/Boxes/%s/break.png" % variant)


func _on_Timer_timeout():
	$Sprite.visible = !$Sprite.visible
	num_blinks += 1
	
	if num_blinks == MAX_NUM_BLINKS:
		queue_free()
	else:
		$Timer.start(0.1)
