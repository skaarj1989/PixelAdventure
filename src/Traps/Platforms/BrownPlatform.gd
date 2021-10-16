extends KinematicBody2D

enum {ON, OFF}

export(float) var speed = 1.0 # Tiles/sec

var state := OFF

onready var start_point := position
onready var end_point = $Destination.global_position


func _physics_process(_delta: float) -> void:
	if state == OFF:
		_check_collisions()


func _check_collisions() -> void:
	var last_position = position
	var collision = move_and_collide(Vector2.ZERO)
	if collision:
		position = last_position
		var collider = collision.collider
		if collider.is_in_group("player") and collision.normal == Vector2.DOWN:
			_change_state(ON)


func _start_tween() -> void:
	var duration = (end_point - start_point).length() / float(GameState.TILE_SIZE * speed)
	$Tween.interpolate_property(
			self,
			"position",
			start_point,
			end_point,
			duration,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN,
			0.5)
	$Tween.start()


func _change_state(new_state) -> void:
	if state == new_state:
		return
	
	match new_state:
		ON:
			_start_tween()
		OFF:
			$AnimatedSprite.play("off")
	
	state = new_state


func _on_Tween_tween_started(_object, _key) -> void:
	$AnimatedSprite.play("on")


func _on_Tween_tween_completed(_object, _key) -> void:
	var tmp = end_point
	end_point = start_point
	start_point = tmp
	_change_state(OFF)
