extends KinematicBody2D

enum {IDLE, ATTACK, HIT}
const ROTATE_SPEED := 90.0 # Degrees/sec

export(GameState.FACING) var facing := GameState.FACING.RIGHT
export(float) var reload_speed := 0.25 # In seconds
export(NodePath) var area_of_sight # Area2D (mandatory)

var state
var velocity := Vector2.ZERO
var target


func _ready() -> void:
	_setup_sighting()
	$Sprite.flip_h = facing == GameState.FACING.RIGHT
	_change_state(IDLE)


func _process(_delta: float) -> void:
	if state == HIT:
		rotation_degrees += -facing * ROTATE_SPEED * _delta
		if GameState.is_outside(position):
			queue_free()


func _physics_process(_delta: float) -> void:
	velocity.y += GameState.GRAVITY * _delta
	velocity = move_and_slide(velocity, Vector2.UP)


func take_damage(_from: Vector2 = Vector2.ZERO) -> bool:
	velocity = Vector2(
		-facing,
		-5.0
	) * GameState.TILE_SIZE
	_change_state(HIT)
	GameState.camera.add_trauma(0.5)
	return true


func _setup_sighting() -> void:
	assert(area_of_sight)
	area_of_sight = get_node(area_of_sight) as Area2D
	area_of_sight.connect("body_entered", self, "_on_Area2D_body_entered")
	area_of_sight.connect("body_exited", self, "_on_Area2D_body_exited")


func _change_state(new_state) -> void:
	if state == new_state:
		return
	
	match new_state:
		IDLE:
			$AnimationPlayer.play("idle")
		ATTACK:
			$AnimationPlayer.play("attack")
		HIT:
			$AnimationPlayer.play("hit")
			$CollisionShape2D.disabled = true
			$Reload.stop()
		
	state = new_state


func _shot() -> void:
	var bullet = GameState.shot_bullet(
			"Plant",
			position + Vector2(facing * 20, 1),	
			Vector2(facing, 0) * GameState.TILE_SIZE * 6
	)
	get_parent().add_child(bullet)
	$Shot.play()


func _on_Area2D_body_entered(body) -> void:
	if body.is_in_group("player"):
		target = body
		_change_state(ATTACK)


func _on_Area2D_body_exited(body) -> void:
	if state != HIT and body.is_in_group("player"):
		target = null
		$Reload.stop()


func _on_Reload_timeout() -> void: 
	_change_state(ATTACK)


func _on_AnimationPlayer_animation_finished(anim_name) -> void:
	if anim_name == "attack":
		_change_state(IDLE)
		if target:
			$Reload.start(reload_speed)
